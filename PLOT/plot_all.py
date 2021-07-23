# This code is for plot stacked waveform to check the quality 
# It's generating 3 kinds of figures:
#   stacked waveform
#   all waveforms stacked
#   rose map for each station

path = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/waveform'
outpath = '/mnt/home/jieyaqi/Documents/plot/wavestack'
stapath = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/stationzh'
evpath = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/eventzh'
merpath = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/zhcurve'
invdatadir = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/file'
linew = 0.4
frame = 0.4
font = 6
cutoff = 8
ncpu = 1
T = 25 # time window [s] of stacked waveform
win = 15

import os
import obspy
import numpy as np
import matplotlib.pyplot as plt
import warnings
import multiprocessing as mp
from tqdm import tqdm

warnings.filterwarnings('ignore')


# get event az for each station
def get_az(sta, ev):
    if len(ev) == 0:
        return []
    

    staaz = []
    for sac in ev:
        tr = obspy.read(f'{path}/{sta}/{sac}.BHZ')
        az = tr[0].stats.sac.az
        staaz.append(az)

    return staaz


# get the displacement for each waveform, return a list of displacements for Z and R component 
# the method to find the zero time should be consistent with Wavestack code.
def sort_wave(sta):
    tempwin = win

    ev = np.loadtxt(f'{path}/{sta}/stacked.dat', dtype=str)
    disstackr = []
    disstackz = []


    for i in range(len(ev)):
        try:
            sac = ev[i]
        except TypeError:
            return None
        
        sacr = f'{path}/{sta}/{sac}.BHR'
        sacz = f'{path}/{sta}/{sac}.BHZ'
        trr = obspy.read(sacr,format='sac')
        trz = obspy.read(sacz,format='sac')
        trr.filter('bandpass',freqmin=0.1,freqmax=1)
        trz.filter('bandpass',freqmin=0.1,freqmax=1)

        # find the arrival
        dt = trz[0].stats.sac.delta
        ampz = -100000
        temp = 0
        try:
            arrival = int((-trz[0].stats.sac.b+trz[0].stats.sac.t0)/dt)
            while temp != ampz:
                temp = ampz
                nb = int((-0.5 / dt) + arrival)
                ne = int((0.5 / dt) + arrival)
                arrival = np.where(np.abs(trz[0].data[nb:ne])==max(np.abs(trz[0].data[nb:ne])))[0][0]+nb
                ampz = max(np.abs(trz[0].data[nb:ne]))
        except AttributeError:
            arrival = -trz[0].stats.sac.b / dt
            nb = int((-15 / dt) + arrival)
            ne = int((15 / dt) + arrival)
            arrival = np.where(np.abs(trz[0].data[nb:ne])==max(np.abs(trz[0].data[nb:ne])))[0][0]+nb
            ampz = max(np.abs(trz[0].data[nb:ne]))
        
        nb = int((-5 / dt) + arrival)
        ne = int((10 / dt) + arrival)

        if trz[0].data[arrival] < 0:
            PNz = -1
        else:
            PNz = 1

        if trr[0].data[arrival] < 0:
            PNr = -1
        else:
            PNr = 1

        trr[0].data = trr[0].data/max(np.abs(trr[0].data[nb:ne])) * PNz
        trz[0].data = trz[0].data/max(np.abs(trz[0].data[nb:ne])) * PNr
            
        displacementr = trr[0].data[nb:ne]*2 + trr[0].stats.sac.gcarc
        displacementz = trz[0].data[nb:ne]*2 + trz[0].stats.sac.gcarc
        disstackr.append(displacementr)
        disstackz.append(displacementz)
        
    return disstackr, disstackz


def sort_zh(path):
    stadic = dict()
    for per in range(2,30):
        file = f'{path}/ZHratio.{per}.dat'
        try:
            zh,std,sta = np.loadtxt(file,unpack=True,usecols=(2,3,6),dtype=str)
        except:
            continue
        if len(zh[0]) == 1:
            zh = [zh]
            std = [std]
            sta = [sta]
        for i in range(len(sta)):
            if sta[i] not in stadic.keys():
                stadic[sta[i]]=[[],[],[]]
            stadic[sta[i]][0].append(per)
            stadic[sta[i]][1].append(float(zh[i]))
            stadic[sta[i]][2].append(float(std[i]))
    return stadic


