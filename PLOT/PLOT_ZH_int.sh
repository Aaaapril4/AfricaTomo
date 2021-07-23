#!/bin/bash
gmt gmtset MAP_FRAME_TYPE plain
gmt gmtset FONT_LABEL 18p, Times-Roman
gmt gmtset FONT_ANNOT_PRIMARY 17p,Times-Roman
gmt gmtset PS_MEDIA a2
gmt gmtset MAP_TITLE_OFFSET 1.5p
gmt gmtset MAP_TICK_LENGTH_PRIMARY 10p
gmt gmtset MAP_TICK_LENGTH_SECONDARY 5p
gmt gmtset MAP_TICK_PEN_PRIMARY 1.5p
gmt gmtset MAP_TICK_PEN_SECONDARY 1p

R=25/40/-15/4
J=m0.2i
PS=~/Documents/plot/tomo_zhev.ps

gmt grdcut  @earth_relief_03m.grd  -Gcut.grd  -R$R
gmt grdgradient cut.grd -A45 -Nt -Gcut.grd.gradient
gmt grdsample cut.grd.gradient -Gcut.grd.gradient2  -I0.1 -R$R

# period you should give your own
per=( 7   9  13  17  21  25  29  )
#id   0  1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18
CPT=cptfile.cpt
gmt makecpt -Cvik -T0.7/1.9/0.3 -D -Ic -Z > $CPT
CPT2=cptfile2.cpt
gmt makecpt -Cdarkgray,black -T0/3000 -D -Z > $CPT2
for (( i=0; i<=6; i++ ))
#for i=0
do

    echo ${per[$i]}
    INPUT_FILE=/mnt/ufs18/nodr/home/jieyaqi/east_africa/zhcurve/ZHratio."${per[$i]}".dat
    echo $INPUT_FILE
    gmt surface $INPUT_FILE -R$R -I0.1  -Ginput.grd -T0.5

	if  (( $i ==  0  )) ; then
        XOFF=1i
        YOFF=12i
        
        gmt grdimage input.grd -R -J$J  -C$CPT  -K -t80 -Icut.grd.gradient2 -X$XOFF -Y$YOFF > $PS
        gmt psclip -R$R -J$J ~/Documents/mask.xy -S10 -K -O -V >> $PS
        gmt grdimage input.grd -R -J$J  -C$CPT -Icut.grd.gradient2 -K -O >> $PS
        gmt psclip -C -O -K >> $PS
        gmt pscoast -R$R -J$J -A1000 -W0.5p,darkgrey -O -K >> $PS
        gmt psbasemap -R$R -J$J -B5f1 -BWseN -K -O >> $PS


    elif (( $i == 4 )) || (( $i == 8 )) || (( $i == 12 )) || (( $i == 16 )) ; then
        XOFF=-10.5i
        YOFF=-5.5i

        gmt grdimage input.grd -R -J$J -C$CPT  -K -O -t80 -X$XOFF -Y$YOFF -Icut.grd.gradient2 >> $PS 
        gmt psclip -R$R -J$J ~/Documents/mask.xy -S10 -K -O -V >> $PS
        gmt grdimage input.grd -R -J$J -C$CPT -Icut.grd.gradient2 -K -O >> $PS 
        gmt psclip -C -O -K >> $PS
        gmt pscoast -R$R -J$J -A1000 -W0.5p,darkgrey -O -K >> $PS
        gmt psbasemap -R$R -J$J -B5f1 -BWseN -K -O  >> $PS

 
    else
        XOFF=3.5i
        YOFF=0i
        gmt grdimage input.grd -R -J$J -C$CPT  -K -O -t80 -Icut.grd.gradient2 -X$XOFF -Y$YOFF >> $PS
        gmt psclip -R$R -J$J ~/Documents/mask.xy -S10 -K -O -V >> $PS
        gmt grdimage input.grd -R -J$J -C$CPT -Icut.grd.gradient2 -K -O >> $PS
        gmt psclip -C -O -K >> $PS
        gmt pscoast -R$R -J$J -A1000 -W0.5p,darkgrey -O -K >> $PS
        gmt psbasemap -R$R -J$J -B5f1 -BwseN -K -O  >> $PS
    fi


    
    gmt psxy ~/Documents/earifts.xy -R$R -J$J -W1p,black -O -K >> $PS
    gmt psxy ~/Documents/tzcraton.xy -R$R -J$J -W1p,black -O -K>> $PS
    gmt psxy ~/Documents/volcano_africa.txt -R$R -J$J -St8p -Wblack -Gred -O -K >> $PS

    awk '$4=="AN"{print $1,$2,$3}' $INPUT_FILE |
    gmt psxy -R$R -J$J -Ss6p -W1p,black -C$CPT -K -O >> $PS
    
    awk '$4=="EQ"{print $1,$2,$3}' $INPUT_FILE |
    gmt psxy -R$R -J$J -Sd6p -W1p,black -C$CPT -K -O >> $PS
    
    awk '$4=="both"{print $1,$2,$3}' $INPUT_FILE |
    gmt psxy -R$R -J$J -Sg6p -W1p,black -C$CPT -K -O >> $PS
    
    echo 26.25 3 ''${per[$i]}'s' | gmt pstext -J$J -R$R -Gwhite -W1p -C0.1c/0.1c -F+f17p -O -K >> $PS

    DSCALE=1.5i/-0.2i/2.6i/0.1ih
    gmt psscale -C$CPT -D$DSCALE  -O -K -X0 -B+l'ZH ratio' >> $PS
done


gmt psconvert -A -P -Tf $PS
rm $PS
rm cptfile.cpt
rm cut.grd
rm cut.grd.gradient
