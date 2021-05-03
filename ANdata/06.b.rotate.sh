#!/bin/sh
out_dir=/mnt/scratch/jieyaqi/africa/RTZ
cod_dir=~/code/JOINT_PAKAGE/bin

for com in EE EN EZ NN NE NZ ZZ ZE ZN
do
     echo $com
     dat_dir=/mnt/scratch/jieyaqi/africa/$com/TF_PWS
     cd $dat_dir

     if [ ! -d $out_dir ] ; then
          mkdir -p $out_dir
     fi


     # sort the single side NCFs by the reciver and source station.
     #COR_432A.532A.EN.SAC
     echo "Sorting the NCFs"
     for NCF in `ls *.Z?.SAC`
     do
          STA1=`echo $NCF | awk -F_ '{print $2}' | awk -F. '{printf"%s.%s\n", $1,$2}'`
          STA2=`echo $NCF | awk -F. '{printf"%s.%s\n", $3,$4}'`
          if [ ! -d $out_dir/$STA1 ] ; then
               mkdir  $out_dir/$STA1
          fi

          cp $NCF $out_dir/$STA1
          if [ ! -d $out_dir/$STA2 ] ; then
                    mkdir  $out_dir/$STA2
          fi
          cp $NCF $out_dir/$STA2
     done

     for NCF in `ls *.N?.SAC`
     do
          STA1=`echo $NCF | awk -F_ '{print $2}' | awk -F. '{printf"%s.%s\n", $1,$2}'`
          STA2=`echo $NCF | awk -F. '{printf"%s.%s\n", $3,$4}'`
          if [ ! -d $out_dir/$STA1 ] ; then
                    mkdir  $out_dir/$STA1
          fi

          cp $NCF $out_dir/$STA1
          if [ ! -d $out_dir/$STA2 ] ; then
                    mkdir  $out_dir/$STA2
          fi
          cp $NCF $out_dir/$STA2
     done

     for NCF in `ls *.E?.SAC`
     do
          STA1=`echo $NCF | awk -F_ '{print $2}' | awk -F. '{printf"%s.%s\n", $1,$2}'`
          STA2=`echo $NCF | awk -F. '{printf"%s.%s\n", $3,$4}'`
          if [ ! -d $out_dir/$STA1 ] ; then
                    mkdir  $out_dir/$STA1
          fi

          cp $NCF $out_dir/$STA1
          if [ ! -d $out_dir/$STA2 ] ; then
                    mkdir  $out_dir/$STA2
          fi
          cp $NCF $out_dir/$STA2
     done

     echo "finish sort" $com
done

# Rotate the ZNE directions to the ZRT directions
cd $out_dir

for station in `ls -d *.*/`
do
     echo $station
     cd $station
     
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

     cd ..
done