def plot_all(sta):
    print(sta)
    # grid = plt.GridSpec(4, 2, wspace=0.5, hspace=0.5)
    plt.figure(figsize=(10,10))
    plot_phase(sta)
    #  plot the stacked telewaveform
    stapath = f'{path}/{sta}'
    try:
        trz = obspy.read(f'{stapath}/stack2.BHZ.sac')
    except FileNotFoundError:
        return
    
    trr = obspy.read(f'{stapath}/stack2.BHR.sac')
    dt = trz[0].stats.sac.delta
    time0 = int(0 - trz[0].stats.sac.b / trz[0].stats.sac.delta)
    Zmax = max(trz[0].data)
    Rmax = max(trr[0].data)
    normp = max(Zmax,Rmax)
    dspZ = trz[0].data[(time0 - int(5/dt)):] / normp + 1
    dspR = trr[0].data[(time0 - int(5/dt)):] / normp - 1
    
    plt.axes([0.05, 0.5, 0.2, 0.15])
    plt.plot(dspZ, linewidth=linew, color='black')
    plt.plot(dspR, linewidth=linew, color='black')
    plt.yticks([-2,-1,0,1,2],['','R','','Z',''],fontsize=font)
    plt.xticks([0,50,100,150],[-5,0,5,10],fontsize=font)
    plt.tick_params(top='on', right='on')
    plt.text(100,2,f'# Stack={int(trz[0].stats.sac.user2)}',fontsize=font)
    plt.ylabel('Amplitude',fontsize=font)
    plt.xlabel('Time [s]',fontsize=font)
    plt.xlim([0,150])
    plt.ylim([-2.5,2.5])
    plt.grid(which='both', axis='y', linestyle='--',alpha=0.6,linewidth=frame)
    plt.grid(which='major', axis='x', linestyle='--',alpha=0.6,linewidth=frame)
    ax = plt.gca()
    ax.spines['bottom'].set_linewidth(frame)
    ax.spines['left'].set_linewidth(frame)
    ax.spines['top'].set_linewidth(frame)
    ax.spines['right'].set_linewidth(frame)
    ax.axvline(50, linestyle='--', color='k', linewidth=frame)
    plt.tick_params(which='major',width=frame)
    plt.tick_params(axis='x',which='minor',width=frame, top='on', right='on')

    # plot the receiver funtion for each station
    try:
        disstackr, disstackz = sort_wave(sta)
    except:
        return

    plt.axes([0.05, 0.05, 0.2, 0.4],ylim=[20,100],xlim=[0,150])
    for i in range(len(disstackz)):
        plt.plot(disstackz[i],linewidth=linew,color='black')
    plt.ylabel('Epicentral [km]',fontsize=font)
    plt.xlabel('time [s]',fontsize=font)
    # plt.xlim([0,500])
    # plt.ylim([20,100])
    plt.xticks([0,50,100,150],[-5,0,5,10],fontsize=font)
    plt.yticks(fontsize=font)
    plt.tick_params(top='on', right='on')
    plt.text(110,92,f'{len(disstackz)} traces',fontsize=font)
    ax = plt.gca()
    ax.spines['bottom'].set_linewidth(frame)
    ax.spines['left'].set_linewidth(frame)
    ax.spines['top'].set_linewidth(frame)
    ax.spines['right'].set_linewidth(frame)
    plt.minorticks_on()
    plt.tick_params(which='major',width=frame)
    plt.tick_params('both',which='minor',width=frame, top='on', right='on')


    plt.axes([0.3, 0.05, 0.2, 0.4])
    for i in range(len(disstackr)):
        plt.plot(disstackr[i],linewidth=linew,color='black')
    plt.ylabel('Epicentral [km]',fontsize=font)
    plt.xlabel('time [s]',fontsize=font)
    plt.xlim([0,150])
    plt.ylim([20,100])
    plt.xticks([0,50,100,150],[-5,0,5,10],fontsize=font)
    plt.yticks(fontsize=font)
    plt.text(120,92,f'{len(disstackr)} traces',fontsize=font)
    ax = plt.gca()
    ax.spines['bottom'].set_linewidth(frame)
    ax.spines['left'].set_linewidth(frame)
    ax.spines['top'].set_linewidth(frame)
    ax.spines['right'].set_linewidth(frame)
    plt.minorticks_on()
    plt.tick_params(which='major',width=frame, top='on', right='on')
    plt.tick_params('both',which='minor',width=frame, top='on', right='on')



    # plot ZH ratio
    plt.axes([0.3,0.5,0.2,0.15])
    plt.xlabel('Period [s]',fontsize=font)
    plt.ylabel('Measurement',fontsize=font)
    plt.xlim([0,30])
    plt.ylim([0.5,2.5])
    plt.xticks(fontsize=font)
    plt.yticks(fontsize=font)
    plt.minorticks_on()
    plt.tick_params(which='major',width=frame)
    plt.tick_params('both',which='minor',width=frame, top='on', right='on')
    plt.tick_params(top='on', right='on')
    ax = plt.gca()
    ax.spines['bottom'].set_linewidth(frame)
    ax.spines['left'].set_linewidth(frame)
    ax.spines['top'].set_linewidth(frame)
    ax.spines['right'].set_linewidth(frame)

    try:
        curper, curzh = np.loadtxt(f'{merpath}/{sta}.DAT', usecols=(0,1), unpack=True)
    except OSError:
        plt.tight_layout()
        plt.savefig(f'/mnt/home/jieyaqi/Documents/plot/wavestack/{sta}.pdf',ppi=300)
        return

    if sta in stadic.keys() and sta in evdic.keys():

        if len(evdic[sta][0])+len(stadic[sta][0]) < 5:
            plt.tight_layout()
            plt.savefig(f'/mnt/home/jieyaqi/Documents/plot/wavestack/{sta}.pdf',ppi=300)
            return

        evper = evdic[sta][0]
        evzh = evdic[sta][1]
        evstd = evdic[sta][2]
        plt.errorbar(evper,evzh,yerr=evstd,fmt='o',
            markerfacecolor='#BDA065',
            markeredgecolor='#BDA065',
            markersize=3,
            capsize=3,
            capthick = linew,
            elinewidth=linew,
            ecolor = 'darkgray',
            label = 'Earthquake')

        stper = stadic[sta][0]
        stzh = stadic[sta][1]
        ststd = stadic[sta][2]
        plt.errorbar(stper,stzh,yerr=ststd,fmt='o',
            markerfacecolor='#4E90B1',
            markeredgecolor='#4E90B1',
            markersize=3,
            capsize=3,
            elinewidth=linew,
            capthick = linew,
            ecolor='darkgray',
            label = 'Ambient Noise')
        plt.plot(curper,curzh,linewidth=linew, color = 'black', label = 'in inversion', zorder = 30)
        plt.legend(fontsize=font, framealpha = 0)
        


    elif sta in evdic.keys() and sta not in stadic.keys():
        if len(evdic[sta][0]) < 5:
            plt.tight_layout()
            plt.savefig(f'{outpath}/{sta}.pdf',ppi=300)
            return
        evper = evdic[sta][0]
        evzh = evdic[sta][1]
        evstd = evdic[sta][2]

        plt.errorbar(evper,evzh,yerr=evstd,fmt='o',
            markerfacecolor='#BDA065',
            markeredgecolor='#BDA065',
            markersize=3,
            capthick = linew,
            capsize=3,
            elinewidth=linew,
            ecolor='darkgray',
            label = 'Earthquake')
        plt.plot(curper,curzh,linewidth=linew, color = 'black', label = 'in inversion', zorder = 30)
        plt.legend(fontsize=font, framealpha = 0)


    elif sta in stadic.keys() and sta not in evdic.keys():
        if len(stadic[sta][0]) < 5:
            plt.tight_layout()
            plt.savefig(f'/mnt/home/jieyaqi/Documents/plot/wavestack/{sta}.pdf',ppi=300)
            return
        staper = stadic[sta][0]
        stazh = stadic[sta][1]
        stastd = stadic[sta][2]

        plt.errorbar(staper,stazh,yerr=stastd,fmt='o',
            markerfacecolor='#BDA065',
            markeredgecolor='#BDA065',
            markersize=3,
            capthick = linew,
            capsize=3,
            elinewidth=linew,
            ecolor='darkgray',
            label = 'Earthquake')
        plt.plot(curper,curzh,linewidth=linew, color = 'black', label = 'in inversion', zorder = 30)
        plt.legend(fontsize=font, framealpha = 0)

    plt.tight_layout()
    plt.savefig(f'/mnt/home/jieyaqi/Documents/plot/wavestack/{sta}.pdf',ppi=300)
    return



