import sys
import numpy as np
from math import radians, cos, sin, asin, sqrt


def haversine(lon1, lat1, lon2, lat2):
   '''
   Calculate the great circle distance between two points on the earth (specified in decimal degrees)
   '''
   lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
   # haversine公式
   dlon = lon2 - lon1
   dlat = lat2 - lat1
   a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
   c = 2 * asin(sqrt(a))
   r = 6371
   return c * r



def get_proj(stlo, stla, lplo, lpla):
   Nst = len(stlo)
   Nlp = len(lplo)
   flagD = np.ones(Nst) * 1000
   ProjX = np.zeros(Nst)
   ProjY = np.zeros(Nst)
   for i in range(Nst):
      for n in range(Nlp):
         dist=haversine(stlo[i],stla[i],lplo[n],lpla[n])
         if dist < flagD[i]:
            flagD[i]=dist 
            ProjX[i]=lplo[n]
            ProjY[i]=lpla[n]
   return ProjX, ProjY, flagD


if __name__ == '__main__':
   if len(sys.argv) != 5:
      sys.exit()
   
   if sys.argv[1] == 'sta':
      station=sys.argv[2]
      line_fn=sys.argv[3]
      cut_off=float(sys.argv[4])
      stlo, stla = np.loadtxt(station, comments="#", unpack=True, usecols=(0,1))
      lplo, lpla = np.loadtxt(line_fn, comments="#", unpack=True, usecols=(0,1))
      ProjX, ProjY, flagD = get_proj(stlo, stla, lplo, lpla)

      for i in range(len(stlo)):
         if flagD[i] < cut_off:
            print("%10.3f %10.3f %10.3f %10.3f %10.3f" %(stlo[i],stla[i],ProjX[i],ProjY[i],flagD[i]))

   elif sys.argv[1] == 'seis':
      seis=sys.argv[2]
      line_fn=sys.argv[3]
      cut_off=float(sys.argv[4])
      
      with open(seis, 'r') as f:
         lines = [ line.strip().split('\t') for line in f.readlines()]

      stlo = []
      stla = []
      dep = []
      mag = []
      for line in lines:
         stlo.append(float(line[0]))
         stla.append(float(line[1]))
         dep.append(float(line[2]))
         if len(line) == 3 or line[3] == '\n':
            mag.append(1)
         else:
            mag.append(float(line[3]))
      
      lplo, lpla = np.loadtxt(line_fn, comments="#", unpack=True, usecols=(0,1))
      ProjX, ProjY, flagD = get_proj(stlo, stla, lplo, lpla)
      size = np.array(mag)/2 + 1

      for i in range(len(stlo)):
         if flagD[i] < cut_off:
            print("%10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %s" %(stlo[i],stla[i],ProjX[i],ProjY[i],flagD[i],dep[i], mag[i], str(size[i])+'p'))
