# This code is to calculate profile from thickness, and interpolate to 1 km.

import sys
import numpy as np

if len(sys.argv) != 5:
    sys.exit(f'Usage: python path denserdepth lat lon')

path = sys.argv[1]
dense = sys.argv[2].split(',')
lat = float(sys.argv[3])
lon = float(sys.argv[4])
denser = [float(x) for x in dense]
depadd = np.arange(1,201,1) #interp depth
depadd = np.append(depadd,denser)
depadd = np.sort(depadd)


def _intp_topo(lat, lon, latl, lonl, valuel):
    # n1        n2
    #      y1
    #   x1    x2
    #      y2
    # n4        n3
    x1 = round(lon % 0.05, 2)
    y2 = round(lat % 0.05, 2)
    x2 = round(0.05 - x1, 2)
    y1 = round(0.05 - y2, 2)
    latup = round(lat + y1, 2)
    latlo = round(lat - y2, 2)
    lonle = round(lon - x1, 2)
    lonrt = round(lon + x2, 2)
    n1 = valuel[latl==latup][lonl[latl==latup]==lonle][0]
    n2 = valuel[latl==latup][lonl[latl==latup]==lonrt][0]
    n3 = valuel[latl==latlo][lonl[latl==latlo]==lonrt][0]
    n4 = valuel[latl==latlo][lonl[latl==latlo]==lonle][0]
    value = (x2*(y1*n4+n1*y2) + x1*(y1*n3+y2*n2) + y1*(x2*n4+x1*n3) + y2*(x2*n1+x1*n2)) / (2 * 0.05 * 0.05)
    return round(value,4)



def get_topo(lat, lon):
    topofile = "/mnt/home/jieyaqi/code/JOINT_PACKAGE/Scripts_JI/PLOT/topo.dat"

    lonl, latl, topol = np.loadtxt(topofile, unpack=True, usecols=(0,1,2), dtype=float)

    try:
        topo = topol[latl==lat][lonl[latl==lat]==lon][0]
    except:
        topo = _intp_topo(lat, lon, latl, lonl, topol)

    return topo



def get_profile():
    depth, vel = np.loadtxt(f'{path}/MAX_PROBVM.dat', unpack=True, usecols=(0,3))
    # depth = []
    # vel = []
    # dep = 0
    # for i in range(len(th)):
    #     depth.append(round(dep,3))
    #     dep = dep + th[i]
    #     vel.append(vs[i])
    #     # depth.append(round(dep,3))
    #     if i+1 < len(th):
    #         if th[i] != th[i+1]:
    #             depth.append(round(dep,3))
    #             vel.append(vs[i+1])
    topo = get_topo(lat, lon)
    print(topo/1000)

    return depth - topo/1000, vel


def intp(depth, vel):
    global depadd
    depadd = np.append(depadd, depth)
    depadd = np.sort(depadd)
    veladd = np.interp(depadd, depth, vel)
    return depadd, veladd


if __name__ == '__main__':
    depth, vel = get_profile()
    np.savetxt(f'{path}/profile.dat', np.column_stack((depth,vel)),fmt='%f',delimiter='\t')
    depthint, velint = intp(depth, vel)
    np.savetxt(f'{path}/intp.dat', np.column_stack((depthint,velint)),fmt='%f',delimiter='\t')
