import sys
import numpy as np
from distaz import DistAz

if len(sys.argv) != 3:
    sys.exit(f"usage python {sys.argv[0]} ell/hyp I3")

staf = "/mnt/ufs18/nodr/home/jieyaqi/three_200922/all.txt"

if __name__=="__main__":
    sta, lon, lat = np.loadtxt(staf,dtype=str,usecols=(1,2,3),unpack=True)
    corr = sys.argv[2][0:-4]
    src = corr.split("_")[0]
    rec1 = corr.split("_")[2]
    rec2 = corr.split("_")[3]
    
    srclon = float(lon[sta==src])
    srclat = float(lat[sta==src])
    rec1lat = float(lat[sta==rec1])
    rec1lon = float(lon[sta==rec1])
    rec2lat = float(lat[sta==rec2])
    rec2lon = float(lon[sta==rec2])
    dij = DistAz(srclat,srclon,rec1lat,rec1lon).delta * 111.19
    dik = DistAz(srclat,srclon,rec2lat,rec2lon).delta * 111.19
    djk = DistAz(rec1lat,rec1lon,rec2lat,rec2lon).delta * 111.19
    if sys.argv[1] == "ell":
        dist = np.abs(dij + dik - djk)
    if sys.argv[1] == "hyp":
        dist = np.abs(dij - dik) - djk
    print(dist)