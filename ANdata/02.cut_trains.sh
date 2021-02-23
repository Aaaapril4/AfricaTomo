#!/bin/bash
dat_dir=/mnt/scratch/jieyaqi/east_africa/data/SAC
cod_dir=~/code/JOINT_PACKAGE/bin
cd $dat_dir

for ymonth in `ls -d 201[4-5]??`
do
	echo $ymonth
	cd $ymonth

	for day in `ls -d 201**`
	do
		echo $day
		cd $day
		ls *.*.??Z > tmp
			$cod_dir/cut_trains tmp 2000.0 85000.0
		ls *.*.??N > tmp
                	$cod_dir/cut_trains tmp 2000.0 85000.0
		ls *.*.??E > tmp
                	$cod_dir/cut_trains tmp 2000.0 85000.0
		cd ..
	done

	cd ..
done
