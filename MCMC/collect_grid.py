stap = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/station'
staf = '/mnt/home/jieyaqi/Documents/station.txt' # file included all stations, format: net, sta, lon, lat
gridf = '/mnt/home/jieyaqi/Documents/invgrid.txt'
outp = '/mnt/home/jieyaqi/Documents'

import numpy as np
import os


def collect_sta(sta):
    with open(f'{stap}/{sta}/Africa.{sta}.dat','r') as f:
        phinfo = f.readline()
        for i in range(int(phinfo.split('\t')[1])+1):
            f.readline()
        wfinfo = f.readline()
        for i in range(int(wfinfo.split('\t')[0])+1):
            f.readline()
        zhinfo = f.readline()
    return int(phinfo.split('\t')[1]), int(wfinfo.split('\t')[0]), int(zhinfo.split('\t')[0])


def get_latlon(sta):
    net = sta.split('.')[0]
    st = sta.split('.')[1]
    nwl, stal, latl, lonl = np.loadtxt(staf,delimiter='|',unpack=True,usecols=(0,1,2,3),skiprows=0,dtype=str)
    lat = round(float(latl[nwl==net][stal[nwl==net]==st][0]),2)
    lon = round(float(lonl[nwl==net][stal[nwl==net]==st][0]),2)
    return lat,lon


if __name__ == '__main__':
    stal = []
    latl = []
    lonl = []
    typ = []

    for sta in os.listdir(stap):
        if not os.path.exists(f'{stap}/{sta}/MAX_PROBVM.dat'):
            continue
        lat, lon = get_latlon(sta)
        latl.append(str(lat))
        lonl.append(str(lon))
        stal.append(sta)
        phinfo, wfinfo, zhinfo = collect_sta(sta)
        if phinfo >= 1 and wfinfo >= 1 and zhinfo >= 1:
            typ.append('phzhwf')
        elif phinfo >= 1 and wfinfo >= 1 and zhinfo == 0:
            typ.append('phwf')
        elif phinfo >= 1 and zhinfo >= 1 and wfinfo == 0:
            typ.append('phzh')
        elif phinfo >= 1 and zhinfo == 0 and wfinfo == 0:
            typ.append('ph')
    
    for grid in np.loadtxt(gridf,dtype='str'):
        latl.append(str(grid.split('+')[0]))
        lonl.append(str(grid.split('+')[1]))
        typ.append('grid')
        stal.append('grid')
    np.savetxt(f'{outp}/invinfo.txt',np.column_stack((lonl,latl,typ,stal)),fmt='%s', delimiter='\t')
