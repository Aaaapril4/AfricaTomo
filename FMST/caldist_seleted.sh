#!/bin/bash
# This is a very simple script to calculate the distance for the accpeted raypaths.
for per in 5 7 9 13 17 21 25 29 33 37 41 45
do
	tomofn=file/tomo_phase_10_"$per".dat   # the tomo file used for the first step of tomography using Barmin's code
    #dt_Africa_200_100_4_8.dat
    stomof=file/sel_phase_"$per".dat   # after the first tomography, the big anomalies are removed.
	outfn=file/out_phase."$per".dat  # The distance of each path are stored in this file and will be used furhter.
	N=`cat $tomofn | wc -l | awk '{print int($1)}'`
	n=`cat $stomof | wc -l | awk '{print int($1)}'`
	echo $per $N $n
	rm -rf $outfn
	for(( i=1;i<=$n; i++ ))
	do
		num=`awk '{if(NR=='$i') print $1}' $stomof`
		awk '{if($1=='$num') print $0}' $tomofn >>  $outfn
	done

	FMM=file/tomo_phase_10_"$per".lst
	rm -rf $FMM
	for (( i=1 ; i<= $n ; i++ ))
	do
		string=`awk '{if(NR=='$i') print $0}' $outfn`
       	dist=`echo $string | awk '{printf"./cal_dist %f %f %f %f\n", $3,$2,$5,$4}' | sh` # cal_dist is a simple C code
		tt=`echo $string $dist | awk '{print $11/$6}'`
		echo $i $string  $tt $dist | awk '{printf"%5d  %s   %10.3f\n", $1, $10, $12}' >> $FMM
	done
done
