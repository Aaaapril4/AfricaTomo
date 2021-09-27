# moho
mohoabs = "/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/moho.xyz"
mohouncert = "/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/uncertaintym.xyz"

# sed
sedabs = "/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/sedi.xyz"
seduncert = "/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/uncertaintys.xyz"

import numpy as np

def read_files(path):
    dic = {}
    lon, lat, value = np.loadtxt(path, dtype = float, usecols=(0,1,2), unpack = True)
    
    for i in range(len(lon)):
        dic[str(round(lon[i], 2))+"_"+str(round(lat[i], 2))] = value[i]
    
    return dic



def calcu(dicm, dicmu, dics, dicsu):
    lst = []
    lst.append("lon\t lat\t moho\t muncertain\t sedi\t suncertain\t mu/m\t m-mu\t m+mu\t su/s\t s-su\t s+su\n")
    for key in dicmu.keys():
        lst.append(key.replace("_", "\t") + "\t" + "\t".join([str(dicm[key]), str(dicmu[key]), str(round(dics[key],4)), str(round(dicsu[key],4)), str(round(dicmu[key]/dicm[key],4)),str(round(dicm[key]-dicmu[key], 4)),str(round(dicm[key]+dicmu[key], 4)),str(round(dicsu[key]/dics[key],4)),str(round(dics[key]-dicsu[key],4)),str(round(dics[key]+dicsu[key], 4))]) + "\n")
    return lst



if __name__ == "__main__":
    dicm = read_files(mohoabs)
    dicmu = read_files(mohouncert)
    dics = read_files(sedabs)
    dicsu = read_files(seduncert)

    lst = calcu(dicm, dicmu, dics, dicsu)

    with open("/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/uncertaintyms.xyz", "w") as f:
        for line in lst:
            f.write(line)