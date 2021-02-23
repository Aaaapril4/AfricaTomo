#!/bin/bash
com=ZZ
in_dir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/data/SAC
out_dir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/data_obs/STACK_doubleside/$com
cod_dir=~/code/JOINT_PACKAGE/bin
sta_fn=/mnt/home/jieyaqi/Documents/station.lst

cd $in_dir
ls -d ?????? > DIR.dat
num_dir=`cat DIR.dat | wc | awk '{print int($1)}'`

if [ ! -e $out_dir/TF_PWS ] ; then
	mkdir -p $out_dir/TF_PWS
fi
if [ ! -e $out_dir/LINE_STACK ] ; then
        mkdir -p $out_dir/LINE_STACK
fi

num1=`cat $sta_fn| wc | awk '{print int($1)}'`
if [ -e corr"$com".lst ]; then
	rm -rf corr"$com".lst
fi

comp1=ZNE
comp2=ZNE
for (( i=1; i<=$num1-1 ; ++i ))
do
        sta1=`sed -n ''$i'p' $sta_fn`

        for (( j=$i+1; j<=$num1 ; ++j ))
        do
                sta2=`sed -n ''$j'p' $sta_fn`
                for (( m=0 ; m<3 ; m++ ))
                do
                        for (( n=0 ; n<3 ; n++ ))
                        do
                                #echo COR_$sta1.$sta2.ZZ.SAC >> corr.lst
                                echo COR_$sta2.$sta1."${comp1:$m:1}${comp2:$n:1}".SAC >> corr"$com".lst
                                echo COR_$sta1.$sta2."${comp1:$m:1}${comp2:$n:1}".SAC >> corr"$com".lst
                        done
                done

        done
done
cd $in_dir

#ls -d 2014???? > dir.lst
grep .$com. corr"$com".lst > "$com"corr.lst
num_clst=`cat "$com"corr.lst| wc | awk '{print int($1)}'`

echo $num_clst  $num1
for (( n=1; n<=$num_clst ; ++n))
do
	rm -rf lst"$com"
        corr1=`sed -n ''$n'p' "$com"corr.lst`
#       if stack two sides together, uncomment the below
#        let n=n+1
#        corr2=`sed -n ''$n'p' '$com'corr.lst`
#	echo $corr1  $corr2
        echo \n \n $corr1
	for (( day=1; day<=7 ; ++day))	
	do 
       	#/data7/ligl/BHZ/output/2009NOV/line_stack
		awk '{ printf"%s/STACK/'$corr1'_'$day'\n",$1}' DIR.dat >> lst"$com"
#		awk '{ printf"%s/STACK/'$corr2'_'$day'\n",$1}' DIR.dat >> lst"$com"
	done
	$cod_dir/tf-PWS -Flst"$com" -B2 -E80 -N0 -c96 -O$out_dir
	mv $out_dir/tf-stack.sac $out_dir/TF_PWS/$corr1
	mv $out_dir/line-stack.sac $out_dir/LINE_STACK/$corr1
pwd
done
