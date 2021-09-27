import os
import numpy as np
import multiprocessing as mp
from tqdm import tqdm

def cal_devia(fvel, vellist):
    sum = 0
    fvel = round(fvel, 4)
    for vel in vellist:
        sum = sum + (fvel-vel)**2
    
    return np.sqrt(sum/len(vellist))



def get_latlon(sta):
    staf = '/mnt/home/jieyaqi/Documents/station.txt' # file included all stations, format: net, sta, lon, lat
    net = sta.split('.')[0]
    st = sta.split('.')[1]
    nwl, stal, latl, lonl = np.loadtxt(staf,delimiter='|',unpack=True,usecols=(0,1,2,3),skiprows=0,dtype=str)
    lat = float(latl[nwl==net][stal[nwl==net]==st][0])
    lon = float(lonl[nwl==net][stal[nwl==net]==st][0])
    return lat,lon



def read_final_model(file):
    depth = np.loadtxt(file, unpack=True, usecols=(0))
    moho = depth[28]
    sedi = depth[8]

    
    return moho, sedi



def main(dir, type):

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

    mohol = np.loadtxt(dir+'/moho.lst')
    sedil = np.loadtxt(dir+'/Sediment.info', unpack=True, usecols=0)

    moho, sedi = read_final_model(dir+'/MAX_PROBVM.dat')
    sedidev = cal_devia(sedi, sedil)
    mohodev = cal_devia(moho, mohol)

    with open(dir+"/uncertaintyms.dat", 'w') as f:
        f.write("\t".join([str(lon), str(lat), str(round(sedidev, 4))])+"\n")
        f.write("\t".join([str(lon), str(lat), str(round(mohodev, 4))])+"\n")
    
    return


if __name__ == "__main__":
    dirpath = "/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion6015"
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