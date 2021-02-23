#!/bin/bash
# to extract waveform from mseed and remove mean, trend
seed_dir=/mnt/ufs18/nodr/home/jieyaqi/earthquake/event_data22/waveforms
out_dir=/mnt/ufs18/nodr/home/jieyaqi/earthquake/SAC
code_dir=/mnt/home/jieyaqi/code/JOINT_PAKAGE/bin
res_dir=/mnt/ufs18/nodr/home/jieyaqi/earthquake/dataless
unsort=/mnt/ufs18/nodr/home/jieyaqi/earthquake/unsort
date
cd $seed_dir
if [ -e $seed_dir/sort1 ]; then
	rm -rf  $seed_dir/sort1
fi
mkdir sort1

if [ ! -e $out_dir ]; then
	mkdir $out_dir
fi

#find ./ -name "*.mseed" | awk -F '/' '{print $2}' > LIST1
cat $unsort > LIST1
for seed in `awk '{ print $1}' LIST1`
do
	dataless=`echo $seed | awk -F '.' '{print $1 "." $2}'`.dataless
	echo $dataless\n
	ALT_RESPONSE_FILE=$res_dir/$dataless
	export ALT_RESPONSE_FILE
	rdseed -f $seed -R -q $seed_dir/sort1
	echo $seed\n
	cp $seed $seed_dir/sort1
	cd ./sort1
	mseed2sac $seed
	rm $seed
sac<<EOF
r *.?H?.?.*.SAC
rmean;rtr;taper
TRANS FROM EVALRESP TO NONE freq 0.01 0.011 0.25 0.3
w over
q
EOF
	printf "finish filtering"
	mv *.SAC $out_dir
	cd ..
done
printf "finish sort $seed_dir"
date
