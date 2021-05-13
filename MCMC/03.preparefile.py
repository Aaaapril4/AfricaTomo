# This code is to generate input files for stations and grids, and collect inversion input information for each station

# path
projd = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion'
staf = '/mnt/home/jieyaqi/Documents/station.txt' # file included all stations, format: net, sta, lon, lat
phased_short = '/mnt/home/jieyaqi/code/FMST/Shell_for_FMM/output_tomo' # path of phase velocity
phased_long = '/mnt/home/jieyaqi/Documents/FinalModels/PhaseVelocities' # path of phase velocity
zhd = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/zhcurve' # path of zh curve
waved = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/waveform'
outd = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/file' # output path
invd = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion' # path to do inversion

ncpu = 48
# set up period used 
perlist_short = [5,7,9,13,17,21,25,29,33,37,41,45]
#perlist_short = [5, 9, 17, 25, 33, 41]
#perlist_long = [50, 67, 80, 100, 125, 143, 167, 182]
perlist_long = []
perlist_long = [67, 80, 100, 125, 143]
filename_long = {20:'bp01', 22:'bp02', 25:'bp03', 29:'bp04', 33:'bp05', 40:'bp06', 50:'bp07', 67:'bp08', 80:'bp09', 100:'bp10', 125:'bp11', 143:'bp12', 167:'bp13', 182:'bp14'}
import numpy as np
import sys
import os
import obspy
from obspy.taup import TauPyModel
from tqdm import tqdm
import multiprocessing as mp
model = TauPyModel(model="ak135")



def collect_grid_latlonpv():
    '''
    Create three dictionaries of latitude, longitude, phase velocity
    Input:
        None
    Return:
        latd, lond, pvd
    '''
    latd = {}
    lond = {}
    pvd = {}
    for per in perlist_short:
        f = f'{phased_short}/vgridc.{per}.txt'
        latl,lonl,vel = np.loadtxt(f,unpack=True)
        latd[per] = np.round(latl,2)
        lond[per] = np.round(lonl,2)
        pvd[per] = vel

    for per in perlist_long:
        f = f'{phased_long}/{filename_long[per]}/2D_result_{filename_long[per]}_interpolated.xyz'
        lonl,latl,vel = np.loadtxt(f,unpack=True)
        latd[per] = np.round(latl,2)
        lond[per] = np.round(lonl,2)
        pvd[per] = vel
    return latd, lond, pvd



def interp(latg, long, valueg, lat, lon, ivlat = 0.05, ivlon = 0.05):

    '''
    Find the nearest four grid for interpolate the phase velocity
        n1        n2
             y1
          x1    x2
             y2
        n4        n3
    '''
    x1 = round((lon % ivlon), 2)
    y2 = round((lat % ivlat), 2)
    y1 = round(ivlat - y2, 2)
    x2 = round(ivlon - x1, 2)
    latup = round(lat+y1,2)
    latlo = round(lat-y2,2)
    lonle = round(lon-x1,2)
    lonrt = round(lon+x2,2)

    try:
        n1 = valueg[latg==latup][long[latg==latup]==lonle][0]
        n2 = valueg[latg==latup][long[latg==latup]==lonrt][0]
        n3 = valueg[latg==latlo][long[latg==latlo]==lonrt][0]
        n4 = valueg[latg==latlo][long[latg==latlo]==lonle][0]
    except IndexError:
        return None
    value = ((x2*(y1*n4+n1*y2)/ivlat + x1*(y1*n3+y2*n2)/ivlat)/ivlon + (y1*(x2*n4+x1*n3)/ivlon + y2*(x2*n1+x1*n2)/ivlon)/ivlat) / 2

    return round(value,4)



def get_raypara(sta,stack):

    rayp = []
    for sac in stack:
        tr = obspy.read(f'{waved}/{sta}/{sac}.BHZ')
        arrival = model.get_ray_paths(source_depth_in_km=tr[0].stats.sac.evdp, distance_in_degree=tr[0].stats.sac.gcarc,phase_list=["P"])
        arr = arrival[0]
        rayp.append(arr.ray_param)

    return np.average(rayp)



def collect_phase_grid(lat,lon):

    phasein = []
    lat = round(float(lat),2)
    lon = round(float(lon),2)
    for per in perlist_short+perlist_long:
        
        latl = latd[per]
        lonl = lond[per]
        vel = pvd[per]
        try:
            phasein.append([2,1,1,per,vel[latl==lat][lonl[latl==lat]==lon][0],1])
        except IndexError:
            continue

    phasein.insert(0,[1,len(phasein),1])

    return phasein



