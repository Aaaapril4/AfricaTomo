import numpy as np
import sys

def _cal_perturbation(absvel):

    avg = np.average(absvel)
    relvel = absvel-avg
    pertb = relvel/avg*100

    return pertb, avg

def cal_perturbation(pathtof):
    
    x,y,absvel = np.loadtxt(pathtof, unpack=True)
    pertb, avg = _cal_perturbation(absvel)
    np.savetxt("pertz.xyz", np.column_stack((x,y,pertb)))
    print(round(avg,4))

    return

if __name__ == '__main__':
    pathtof = sys.argv[1]
    cal_perturbation(pathtof)
