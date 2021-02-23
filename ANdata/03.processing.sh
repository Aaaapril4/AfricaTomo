#!/bin/bash
dat_dir=/mnt/scratch/jieyaqi/east_africa/data/SAC
cod_dir=~/code/JOINT_PACKAGE/bin

date
cd $dat_dir
for ymonth in `ls -d 201*/`
do
	cd $ymonth
	echo $ymonth
	for day in `ls -d 201*`
	do
		cd $day
		echo $day
		pwd
		if [ -e temp ]; then
			rm -rf temp
		fi
		if [ -e Ztemp ]; then
			rm -rf Ztemp
		fi
		for Z in `ls *.??Z.SAC`
		do 
			#for A13A.LHZ.SAC,the fllowing sentence is ..
			#for others, the fllowing sentence may need change
			N=${Z/LHZ/LHN}
			E=${Z/LHZ/LHE}
			echo $Z  $N   $E
			if [ -e $N ] && [ -e $E ]; then
				ls $Z >> temp
			else
				ls $Z >> Ztemp
			fi
		done
		if [ -e temp ]; then
#			$cod_dir/process  -F temp -b 0.07 -e 8.0 -T 64 -S
			$cod_dir/process  -F temp -b 4 -e  100  -T 64		
		fi
		if [ -e Ztemp ]; then
			$cod_dir/process -F Ztemp -b 4 -e 100 -T 64 -S -Z
		fi
		rm temp
		rm Ztemp
		cd ..
	done
	cd ..
done
date
