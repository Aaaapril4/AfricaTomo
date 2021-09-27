import numpy as np
import os
import multiprocessing as mp
from tqdm import tqdm

def remove_null(lst):
    while "" in lst:
        lst.remove("")
    return lst


def intp(depth, vel, mapdep):
    vel = np.interp(mapdep, depth, vel)

    return list(mapdep), list(vel)



def organize(lines, mapdep, topo):
    '''
    organize 
    '''
    modeldic = {}
    for j in range(len(mapdep)):
        modeldic[j] = []
    dep = []
    vel = []
    modelnum = 0
    i = 0
    while i < len(lines):
        if ">" not in lines[i]:
            line = lines[i].split("     ")
            line = remove_null(line)
            dep.append(float(line[0]) - topo)
            vel.append(float(line[3]))
        elif ">" in lines[i] and i !=0:
            modelnum = modelnum + 1
            dep, vel = intp(dep, vel, mapdep)
            for j in range(len(dep)):
                modeldic[j].append(round(vel[j],4))
            dep = []
            vel = []

        i = i+1

    dep, vel = intp(dep, vel, mapdep)
    for j in range(len(dep)):
        modeldic[j].append(round(vel[j],4))
    
    return modeldic



def org_profiles(file, mapdep, topo):

    with open(file) as f:
        lines = f.readlines()
    modeldic = organize(lines, mapdep, topo)
    return modeldic



def read_final_model(file, mapdep, topo):
    depth, vel = np.loadtxt(file, unpack=True, usecols=(0,3))
    depth = depth - topo
    dep, vel = intp(depth, vel, mapdep)
    
    return vel



def cal_devia(fvel, vellist):
    sum = 0
    fvel = round(fvel, 4)
    for vel in vellist:
        sum = sum + (fvel-vel)**2
    
    return np.sqrt(sum/len(vellist))



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
    try:
        n1 = valuel[latl==latup][lonl[latl==latup]==lonle][0]
    except:
        print(lat, lon)
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



def get_latlon(sta):
    staf = '/mnt/home/jieyaqi/Documents/station.txt' # file included all stations, format: net, sta, lon, lat
    net = sta.split('.')[0]
    st = sta.split('.')[1]
    nwl, stal, latl, lonl = np.loadtxt(staf,delimiter='|',unpack=True,usecols=(0,1,2,3),skiprows=0,dtype=str)
    lat = float(latl[nwl==net][stal[nwl==net]==st][0])
    lon = float(lonl[nwl==net][stal[nwl==net]==st][0])
    return lat,lon


def main(dir, type):
    uncertainty = []

    mapdep = [0.4, 10, 25, 40, 60, 100, 150, 190]
    if not os.path.exists(dir+'/MAX_PROBVM.dat'):
        return

    if type == "grid":
        grid = dir.split("/")[-1]
        lat = float(grid.split("_")[1])
        lon = float(grid.split("_")[2])
    
    elif type == "sta":
        sta = dir.split("/")[-1]
        lat, lon = get_latlon(sta)
        
    if lat > 4 or lat < -15 or lon < 25 or lon > 40:
        return

    topo = get_topo(lat, lon)

    modeldic = org_profiles(dir+'/MODELS.dat', mapdep, topo/1000)
    
    final = read_final_model(dir+'/MAX_PROBVM.dat', mapdep, topo/1000)

    for key in modeldic.keys():
        dev = cal_devia(final[key], modeldic[key])
        uncertainty.append(round(dev,4))
    
    with open(dir+"/uncertainty.dat", 'w') as f:
        for i in range(len(mapdep)):
            f.write("\t".join([str(lon), str(lat), str(mapdep[i]), str(uncertainty[i])])+"\n")
    
    return


        
if __name__ == "__main__":
    dirpath = "/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion"
    sta = os.listdir(dirpath+"/station")
    grid = os.listdir(dirpath+"/grid")
    stadir = []
    griddir = []
    for s in sta:
        stadir.append(("/".join([dirpath, "station", s]), "sta"))

    for g in grid:
        griddir.append(("/".join([dirpath, "grid", g]), "grid"))

    print("sta")
    with mp.Pool(48) as p:
        # p.starmap(main, stadir)
        p.starmap(main, stadir)
    print("grid")

    with mp.Pool(48) as p:
        p.starmap(main, griddir)

    # dir = dirpath+"/station/YA.KV08"
    # main(dir, "sta")