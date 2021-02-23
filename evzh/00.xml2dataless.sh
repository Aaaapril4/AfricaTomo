#path=/mnt/ufs18/nodr/home/jieyaqi/earthquake/event_data22/stations
path=/mnt/home/jieyaqi/code/Africa_tomo/prepare_data/~/data/stations
codedir=/mnt/home/jieyaqi/code
outdir=/mnt/home/jieyaqi/code/Africa_tomo/prepare_data/~/data/dataless
#outdir=/mnt/ufs18/nodr/home/jieyaqi/earthquake/dataless
cd $codedir
mkdir $outdir
for xml in `ls $path/*.xml`
do
    echo $xml
    sta=`echo $xml | awk -F '/' '{print $NF}' | awk -F '.' '{print $1 "." $2}'`
    java -jar stationxml-seed-converter-2.1.0.jar --input $xml --output $outdir/$sta.dataless
done
