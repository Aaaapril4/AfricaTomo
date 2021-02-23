#!/bin/bash
code_dir=/mnt/home/jieyaqi/code/JOINT_PACKAGE/bin
data_dir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/waveform

cd $data_dir
for stat in `ls -d */ | awk -F '/' '{print $1}'`
do
	pwd
    echo $stat
	cd $stat
	ls *.BHZ |  awk -F. '{printf"%s.%s.%s.%s.%s\n",$1, $2, $3, $4, $5}' > stack_quality
	$code_dir/Waveform_stack -F stack_quality -Z BHZ -R BHR -b 0.1 -e 1 -T10 -C10 -W15
	cd ..
done
