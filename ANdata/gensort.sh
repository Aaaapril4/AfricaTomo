net=YQ
datadir=/mnt/scratch/jieyaqi/$net
file=01.sort_data.sh

for stac in `ls $datadir | awk -F '.' '{print $1}' | uniq`
do
    echo $sta
    sta=${stac:0:-3}
    outf=01.sort_data"$net""$sta".sh
    cp $file $outf
    sed -i "4c net="$net"" $outf
    sed -i "5c sta="$sta"" $outf
done

