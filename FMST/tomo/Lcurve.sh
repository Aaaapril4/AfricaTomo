#!/bin/sh

#  do_tomo.sh
#  
#
#  Created by Yaqi Jie on 1/24/20.
#

per=45
fpath=/mnt/home/jieyaqi/code/FMST/Shell_for_FMM_obs
wpath=$fpath/tomo/Lcurve/$per
output=Lcurve.dat

cp $fpath/gridi."$per".vtx  $wpath/gridi.vtx
cp $fpath/FMM_input"$per"  $wpath/otimes.dat
cp $fpath/receivers."$per".dat  $wpath/receivers.dat
cp $fpath/sources."$per".dat  $wpath/sources.dat

cd $wpath
if [ -e ./$output ]
then
    rm ./$output
fi

for a in 0.0001 0.001 0.01 0.1 1 10 50 100 200 500 1000 2000 5000 10000 20000 50000
do

    sed -i '12c '$a'' subinvss.in
    for b in 0.0001 0.001 0.01 0.1 1 50 10 100 150 200 500 1000 2000 5000 10000 20000 50000
    do
        echo $a $b
        sed -i '15c '$b'' subinvss.in
        zsh ttomoss > $wpath/temp
        res=`residualss  | awk '{print $1}'`
        rough=`misfitss | awk 'NR==2{print $6}'`
        echo $a $b $res $rough >> ./$output
    done
done
