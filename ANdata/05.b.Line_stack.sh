#!/bin/bash
in_dir=/mnt/home/jieyaqi/data/waveforms/SAC
out_dir=/mnt/home/jieyaqi/data/waveforms/SAC/STACK_old
cod_dir=~/code/JOINT_PAKAGE/bin 
sta_fn=/mnt/home/jieyaqi/data/SAC/station.lst

cd $in_dir

ls -d 199505 > DIR.dat
num_dir=`cat DIR.dat | wc | awk '{print int($1)}'`

mkdir $out_dir

num1=`cat $sta_fn| wc | awk '{print int($1)}'`
if [ -e corr.lst ]; then
       rm -rf corr.lst
fi
#
## generate the cross-correlation pairs between each two sations.
#comp1=ZNE
#comp2=ZNE
#echo $num1
#for (( i=1; i<=$num1-1 ; i=i+1 ))
#do
#        sta1=`sed -n ''$i'p' $sta_fn`
#
#        for (( j=$i+1; j<=$num1 ; ++j ))
#        do
#                sta2=`sed -n ''$j'p' $sta_fn`
#                for (( m=0 ; m<3 ; m++ ))
#                do
#                        for (( n=0 ; n<3 ; n++ ))
#                        do
#                                #echo COR_$sta1.$sta2.ZZ.SAC >> corr.lst     |   postive side
#                                #echo COR_$sta2.$sta1.ZZ.SAC >> corr.lst     |   negative side
#                                echo COR_$sta2.$sta1."${comp1:$m:1}${comp2:$n:1}".SAC >> corr.lst
#                                echo COR_$sta1.$sta2."${comp1:$m:1}${comp2:$n:1}".SAC >> corr.lst
#                        done
#                done
#
#        done
#done
#cd $in_dir
#
#
#
#if [ ! -e $out_dir ] ; then
#	mkdir -p $out_dir
#fi

num_dir=`cat DIR.dat | wc | awk '{print int($1)}'`

#num_clst=`cat corr.lst| wc | awk '{print int($1)}'`
num_clst=`cat ZZcorr.lst| wc | awk '{print int($1)}'`


# stacking the single side NCFs. Notice the positive and negative sides can be stacked together or seperately.
echo $num_clst  $num_dir
for (( n=1; n< $num_clst ; ++n ))
do
	rm -rf lst1
	corr1=`sed -n ''$n'p' ZZcorr.lst`
#        let n=n+1                                       #if stack seperately, this sentence should be deleted
#        corr2=`sed -n ''$n'p' ZZcorr.lst`                 #if stack seperately, this sentence should be deleted
	echo $corr1	
	for (( day=1 ; day < 2 ; day++ ))	
	do 
       	awk '{ printf"%s/STACK/'$corr1'_'$day'\n",$1}' DIR.dat >> lst1
#       	awk '{ printf"%s/STACK/'$corr2'_'$day'\n",$1}' DIR.dat >> lst1  #if stack seperately, this sentence should be deleted
	done
	$cod_dir/Line_stack  lst1 $out_dir
	if [ -e $out_dir/Line_stack.sac ] ; then
		mv $out_dir/Line_stack.sac $out_dir/$corr1
	fi
done

