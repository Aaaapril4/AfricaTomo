import numpy as np

gridf = '/mnt/home/jieyaqi/Documents/FinalModels/ShearVelocities/node_coords_subset.xyz'
resultf = '/mnt/home/jieyaqi/Documents/FinalModels/ShearVelocities/Vs_node_profiles.xyz'
outf = '/mnt/home/jieyaqi/Documents/FinalModels/ShearVelocities/vs.xyz'

def get_coord(gridf):
    coorddic = {}
    with open(gridf, 'r') as f:
        for line in f:
            ele = line.split(' ')
            coorddic[ele[0]] = [ele[1], ele[2]]
    return coorddic



def organize_profile(resultf):
    profiledic = {}
    with open(resultf, 'r') as f:
        line = f.readline()
        while True:
            
            if "node" in line:
                nodenum = line.strip().split('_')[1]
                depth = []
                vel = []
                line = f.readline()

                while "node" not in line:
                    ele = line.strip().split(' ')

                    while '' in ele:
                        ele.remove('')

                    if len(ele) == 2:
                        vel.append(float(ele[0]))
                        depth.append(-float(ele[1]))
                        line = f.readline()
                    else:
                        line = f.readline()

                    if not line:
                        break

                profiledic[nodenum] = [vel,depth]

            if not line:
                return profiledic




def intp(depth, vel):
    depout = np.arange(0,201)
    velout = np.interp(depout, depth, vel)
    return depout, velout



def interprofile(profiledic):
    for node in profiledic.keys():
        if len(profiledic[node][1]) == 0:
            continue
        dep, vel = intp(profiledic[node][1], profiledic[node][0])
        profiledic[node] = [vel, dep]
    return profiledic



def writefile(coorddic, profiledic):
    with open(outf, 'w') as f:
        for node in profiledic.keys():
            for i in range(len(profiledic[node][0])):
                f.write(coorddic[node][1] + ' ' + coorddic[node][0] + ' ' + str(round(profiledic[node][1][i],4)) + ' ' + str(round(profiledic[node][0][i],4)) + '\n')
    return None



if __name__ == "__main__":
    coorddic = get_coord(gridf)
    profiledic = organize_profile(resultf)
    profiledic = interprofile(profiledic)
    writefile(coorddic, profiledic)
                
        