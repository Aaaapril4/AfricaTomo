# This code is to generate input files for stations and grids, and collect inversion input information for each station

# path
path = '/mnt/home/jieyaqi/'
staf = '/mnt/home/jieyaqi/Documents/station.txt' # file included all stations, format: net, sta, lon, lat
phasep = '/mnt/home/jieyaqi/code/FMST/Shell_for_FMM_obs' # path of phase velocity
zhp = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/zhcurve' # path of zh curve
wavep = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/waveformstack/station'
outp = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/file' # output path
invp = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion' # path to do inversion

# set up period used 
perlist = [5,7,9,13,17,21,25,29,33,37,41]

import numpy as np
import sys
import os
import obspy
from obspy.taup import TauPyModel
from tqdm import tqdm
import multiprocessing as mp
model = TauPyModel(model="ak135")

if len(sys.argv) != 4 and len(sys.argv) != 1:
    sys.exit(f'Usage: "python {sys.argv[0]} sta network station" or "python {sys.argv[0]} grid lat lon"')

latd = {}
lond = {}
veld = {}
for per in perlist:
    f = f'{phasep}/vgridc.{per}.txt'
    latl,lonl,vel = np.loadtxt(f,unpack=True)
    latd[per] = latl
    lond[per] = lonl
    veld[per] = vel

# find the nearest four grid for interpolate the phase velocity
# n1        n2
#      y1
#   x1    x2
#      y2
# n4        n3
# the grid file 1, 1.25, 1.5 ... 
def interp(lat, lon, per, ivlat = 0.5, ivlon = 0.5):
    # the format of file lat, lon, value
    file = f'{phasep}/vgridc.{per}.txt'
    latg, long, valuel = np.loadtxt(file, unpack=True)
    x1 = round((lon % ivlon), 2)
    y2 = round((lat % ivlat), 2)
    y1 = round(ivlat - y2, 2)
    x2 = round(ivlon - x1, 2)
    latup = round(lat+y1,2)
    latlo = round(lat-y2,2)
    lonle = round(lon-x1,2)
    lonrt = round(lon+x2,2)
    n1 = valuel[latg==latup][long[latg==latup]==lonle][0]
    n2 = valuel[latg==latup][long[latg==latup]==lonrt][0]
    n3 = valuel[latg==latlo][long[latg==latlo]==lonrt][0]
    n4 = valuel[latg==latlo][long[latg==latlo]==lonle][0]
    value = ((x2*(y1*n4+n1*y2)/ivlat + x1*(y1*n3+y2*n2)/ivlat)/ivlon + (y1*(x2*n4+x1*n3)/ivlon + y2*(x2*n1+x1*n2)/ivlon)/ivlat) / 2
    return round(value,4)


def get_raypara(sta,stack):
    rayp = []
    for sac in stack:
        tr = obspy.read(f'{wavep}/{sta}/{sac}.BHZ')
        arrival = model.get_ray_paths(source_depth_in_km=tr[0].stats.sac.evdp, distance_in_degree=tr[0].stats.sac.gcarc,phase_list=["P"])
        arr = arrival[0]
        rayp.append(arr.ray_param)
    return np.average(rayp)


# collect phase velocity for grid
def collect_phase_grid(lat,lon):
    phasein = []
    lat = round(float(lat),2)
    lon = round(float(lon),2)
    for per in perlist:
        
        # f = f'{phasep}/vgridc.{per}.txt'
        # latl,lonl,vel = np.loadtxt(f,unpack=True)
        # latl = latd[per]
        # lonl = lond[per]
        # vel = veld[per]
        # phasein.append([2,1,1,per,vel[latl==lat][lonl[latl==lat]==lon][0],1])
        vel = interp(lat,lon,per)
        phasein.append([2,1,1,per,vel,1])

    phasein.insert(0,[1,len(phasein),1])

    return phasein


