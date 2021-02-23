#!/bin/csh
set dat_dir = /mnt/ufs18/nodr/home/jieyaqi/east_africa/data/SAC
set cod_dir = ~/code/JOINT_PACKAGE/bin
cd $dat_dir
	
#foreach ymonth ( 2000??? 2001??? 2002???)
date
#foreach ymonth ( 1994?? 1995?? )
foreach ymonth ( 199??? )
    echo $ymonth
	cd $ymonth
    
	if( ! -d STACK ) then
		mkdir STACK
	endif
	#2001_11_04_0_0_0
	ls -d ????_*_??_0_0_0 | awk -F_ '{ if(NR==1) print $1,$2}' > newsta.lst
        ls */*.*.L?Z.SAC.am | awk -F"/" '{print $2}' | awk -F. '{printf"%s.%s\n", $1,$2}' | sort -u >> newsta.lst
#                                     correlating componets   npts of NCFs    stations for calculation correlations
	$cod_dir/correlate newsta.lst        LHZ LHZ              4096              newsta.lst 
	$cod_dir/correlate newsta.lst        LHZ LHN              4096              newsta.lst 
	$cod_dir/correlate newsta.lst        LHZ LHE              4096              newsta.lst 
	$cod_dir/correlate newsta.lst        LHN LHZ              4096              newsta.lst 
	$cod_dir/correlate newsta.lst        LHN LHN              4096              newsta.lst 
	$cod_dir/correlate newsta.lst        LHN LHE              4096              newsta.lst 
	$cod_dir/correlate newsta.lst        LHE LHZ              4096              newsta.lst 
	$cod_dir/correlate newsta.lst        LHE LHN              4096              newsta.lst 
	$cod_dir/correlate newsta.lst        LHE LHE              4096              newsta.lst 
        cd .. 
end
date	
