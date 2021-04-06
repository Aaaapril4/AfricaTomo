#!/bin/bash
# a script to plot profile
# usage: sh PLOT_profile.sh startlon startlat endlon endlat (base on) lat/lon

gmt gmtset MAP_FRAME_WIDTH 0.5p
gmt gmtset MAP_FRAME_TYPE plain
gmt gmtset FONT_LABEL 16
gmt gmtset FONT_ANNOT_PRIMARY 14p,Times-Roman
gmt gmtset PS_MEDIA a2
gmt gmtset MAP_TITLE_OFFSET 1.5p
gmt gmtset MAP_TICK_LENGTH_PRIMARY 4p

minus()
{
    echo $1 - $2 | bc -l
}

multi()
{
    echo $1 \* $2 | bc -l
}

abs() 
{ 
    # [[ $[ $@ ] -lt 0 ]] && echo "$[ ($@) * -1 ]" || echo "$[ $@ ]"
    (( $(echo "`minus $@` < 0" | bc -l) )) && echo "`multi $(minus $@) -1`" || echo "`minus $@`"
}

avalue()
{
    startx=$1
    starty=$2
    endx=$3
    endy=$4
}

plot_on_topo()
{
    # -S # -W # -G
    python3 staclose.py sta temp lined 30 > staXY
    if [ "$base" == "lon" ]
    then
        awk '{print $3, -700}' staXY | gmt psxy -R$R1 -J$J1 $1 $2 $3 -O -K >> $PS
    else
        awk '{print $4, -700}' staXY | gmt psxy -R$R1 -J$J1 $1 $2 $3 -O -K >> $PS
    fi
}

londif=`abs $1 $3`
latdif=`abs $2 $4`
tag="norm"
if (( $(echo "$londif < $latdif" | bc -l) ))
then
    base="lat"
    if (( $(echo "$2 < $4" | bc -l) )); then
    # if [ $2 -lt $4 ]; then
        avalue $2 $1 $4 $3
    else
        avalue $4 $3 $2 $1
        tag="inv"
    fi
else
    base="lon"
    if (( $(echo "$1 < $3" | bc -l) )); then
        avalue $1 $2 $3 $4
    else
        avalue $3 $4 $1 $2
        tag="inv"
    fi
fi

# init
R=25/42/-15/4
R1=$startx/$endx/-1000/3000
R2=$startx/$endx/0/4
R3=$startx/$endx/0/200
PS=~/Documents/plot/profile/profile"$1"_"$2"_"$3"_"$4".ps
if [ $tag == "norm" ]
then
    J1=x1i/0.00015i
    J2=x1i/-0.2i
    J3=x1i/-0.01i
else
    J1=x-1i/0.00015i
    J2=x-1i/-0.2i
    J3=x-1i/-0.01i
fi

datap=/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion
infof=~/Documents/invinfo.txt
volcanof=~/Documents/volcano_africa.txt
seisf=~/Documents/seismicity.txt 

gmt project -C$1/$2 -E$3/$4 -G0.025 > lined



# topography
gmt grdcut @earth_relief_03m.grd -R$R -Gtopo.grd
gmt grdtrack lined -Gtopo.grd | awk '{print $1, $2, $4}' > tomolined.dat
awk '{if(NR==1) print $1, $2, -1000}' tomolined.dat > temp
cat tomolined.dat >> temp 
tail -n1 tomolined.dat | awk '{print $1, $2, -1000}' >> temp
mv temp tomolined.dat

gmt psbasemap -R$R1 -J$J1 -By2000 -BWsen -K -X1i -Y5i > $PS
if [ "$base" == "lon" ]
then
    awk '{print $1,$3}' tomolined.dat | gmt psxy -R$R1 -J$J1 -Bwsen -W1p -Ggrey  -K -O -X0 -Y0 >> $PS
else
    awk '{print $2,$3}' tomolined.dat | gmt psxy -R$R1 -J$J1 -Bwsen -W1p -Ggrey  -K -O -X0 -Y0 >> $PS
fi
rm topo.grd
rm tomolined.dat

# plot stations and grids
awk '$3=="ph" || $3=="grid" {print $1, $2}' $infof > temp
plot_on_topo -Sd5p -W0.7p,black 

