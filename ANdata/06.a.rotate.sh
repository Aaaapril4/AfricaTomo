#!/bin/sh
dat_dir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/all_obs
#dat_dir=/mnt/ufs18/nodr/home/jieyaqi/east_africa/data_obs/STACK_doubleSTACK/TF_PWS
cod_dir=~/code/JOINT_PAKAGE/bin

cd $dat_dir
#COR_432A.532A.EN.SAC

       for ZZ in `ls *.ZZ.SAC`
       do
            string=${ZZ%.ZZ.SAC}
	    EE=${ZZ%.ZZ.SAC}".EE.SAC"
	    EN=${ZZ%.ZZ.SAC}".EN.SAC"
	    EZ=${ZZ%.ZZ.SAC}".EZ.SAC"
	    NE=${ZZ%.ZZ.SAC}".NE.SAC"
	    NN=${ZZ%.ZZ.SAC}".NN.SAC"
	    NZ=${ZZ%.ZZ.SAC}".NZ.SAC"
	    ZE=${ZZ%.ZZ.SAC}".ZE.SAC"
	    ZN=${ZZ%.ZZ.SAC}".ZN.SAC"
	    echo $string  $EE
            if [[ -e $EE && -e $EN && -e $EZ && -e $NE && -e $NN && -e $NZ && -e $ZE && -e $ZN ]] ; then
			
sac << EOF
r $ZZ $EE $EN $EZ $NE $NN $NZ $ZE $ZN
w over
q
EOF
	             $cod_dir/rotate $EE $EN $EZ $NE $NN $NZ $ZE $ZN $string
	    fi
       done
