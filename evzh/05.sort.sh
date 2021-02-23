path=/mnt/ufs18/nodr/home/jieyaqi/earthquake/SAC/rotate
outdir=/mnt/ufs18/nodr/home/jieyaqi/eventzh

cd $path
if [ ! -e $outdir ]
then
    mkdir $outdir
fi

for sac in `ls ./`
do
    sta=`echo $sac | awk -F '.' '{print $1 "." $2}'`
    if [ ! -e $outdir/$sta ]
    then
        echo $sta
        mkdir $outdir/$sta
    fi
    cp $sac $outdir/$sta
done