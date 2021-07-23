pathccf='/mnt/ufs18/nodr/home/jieyaqi/east_africa/data/STACK_doubleside/ZZ/TF_PWS'
pathfile='/mnt/ufs18/nodr/home/jieyaqi/east_africa/tomoI2/tomo'
pathselect='/mnt/ufs18/nodr/home/jieyaqi/east_africa/tomoI2/tomo/select_result'
typefile = '/mnt/home/jieyaqi/code/sacfile2.txt'
outpath = '/mnt/home/jieyaqi/Documents/plot/ccf'

linew = 0.3
frame = 0.4
font = 12
# freq = [0.05,0.2]
freq = [0.02,0.05]

import obspy
import numpy as np
import matplotlib.pyplot as plt
import os
from geopy.distance import geodesic
import warnings
import multiprocessing as mp
from tqdm import tqdm

warnings.filterwarnings('ignore')

network = ['1C','AF','GE','II','IU','XD','XI','XJ','XK','XW','Y1','YA','YH','YI','YQ','YY','ZP','ZU','ZV']
# network = ['ZP']

def cal_distance(sac):

    stationList = np.loadtxt('/mnt/home/jieyaqi/Documents/station.txt',unpack = True ,delimiter='|',dtype=str)
    sourcenet = sac.split('.')[0].split('_')[1]
    sourcesta = sac.split('.')[1]
    receivernet = sac.split('.')[2]
    receiversta = sac.split('.')[3]
    sourcemark = [stationList[1][stationList[0]==sourcenet],
                  stationList[3][stationList[0]==sourcenet],
                  stationList[2][stationList[0]==sourcenet]]
    receivermark = [stationList[1][stationList[0]==receivernet],
                    stationList[3][stationList[0]==receivernet],
                    stationList[2][stationList[0]==receivernet]]
    distance = geodesic((sourcemark[1][sourcemark[0]==sourcesta][0],sourcemark[2][sourcemark[0]==sourcesta][0]),
                        (receivermark[1][receivermark[0]==receiversta][0],receivermark[2][receivermark[0]==receiversta][0]))
#     print('source:',sourcenet,'.',sourcesta,
#           'receiver,',receivernet,'.',receiversta,
#           'distance:',distance)
    return distance.km



def get_ccf(nw):

    # get selected ccf used in tomo from files
    # plotl = []
    # # for per in [5,7,9,13,17,21,25,29,33,37,41]:
    # # for per in [5,7,9,13,17]:
    # for per in [21,25,29,33,37,41]:
    #     temp = []
    #     file = f'{pathfile}/tomo_phase_10_{per}.dat'
    #     num, name = np.loadtxt(file, usecols=(0,8), unpack = True, dtype=str)
    #     selectfile = f'{pathselect}/dt_Africa_300_100_{per}_8.dat'
    #     selectnum = np.loadtxt(selectfile, usecols=0, unpack = True, dtype=str)
    #     for n in selectnum:
    #         if f'COR_{nw}' in name[num==n][0]:
    #             temp.append(name[num==n][0])
    #     for ccf in temp:
    #         if ccf not in plotl:
    #             plotl.append(ccf)
    alll = os.listdir(pathccf)
    temp = []
    plotl = []
    for ccf in alll:
        if f'COR_{nw}' in ccf:
            temp.append(ccf)
    plotl = temp

    # sort by types
    # sactype, sacname = np.loadtxt(typefile,usecols=(2,3),unpack=True,dtype=str)
    I2 = []
    I3 = []
    for sac in plotl:
        ccftype = 'I2'
        I2.append(sac)
        # try:
        #     ccftype = sactype[sacname==sac][0]
        #     ccftype = 'I2'
        # except IndexError:
        #     continue
        # if ccftype == 'I2':
        #     I2.append(sac)
        # if ccftype == 'I3_ell':
        #     I3.append(sac)
        # if ccftype == 'I3_hyp':
        #     I3.append(sac)
        # if ccftype == 'I3_coda':
        #     I3.append(sac)
        
    disstackI2 = []
    for sac in I2:
        sacpath = f'{pathccf}/{sac}'
        tra = obspy.read(sacpath,format='sac')
        tra.filter('bandpass',freqmin=freq[0],freqmax=freq[1])
        tra[0].normalize()
        displacement = tra[0].data[0:1200]
        distance = cal_distance(sac)
        displacement_d = displacement*8 + distance
        disstackI2.append(displacement_d)
        
    disstackI3 = []
    for sac in I3:
        sacpath = f'{pathccf}/{sac}'
        tra = obspy.read(sacpath,format='sac')
        tra.filter('bandpass',freqmin=freq[0],freqmax=freq[1])
        tra[0].normalize()
        displacement = tra[0].data[0:1200]
        distance = cal_distance(sac)
        displacement_d = displacement*8 + distance
        disstackI3.append(displacement_d)

    return disstackI2, disstackI3



def plot_ccf(nw, disstackI2, disstackI3):
    # try:
    #     temp = np.max(disstackI2)
    # except ValueError:
    #     temp = 0
    # try:
    #     maxr = np.ceil(max(temp, np.max(disstackI3))/10) * 10
    # except ValueError:
    #     pass
    # try:
    #     temp = np.min(disstackI2)
    # except ValueError:
    #     temp = 9999
    # try:
    #     minr = np.floor(min(temp, np.min(disstackI3))/10) * 10
    # except ValueError:
    #     return

    plt.figure(figsize=(4,8))
    try:
        plt.plot(disstackI3[0],linewidth=linew,color='red',label='I3')
        for i in range(1,len(disstackI3)):
            plt.plot(disstackI3[i],linewidth=linew,color='red')
    except IndexError:
        pass
    try:
        plt.plot(disstackI2[0],linewidth=linew,color='black',label='I2')
        for i in range(1,len(disstackI2)):
            plt.plot(disstackI2[i],linewidth=linew,color='black')
    except IndexError:
        pass

    x = np.linspace(0,1300,50)
    a,b=-10,1200
    xf=x[np.where((x>a)&(x<b))]
    plt.fill_between(xf,2*xf,5*xf,color='black',alpha=0.05)
    plt.ylabel('Distance [km]',fontsize=font)
    plt.xlabel('Time [s]',fontsize=font)
    # plt.legend(fontsize=font, loc=1, framealpha = 0)
    plt.xlim([100,600])
    # plt.ylim([minr,maxr])
    plt.ylim([100, 1500])
    plt.xticks(fontsize=font)
    plt.yticks(fontsize=font)
    plt.title(f'{nw} [{int(1/freq[1])}-{int(1/freq[0])} s]', fontsize=font)
    ax = plt.gca()
    ax.spines['bottom'].set_linewidth(frame)
    ax.spines['left'].set_linewidth(frame)
    ax.spines['top'].set_linewidth(frame)
    ax.spines['right'].set_linewidth(frame)
    plt.minorticks_on()
    plt.tick_params(which='major',width=frame)
    plt.tick_params(which='minor',width=frame)
    plt.rcParams['figure.dpi'] = 300
    name = f'{outpath}/ccf{nw}{int(1/freq[1])}-{int(1/freq[0])}.pdf'
    plt.savefig(name,ppi=300)
    
    return


def _plot_ccf(nw):
    disstackI2,disstackI3 = get_ccf(nw)
    plot_ccf(nw, disstackI2, disstackI3)

    return

if __name__ == '__main__':

    with mp.Pool(10) as p:
        N = list(tqdm(p.imap(_plot_ccf, network),total=len(network)))
