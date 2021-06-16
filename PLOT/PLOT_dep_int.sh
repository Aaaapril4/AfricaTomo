#!/bin/bash
gmt gmtset MAP_FRAME_TYPE plain
gmt gmtset FONT_LABEL 18p, Times-Roman
gmt gmtset FONT_ANNOT_PRIMARY 17p,Times-Roman
gmt gmtset PS_MEDIA a2
gmt gmtset MAP_TITLE_OFFSET 1.5p
gmt gmtset MAP_TICK_LENGTH_PRIMARY 3p
gmt gmtset MAP_TICK_LENGTH_SECONDARY 2p

R=25/40/-15/4
J=m0.2i
PS=~/Documents/plot/vs.ps
#INPUT_FILE=/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/dep.${dep[$i]}.grd

CPT=cptfile.cpt
rfile=vscolor.dat
seisf=~/Documents/seismicity.txt 

# depth you should give your own
#dep=( 10 30 50 )
dep=( 0.40 5    10   20   30  40  50  60  80  100 120 150 180 200 )
#id   0    1    2    3    4   5   6   7   8   9   10  11  12  13  14  15  16  17  18
CPT=cptfile.cpt
# gmt grdcut  ~/Documents/global_xyz_2m.grd  -Gcut.grd  -R$R -V
# gmt grdgradient cut.grd  -A45 -Gcut.grd.gradient -Nt -V
# gmt grdsample cut.grd.gradient -Gcut.grd.gradient2  -I0.1 -R$R -V

for (( i=0; i<=13; i++ ))
do

    echo ${dep[$i]}
	INPUT_FILE=/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/dep.${dep[$i]}.grd
    # awk '$3=='${dep[$i]}'{print $1,$2,$4}' $INPUT_FILE | gmt surface  -R$R -I0.2  -Ginput.grd -T0.5
    gmt grdsample $INPUT_FILE -Ginput.grd2  -I0.1 -R$R -V
    gmt grdfilter input.grd2 -Ginput.grd3 -Fg150 -D4 -R$R

    range=`cat $rfile | awk '$1==per {print $2}' per="${dep[$i]}"`
    gmt makecpt -Croma -T$range -Z -D > $CPT

	if  (( $i ==  0  )) ; then
       XOFF=1i
       YOFF=12i
       gmt psbasemap -R$R -J$J -B4f1 -BWseN -K -X$XOFF -Y$YOFF > $PS
       gmt grdimage  input.grd3  -R -J$J -BWseN -C$CPT -O -K -t80>> $PS
       gmt psclip -R$R -J$J ~/Documents/mask.xy -BWseN -S10 -K -O -V >> $PS
       gmt grdimage  input.grd3  -R -J$J -BWseN -C$CPT -O -K >> $PS
       gmt psclip -C -O -K >> $PS

    elif (( $i == 6 )) || (( $i == 12 )) || (( $i == 18 )) || (( $i == 24 )) ; then
       XOFF=-15.5i
       YOFF=-5.3i
       gmt psbasemap -R$R -J$J -B4f1 -BWseN -K -O -X$XOFF -Y$YOFF >> $PS
       gmt grdimage  input.grd3  -R -J$J -BWseN -C$CPT -O -K -t80>> $PS
       gmt psclip -R$R -J$J ~/Documents/mask.xy -BWseN -S10 -K -O -V >> $PS
       gmt grdimage  input.grd3  -R -J$J  -BWseN -C$CPT -K  -O >> $PS
       gmt psclip -C -O -K >> $PS

    else
       XOFF=3.1i
       YOFF=0i
       gmt psbasemap -R$R -J$J -B4f1 -BwseN -K -O -X$XOFF -Y$YOFF >> $PS
       gmt grdimage  input.grd3  -R -J$J -BWseN -C$CPT -O -K -t80>> $PS
       gmt psclip -R$R -J$J ~/Documents/mask.xy -BWseN -S10 -K -O -V >> $PS
       gmt grdimage  input.grd3  -R -J$J  -BwseN -C$CPT -K  -O  >> $PS
       gmt psclip -C -O -K >> $PS
    fi

    # Plot seismicity
    if [ `echo "${dep[$i]} == 5" | bc -l` -eq 1 ]
    then
        awk '$3<=5{print $1,$2,$4/2+1"p"}' $seisf | gmt psxy -R$R -J$J -Sc -Wdarkgrey -Gdarkgrey -O -K -t10 >> $PS

    elif [ `echo "${dep[$i]} > 5" | bc -l` -eq 1 ]
    then
        upperbound=`echo ${dep[$i]} - 5 | bc -l`
        lowerbound=`echo ${dep[$i]} + 5 | bc -l`
        # echo $upperbound $lowerbound
        awk '$3>'$upperbound' && $3<='$lowerbound'{print $1,$2,$4/2+1"p"}' $seisf | gmt psxy -R$R -J$J -Sc -Wdarkgrey -Gdarkgrey -O -K -t10 >> $PS
    fi

    gmt pscoast -R$R -J$J -W0.25p,grey -A1000 -K -O >> $PS
	gmt psxy ~/Documents/earifts.xy -R$R -J$J -W1p/black -O -K >> $PS
    gmt psxy ~/Documents/tzcraton.xy -R$R -J$J -W1p/black -O -K>> $PS
    gmt psxy ~/Documents/volcano_africa.txt -R$R -J$J -St8p -Wblack -Gred -O -K >> $PS
    echo 36.5 -14 'Depth: '${dep[$i]}' km' | gmt pstext -J$J -R$R -F+f16p -O -K >> $PS
   
    DSCALE=1.5i/-0.12i/2.6i/0.1ih
	gmt psscale -C$CPT -D$DSCALE -O -K -X0 -B+l'Vs (km/s)' >> $PS


done
gmt psconvert -A -P -Tf $PS
rm $PS
rm cptfile.cpt
rm input.grd
rm input.grd2
time
