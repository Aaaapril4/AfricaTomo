import numpy as np
from itertools import islice
import os
import sys

cbp=r'../output_cb'
perl=[5,7,9,13,17,21,25,29,33,37,41,45]
lon=[25,42,0.25]
lat=[-15,6,0.25]


# reorder data
for per in perl:
    # inputfile = f'grid2dv.{per}.z'
    # velocity = np.loadtxt(f'{tomop}/{inputfile}')

    # latl = list(np.arange(lat[0],lat[1]+lat[2],lat[2]))
    # lonl = list(np.arange(lon[0],lon[1]+lon[2],lon[2]))
    # lat_a = [val for val in latl for i in range(len(lonl))]
    # lon_a = lonl * len(lat)

    # #print(velocity)
    # outputfile = f'tomog.{per}.txt'
    # np.savetxt(tomop+'/'+outputfile,np.column_stack((lon_a,lat_a,velocity)),fmt='%.4f')


    # read the initial checkboard
    inputf_cb = f'gridc.{per}.vtx'
    inputf_ini = f'gridi_cb.{per}.vtx'

    if inputf_ini not in os.listdir(cbp) or inputf_cb not in os.listdir(cbp):
        continue

    f = open(cbp+'/'+inputf_ini,'r')
    print(inputf_ini)

    info = []
    for i in range(3):
        a = f.readline().strip('\n').split(' ')
        while '' in a:
            a.remove('')
        info.append([float(a[0]),float(a[-1])])

    v_ini = []
    for line in f.readlines():

        a = line.strip('\n').split(' ')
        while '' in a:
            a.remove('')
        if len(a):
            v_ini.append(float(a[0]))


    # read the checkboard
    f = open(cbp+'/'+inputf_cb,'r')
    print(inputf_cb)

    info = []
    for i in range(3):
        a = f.readline().strip('\n').split(' ')
        while '' in a:
            a.remove('')
        info.append([float(a[0]),float(a[-1])])

    v_cb = []
    for line in f.readlines():

        a = line.strip('\n').split(' ')
        while '' in a:
            a.remove('')
        if len(a):
            v_cb.append(float(a[0]))
    
    
    # calculate the absolute difference
    v_cb = np.array(v_cb)
    v_ini = np.array(v_ini)
    dif = np.abs(v_ini - v_cb)

    # reorder the difference
    lat = np.arange(info[1][0]-info[2][0]*info[0][0],info[1][0]+info[2][0]*2,info[2][0])[::-1]
    lon = np.arange(info[1][1]-info[2][1],info[1][1]+info[2][1]*(info[0][1]+1),info[2][1])
    lon_a = [val for val in lon for i in range(int(info[0][0])+2)]
    lat_a = list(lat) * int(info[0][1]+2)

    outputfile = f'mask.{per}.txt'
    np.savetxt(f'{cbp}/{outputfile}',np.column_stack((lon_a,lat_a,dif)),fmt='%.4f')
