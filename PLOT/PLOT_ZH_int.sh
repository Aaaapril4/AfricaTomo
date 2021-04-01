#!/bin/bash
gmt gmtset MAP_FRAME_TYPE plain
gmt gmtset FONT_LABEL 16
gmt gmtset FONT_ANNOT_PRIMARY 14p,Times-Roman
gmt gmtset PS_MEDIA a2
gmt gmtset MAP_TITLE_OFFSET 1.5p
gmt gmtset MAP_TICK_LENGTH_PRIMARY 3p
gmt gmtset MAP_TICK_LENGTH_SECONDARY 2p

R=25/40/-15/4
J=m0.2i
PS=~/Documents/plot/tomo_zhev.ps

gmt grdcut  @earth_relief_03m.grd  -Gcut.grd  -R$R -V
gmt grdgradient cut.grd -A45 -Nt -Gcut.grd.gradient -V


# period you should give your own
per=( 7   9  13  17  21  25  29  33  37  41  45  49  53 )
#id   0  1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18
CPT=cptfile.cpt
gmt makecpt -Cpanoply -T0.6/2.1/0.3 -D -Ic -Z > cptfile.cpt
for (( i=0; i<=6; i++ ))
#for i=0
do

    echo ${per[$i]}
    INPUT_FILE=/mnt/ufs18/nodr/home/jieyaqi/east_africa/zhcurve/ZHratio."${per[$i]}".dat
    echo $INPUT_FILE
    
	if  (( $i ==  0  )) ; then
       XOFF=1i
       YOFF=12i
        gmt grdimage cut.grd -R -J$J  -Bx4f2  -By4f2 -BWseN -Icut.grd.gradient -Cgray -X$XOFF -Y$YOFF -K  > $PS

    elif (( $i == 4 )) || (( $i == 8 )) || (( $i == 12 )) || (( $i == 16 )) ; then
       XOFF=-9.3i
       YOFF=-5.3i
        gmt grdimage -R -J$J cut.grd -Bx4f2  -By4f2 -BwseN -Icut.grd.gradient -X$XOFF -Y$YOFF -Cgray -K -O >> $PS  
 
    else
       XOFF=3.1i
       YOFF=0i
        gmt grdimage -R -J$J cut.grd -Bx4f2  -By4f2 -BwseN -Icut.grd.gradient -Cgray -X$XOFF -Y$YOFF -K -O>> $PS

    fi

	gmt pscoast -R$R -J$J -N2/1p -A500 -W1p -O -K >> $PS


    awk '$4=="AN"{print $1,$2,$3}' $INPUT_FILE |
    gmt psxy -R$R -J$J -Ss10p -Wblack -C$CPT -K -O >> $PS
    
    awk '$4=="EQ"{print $1,$2,$3}' $INPUT_FILE |
    gmt psxy -R$R -J$J -Sd10p -Wblack -C$CPT -K -O >> $PS
    
    awk '$4=="both"{print $1,$2,$3}' $INPUT_FILE |
    gmt psxy -R$R -J$J -Sg10p -Wblack -C$CPT -K -O >> $PS
    
    echo 38 -14 'T='${per[$i]}'s' | gmt pstext -J$J -R$R -F+f17p,white  -O -K >> $PS

    DSCALE=1.5i/-0.12i/2.6i/0.1ih
    gmt psscale -C$CPT -D$DSCALE  -O -K -X0 -B+l'Z/H' >> $PS
done


gmt psconvert -A -P -Tf $PS
rm $PS
rm cptfile.cpt
rm cut.grd
rm cut.grd.gradient