def get_phase(sta):
    stafile = f'{invdatadir}/Africa.{sta}.dat'
    per = []
    phase = []
    with open(stafile,'r') as f:
        f.readline()
        for i in range(2,19):
            line = f.readline()
            line = line.split('\t')
            per.append(int(line[3]))
            phase.append(float(line[4]))
        
    return per,phase



def plot_phase(sta):
    per, phase = get_phase(sta)
    plt.axes([0.55,0.5,0.2,0.15])
    plt.xlabel('Period [s]',fontsize=font)
    plt.ylabel('Phase velocity [km/s]',fontsize=font)
    plt.xlim([0,150])
    plt.ylim([3,5])
    plt.xticks(fontsize=font)
    plt.yticks(fontsize=font)
    plt.minorticks_on()
    plt.tick_params(which='major',width=frame)
    plt.tick_params('both',which='minor',width=frame, top='on', right='on')
    plt.tick_params(top='on', right='on')
    ax = plt.gca()
    ax.spines['bottom'].set_linewidth(frame)
    ax.spines['left'].set_linewidth(frame)
    ax.spines['top'].set_linewidth(frame)
    ax.spines['right'].set_linewidth(frame)
    plt.plot(per, phase, 'k-')
    plt.plot(per[0:12], phase[0:12], 'o', markeredgecolor='#BDA065', markerfacecolor='#BDA065',markersize=3,label='This Study')
    plt.plot(per[12:], phase[12:], 'o', markerfacecolor='#4E90B1', markeredgecolor='#4E90B1', markersize=3, label='O\'Donnel')
    plt.legend(fontsize=font, framealpha = 0)

    return



if __name__ == '__main__':
    stadic = sort_zh(stapath)
    evdic = sort_zh(evpath) 
    stalist = np.loadtxt('/mnt/home/jieyaqi/Documents/mysta.lst', dtype=str)
    for sta in stalist:
        plot_all(sta)
    # with mp.Pool(ncpu) as p:
        # N = list(tqdm(p.imap(plot_all, stalist),total=len(stalist)))
