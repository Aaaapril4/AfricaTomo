#!/bin/bash
dat_dir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/eventzh
cod_dir=/mnt/home/jieyaqi/code/JOINT_PACKAGE/bin
vel_fn=/mnt/home/jieyaqi/code/JOINT_PACKAGE/ref_grp.dat
cd $dat_dir
pwd
for sta in `ls -d */ | awk -F '/' '{print $1}'`
do
        cd $sta
        rm *DAT1 *DAT
        echo $sta
    	ls "$sta".*.Z.SAC > tempZ
        for Z in `cat tempZ`
        do
                R=${Z/Z.SAC/R.SAC}
                dat=${Z/Z.SAC/DAT1}
                $cod_dir/calzh -Z $Z -R $R -V $vel_fn -P -S -b 2 -e 40 -O $dat
        done
        cd ..
done
