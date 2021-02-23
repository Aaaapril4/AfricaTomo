import numpy as np
import os

from numpy.lib.function_base import average

def _cal_perturbation(zfile):
    absvel = np.loadtxt(zfile)
    avg = np.average(absvel)
    relvel = absvel-avg
    pertb = relvel/avg*100
    return pertb, avg

def cal_perturbation(path):
    per = []
    avg = []
    for file in os.listdir(path):
        if 'grid2dv' not in file:
            continue
        else:
            pertb, avgeach = _cal_perturbation(f'{path}/{file}')
            np.savetxt(f'{path}/pertb.{file.split(".")[1]}.z', pertb)
            per.append(int(file.split(".")[1]))
            avg.append(avgeach)
    np.savetxt(f'{path}/avgvel.dat', np.column_stack((per,avg)), fmt='%.4f, %.4f')
    return

if __name__ == '__main__':
    cal_perturbation(r'../output_tomo')