# collect phase velocity for station (interpolation)
def collect_phase_sta(net,st):
    phasein = []
    nwl, stal, latl, lonl = np.loadtxt(staf,delimiter='|',unpack=True,usecols=(0,1,2,3),skiprows=0,dtype=str)
    lat = round(float(latl[nwl==net][stal[nwl==net]==st][0]),2)
    lon = round(float(lonl[nwl==net][stal[nwl==net]==st][0]),2)

    for per in perlist:
        vel = interp(lat,lon,per)
        phasein.append([2,1,1,per,vel,1])

    phasein.insert(0,[1,len(phasein),1])

    return phasein



# collect ZH ratio for station
# input format: nw.sta
def collect_zhsta(sta):
    zhin = []
    f = f'{zhp}/{sta}.DAT'
    try: 
        per,zh = np.loadtxt(f,usecols=(0,1),unpack=True)
    except OSError:
        return [[0,1]]
    
    if len(per) < 5:
        return [[0,1]]
    else:
        for i in range(len(per)):
            zhin.append([per[i],zh[i],1])
        zhin.insert(0,[len(zhin),1])
    return zhin


# collect waveform for station
# input format: nw.sta
def collect_wave(sta):
    wavein = []
    try:
        stack = np.loadtxt(f'{wavep}/{sta}/stacked.dat', dtype=str)
    except (ValueError, OSError):
        return [[0,1]]
    
    try:
        len(stack)
    except TypeError:
        stack = [f'{stack}']

    if len(stack) < 1:
        return [[0,1]]
    else:
        if not os.path.exists(f'{invp}/station/{sta}'):
            os.mkdir(f'{invp}/station/{sta}')
        os.system(f'cp {wavep}/{sta}/stack2.BHR.sac {invp}/station/{sta}/R.SAC')
        os.system(f'cp {wavep}/{sta}/stack2.BHZ.sac {invp}/station/{sta}/Z.SAC')
        ray_p = get_raypara(sta,stack)
        wavein.append([1,1])
        wavein.append(["Z.SAC","R.SAC",round(ray_p,2),1])
        return wavein


def pre_grid_all(grid):
    lat = round(float(grid.split('+')[0]),1)
    lon = round(float(grid.split('+')[1]),1)
    phasein = collect_phase_grid(lat, lon)
    wavein = [[0,1]]
    zhin = [[0,1]]
    outputf = f'{outp}/Africa_{lat}_{lon}.dat'
    with open(outputf,'a') as f:
        for e in phasein:
            f.write(list2str(e))

        f.write('\n')

        for e in wavein:
            f.write(list2str(e))

        f.write('\n')

        for e in zhin:
            f.write(list2str(e))
    return

# format list into str
def list2str(l):
    s = ''
    for ele in l:
        s = s + str(ele) + '\t'
    s = s + '\n'
    return s


if __name__=='__main__':

    if len(sys.argv) == 1:
        gridf = '/mnt/home/jieyaqi/Documents/invgrid.txt'
        gridl = np.loadtxt(gridf,dtype='str')
        with mp.Pool(48) as p:
            N = list(tqdm(p.imap(pre_grid_all, gridl), total=len(gridl)))

    else:
        if sys.argv[1].lower() == 'sta':
            phasein = collect_phase_sta(sys.argv[2], sys.argv[3])
            #wavein = [[0,1]]
            #zhin = [[0,1]]
            wavein = collect_wave(f'{sys.argv[2]}.{sys.argv[3]}')
            zhin = collect_zhsta(f'{sys.argv[2]}.{sys.argv[3]}')
            if len(phasein) > 1 and len(wavein) == 1 and len(zhin) == 1:
                print('phase')
            else:
                print('multi')
        elif sys.argv[1].lower() == 'grid':
            phasein = collect_phase_grid(sys.argv[2], sys.argv[3])
            wavein = [[0,1]]
            zhin = [[0,1]]
        outputf = f'{outp}/Africa.{sys.argv[2]}.{sys.argv[3]}.dat'
   
        if os.path.exists(outputf):
            os.remove(outputf)

        with open(outputf,'a') as f:
            for e in phasein:
                f.write(list2str(e))

            f.write('\n')

            for e in wavein:
                f.write(list2str(e))

            f.write('\n')

            for e in zhin:
                f.write(list2str(e))
