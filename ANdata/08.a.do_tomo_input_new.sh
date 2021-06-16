#!/bin/bash

datadir=/mnt/ufs18/nodr/home/jieyaqi/africa_love/tomoI2/disp
#datadir=/mnt/ufs18/nodr/home/jieyaqi/threestation/curve
sacdir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/all_debias
sacdir=/mnt/ufs18/nodr/home/jieyaqi/africa_love/all_tt

cod_dir=~/code/JOINT_PACKAGE/bin

cd $datadir
ls  $sacdir/*.SAC| awk '{print "ln -s", $1, "."}' > ln.csh
csh ln.csh
cd $datadir
pwd
for disp in `ls *.TT.disp`
do
        #COR_MC04.MC18.ZZ.SAC.disp
        echo $disp
        fn=${disp%.disp}".SAC_s_2_DISP.1"
        echo $fn
        awk '{printf"%3d  %7.3f  %7.3f  %7.3f  %7.3f  %7.3f  %7.3f\n",NR,$1,$2,$3,$4,$5,$6}' $disp > $fn
        fn=${disp%.disp}".SAC_s_snr.txt"
        echo $fn
        awk '{printf"%7.3f  %7.3f\n",$2,$5}' $disp >$fn
done


cd ${datadir}
  rm -rf temp  5to50_file_s.dat
  ls *.TT.SAC > temp
  awk '{printf"%s_s\n",$1}' temp> 5to50_file_s.dat

  for per in 5 7 9 13 17 21 25 29 33 37 41 45 49 53 57 61 65
  do
	echo $per
	rm -rf tempinp
  	echo $per > tempinp
  	echo 5to50_file_s.dat >> tempinp
  	echo 5to50_SNR_${per}.dat >> tempinp
  	$cod_dir/find_rms_per_v2 < tempinp
  done


snr_cut=10
cd $datadir
  for per in 5 7 9 13 17 21 25 29 33 37 41 45 49 53 57 61 65
  do
	echo $per
	rm -rf tempinp
  	echo ${per} > tempinp
  	echo ${snr_cut} >> tempinp
  	echo 5to50_SNR_${per}.dat >> tempinp
  	echo tomo_phase_${snr_cut}_${per}.dat >> tempinp
  	$cod_dir/tomo_input_ph < tempinp
  done
