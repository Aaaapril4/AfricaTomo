#!/bin/csh
set dat_dir = /mnt/ufs18/nodr/home/jieyaqi/east_africa/stationzh/
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
	ls COR_*.DAT1 > $outfn
	$cod_dir/do_analysis $outfn 2 40 $sta".DAT1"

	# results from the negative parts of the correlations
	rm -rf $outfn $sta".DAT2"
	ls COR_*.DAT2 > $outfn
        $cod_dir/do_analysis $outfn 2 40 $sta".DAT2"
	
	# results from both positvie and negative parts of the correlations
	rm -rf $outfn $sta".DAT" 
	ls COR_*.DAT? > $outfn
	$cod_dir/do_analysis $outfn 2 40 $sta".DAT"

	#$cod_dir/plot-zh-dat.sh $sta".DAT" $sta".DAT1" $sta".DAT2" $sta".DAT.ps"
	cd ..
end
