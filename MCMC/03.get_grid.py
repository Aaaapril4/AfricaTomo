# init
stafile = '/mnt/home/jieyaqi/Documents/station.txt'
mystafile = '/mnt/home/jieyaqi/Documents/mysta.lst'
outp = '/mnt/home/jieyaqi/Documents'
latrange = [-15,3]
lonrange = [25,40]


import numpy as np
import os
latl = np.arange(latrange[0],latrange[1]+1,0.4)
lonl = np.arange(lonrange[0],lonrange[1]+1,0.4)


def _statogrid(lat,lon,ivlat=0.4,ivlon=0.4):
    mlat = (lat-latrange[0]) % ivlat
    mlon = (lon-lonrange[0]) % ivlon
    if mlat <= ivlat/2:
        latgi = lat - mlat
    else:
        latgi = lat + ivlat - mlat
    if mlon <= ivlon/2:
        longi = lon -  mlon
    else:
        longi = lon - mlon + ivlat
    return round(latgi,1),round(longi,1)


def statogrid():
    nwl, stal, latl, lonl = np.loadtxt(stafile,delimiter='|',unpack=True,usecols=(0,1,2,3),skiprows=0,dtype=str)
    grid = []
    stalist = np.loadtxt(mystafile, dtype=str)
    for sta in stalist:
        net = sta.split('.')[0]
        st = sta.split('.')[1]
        try:
            lat = float(latl[nwl==net][stal[nwl==net]==st][0])
            lon = float(lonl[nwl==net][stal[nwl==net]==st][0])
        except:
            continue
        latgi,longi = _statogrid(float(lat),float(lon))
        grid.append(f'{round(latgi,1)}+{round(longi,1)}')
    return grid


if __name__ == '__main__':
    stagrid = statogrid()
    grid = []
    for lat in latl:
        for lon in lonl:
            grid.append(f'{round(lat,1)}+{round(lon,1)}')
    stagrid = list(set(stagrid))
    for ele in stagrid:
        try:
            grid.remove(ele)
        except:
            continue
    np.savetxt(f'{outp}/invgrid.txt',grid,fmt='%s')
