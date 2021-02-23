#!/bin/bash
dat_dir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/all_obs_debias
#dat_dir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/data_obs/STACK_doubleSTACK/TF_PWS
code_dir=~/code/JOINT_PACKAGE/bin
ref_vel=~/code/JOINT_PACKAGE/myref_vel.dat
out_dir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/tomoI3obs/disp

# result2: central period, observed period, group vel, phase velocity, amplitude, snr, maximum half width
# output: central period, observed period, group vel, phase velocity, snr, amplitude, srclat, srclon, reclat, reclon
cd $dat_dir
for sacfn in `ls *.SAC`
#for sacfn in `ls line_stack_1.SAC`
do
	echo $sacfn
	str=`pwd`	
	ls $sacfn>lstI2
	$code_dir/BP_stack -B2 -E100 -I2 -F lstI2 -R $ref_vel -P-1 -W1 -D0 
	disp=${sacfn%.SAC}.disp
	mv Second_extract.dsp  $out_dir/$disp
done
