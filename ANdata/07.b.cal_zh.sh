#!/bin/bash
dat_dir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/stationzh
cod_dir=/mnt/home/jieyaqi/code/JOINT_PACKAGE/bin
vel_fn=/mnt/home/jieyaqi/code/JOINT_PACKAGE/ref_grp.dat
cd $dat_dir
pwd
for sta in `ls -d */`
do
        sta=`echo $sta | awk -F '/' '{print $1}'`
        echo $sta
        cd $sta
        rm *DAT1 *DAT2 *DAT

    	ls COR_*."$sta".ZZ.SAC > tempR
        for Z in `cat tempR`
        do
            bh=`echo $Z | awk -F '.' '{print $1 "." $2 "." $3 "." $4}'`
            R=$bh".ZR.SAC"
		    z=$bh".RZ.SAC"
		    r=$bh".RR.SAC"
            dat=$bh".DAT1"
            echo $Z $R $z $r
            
            if [ -e $R ]
            then
                $cod_dir/calzh -Z $Z -R $R -z $z -r $r -V $vel_fn -P  -b 2 -e 40 -O $dat
            fi
        done

        ls COR_"$sta".*.ZZ.SAC > tempR
        for Z in `cat tempR`
        do  
            bh=`echo $Z | awk -F '.' '{print $1 "." $2 "." $3 "." $4}'`
            R=$bh".RZ.SAC"
            z=$bh".ZR.SAC"
            r=$bh".RR.SAC"
            dat=$bh".DAT2"
            
            if [ -e $R ]
            then
                $cod_dir/calzh -Z $Z -R $R -z $z -r $r -V $vel_fn -P  -b 2 -e 40 -O $dat
            fi  
        done

        #rm ZZ.SAC ZR.SAC RZ.SAC RR.SAC
        cd ..
done
