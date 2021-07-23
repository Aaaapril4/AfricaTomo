import numpy as np
import os

from numpy.lib.shape_base import column_stack

stapath = "/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/station"
gridpath = "/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/grid"
stationf = "/mnt/home/jieyaqi/Documents/mystationwll.lst"

def read_dep_vs(vsfile):
    dep, vs = np.loadtxt(vsfile, dtype=float, unpack=True)

    return dep, vs



def cal_gradient(dep, vs):
    vgrad = []
    for i in range(1, len(vs)-1):
        gradient = ((vs[i+1] - vs[i])/(dep[i+1] - dep[i]) + (vs[i] - vs[i-1])/(dep[i] - dep[i-1]))/2
        vgrad.append(gradient)
    
    return np.array(vgrad)



def find_max(vsfile):
    dep, vs = read_dep_vs(vsfile)
    vgrad = cal_gradient(dep, vs)
    dep = dep[1:-1]
    
    max = 0
    maxdepth = 0
    for i in range(len(vgrad)):
        if dep[i]>50 and vgrad[i]>max:
            max = vgrad[i]
            maxdepth = dep[i]

    return maxdepth



def get_sta_cor(sta):
    stal, lonl, latl = np.loadtxt(stationf, dtype=str, unpack=True)
    return lonl[stal==sta][0], latl[stal==sta][0]



if __name__ == "__main__":
    latl, lonl, depl = [], [], []
    for grid in os.listdir(gridpath):
        try:
            dep = find_max(f'{gridpath}/{grid}/intp.dat')
        except OSError:
            continue
        [lat,lon] = grid.split('_')[1:]
        latl.append(lat)
        lonl.append(lon)
        depl.append(dep)
    
    for sta in os.listdir(stapath):
        try:
            dep = find_max(f'{stapath}/{sta}/intp.dat')
        except OSError:
            continue
        lon, lat = get_sta_cor(sta)
        latl.append(lat)
        lonl.append(lon)
        depl.append(dep)

    np.savetxt("lithosphere.dat", np.column_stack((lonl,latl,depl)),fmt="%s", delimiter='\t')
