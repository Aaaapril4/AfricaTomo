# This code is for add header to event sac, do bandpass filtering and downsampling.
# add header:
#   stations: knetwk, kstnm, stla, stlo, stel
#   events: evla, evlo, evel, evdp, mag
# estimate: 19 items/s
import numpy as np
import os
import obspy
# from obspy.clients.iris import Client
from tqdm import tqdm
from distaz import DistAz
from math import pi
import multiprocessing as mp
import logging
logging.basicConfig(level = logging.INFO,format = '%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

path = "/mnt/ufs18/nodr/home/jieyaqi/earthquake/SAC"
# staxmlp = "/mnt/ufs18/nodr/home/jieyaqi/earthquake/event_data22/stations"
stafile = "/mnt/home/jieyaqi/Documents/station.txt"
evfile = "/mnt/home/jieyaqi/Documents/wavecat.xml"
catl = obspy.read_events(evfile)
radius = 6371 #km
ncpu = 40
logger.info('Catching event and station information')
# save catlog in one list
catdict = [[],[],[],[],[]]
for cat in catl:
    idn = str(cat.origins[0].resource_id)
    idn = idn.split('=')[-1]
    time = cat.origins[0].time
    time.microsecond = 0
    catdict[0].append(time)
    catdict[1].append(cat.origins[0].latitude)
    catdict[2].append(cat.origins[0].longitude)
    catdict[3].append(cat.origins[0].depth)
    catdict[4].append(cat.magnitudes[0].mag)
catdict[0] = np.array(catdict[0])
catdict[1] = np.array(catdict[1])
catdict[2] = np.array(catdict[2])
catdict[3] = np.array(catdict[3])
catdict[4] = np.array(catdict[4])

# read station info
nwl, stal, stlatl, stlonl, stell = np.loadtxt(stafile, unpack = True,\
    dtype = 'str', usecols = (0,1,2,3,4),skiprows=0,delimiter='|')
nwstl = np.array([nwl[i]+'.'+stal[i] for i in range(len(nwl))])

def add_stainfo(sac,trace):
    global nwstl,stlatl,stlonl,stell
    sta = sac.split('.')[0]+'.'+sac.split('.')[1]
    trace.stats.sac['kstnm'] = sac.split('.')[1]
    trace.stats.sac['knetwk'] = sac.split('.')[0]
    try:
        trace.stats.sac['stla'] = stlatl[nwstl==sta][0]
    except IndexError:
        return None
    else:
        trace.stats.sac['stlo'] = stlonl[nwstl==sta][0]
        trace.stats.sac['stel'] = stell[nwstl==sta][0]
    return trace

def add_evinfo(trace):
    global catdict
    # client = Client()
    eventtime = trace.stats.starttime + 5 * 60
    eventtime.microsecond = 0
    try:
        trace.stats.sac['evla'] = catdict[1][catdict[0]==eventtime][0]
    except IndexError:
        return None
    trace.stats.sac['evlo'] = catdict[2][catdict[0]==eventtime][0]
    trace.stats.sac['evdp'] = catdict[3][catdict[0]==eventtime][0]/1000
    trace.stats.sac['mag'] = catdict[4][catdict[0]==eventtime][0]
    trace.stats.sac['nzyear'] = eventtime.year
    trace.stats.sac['nzjday'] = eventtime.julday
    trace.stats.sac['hour'] = eventtime.hour
    trace.stats.sac['nzmin'] = eventtime.minute
    trace.stats.sac['nzsec'] = eventtime.second
    trace.stats.sac['nzmsec'] = eventtime.microsecond/1000
    trace.stats.sac['b'] = -300
    trace.stats.sac['e'] = trace.stats.sac['e'] - 300
    # distaz = client.distaz(stalat=float(trace.stats.sac['stla']),\
    #                         stalon=float(trace.stats.sac['stlo']),\
    #                         evtlat=float(trace.stats.sac['evla']),\
    #                         evtlon=float(trace.stats.sac['evlo']))
    distaz = DistAz(float(trace.stats.sac['stla']),\
                    float(trace.stats.sac['stlo']),\
                    float(trace.stats.sac['evla']),\
                    float(trace.stats.sac['evlo']))
    # trace.stats.sac['dist'] = distaz['distancemeters']/1000
    # trace.stats.sac['az'] = distaz['azimuth']
    # trace.stats.sac['baz'] = distaz['backazimuth']
    trace.stats.sac["gcarc"] = distaz.delta
    trace.stats.sac['dist'] = distaz.delta * 2 * pi * radius / 360
    trace.stats.sac['az'] = distaz.az
    trace.stats.sac['baz'] = distaz.baz
    return trace

def get_factor(n):
    tempn = n
    f = 2
    factor = []
    while tempn > 16:
        if tempn%f == 0 and f <= 16:
            factor.append(int(f))
            tempn /= f
            f = f+1
        else:
            f = f+1
    factor.append(int(tempn))
    return factor

def downsample(trace):
    freq = round(trace.stats.sampling_rate,0)

    if freq == 1:
        return trace

    elif freq > 16:
        factor = get_factor(freq/1)
        for f in factor:
            trace.decimate(f,strict_length=False)

    elif freq > 1 and freq <= 16:
        trace.decimate(freq,strict_length=False)
    return trace

def process(sac):
    global path
    if '.SAC' in sac:
        sacp = f'{path}/{sac}'
        try:
            tr = obspy.read(sacp, format='sac')
        except IndexError:
            logger.debug(f'No data read in, {sac} is removed.')
            os.remove(sacp)
            return
        else:

            for trace in tr:
                try:
                    switch = trace.stats.sac["kuser1"]
                except KeyError:
                    trace.stats.sac["kuser1"] = 'False'
                
                if trace.stats.sac["kuser1"]=='False':

                    # # remove instrumental response    
                                
                    # invfile = f'{staxmlp}/{sac.split(".")[0]}.{sac.split(".")[1]}.xml'
                    
                    # try:
                    #     inv = obspy.read_inventory(invfile)
                    #     tr.remove_response(inventory=inv)
                    # except:
                    #     logger.debug(f'Cannot remove instrumental response, {sac} removed')
                    #     os.remove(sacp)
                    #     return
                    
                    # add event info
                    trace = add_stainfo(sac, trace)
                    if trace == None:
                        logger.debug(f'Cannot find info for station, {sac} removed')
                        os.remove(sacp)
                        return

                    # add event data and align trace
                    trace = add_evinfo(trace)
                    if trace == None:
                        logger.debug(f'Cannot find info for event, {sac} removed')
                        os.remove(sacp)
                        return

                    # filter and downsample
                    trace.filter('bandpass',freqmin=0.02,freqmax=0.5)
                    trace = downsample(trace)

                    trace.stats.sac["kuser1"] = True

                    # tr.write(sacp,format='sac')
                else:
                    logger.debug(f'{sac} is filtered')
    return

if __name__ == "__main__":
    logger.info('Begin Filtering')
    with mp.Pool(ncpu) as p:
        N = list(tqdm(p.imap(process, os.listdir(path)),total=len(os.listdir(path))))
    logger.info('Finish Filtering')