awk '$3=="phzh" || $3=="phzhwf" || $3=="phwf"{print $1, $2}' $infof > temp
plot_on_topo -Si5p -Wblack -Gblack

awk '{print $1, $2}' $volcanof > temp
plot_on_topo -Si5p -Wblack -Gred


# generate grdfile for line
for dep in {0..10}
do
    gmt grdtrack lined -G$datap/dep.$dep.grd -T0.1 | awk dep=$dep'{print $1, $2, dep, $4}' >> profile.grd
done
for dep in {15..200..5} 
do
    gmt grdtrack lined -G$datap/dep.$dep.grd -T0.1 | awk dep=$dep'{print $1, $2, dep, $4}' >> profile.grd
done
for dep in 0.40 0.60 0.80 1.5 
do
    gmt grdtrack lined -G$datap/dep.$dep.grd -T0.1 | awk dep=$dep'{print $1, $2, dep, $4}' >> profile.grd
done

gmt grdtrack lined -G$datap/sed.grd -T0.1 | awk '{print $1, $2, $4}' > profilesed.grd
gmt grdtrack lined -G$datap/moho.grd -T0.1 | awk '{print $1, $2, $4}' > profilemoho.grd


# 0-4km
plotshallow()
{
    gmt psbasemap -R$R2 -J$J2 -Bx1f0.5 -By2f1 -BWsen -P -K -O -X0i -Y-0.8i >> $PS
    awk x=$1'{print $(x),$3,$4}' profile.grd | gmt blockmean -R$R2 -I0.1/0.5 > out.dat
    awk '{print $1, $2, $3}' out.dat | gmt surface  -R$R2 -I0.05/0.1  -Ginput.grd -T0.3 -C0.01 
    gmt makecpt -Croma -T1.4/3.8/0.6 -D -Z > cptfile.cpt
    gmt grdimage  input.grd  -R -J$J2  -BWSen -Ccptfile.cpt -P -O -K >> $PS
    gmt grdcontour input.grd -R -J -C0.5 -A1+f14p -W0.5p,black,dashed -O -K >> $PS
    awk x=$1'{print $(x),$3}' profilesed.grd | gmt psxy -R -J -Bwsen -W1p -K -O >> $PS
    DSCALE=1.5i/-2.4i/2.5i/0.2ih
    gmt psscale -Ccptfile.cpt -D$DSCALE -Bx+l'Shallow Vs (km/s)' -O -K -X0 >> $PS
}


# 0-200km
plotdeep()
{
    gmt psbasemap -R$R3 -J$J3 -By30f5 -Bx1f0.5 -BWSen -P -K -O -X0i -Y-2.3i >> $PS
    awk x=$1'{print $(x),$3,$4}' profile.grd | gmt blockmean -R$R3 -I0.1/2 > out.dat

    awk '{print $1, $2, $3}' out.dat | gmt surface  -R -I0.05/1  -Ginput.grd -T0.3 -C0.1 
    gmt makecpt -Croma -T3.1/4.7/0.4 -D -Z > cptfile.cpt
    gmt grdimage  input.grd  -R -J  -BWSen -Ccptfile.cpt -P -O -K >> $PS
    gmt grdcontour input.grd -R -J -L2/5 -C0.2 -A0.4+f14p -W0.5p,black,dashed -O -K >> $PS
    awk x=$1'{print $(x),$3}' profilemoho.grd | gmt psxy -R -J -Bwsen -W1p -K -O >> $PS

    awk '{print $0}' $seisf > temp
    python3 staclose.py seis temp lined 30 > staXY
    col=`echo $1 + 2 | bc -l`
    awk x=$col'{print $(x), $6, $8}' staXY | gmt psxy -R$R3 -J$J3 -Sc -Wwhite -Gwhite -O -K >> $PS

    DSCALE=5i/-0.5i/2.5i/0.2ih
    gmt psscale -Ccptfile.cpt -D$DSCALE -Bx+l'Deep Vs (km/s)' -O -X0 >> $PS
}

if [ "$base" == "lon" ]
then
    plotshallow 1
    plotdeep 1
else
    plotshallow 2
    plotdeep 2
fi

gmt psconvert -A -P -Tf $PS

rm $PS
rm out.dat
rm profile.grd
rm lined temp
rm cptfile.cpt
rm input.grd
