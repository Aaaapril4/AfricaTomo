#!/bin/sh
dat_dir=/mnt/scratch/jieyaqi/africa
#dat_dir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/data_obs/STACK_doubleSTACK/TF_PWS
cod_dir=~/code/JOINT_PACKAGE/bin

cd $dat_dir
#COR_432A.532A.EN.SAC

       for ZZ in `ls ZZ/LINE_STACK/*.ZZ.SAC`
       do
            nm=`echo $ZZ | awk -F '/' '{print $3}'`
            string=${nm%.ZZ.SAC}
	    EE=EE/LINE_STACK/$string".EE.SAC"
	    EN=EN/LINE_STACK/$string".EN.SAC"
	    EZ=EZ/LINE_STACK/$string".EZ.SAC"
	    NE=NE/LINE_STACK/$string".NE.SAC"
	    NN=NN/LINE_STACK/$string".NN.SAC"
	    NZ=NZ/LINE_STACK/$string".NZ.SAC"
	    ZE=ZE/LINE_STACK/$string".ZE.SAC"
	    ZN=ZN/LINE_STACK/$string".ZN.SAC"
	    echo $string  $EE
        if [[ -e $EE && -e $EN && -e $EZ && -e $NE && -e $NN && -e $NZ && -e $ZE && -e $ZN ]] ; then
		
sac << EOF
r $ZZ $EE $EN $EZ $NE $NN $NZ $ZE $ZN
w over
q
EOF
	             $cod_dir/rotate $EE $EN $EZ $NE $NN $NZ $ZE $ZN $string
	   mv *.SAC RTZ/
       fi
       done
