import obspy
import os
from tqdm import tqdm
import multiprocessing as mp
import logging
import numpy as np
logging.basicConfig(level = logging.INFO,format = '%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# estimate: 90 items/s

path = "/mnt/ufs18/nodr/home/jieyaqi/earthquake/SAC"
cutvmin = 2.5
cutvmax = 5
ncpu = 1

def _cut_trace(trace,b,e):
    # b is the begin respect to the reference time
    # e is the end respect to the reference time
    # unit: sec
    ib = int(np.floor(max(0, b-trace.stats.sac.b) / trace.stats.delta))
    ie = int(np.ceil((min(trace.stats.sac.e, e)-trace.stats.sac.b) / trace.stats.delta))
    trace.data = trace.data[ib:ie]
    trace.stats.sac.b = b
    trace.stats.sac.e = e
    trace.stats.starttime = trace.stats.starttime + ib
    if ie < ib:
        return None
    return trace

def cut_trace(sac):
    if '.SAC' in sac:
        sacp = f'{path}/{sac}'
        try:
            tr = obspy.read(sacp, format='sac')
        except IndexError:
            logger.debug(f'No data read in, {sac} is removed.')
            os.remove(sacp)
            return
        else:
            # 1C.BLS..HHE.M.2013.237.160216.SAC
            for trace in tr:
                try:
                    switch = trace.stats.sac["kuser2"]
                except KeyError:
                    trace.stats.sac["kuser2"] = 'False'

                if trace.stats.sac["kuser2"] == 'False':
                    try:
                        b = np.floor(trace.stats.sac.dist / cutvmax)
                    except AttributeError:
                        os.remove(sacp)
                        logger.debug(f'Not processed, {sac} removed.')
                        return
                    e = np.ceil(trace.stats.sac.dist / cutvmin) + 1000
                    trace = _cut_trace(trace,b,e)
                    if trace == None:
                        os.remove(sacp)
                        logger.debug(f'The length of {sac} is incorrect, removed')
                        return
                    trace.stats.sac["kuser2"] = 'True'
                    tr.write(sacp,format='sac')
                # else:
                #     print(f'{sac} is cut')
    return

if __name__ == "__main__":
    logger.info('Begin Cutting')
    with mp.Pool(ncpu) as p:
        N = list(tqdm(p.imap(cut_trace, os.listdir(path)),total=len(os.listdir(path))))
    logger.info('Finish Cutting')

    # 1-------------------  join  exit
    # 2-------------------  join
    # 3------ xx