projd=/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion
outf=$projd/vel.xyz
mohof=$projd/moho.xyz
sedif=$projd/sedi.xyz
denser="0.4,0.6,0.8,1.5"


if [ -e $outf ]
then
    rm $outf
fi

if [ -e $sedif ]
then
    rm $sedif
fi

if [ -e $mohof ]
then
    rm $mohof
fi


# collect grid
path=$projd/grid

cd $path
for grid in `ls -d */ | awk -F '/' '{print $1}'`
do
    echo $grid
    if [ -e $grid/MAX_PROBVM.dat ]
    then
        python3 /mnt/home/jieyaqi/code/JOINT_PACKAGE/Shell_code/MCMC/thick2dep.py $path/$grid $denser
        lat=`echo $grid | awk -F '_' '{print $2}'`
        lon=`echo $grid | awk -F '_' '{print $3}'`
        sedi=`awk 'NR==8 {print $1}' $grid/MAX_PROBVM.dat`
        moho=`awk 'NR==28 {print $1}' $grid/MAX_PROBVM.dat`
        awk '{print '$lon','$lat',$1,$2}' $grid/intp.dat >> $outf
        echo $lon   $lat    $moho >> $mohof
        echo $lon   $lat    $sedi >> $sedif
    else
        echo "NO RESULT"
    fi
done



# collect station
path=$projd/station

cd $path
stationfile=/mnt/home/jieyaqi/Documents/station.txt
for sta in `ls -d */ | awk -F '/' '{print $1}'`
do
    echo $sta
    if [ -e $sta/MAX_PROBVM.dat ]
    then
        python3 /mnt/home/jieyaqi/code/JOINT_PACKAGE/Shell_code/MCMC/thick2dep.py $path/$sta $denser
        net=`echo $sta | awk -F '.' '{print $1}'`
        stn=`echo $sta | awk -F '.' '{print $2}'`
        lat=`awk -F '|' '$1=="'$net'" && $2=="'$stn'"{print $3}' $stationfile`
        lon=`awk -F '|' '$1=="'$net'" && $2=="'$stn'"{print $4}' $stationfile`
        sedi=`awk 'NR==8 {print $1}' $sta/MAX_PROBVM.dat`
        moho=`awk 'NR==28 {print $1}' $sta/MAX_PROBVM.dat`
        awk '{print '$lon','$lat',$1,$2}' $sta/intp.dat >> $outf
        echo $lon   $lat    $moho >> $mohof
        echo $lon   $lat    $sedi >> $sedif
    else 
        echo "NO RESULT"
    fi
    
done

for dep in 0 0.40 0.60 0.80 1 1.5 2 3 4 5 6 7 8 10 12 16 20 25 30 35 40 45 50 55 60
do
    awk '$3=='$dep' {print $1, $2, $4}' $outf | gmt surface  -R25/42/-15/4 -I0.2  -G$projd/dep."$dep".grd -T0.5
done
gmt surface $projd/sedi.xyz -R25/42/-15/4 -I0.2  -G$projd/sed.grd -T0.5
gmt surface $projd/moho.xyz -R25/42/-15/4 -I0.2  -G$projd/moho.grd -T0.5
