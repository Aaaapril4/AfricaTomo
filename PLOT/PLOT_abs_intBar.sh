#!/bin/bash
gmt gmtset MAP_FRAME_TYPE plain
gmt gmtset FONT_LABEL 18p,Times-Roman
gmt gmtset FONT_ANNOT_PRIMARY 17p,Times-Roman
gmt gmtset PS_MEDIA a2
gmt gmtset MAP_TITLE_OFFSET 1.5p
gmt gmtset MAP_TICK_LENGTH_PRIMARY 3p
gmt gmtset MAP_TICK_LENGTH_SECONDARY 2p
para=300_100

R=25/40/-15/4
J=m0.2i
PS=~/Documents/plot/tomo_abBarminI3$para.ps

# period you should give your own
per=( 5  7   9  13  17  21  25  29  33  37  41  45  49  53  57  61  65 )
#id   0  1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18
CPT=cptfile.cpt

for (( i=0; i<=11; i++ ))
do

    echo ${per[$i]}
	INPUT_FILE=/mnt/ufs18/nodr/home/jieyaqi/east_africa/tomoI3/tomo/select_result/"${per[$i]}"/"$para"_100/Africa_"$para"_"${per[$i]}".1_%_
    awk '{print $1,$2,$3}' $INPUT_FILE |gmt surface  -R$R -I0.2  -Ginput.grd -T0.5
    gmt grdsample input.grd -Ginput.grd2  -I0.1 -R$R -V

    gmt makecpt -Cvik -T-12/12/4 -Ic -D -Z > $CPT

    # mask the area
    MASK_FILE=/mnt/ufs18/nodr/home/jieyaqi/east_africa/tomoI3/tomo/select_result/"${per[$i]}"/"$para"_100/Africa_"$para"_"${per[$i]}".azi
    awk '$3>2{print $1, $2, $3}' $MASK_FILE > MASK.xyz


	if  (( $i ==  0  )) ; then
       XOFF=1i
       YOFF=12i
       gmt psbasemap -R$R -J$J -B4f1 -BWseN -K -X$XOFF -Y$YOFF > $PS
       gmt grdimage  input.grd2  -R -J$J -B -C$CPT -O -K -t50 >> $PS
       gmt psclip -R$R -J$J ~/Documents/mask.xy -BWseN -S10 -K -O -V >> $PS
       gmt grdimage  input.grd2  -R -J$J -B -C$CPT -O -K >> $PS
       gmt psclip -C -O -K >> $PS

    elif (( $i == 4 )) || (( $i == 8 )) || (( $i == 12 )) || (( $i == 16 )) ; then
       XOFF=-9.3i
       YOFF=-5.3i
       gmt psbasemap -R$R -J$J -B4f1 -BWseN -K -O -X$XOFF -Y$YOFF >> $PS
       gmt grdimage  input.grd2  -R -J$J  -B -C$CPT -K  -O -t50 >> $PS
       gmt psclip -R$R -J$J ~/Documents/mask.xy -BWseN -S10 -K -O -V >> $PS
	   gmt grdimage  input.grd2  -R -J$J  -B -C$CPT -K  -O >> $PS
       gmt psclip -C -O -K >> $PS

    else
       XOFF=3.1i
       YOFF=0i
       gmt psbasemap -R$R -J$J -B4f1 -BwseN -K -O -X$XOFF -Y$YOFF >> $PS
       gmt grdimage  input.grd2  -R -J$J  -B -C$CPT -K  -O -t50 >> $PS
       gmt psclip -R$R -J$J ~/Documents/mask.xy -BWseN -S10 -K -O -V >> $PS
	   gmt grdimage  input.grd2  -R -J$J  -B -C$CPT -K  -O  >> $PS
       gmt psclip -C -O -K >> $PS
    fi

	gmt pscoast -R$R -J$J -A1000 -W0.5p,grey -O -K >> $PS
    gmt psxy ~/Documents/earifts.xy -R$R -J$J -W1p,black -O -K >> $PS
    gmt psxy ~/Documents/tzcraton.xy -R$R -J$J -W1p,black -O -K>> $PS
    echo 38 -14 'T: '${per[$i]}'s' | gmt pstext -J$J -R$R -F+f18p -O -K >> $PS
    avg=`awk '$1=='${per[$i]}' {print $2}' /mnt/ufs18/nodr/home/jieyaqi/east_africa/tomoI3obs/tomo/velocity$para.dat`
    echo 31.5 3 'Average: '$avg' km/s' | gmt pstext -J$J -R$R -F+f18p -O -K >> $PS
    DSCALE=1.5i/-0.12i/2.6i/0.1ih
	gmt psscale -C$CPT -D$DSCALE -O -K -X0 -B+l"Perturbation (%)" >> $PS

done
gmt psconvert -A -P -Tf $PS
rm $PS
rm cptfile.cpt
rm input.grd
rm input.grd2
