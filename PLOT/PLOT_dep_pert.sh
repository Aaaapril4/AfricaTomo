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

PS=~/Documents/plot/vs.ps
CPT=cptfile.cpt
INPUT_FILE=/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/vel.xyz
#INPUT_FILE=/mnt/home/jieyaqi/Documents/FinalModels/ShearVelocities/vs.xyz
rfile=pertcolor.dat
seisf=~/Documents/seismicity.txt 


# depth you should give your own
#dep=( 10 30 50 )
dep=( 0.40 10   25  40  60   100  150 200 )
#id   0    1    2    3    4   5   6   7   8   9   10  11  12  13  14  15  16  17  18
gmt grdcut  @earth_relief_03m.grd  -Gcut.grd  -R$R
gmt grdgradient cut.grd -A45 -Nt -Gcut.grd.gradient
gmt grdsample cut.grd.gradient -Gcut.grd.gradient2  -I0.1 -R$R

for (( i=0; i<=7; i++ ))
do

    echo ${dep[$i]}
	awk '$3=='${dep[$i]}'{print $1,$2,$4}' $INPUT_FILE > absvel.xyz
    if [ i==0 ]
    then
        avg=`python3 cal_perturbation.py absvel.xyz filter`
    else
        avg=`python3 cal_perturbation.py absvel.xyz`
    fi
    gmt surface pertz.xyz -R$R -I0.2  -Ginput.grd -T0.5
    gmt grdsample input.grd -Ginput.grd2  -I0.1 -R$R -V
    gmt grdfilter input.grd2 -Ginput.grd3 -Fg180 -D4 -R$R

    range=`cat $rfile | awk '$1==per {print $2}' per="${dep[$i]}"`
    gmt makecpt -Cvik -T$range -D -Z -Iz> $CPT

	if  (( $i ==  0  )) ; then
       XOFF=1i
       YOFF=12i
       gmt grdimage  input.grd3  -R -J$J -C$CPT -K -X$XOFF -Y$YOFF -t80 -Icut.grd.gradient2> $PS
       gmt psclip -R$R -J$J ~/Documents/mask.xy -S10 -K -O -V >> $PS
       gmt grdimage  input.grd3  -R -J$J -C$CPT -O -K -Icut.grd.gradient2>> $PS
       gmt psclip -C -O -K >> $PS
       gmt pscoast -R$R -J$J -W0.5p,darkgrey -A1000 -K -O >> $PS
       gmt psbasemap -R$R -J$J -B5f1 -BWseN -K -O >> $PS

    elif (( $i == 4 )) || (( $i == 8 )) || (( $i == 12 )) || (( $i == 16 )) ; then
       XOFF=-10.5i
       YOFF=-5.5i
       gmt grdimage  input.grd3  -R -J$J -C$CPT -O -K -t80 -X$XOFF -Y$YOFF -Icut.grd.gradient2>> $PS
       gmt psclip -R$R -J$J ~/Documents/mask.xy -S10 -K -O -V >> $PS
       gmt grdimage  input.grd3  -R -J$J -C$CPT -K  -O -Icut.grd.gradient2>> $PS
       gmt psclip -C -O -K >> $PS
       gmt pscoast -R$R -J$J -W0.5p,darkgrey -A1000 -K -O >> $PS
       gmt psbasemap -R$R -J$J -B5f1 -BWseN -K -O >> $PS

    else
       XOFF=3.5i
       YOFF=0i
       gmt grdimage  input.grd3  -R -J$J -C$CPT -O -K -t80 -X$XOFF -Y$YOFF -Icut.grd.gradient2 >> $PS
       gmt psclip -R$R -J$J ~/Documents/mask.xy  -S10 -K -O -V >> $PS
       gmt grdimage  input.grd3  -R -J$J   -C$CPT -K  -O  -Icut.grd.gradient2>> $PS
       gmt psclip -C -O -K >> $PS
       gmt pscoast -R$R -J$J -W0.5p,darkgrey -A1000 -K -O >> $PS
       gmt psbasemap -R$R -J$J -B5f1 -BwseN -K -O  >> $PS
    fi

    # Plot seismicity
    python3 seismoho.py $seisf ${dep[$i]} 2
    awk '{print $1,$2,$4/2+1"p"}' abovemoho.dat | gmt psxy -R$R -J$J -Sc -Wdarkgreen -Gdarkgreen -O -K -t10 >> $PS
    awk '{print $1,$2,$4/2+1"p"}' belowmoho.dat | gmt psxy -R$R -J$J -Sa -Wdarkgreen -Gdarkgreen -O -K -t10 >> $PS

    
	gmt psxy ~/Documents/earifts.xy -R$R -J$J -W1p,black -O -K >> $PS
    gmt psxy ~/Documents/tzcraton.xy -R$R -J$J -W1p,black -O -K>> $PS
    gmt psxy ~/Documents/volcano_africa.txt -R$R -J$J -St8p -Wblack  -Gred -O -K >> $PS
    echo 37.75 -14 ''${dep[$i]}' km' | gmt pstext -J$J -R$R -Gwhite -C0.1c/0.1c -W1p -F+f17p -O -K >> $PS
    echo 27.75 3 ''$avg' km/s' | gmt pstext -J$J -R$R -Gwhite -W1p -C0.1c/0.1c -F+f17p -O -K >> $PS

    DSCALE=1.5i/-0.2i/2.6i/0.1ih
	gmt psscale -C$CPT -D$DSCALE -O -K -X0 -B+l'@~\144@~V@-s@-/V@-s@- (%)' >> $PS


done
gmt psconvert -A -P -Tf $PS
rm $PS
rm cptfile.cpt
rm input.grd*
rm abovemoho.dat belowmoho.dat
rm absvel.xyz pertz.xyz
time
