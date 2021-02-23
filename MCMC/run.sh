#!/bin/bash
date
cd /mnt/ufs18/nodr/home/jieyaqi/inversion/grid/G_-12.6_30.6
if [ -e run_info ] ; then 
rm -rf run_info
fi
/mnt/home/jieyaqi/code/JOINT_PAKAGE/MCMC_JOINT/EXAMPLE/LITMOD para.input Africa_-12.6_30.6.dat >> run_info
python3 /mnt/home/jieyaqi/code/JOINT_PACKAGE/Shell_code/MCMC/thick2dep.py /mnt/home/jieyaqi/code/JOINT_PACKAGE/Shell_code/MCMC
rm bsp* Hz* mod* pCr* Ref*
awk '{print -12.6,30.6,$1,$2}' intp.dat >> /mnt/ufs18/nodr/home/jieyaqi/inversion/vel.xyz
sh plot_mcmc2.sh
date
