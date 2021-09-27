projd=/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion
outf=$projd/vel.xyz
mohotf=$projd/moho.xyz #thickness
seditf=$projd/sedi.xyz
mohodf=$projd/mohod.xyz #depth
sedidf=$projd/sedid.xyz
testd=$projd/test
uncert=$projd/uncertainty.xyz
uncertmoho=$projd/uncertaintym.xyz
uncertsed=$projd/uncertaintys.xyz
denser="0.1,0.2,0.3,0.4,0.5,0.6,0.8,1.5"


if [ -e $outf ]
then
    rm $outf
fi

if [ -e $seditf ]
then
    rm $seditf
fi

if [ -e $mohotf ]
then
    rm $mohotf
fi

if [ -e $mohodf ]
then
    rm $mohodf
fi

if [ -e $sedidf ]
then
    rm $sedidf
fi

if [ -e $testd ]
then
    rm -r $testd
    mkdir $testd
fi

if [ -e $uncert ]
then
    rm $uncert
fi

if [ -e $uncertmoho ]
then
    rm $uncertmoho
fi

if [ -e $uncertsed ]
then
    rm $uncertsed
fi

python3 uncertainty.py
python3 uncertain_ms.py

# collect grid
path=$projd/grid

cd $path
for grid in `ls -d */ | awk -F '/' '{print $1}'`
do
    echo $grid
    if [ -e $grid/MAX_PROBVM.dat ]
    then
        lat=`echo $grid | awk -F '_' '{print $2}'`
        lon=`echo $grid | awk -F '_' '{print $3}'`
        topo=`python3 /mnt/home/jieyaqi/code/JOINT_PACKAGE/Scripts_JI/MCMC/thick2dep.py $path/$grid $denser $lat $lon`

        sedit=`awk 'NR==9 {print $1}' $grid/MAX_PROBVM.dat`
        mohot=`awk 'NR==29 {print $1}' $grid/MAX_PROBVM.dat`
        sedid=`echo $sedit - $topo | bc -l`
        mohod=`echo $mohot - $topo | bc -l`

        awk '{print '$lon','$lat',$1,$2}' $grid/intp.dat >> $outf
        echo $lon   $lat    $mohot   "grid" >> $mohotf
        echo $lon   $lat    $sedit   "grid" >> $seditf
        echo $lon   $lat    $mohod   "grid" >> $mohodf
        echo $lon   $lat    $sedid   "grid" >> $sedidf
        cat $grid/uncertainty.dat >> $uncert
        awk 'NR==1{print $1, $2, $3}' $projd"6015"/grid/$grid/uncertaintyms.dat >> $uncertsed
        awk 'NR==2{print $1, $2, $3}' $projd"6015"/grid/$grid/uncertaintyms.dat >> $uncertmoho

        
        mv $grid/test.pdf $testd/"$grid".pdf
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
        net=`echo $sta | awk -F '.' '{print $1}'`
        stn=`echo $sta | awk -F '.' '{print $2}'`
        lat=`awk -F '|' '$1=="'$net'" && $2=="'$stn'"{print $3}' $stationfile`
        lon=`awk -F '|' '$1=="'$net'" && $2=="'$stn'"{print $4}' $stationfile`
        topo=`python3 /mnt/home/jieyaqi/code/JOINT_PACKAGE/Scripts_JI/MCMC/thick2dep.py $path/$sta $denser $lat $lon`

        sedit=`awk 'NR==8 {print $1}' $sta/MAX_PROBVM.dat`
        mohot=`awk 'NR==28 {print $1}' $sta/MAX_PROBVM.dat`
        sedid=`echo $sedit - $topo | bc -l`
        mohod=`echo $mohot - $topo | bc -l`

        awk '{print '$lon','$lat',$1,$2}' $sta/intp.dat >> $outf
        echo $lon   $lat    $mohot  $sta >> $mohotf
        echo $lon   $lat    $sedit  $sta >> $seditf
        echo $lon   $lat    $mohod  $sta >> $mohodf
        echo $lon   $lat    $sedid  $sta >> $sedidf

        cat $sta/uncertainty.dat >> $uncert
        awk 'NR==1{print $1, $2, $3}' $projd"6015"/station/$sta/uncertaintyms.dat >> $uncertsed
        awk 'NR==2{print $1, $2, $3}' $projd"6015"/station/$sta/uncertaintyms.dat >> $uncertmoho
        mv $sta/test.pdf $testd/"$sta".pdf
    else 
        echo "NO RESULT"
    fi
    
done

for dep in {0..200}
do
    awk '$3=='$dep' {print $1, $2, $4}' $outf | gmt surface  -R25/42/-15/4 -I0.2  -G$projd/dep."$dep".grd -T0.5
done

gmt surface $projd/sedid.xyz -R25/42/-15/4 -I0.2  -G$projd/sed.grd -T0.5
gmt surface $projd/mohod.xyz -R25/42/-15/4 -I0.2  -G$projd/moho.grd -T0.5