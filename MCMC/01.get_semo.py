sedf = '/mnt/home/jieyaqi/Documents/sedthk.xyz'
mohof = '/mnt/home/jieyaqi/Documents/Tugume_et_al_Tectonophys_2013_model.xyz'
staf = '/mnt/home/jieyaqi/Documents/station.txt'
outp = '/mnt/home/jieyaqi/Documents'

import numpy as np

lonl_sed,latl_sed = np.loadtxt(sedf,unpack=True,usecols=(0,1))
sedl = np.loadtxt(sedf,unpack=True,usecols=2)
lonl_moho,latl_moho = np.loadtxt(mohof,unpack=True,usecols=(0,1),skiprows=1)
mohol = np.loadtxt(mohof,unpack=True,usecols=2, skiprows=1)
# mohol = -mohol



# n1        n2
#      y1
#   x1    x2
#      y2
# n4        n3
def _get_sed(lat,lon,valuel):
    global lonl_sed, latl_sed
    if lat < -9 and lat > -15 and lon > 34 and lon < 36:
        value = 3
    else:
        x1 = round((lon - 0.5) % 1, 2)
        y2 = round((lat - 0.5) % 1, 2)
        x2 = round(1 - x1, 2)
        y1 = round(1 - y2, 2)
        latup = round(lat+y1,2)
        latlo = round(lat-y2,2)
        lonle = round(lon-x1,2)
        lonrt = round(lon+x2,2)
        n1 = valuel[latl_sed==latup][lonl_sed[latl_sed==latup]==lonle][0]
        n2 = valuel[latl_sed==latup][lonl_sed[latl_sed==latup]==lonrt][0]
        n3 = valuel[latl_sed==latlo][lonl_sed[latl_sed==latlo]==lonrt][0]
        n4 = valuel[latl_sed==latlo][lonl_sed[latl_sed==latlo]==lonle][0]
        value = (x2*(y1*n4+n1*y2) + x1*(y1*n3+y2*n2) + y1*(x2*n4+x1*n3) + y2*(x2*n1+x1*n2)) / 2
    return round(value,2)


def _get_moho(lat,lon,valuel):
    global lonl_sed, latl_sed
    # x1 = round((lon - 0.5) % 1, 2)
    # y2 = round((lat - 0.5) % 1, 2)
    # x2 = round(1 - x1, 2)
    # y1 = round(1 - y2, 2)
    x1 = round(lon % 0.25, 2)
    y2 = round(lat % 0.25, 2)
    x2 = round(0.25 - x1, 2)
    y1 = round(0.25 - y2, 2)
    latup = round(lat+y1,2)
    latlo = round(lat-y2,2)
    lonle = round(lon-x1,2)
    lonrt = round(lon+x2,2)
    n1 = valuel[latl_moho==latup][lonl_moho[latl_moho==latup]==lonle][0]
    n2 = valuel[latl_moho==latup][lonl_moho[latl_moho==latup]==lonrt][0]
    n3 = valuel[latl_moho==latlo][lonl_moho[latl_moho==latlo]==lonrt][0]
    n4 = valuel[latl_moho==latlo][lonl_moho[latl_moho==latlo]==lonle][0]
    value = (x2*(y1*n4+n1*y2) + x1*(y1*n3+y2*n2) + y1*(x2*n4+x1*n3) + y2*(x2*n1+x1*n2)) / 2 *16
    return round(value,2)


def get_sednmoho(lat,lon):
    global sedl, mohol
    sed = _get_sed(lat,lon,sedl)
    moho = _get_moho(lat,lon,mohol)

    return sed, moho

if __name__ == "__main__":
    # get moho and sed for grid
    lat = np.arange(-15,3,0.4)
    lon = np.arange(25,40,0.4)
    sedr = []
    mohor = []
    latr = []
    lonr = []
    for la in lat:
        for lo in lon:
            sed, moho = get_sednmoho(la,lo)

            sedr.append(sed)
            mohor.append(moho)
            latr.append(la)
            lonr.append(lo)
    np.savetxt(f'{outp}/sednmohogrid.dat',np.column_stack((latr,lonr,sedr,mohor)),fmt='%f',comments='#lat, lon, sedi, moho',delimiter='\t')


    # get moho and sed for station
    nwl, stal, stlatl, stlonl = np.loadtxt(staf,delimiter='|',unpack=True,usecols=(0,1,2,3),skiprows=0,dtype=str)
    sedr = []
    mohor = []
    sta = []
    for i in range(len(nwl)):
        sed, moho = get_sednmoho(round(float(stlatl[i]),2),round(float(stlonl[i]),2))
        sedr.append(sed)
        mohor.append(moho)
        sta.append(f'{nwl[i]}.{stal[i]}')
    np.savetxt(f'{outp}/sednmohosta.dat',np.column_stack((sta,sedr,mohor)),fmt='%s',header='#nw.sat, sedi, moho',delimiter='\t')
