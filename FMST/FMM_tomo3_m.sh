#!/bin/bash
let N=`cat station.txt | wc -l | awk '{print $1}'`
echo $N
for per in 5 7 9 13 17 21 25 29 33 37 41 45
do
    # 1573    -7.5094    31.0414    -9.2958    32.7712   3.295 0.000  1   COR_ZP.TUND.ZP.NAMA.ZZ.SAC                  52.30
	awk '{print $9}' file/out_phase.${per}.dat | awk -F_ '{print $2}' | awk -F. '{printf"%s.%s\n",$1, $2}' | sort -u > temp   # source network & station
	n=`cat temp | wc -l | awk '{print int($1)}'`
	echo $n > source.${per}.dat
    for (( i=1 ; i <= $n; i++ ))
	do
		stat=`awk '{if(NR=='$i') print $1}' temp`
		string=`awk '$1=="'$stat'" {print $0}' station.txt`
		echo $string | awk '{if(NR==1) printf"%10s  %10.4f  %10.4f\n",$1, $3, $2}' >> source.${per}.dat
	done

	awk '{print $9}' file/out_phase.${per}.dat | awk -F_ '{print $2}' | awk -F. '{printf"%s.%s\n",$3, $4}' | sort -u > temp
	n=`cat temp | wc -l | awk '{print int($1)}'`
	echo $n > receiver.${per}.dat
	for (( i=1 ; i <= $n; i++ ))
	do
		stat=`awk '{if(NR=='$i') print $1}' temp`
		string=`awk '$1=="'$stat'" {print $0}' station.txt`
		echo $string | awk '{if(NR==1) printf"%10s  %10.4f  %10.4f\n",$1, $3, $2}' >> receiver.${per}.dat
	done

done

for per in 5 7 9 13 17 21 25 29 33 37 41 45
do 
#	the following format should be changed as your data format
	tomo=file/tomo_phase_10_${per}.lst
	echo $tomo
 	rm -rf FMM_input"$per"
	NS=`cat source.${per}.dat | wc -l | awk '{print int($1)}'`
	NR=`cat receiver.${per}.dat | wc -l | awk '{print int($1)}'`
	echo period: $per
	echo source.${per}.dat  $NS
	echo receiver.${per}.dat  $NR
	for (( i=2; i<= $NS ;i++ ))
	do
		let flag=0
	        rm -rf temp
		sta1=`awk '{if(NR=='$i') print $1}' source.${per}.dat`
     
		for(( k=2; k<= $NR; k++))
		do
			sta2=`awk '{if(NR=='$k') print $1}' receiver.${per}.dat`
			if [[ $sta1 != $sta2 ]] ; then
                echo "$sta1.$sta2"
				string=`grep ".$sta1.$sta2.ZZ.SAC" $tomo``grep ".$sta2.$sta1.ZZ.SAC" $tomo`
				if [[ $string != "" ]] ; then
				     echo 1 $string 0.3 | awk '{printf"%d  %10.4f  0.3\n",$1, $4}' >>temp
					 echo 1 $string 0.3 | awk '{printf"%d  %10.4f  %.1f  %s\n",$1, $4, $NF, $3}' >> FMM_detail"$per"
				     let flag++ 
                else
				     echo 0 100 0.3 | awk '{printf"%d  %10.4f  0.3\n",$1, $2}'>>temp
                     echo 0 100 0.3 | awk '{printf"%d  %10.4f  0.3  NONE\n",$1, $2}'>>FMM_detail"$per"
				fi
			else
				echo 0 100 0.3 | awk '{printf"%d  %10.4f  0.3\n",$1, $2}'>>temp
                echo 0 100 0.3 | awk '{printf"%d  %10.4f  0.3  NONE\n",$1, $2}'>>FMM_detail"$per"
			fi
		done

		if (( flag >= 1 )); then
		     cat temp >> FMM_input"$per"
        else
		     echo $sta1
		fi
	done
    cat source.${per}.dat | awk '{if(NR==1) print $1}' > sources.${per}.dat
    cat source.${per}.dat | awk '{if(NR>1) print $2,$3}' >> sources.${per}.dat
    rm source.${per}.dat
    cat receiver.${per}.dat | awk '{if(NR==1) print $1}' > receivers.${per}.dat
    cat receiver.${per}.dat | awk '{if(NR>1) print $2,$3}' >> receivers.${per}.dat
    rm receiver.${per}.dat
done
