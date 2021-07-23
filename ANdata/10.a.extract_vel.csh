#!/bin/csh
set dat_dir = /mnt/ufs18/nodr/home/jieyaqi/east_africa/tomoI3/tomo/select_result  
set out_dir = /mnt/ufs18/nodr/home/jieyaqi/east_africa/tomoI3/curve
set cod_dir = ~/code/JOINT_PACKAGE/bin
set stalist = /mnt/home/jieyaqi/Documents/stationwll.lst
#sta lon lat
set prename = Africa

# dampling, smooting and alpha are the  alpha0, sigma0 and beta0 in Run_tomo_first.csh.
set dampling = 300
set smoothing = 100
set beta = 100

# The station.lst contains:
#    station_name longtitude latitude

if ( ! -d $out_dir ) mkdir $out_dir 

cd $dat_dir
rm -rf $out_dir/phase.dat
foreach per ( 5 9 13 17 21 25 29 33 37 41 45)
	set velfn = $dat_dir/$per/"$dampling"_"$smoothing"_"$beta"/"$prename"_"$dampling"_"$smoothing"_"$per".1
	echo $velfn
	awk '{print $1,$2,$3}' $velfn > $dat_dir/data
	$cod_dir/extract_vel $stalist $dat_dir/data $per $out_dir/phase.dat
	rm -rf data
end  

set num = `cat $stalist | wc | awk '{print $1}'`
@ j = 1
while( $j <= $num )
# 	set sta = `sed -n '$j,1p' $cod_dir/station.lst | awk '{print $1}'`
 	set sta = `sed -n "$j,1p" $stalist | awk '{print $1}'`
	echo $sta $j
	awk '$1=="'$sta'"' $out_dir/phase.dat > $out_dir/$sta
	#row=`awk '{print $1}' phase.dat | grep -n 104 | awk -F ':' '{print $1}'`

    @ j ++
end 
