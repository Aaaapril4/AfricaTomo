#!/bin/bash
gmt gmtset MAP_FRAME_TYPE plain
gmt gmtset FONT_LABEL 18p,Times-Roman
gmt gmtset FONT_ANNOT_PRIMARY 17p,Times-Roman
gmt gmtset PS_MEDIA a2
gmt gmtset MAP_TITLE_OFFSET 1.5p
gmt gmtset MAP_TICK_LENGTH_PRIMARY 3p
gmt gmtset MAP_TICK_LENGTH_SECONDARY 2p

R=25/42/-15/4
J=m0.2i
PS=~/Documents/plot/tomo_cbr.ps

# period you should give your own
per=( 5  7  9  13  17  21  25  29  33  37  41  45  49  53  57  61  65)
#id   0  1  2  3   4   5   6   7   8   9   10  11  12  13  14  15  16  17  18
CPT=cptfile.cpt

for (( i=0; i<=10; i++ ))
do

    # mask the area
    echo ${per[$i]}
    MASK_FILE=../output_cb/mask."${per[$i]}".txt
    awk '$3<0.6 && $2<3{print $1, $2, $3}' $MASK_FILE > MASK.xyz

    INPUT_FILE=../output_cb/grid2dv."${per[$i]}".z
	gmt xyz2grd $INPUT_FILE -Ginput.grd2 -I0.025/0.025 -ZLB -R25/42/-15/6
        
    gmt makecpt -Cvik -T-0.1/0.1/0.02 -Ic -D -Z > $CPT

	if  (( $i ==  0  )) ; then
       XOFF=1i
       YOFF=12i
       gmt psbasemap -R$R -J$J -B4f1 -BWseN -K -X$XOFF -Y$YOFF > $PS
	   gmt psmask -R$R -J$J -I0.7 MASK.xyz -B -K -O -V -S40 >> $PS
       gmt grdimage  input.grd2  -R -J$J -B -C$CPT -O -K >> $PS
       gmt psmask -C -O -K >> $PS

    elif (( $i == 4 )) || (( $i == 8 )) || (( $i == 12 )) || (( $i == 16 )) ; then
       XOFF=-10.5i
       YOFF=-5.3i
       gmt psbasemap -R$R -J$J -B4f1 -BWseN -K -O -X$XOFF -Y$YOFF >> $PS
	   gmt psmask -R$R -J$J -I0.7 MASK.xyz -B -K -O -V -S40 >> $PS
       gmt grdimage  input.grd2  -R -J$J  -B -C$CPT  -K  -O >> $PS
       gmt psmask -C -O -K >> $PS

    else
       XOFF=3.5i
       YOFF=0i
       gmt psbasemap -R$R -J$J -B4f1 -BwseN -K -O -X$XOFF -Y$YOFF >> $PS
	   gmt psmask -R$R -J$J -I0.7 MASK.xyz -B -K -O -V -S40 >> $PS
       gmt grdimage  input.grd2  -R -J$J  -B -C$CPT  -K  -O  >> $PS
       gmt psmask -C -O -K >> $PS
    fi

    gmt pscoast -R$R -J$J -W0.25p,grey -A1000 -K -O >> $PS
    gmt psxy ~/Documents/earifts.xy -R$R -J$J -W1p,black -O -K >> $PS
    gmt psxy ~/Documents/tzcraton.xy -R$R -J$J -W1p,black -O -K>> $PS
    echo 40.5 -14 'T: '${per[$i]}'s' | gmt pstext -J$J -R$R -F+f18p -O -K >> $PS
    
    DSCALE=1.7i/-0.12i/3i/0.1ih
	gmt psscale -C$CPT -D$DSCALE -O -K -X0 -B+l"Deviation (km/s)" >> $PS

    
done
gmt psconvert -A -Tf $PS
rm $PS
rm cptfile.cpt
rm input.grd2
