outpath = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/zhcurve'
evpath = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/eventzh'
stapath = '/mnt/ufs18/nodr/home/jieyaqi/east_africa/stationzh'
stafile = '/mnt/home/jieyaqi/Documents/stationwll.lst'

import numpy as np

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
                stadic[sta[i]]=dict()
            stadic[sta[i]][per] = [float(zh[i]),float(std[i])]

    return stadic 


def merge_zh(sta, stadic, evdic):
    lat = latl[stal == sta][0]
    lon = lonl[stal == sta][0]
    source = []
    period = []
    curve = []
    std = []

    for per in range(2,40):
        zhtemp = []
        stdtemp = []
        stemp = []
        try:
            zhtemp.append(stadic[sta][per][0])
            stdtemp.append(stadic[sta][per][1])
        except KeyError:
            pass
        else:
            stemp.append('AN')

        try:
            zhtemp.append(evdic[sta][per][0])
            stdtemp.append(evdic[sta][per][1])
        except KeyError:
            pass
        else:
            stemp.append('EQ')

        if len(zhtemp) == 0:
            continue
        elif len(zhtemp) == 2:
            period.append(str(per))
            curve.append(str(round(np.average(zhtemp),4)))
            std.append(str(round(np.average(stdtemp),4)))
            source.append('both')
        elif len(zhtemp) == 1:
            period.append(str(per))
            curve.append(str(zhtemp[0]))
            std.append(str(stdtemp[0]))
            source.append(stemp[0])

    if len(period) >= 5:
        np.savetxt(f'{outpath}/{sta}.DAT', np.column_stack((period, curve, std, source)), fmt='%s')

        for i in range(len(period)):
            with open(f'{outpath}/ZHratio.{period[i]}.dat', 'a') as f:
                f.writelines(f'{lon}    {lat}   {curve[i]}  {source[i]}\n')


        source = list(set(source))
        if len(source) >= 2:
            source = 'both' 
        elif len(source) == 1:
            source =  source[0]
        with open('/mnt/home/jieyaqi/Documents/zhsta.dat','a') as f:
            f.writelines(f'{sta}    {lon}    {lat}  {std}   {source}\n')

    return


if __name__ == '__main__':
    # global lonl, latl, stal
    print("begin")
    stadic = sort_zh(stapath)
    evdic = sort_zh(evpath)
    stal, lonl, latl = np.loadtxt(stafile, usecols=(0,1,2), unpack=True, dtype=str)

    for sta in stadic:
        merge_zh(sta, stadic, evdic)

    for sta in evdic:
        merge_zh(sta, stadic, evdic)