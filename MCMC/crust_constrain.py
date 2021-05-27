import sys
column1 = [0] + [10]*3 + [1]*5 + [0] + [2]*7 + [3]*3
column2 = [0] + list(range(1,4)) + list(range(1,6)) + [1] + list(range(1,8)) + list(range(1,4))

def search_line(slist, keyword):
    i = len(slist)-1
    while i >= 0:
        if keyword in slist[i]:
            return i
        i = i - 1

    return

def seperate_constrain(slist):
    parameter = []
    for ele in slist:
        for a in ele.strip().split(' '):
            if a != '':
                parameter.append(round(float(a),2))
    return parameter

if __name__ == '__main__':
    file = sys.argv[1]
    with open(file, 'r') as f:
        slist = f.readlines()

    index = search_line(slist, 'In Write_maxprobility subroutine')
    parameter = seperate_constrain(slist[index+1: index+8])

    with open("crust_para.dat", 'w') as f:
        for i,ele in enumerate(parameter):
            f.write("%d  %d  %.2f  %.2f\n" % (column1[i], column2[i], max(ele-0.1, 0), ele+0.1))
    
