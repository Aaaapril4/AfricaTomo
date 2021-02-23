path=/mnt/ufs18/nodr/home/jieyaqi/east_africa/data/SAC
file=05.a.tf_PWSZZ.sh

for com in ZE ZN NN NE NZ EE EZ EN
do
    echo $com
    outf=${file/ZZ/$com}
    cp $file $outf
    sed -i "2c com=$com" $outf
done

