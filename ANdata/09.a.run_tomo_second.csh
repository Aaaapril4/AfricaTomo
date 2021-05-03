#!/bin/csh
## Pick data
limit datasize 1000000; limit stacksize 120000

set work = /mnt/ufs18/nodr/home/jieyaqi/east_africa/tomoI3/tomo
set code_dir = /mnt/home/jieyaqi/code/JOINT_PACKAGE/bin
set out_dir = "$work"/select_result 
set numwave = 1.5
set prename = Africa
mkdir $out_dir
foreach per (5 7 9 13 17 21 25 29 33 37 41 45 49 53 57 61 65)
  set alpha0 = ( 3000 1000 850 750 600 650 600 500 500 400 400 300 250 200 100 50 )
  set sigma0 = ( 500  300  175 150 200 150 100 125 100 150 100 100 100 50  50  25 )
  #               1     2    3   4   5   6   7   8   9  10  11  12  13  14 15
  set beta0  = ( 200  100  40  10 )
  set sigma = ${sigma0[12]}
  set alpha = ${alpha0[12]}
  set beta = ${beta0[2]}

  set name = $prename"_"$alpha"_"$sigma
  set dir = $per"/"$alpha"_"$sigma"_"$beta
  cd $work/$dir
  echo `pwd`
  foreach cutper ( 8 ) #4 5 6 7 8 )
    echo $cutper $numwave > tempinp
    echo $per >> tempinp
    echo ${name}_${per}.resid >> tempinp
    echo dt_${name}_${per}_${cutper}.dat  >> tempinp
    $code_dir/find_bad_dt_name < tempinp
    cp dt_${name}_${per}_${cutper}.dat $out_dir
#    rm tempinp
  end
end
