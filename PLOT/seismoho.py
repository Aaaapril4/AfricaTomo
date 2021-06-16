import sys


def read_file(file, delimiter):
    with open(file, 'r') as f:
        lines = [ line.strip().split(delimiter) for line in f.readlines() ]
    
    return lines



def write_file(file, content, delimiter):
    with open(file, 'w') as f:
        for line in content:
            f.write(delimiter.join(line) + '\n')

    return



def find_nearestgrid(lat, lon, moholines):

    dis = [ ((float(line[0])-lon)**2+(float(line[1])-lat)**2) for line in moholines ]
    dissort = sorted((dis, i) for (i, dis) in enumerate(dis))
    n1, n2, n3, n4 = dissort[0][1], dissort[1][1], dissort[2][1], dissort[3][1]
    return [dis[n1], float(moholines[n1][2])], [dis[n2], float(moholines[n2][2])], \
        [dis[n3], float(moholines[n3][2])], [dis[n4], float(moholines[n4][2])]
        


def find_moho(lat, lon, moholines):
    n1, n2, n3, n4 = find_nearestgrid(lat, lon, moholines)
    if n1[0] == 0:
        moho = n1[1]
    else:
        moho = (1/n1[0] * n1[1] + 1/n2[0] * n2[1] + 1/n3[0] * n3[1] + 1/n4[0] * n4[1]) / (1/n1[0]+1/n2[0]+1/n3[0]+1/n4[0])

    return round(moho,2)



def comp(seisline, moholines):
    [lon, lat, dep] = seisline[0:3]
    moho = find_moho(float(lat), float(lon), moholines)
    
    if len(seisline) == 3:
        seisline.append(str(1))

    return (moho+2 < float(dep)), seisline



if __name__  ==  "__main__":
    seisp, dep, div = sys.argv[1], float(sys.argv[2]), float(sys.argv[3])
    seislines = read_file(seisp, '\t')
    abovemoho = []
    belowmoho = []

    if dep <= 20:
        for seisline in seislines:
            if float(seisline[2]) <= dep+div and float(seisline[2]) > dep-div:
                if len(seisline) == 3:
                    seisline.append(str(1))
                abovemoho.append(seisline)
    else:
        moholines = read_file("/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/moho.xyz", ' ')
        for seisline in seislines:
            if float(seisline[2]) <= dep+div and float(seisline[2]) > dep-div:
                flag, seisline = comp(seisline, moholines)
                if flag:
                    belowmoho.append(seisline)
                else:
                    abovemoho.append(seisline)

    write_file("belowmoho.dat", belowmoho, "\t")
    write_file("abovemoho.dat", abovemoho, "\t")