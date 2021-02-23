# This code is to calculate profile from thickness, and interpolate to 1 km.

import sys
import os
import numpy as np

if len(sys.argv) != 3:
    sys.exit(f'Usage: python path denserdepth')

path = sys.argv[1]
dense = sys.argv[2].split(',')
denser = [float(x) for x in dense]
depadd = np.arange(1,201,1) #interp depth
depadd = np.append(depadd,denser)
depadd = np.sort(depadd)


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
    return depth, vel


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