def collect_phase_sta(net,st):

    phasein = []
    nwl, stal, latl, lonl = np.loadtxt(staf,delimiter='|',unpack=True,usecols=(0,1,2,3),skiprows=0,dtype=str)
    lat = round(float(latl[nwl==net][stal[nwl==net]==st][0]),2)
    lon = round(float(lonl[nwl==net][stal[nwl==net]==st][0]),2)
    
    for per in perlist_short:
        latl = latd[per]
        lonl = lond[per]
        valuel = pvd[per]
        vel = interp(latl, lonl, valuel, lat, lon)
        phasein.append([2,1,1,per,vel,1])

    for i in range(len(perlist_long)):
        latl = latd[perlist_long[i]]
        lonl = lond[perlist_long[i]]
        valuel = pvd[perlist_long[i]]
        vel = interp(latl, lonl, valuel, lat, lon, ivlat = 0.1, ivlon = 0.1)
        if vel != None:
            phasein.append([2,1,1,perlist_long[i],vel,1])

    phasein.insert(0,[1,len(phasein),1])

    return phasein



def collect_zhsta(sta):

    '''
    Collect ZH ratio for station
    Input: 
        nw.sta
    '''
    zhin = []
    f = f'{zhd}/{sta}.DAT'
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



def collect_wave(sta):

    '''
    Collect waveform for station
    Input: 
        nw.sta
    '''
    wavein = []
    try:
        stack = np.loadtxt(f'{waved}/{sta}/stacked.dat', dtype=str)
    except (ValueError, OSError):
        return [[0,1]]
    
    try:
        len(stack)
    except TypeError:
        stack = [f'{stack}']

    if len(stack) < 1:
        return [[0,1]]
    else:
        if not os.path.exists(f'{invd}/station/{sta}'):
            os.mkdir(f'{invd}/station/{sta}')
        os.system(f'cp {waved}/{sta}/stack2.BHR.sac {invd}/station/{sta}/R.SAC')
        os.system(f'cp {waved}/{sta}/stack2.BHZ.sac {invd}/station/{sta}/Z.SAC')
        ray_p = get_raypara(sta,stack)
        wavein.append([1,1])
        wavein.append(["Z.SAC","R.SAC",round(ray_p,2),1])
        return wavein



def save_file(outputf, phasein, wavein, zhin):

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

    return


def pre_grid_all(grid):

    lat = round(float(grid.split('+')[0]),1)
    lon = round(float(grid.split('+')[1]),1)
    phasein = collect_phase_grid(lat, lon)
    wavein = [[0,1]]
    zhin = [[0,1]]
    outputf = f'{outd}/Africa_{lat}_{lon}.dat'
    save_file(outputf, phasein, wavein, zhin)

    return



def pre_sta_all(sta):

    net = sta.split('.')[0]
    st = sta.split('.')[1]
    phasein = collect_phase_sta(net, st)
    wavein = collect_wave(sta)
    zhin = collect_zhsta(sta)
    outputf = f'{outd}/Africa.{sta}.dat'
    save_file(outputf, phasein, wavein, zhin)

    return



def list2str(l):

    s = ''
    for ele in l:
        s = s + str(ele) + '\t'
    s = s + '\n'

    return s



if __name__=='__main__':

    if len(sys.argv) != 4 and len(sys.argv) != 2:
        sys.exit(f'Usage: "python {sys.argv[0]} sta network station" or "python {sys.argv[0]} grid lat lon"')

    latd, lond, pvd = collect_grid_latlonpv()

    if len(sys.argv) == 2:

        if sys.argv[1] == 'grid':
            gridlf = '/mnt/home/jieyaqi/Documents/invgrid.txt'
            gridl = np.loadtxt(gridlf,dtype='str')
            with mp.Pool(ncpu) as p:
                N = list(tqdm(p.imap(pre_grid_all, gridl), total=len(gridl)))

        elif sys.argv[1] == 'sta':
            stalf = '/mnt/home/jieyaqi/Documents/station.lst'
            stal = np.loadtxt(stalf, dtype='str')
            with mp.Pool(ncpu) as p:
                N = list(tqdm(p.imap(pre_sta_all, stal), total=len(stal)))


    else:

        if sys.argv[1].lower() == 'sta':
            phasein = collect_phase_sta(sys.argv[2], sys.argv[3])
            #wavein = [[0,1]]
            #zhin = [[0,1]]
            wavein = collect_wave(f'{sys.argv[2]}.{sys.argv[3]}')
            zhin = collect_zhsta(f'{sys.argv[2]}.{sys.argv[3]}')

        elif sys.argv[1].lower() == 'grid':
            phasein = collect_phase_grid(sys.argv[2], sys.argv[3])
            wavein = [[0,1]]
            zhin = [[0,1]]
        outputf = f'{outd}/Africa.{sys.argv[2]}.{sys.argv[3]}.dat'

        save_file(outputf, phasein, wavein, zhin)
