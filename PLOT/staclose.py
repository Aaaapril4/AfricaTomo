import sys
import numpy as np
from math import radians, cos, sin, asin, sqrt
station=sys.argv[1]
line_fn=sys.argv[2]
cut_off=float(sys.argv[3])

def haversine(lon1, lat1, lon2, lat2):
    """
    Calculate the great circle distance between two points on the earth (specified in decimal degrees)
    """
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    # haversine公式
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    r = 6371
    return c * r


with open(station, 'r') as f:
  lines = [ l.split() for l in f.readlines() if not(l.startswith('#')) ]

# stna=np.array([str(x[0])for x in lines])
stlo=np.array([float(x[1]) for x in lines])
stla=np.array([float(x[0]) for x in lines])
Nst=len(stlo)

#for i in range(len(stlo)):
#   print(stna[i],stlo[i],stla[i])

with open(line_fn, 'r') as f:
  lines = [ l.split() for l in f.readlines() if not(l.startswith('#')) ]

lplo=np.array([float(x[0])for x in lines])
lpla=np.array([float(x[1])for x in lines])
Nlp=len(lplo)

flagD = [1000.0 for x in range(Nst)]
ProjX=[0.0 for x in range(Nst)]
ProjY=[0.0 for x in range(Nst)]
for i in range(Nst):
   for n in range(Nlp):
      dist=haversine(stlo[i],stla[i],lplo[n],lpla[n])
      if dist < flagD[i]:
         flagD[i]=dist 
         ProjX[i]=lplo[n]
         ProjY[i]=lpla[n]

for i in range(Nst):
   if flagD[i] < cut_off:
      print("%10.3f %10.3f %10.3f %10.3f %10.3f" %(stlo[i],stla[i],ProjX[i],ProjY[i],flagD[i]))
