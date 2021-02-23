import numpy as np
from itertools import islice
import os

lat = [-15,6]
inv = 0.025

for per in [5,7,9,13,17,21,25,29,33,37,41,45]:
    print(per)
    inputfile = 'grid2dv.' + str(per) + '.z'
    try:
        f = open(f'{workpath}/{inputfile}', 'r')
    except FileNotFoundError:
        print(f'velocity file for {per} second does not exist')
        continue

    # get the velocity
    velocity = np.loadtxt(f'{workpath}/{inputfile}',dtype=float)

    lonl = np.arange(lon[0],lon[1]+inv,inv)
    lonl = list(lonl)
    latl = np.arange(lat[0],lat[1]+inv,inv)
    latl = np.round(latl,decimals=3)
    latl = list(latl)
    lat_a = list(latl) * len(lonl)
    lon_a = [val for val in lonl for i in range(len(latl))]

    #print(velocity)
    outputfile = 'vgridc.' + str(per) + '.txt'
    np.savetxt(workpath+'/'+outputfile,np.column_stack((lat_a,lon_a,velocity)),fmt='%.6f')
