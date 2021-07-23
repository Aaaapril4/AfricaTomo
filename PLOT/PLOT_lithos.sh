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
PS=~/Documents/plot/lithos.ps
site=~/Documents/mystation.txt

gmt grdcut  @earth_relief_03m.grd  -Gcut.grd  -R$R -V
gmt grdgradient cut.grd -A45 -Nt -Gcut.grd.gradient -V


CPT=cptfile.cpt
gmt makecpt -Cvik -T160/200/10 -D -Z -Iz> $CPT
INPUT_FILE=/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/moho.xyz
echo $INPUT_FILE
XOFF=1i
YOFF=12i

gmt psbasemap -R$R -J$J -B4f1 -BWseN -K -X$XOFF -Y$YOFF > $PS
gmt pscoast -R$R -J$J -N2/1p -A500 -W1p -O -K >> $PS

INPUT_FILE=../lithosphere.dat
gmt surface $INPUT_FILE -R$R -I0.2  -Ginput.grd -T0.5
gmt grdsample input.grd -Ginput.grd2  -I0.1 -R$R -V
gmt grdfilter input.grd2 -Ginput.grd3 -Fg150 -D4 -R$R
gmt grdimage  input.grd3  -R -J$J -BWseN -C$CPT -O -K -t80>> $PS
DSCALE=1.5i/-0.12i/2.6i/0.1ih
gmt psscale -C$CPT -D$DSCALE  -O -X0 -B+l'Crustal depth (km)' >> $PS





gmt psconvert -A -P -Tf $PS
rm $PS
rm cptfile.cpt
rm cut.grd
rm cut.grd.gradient
