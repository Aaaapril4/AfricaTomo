#!/bin/bash
#seed_dir=$(pwd)
#echo $seed_dir
net=1C
sta=
seed_dir=/mnt/scratch/jieyaqi/$net
out_dir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/data/SAC
code_dir=~/code/JOINT_PAKAGE/bin

date
cd $seed_dir
#dataless=`ls|grep 'dataless'`
#responsef=`ls|grep 'mseed'|awk '{print$1}'|sed -n 1p`
if [ -e $seed_dir/sort$sta ]; then
	rm -rf  $seed_dir/sort$sta
fi
mkdir sort$sta
find ./ -maxdepth 1 -name ""$sta"???.*.mseed"| awk -F '/' '{print $2}' > LIST$sta
#ALT_RESPONSE_FILE=/mnt/home/jieyaqi/code/Africa_tomo/prepare_data/~/data/dataless/ZP.2007-2009.dataless
ALT_RESPONSE_FILE=/mnt/home/jieyaqi/code/Africa_tomo/prepare_data/~/data/dataless/"$net"."$sta".dataless
export ALT_RESPONSE_FILE
#seed=`ls|grep 'mseed'|awk '{print$1}'|sed -n 1p`
#seed=`ls $sta*.mseed | awk '{print$1}'|sed -n 1p`
#rdseed -f $seed -R -q $seed_dir/sort$sta
#rdseed -f $responsef -R -q $seed_dir/sort1

for seed in `awk '{ print $1}' LIST$sta`
do
    echo $seed/n
    sta=`echo $seed | awk -F '.' '{print $1}'`
    sta=${sta:0:end-3}
    #ALT_RESPONSE_FILE=/mnt/home/jieyaqi/code/Africa_tomo/prepare_data/~/data/dataless/"$net"."$sta".dataless
    #export ALT_RESPONSE_FILE
    rdseed -f $seed -R -q $seed_dir/sort$sta

    cp $seed ./sort$sta
	cd ./sort$sta
	mseed2sac $seed
sac<<EOF
r *.???.M.*.SAC
rmean;rtr;taper
TRANS FROM EVALRESP TO NONE freq 0.01 0.011 0.25 0.3
w over
q
EOF
printf "finish filtering\n"

	for file in `ls *.M.*.SAC`
	do
#		XD.AMBA..BHE.M.1994.304.081728.SAC
		year=`echo  $file | awk -F. '{print $6, $7}' | awk '{printf"'$code_dir'/year-month-day %d %d\n",$1,$2}'| sh | awk '{ printf"%s\n",$1}'`
        	month=`echo $file | awk -F. '{print $6, $7}' | awk '{printf"'$code_dir'/year-month-day %d %d\n",$1,$2}'| sh | awk '{ printf"%s\n",$2}'`
		day=`echo   $file | awk -F. '{print $6, $7}' | awk '{printf"'$code_dir'/year-month-day %d %d\n",$1,$2}'| sh | awk '{ printf"%s\n",$3}'`
		ymonth="$year""$month"
		echo $year  $ymonth
        	if [ ! -d  $out_dir/$ymonth/"$year"_"$month"_"$day"_0_0_0 ]; 
		then
			mkdir -p $out_dir/$ymonth/"$year"_"$month"_"$day"_0_0_0
		fi
		newfn=`echo $file | awk -F. '{printf"%s.%s.%s\n",$1,$2,$4}'`
		mv  $file   "$out_dir"/"$ymonth"/"$year"_"$month"_"$day"_0_0_0/$newfn	
	done
    rm $seed
	cd ..
	printf "finish moving\n"
done
printf "finish sort $net $sta\n"
rm -r $seed_dir/sort$sta
cd $seed_dir
cd ..
#zip -r -f ${net}.zip $seed_dir
date
