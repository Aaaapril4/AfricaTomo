#!/bin/bash
run=/mnt/home/jieyaqi/code/JOINT_PACKAGE/bin/LITMOD
filep=/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion
outdir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/station
codedir=/mnt/home/jieyaqi/code/JOINT_PACKAGE/Scripts_JI/MCMC
sedmohof=/mnt/home/jieyaqi/Documents/sednmohosta.dat
stationfile=/mnt/home/jieyaqi/Documents/station.txt
crustpath=/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion6015

if [ ! -e $outdir ]
then 
    mkdir $outdir
fi

#for sta in 1C.GSSH XD.INZA XD.KIBA XD.KIBE XD.KOMO XD.KOND XD.LONG XD.MBWE XD.KIMU XD.MTAN XD.MTOR XD.PAND XD.PUGE XD.RUNG XD.SING XD.TARA XD.TUND XD.URAM XJ.KEN2 XJ.LL65 XJ.LN45 XJ.LN46 XJ.MW36 XJ.MW41 XJ.MW42 XJ.MW43 XJ.MW44 XJ.NG54 XJ.NG55 
for sta in `awk '{print $1}' /mnt/home/jieyaqi/Documents/mysta.lst`
do
    echo $sta

    if [ ! -e $outdir/$sta ]
    then
        mkdir $outdir/$sta
    fi

    cp $filep/file/Africa."$sta".dat $outdir/$sta
    cp para.input $outdir/$sta
    cp input_DRAM_T.dat $outdir/$sta
    cp plot_mcmc2.sh $outdir/$sta 

    cd $outdir/$sta

    lat=`awk -F '|' '$1=="'$net'" && $2=="'$stn'"{print $3}' $stationfile`
    lon=`awk -F '|' '$1=="'$net'" && $2=="'$stn'"{print $4}' $stationfile`

    # get moho and sediment information
    changesedmoho()
    {
        sed=`awk '$1=="'$sta'" {print $2}' $sedmohof`
        moho=`awk '$1=="'$sta'" {print $3}' $sedmohof`
        
        if [ ! -n "$moho" ] 
        then
            moho=35
        fi  

        mohomin=`echo $moho | awk '{print $1-5}'`
        mohomax=`echo $moho | awk '{print $1+5}'`
        sedmax=`echo $sed | awk '{print $1+3}'`
        sedmin=`echo $sed | awk '{print $1-3}'`
        if [ `echo "0 > $sedmin" | bc` = 1 ]
        then
            sedmin=0
        fi
        sed -i "11c 0  0   $sedmin $sedmax" para.input
        sed -i "20c 0  1   $mohomin $mohomax" para.input
    }


    # To constrain the crust structure
    parameterf=$crustpath/station/$sta/crust_para.dat

    changepara()
    {
        range=`awk 'NR=='$1'{print $0}' $parameterf`
        sed -i ""$2"c $range" para.input
    }

    if [ ! -e $parameterf ]
    then
        echo "noconstrain"
        changesedmoho
    else
        for i in 1 10
        do
            changepara $i `echo $i|awk '{print $1+10}'`
        done
    fi

    # generate script to run
    echo "#!/bin/bash" > run.sh
    echo "date" >> run.sh
    echo "cd $outdir/$sta" >> run.sh
    echo "if [ -e run_info ] ; then " >> run.sh
    echo "rm -rf run_info" >> run.sh
    echo "fi" >> run.sh
    echo "$run para.input Africa."$sta".dat >> run_info" >> run.sh
    echo "sh plot_mcmc2.sh" >> run.sh
    echo "date" >> run.sh
    cd $codedir

done
