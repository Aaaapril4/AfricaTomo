import numpy as np
import sys

def _cal_perturbation(absvel, filter):

    if filter:
        avg = np.average(absvel[absvel>3.1])
    else:
        avg = np.average(absvel)
    relvel = absvel-avg
    pertb = relvel/avg*100

    return pertb, avg

def cal_perturbation(pathtof, filter):
    
    x,y,absvel = np.loadtxt(pathtof, unpack=True)
    pertb, avg = _cal_perturbation(absvel, filter)
    np.savetxt("pertz.xyz", np.column_stack((x,y,pertb)))
    print(round(avg,2))

    return

if __name__ == '__main__':
    pathtof = sys.argv[1]
    if sys.argv[2] == "filter":
        cal_perturbation(pathtof, True)
    else:
        cal_perturbation(pathtof, False)
