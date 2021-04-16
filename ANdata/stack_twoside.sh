#!/bin/bash
com=TT
in_dir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/threestation_tt/I2
out_dir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/data_tt
cod_dir=~/code/JOINT_PACKAGE/bin
sta_fn=/mnt/home/jieyaqi/Documents/station.lst

cd $in_dir

if [ ! -e $out_dir/TF_PWS ] ; then
	mkdir -p $out_dir/TF_PWS
fi
if [ ! -e $out_dir/LINE_STACK ] ; then
        mkdir -p $out_dir/LINE_STACK
fi

num1=`cat $sta_fn| wc | awk '{print int($1)}'`

for (( i=1; i<=$num1-1 ; ++i ))
do
        sta1=`sed -n ''$i'p' $sta_fn`

        for (( j=$i+1; j<=$num1 ; ++j ))
        do
                sta2=`sed -n ''$j'p' $sta_fn`
                rm lst
                echo COR_$sta2.$sta1."$com".SAC >> lst
                echo COR_$sta1.$sta2."$com".SAC >> lst
                echo COR_$sta2.$sta1."$com".SAC COR_$sta1.$sta2."$com".SAC
                if [[ -e COR_$sta2.$sta1."$com".SAC && -e COR_$sta1.$sta2."$com".SAC ]]
                then
                        $cod_dir/tf-PWS -Flst -B2 -E80 -N0 -c96 -O$out_dir
                        mv $out_dir/tf-stack.sac $out_dir/TF_PWS/COR_$sta2.$sta1."$com".SAC
                        mv $out_dir/line-stack.sac $out_dir/LINE_STACK/COR_$sta2.$sta1."$com".SAC
                fi
        done
done
