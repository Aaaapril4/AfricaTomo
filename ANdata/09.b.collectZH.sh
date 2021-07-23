#!/bin/bash
datdir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/stationzh 
cod_dir=/mnt/home/jieyaqi/code/JOINT_PACKAGE/bin

cd $datdir        

$cod_dir/collect ~/Documents/station.lst 2 40 $datdir 0.15
# format to use: 
#   collect stationlst startper endper datadirectory cutoffstd
# format of stationlst:
#   name longitude latitude
#output:    ZHratio.per.dat
#   stlon, stlat, zh, std, err, num collected, stname

for per in {2..40}
do
    mv ZHratio.$per.000000.dat ZHratio.$per.dat
done
rm ZHratio.*00000.dat
