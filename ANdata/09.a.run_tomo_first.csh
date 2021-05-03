#!/bin/csh

limit datasize unlimited
limit stacksize unlimited

set work_dir = /mnt/ufs18/nodr/home/jieyaqi/east_africa/tomoI3/tomo
set code_dir = /mnt/home/jieyaqi/code/JOINT_PACKAGE/bin 


set cutoff = 10
set prename = Africa
set work = `pwd`

cd  $work_dir
set per0 = ( 5  7  9  13  17  21  25  29  33  37  41  45  49  53  57  61  65)
foreach id ( 1  2  3   4   5   6   7   8   9  10  11  12  13  14  15  16  17)
#foreach id ( 1 )

  set per = ${per0[$id]}

  mkdir $per

  set alpha0 = ( 3000 1000 850 750 600 650 600 500 500 400 400 300 250 200 100 )
  set sigma0 = ( 500  300  175 150 200 150 100 125 100 150 100 100 100 50  50 )
  #    id         1    2    3   4   5   6   7   8   9  10   11  12  13 14  15
  set beta0  = ( 200  100  40  10 )
  set data = ./tomo_phase_"$cutoff"_"$per".dat
  awk '{printf"%8d %10.5f  %10.5f  %10.5f  %10.5f  %10.5f  %5d   1\n",$1,$2,$3,$4,$5,$6,$8}' $data > INPUT.dat
#set sigma = 300
#set alpha = 800
  set sigma = ${sigma0[12]}
  set alpha = ${alpha0[12]}
  set beta = ${beta0[2]}
  set dir = "./"$per"/"$alpha"_"$sigma"_"$beta
  mkdir -p $dir
  set name = $prename"_"$alpha"_"$sigma
  $code_dir/tomo_sp_cu_s INPUT.dat $name $per << EOF
me
1
2
10000
4
5
-15  6  0.25
6
25  45  0.25
10
0.3
R
P
1
3
12
$alpha
$beta
$sigma
$sigma
19
25
26
x
v
go
EOF
  mv ${name}_${per}* $dir
  
end
