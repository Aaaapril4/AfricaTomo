#!/bin/bash
date
cd /mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/station/AF.MTVE
if [ -e run_info ] ; then 
rm -rf run_info
fi
/mnt/home/jieyaqi/code/JOINT_PACKAGE/bin/LITMOD para.input Africa.AF.MTVE.dat >> run_info
sh plot_mcmc2.sh
date
