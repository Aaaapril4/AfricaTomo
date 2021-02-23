path=/mnt/ufs18/nodr/home/jieyaqi/east_africa/data/SAC
file=04.correlate.csh

for ym in `ls $path`
do
    echo $ym
    outf=04.correlate"$ym".csh
    cp $file $outf
    sed -i "9c foreach ymonth ( "$ym" )" $outf
done

