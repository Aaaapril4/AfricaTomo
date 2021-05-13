#!/bin/bash
run=/mnt/home/jieyaqi/code/JOINT_PACKAGE/src/MCMC_JOINT/LITMOD
filep=/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion
outdir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/grid
codedir=/mnt/home/jieyaqi/code/JOINT_PACKAGE/Scripts_JI/MCMC
sedmohof=/mnt/home/jieyaqi/Documents/sednmohogrid.dat
gridf=/mnt/home/jieyaqi/Documents/invgrid.txt
waterf=~/Documents/water.dat

if [ ! -e $outdir ]
then 
    mkdir $outdir
fi

for grid in `awk '{print $1}' $gridf`
do

    lat=`echo $grid | awk -F '+' '{print $1}'`
    lon=`echo $grid | awk -F '+' '{print $2}'`
    if [ -e $outdir/G_"$lat"_$lon ]
    then
        rm -r $outdir/G_"$lat"_$lon
    fi
    mkdir $outdir/G_"$lat"_$lon
    echo $lat $lon

    cp $filep/file/Africa_"$lat"_"$lon".dat $outdir/G_"$lat"_$lon
    cp para.input $outdir/G_"$lat"_$lon
    cp input_DRAM_T.dat $outdir/G_"$lat"_$lon
    cp plot_mcmc2.sh $outdir/G_"$lat"_$lon

    cd $outdir/G_"$lat"_$lon

    # get moho and sediment information
    # sed=`awk '$1=='$lat' && $2=='$lon' {print $3}' $sedmohof`
    # moho=`awk '$1=='$lat' && $2=='$lon' {print $4}' $sedmohof`
    
    # if [ ! -n "$moho" ] 
    # then
    #     moho=35
    # fi  

    # mohomin=`echo $moho | awk '{print $1-5}'`
    # mohomax=`echo $moho | awk '{print $1+5}'`
    # sedmax=`echo $sed | awk '{print $1+3}'`
    # sedmin=`echo $sed | awk '{print $1-3}'`
    # if [ `echo "0 > $sedmin" | bc` = 1 ]
    # then
    #     sedmin=0
    # fi
    # sed -i "11c 0  0   $sedmin $sedmax" para.input
    # sed -i "20c 0  1   $mohomin $mohomax" para.input

    # constrain water layer
    water=`awk '$1=='$lon' && $2=='$lat' {print $3}' $waterf`
    if [ $water ]
    then
        sed -i "3c  1   $water" para.input
    fi

    # To constrain the crust structure
    parameterf=$crustpath/station/$sta/crust_para.dat

    changepara()
    {
        range=`awk 'NR=='$1'{print $0}' $parameterf`
        sed -i ""$2"c $range" para.input
    }

    for i in {1..10}
    do
        changepara $i `echo $i|awk '{print $1+10}'`
    done

    # generate script to run
    echo "#!/bin/bash" > run.sh
    echo "date" >> run.sh
    echo "cd $outdir/G_"$lat"_$lon" >>run.sh
    echo "if [ -e run_info ] ; then " >> run.sh
    echo "rm -rf run_info" >> run.sh
    echo "fi" >> run.sh
    echo "$run para.input Africa_"$lat"_"$lon".dat >> run_info" >> run.sh
    # echo "awk '{print $lat,$lon,\$1,\$2}' intp.dat >> $filep/vel.xyz" >> run.sh
    echo "sh plot_mcmc2.sh" >> run.sh
    echo "date" >> run.sh
    cd $codedir

done
