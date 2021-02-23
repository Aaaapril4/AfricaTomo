#!/bin/csh
set dat_dir = /mnt/ufs18/nodr/home/jieyaqi/eventzh/
set cod_dir = /mnt/home/jieyaqi/code/JOINT_PACKAGE/bin

cd $dat_dir
foreach sta ( `ls -d */` )
	set sta = `echo $sta | awk -F '/' '{print $1}'`
    echo $sta
    cd $sta
	set outfn = "$sta".zh.Z""
	echo "Outfn" $outfn
	# results from the positvie parts of the correlations
	rm -rf $outfn $sta".DAT1"
	ls $sta*.DAT1 > $outfn
	$cod_dir/do_analysis $outfn 2 40 $sta".DAT"

	cd ..
end
