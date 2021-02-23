import obspy
import os
from obspy.signal.rotate import rotate_ne_rt
from tqdm import tqdm
from shutil import copyfile
import multiprocessing as mp
import logging
logging.basicConfig(level = logging.INFO,format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# estimate: 500 items/s for 10 cpu

path = "/mnt/ufs18/nodr/home/jieyaqi/earthquake/SAC"
outdir = "/mnt/ufs18/nodr/home/jieyaqi/earthquake/SAC/rotate"
ncpu = 10

if not os.path.exists(outdir):
    os.makedirs(outdir)

def rotate(sac):
    global path
    if '.SAC' not in sac or sac.split('.')[3][-2:]!='HN':
        return

    sacp = f'{path}/{sac}'
    try:
        trn = obspy.read(sacp, format='sac')
    except IndexError:
        os.remove(sacp)
        return
    else:
        # 1C.BLS..HHE.M.2013.237.160216.SAC
        try:
            sace = '.'.join(sac.split('.')[0:3]+[sac.split('.')[3].replace('N','E')]+sac.split('.')[4:])
            tre = obspy.read(f'{path}/{sace}')
        except FileNotFoundError:
            logger.debug(f'Cannot find E component for {sac}')
            return

        trr = trn.copy()

        for i in range(len(trn)):
            try:
                trr[i].data = rotate_ne_rt(trn[i].data,tre[i].data,trn[i].stats.sac.baz)[0]
            except TypeError:
                return
            trr[i].stats.channel = 'LHR'
        sacr = '.'.join(sac.split('.')[0:2]+sac.split('.')[5:8]+['R.SAC'])
        trr.write(f'{outdir}/{sacr}',format='SAC')
        sacz = '.'.join(sac.split('.')[0:3]+[sac.split('.')[3].replace('N','Z')]+sac.split('.')[4:])
        saczo = '.'.join(sac.split('.')[0:2]+sac.split('.')[5:8]+['Z.SAC'])
        try:
            trz = obspy.read(f'{path}/{sacz}')
        except FileNotFoundError:
            logger.debug(f'cannot find Z component for {sac}')
            os.remove(f'{outdir}/{sacr}')
            return
        for i in range(len(trz)):
            trz[i].stats.channel = 'LHZ'
        saczo = '.'.join(sac.split('.')[0:2]+sac.split('.')[5:8]+['BHZ'])
        trz.write(f'{outdir}/{saczo}',format='SAC')
    return

if __name__ == "__main__":
    with mp.Pool(ncpu) as p:
        N = list(tqdm(p.imap(rotate, os.listdir(path)),total=len(os.listdir(path))))
        # N = p.map(main, tqdm(os.listdir(path)))