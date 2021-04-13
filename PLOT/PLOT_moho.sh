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
PS=~/Documents/plot/moho.ps
site=~/Documents/mystation.txt

gmt grdcut  @earth_relief_03m.grd  -Gcut.grd  -R$R -V
gmt grdgradient cut.grd -A45 -Nt -Gcut.grd.gradient -V


CPT=cptfile.cpt
gmt makecpt -Cvik -T30/50/4 -D -Ic -Z > cptfile.cpt
INPUT_FILE=/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/moho.grd
echo $INPUT_FILE
XOFF=1i
YOFF=12i

gmt psbasemap -R$R -J$J -B4f1 -BWseN -K -X$XOFF -Y$YOFF > $PS
gmt pscoast -R$R -J$J -N2/1p -A500 -W1p -O -K >> $PS

# gmt grdimage cut.grd -R -J$J  -Bx4f2  -By4f2 -BWseN -Icut.grd.gradient -Cgray -X$XOFF -Y$YOFF -K > $PS
# for sta in `awk '$3=="phzh" || $3=="phwf" || $3=="phzhwf" {print $4}' /mnt/home/jieyaqi/Documents/invinfo.txt`
# do
#     awk '$4=="'$sta'" {print $1,$2,$3}' $INPUT_FILE |
#     gmt psxy -R$R -J$J -Sc8p -Wblack -C$CPT -K -O >> $PS
# done

gmt grdsample $INPUT_FILE -Ginput.grd2  -I0.1 -R$R -V
gmt grdfilter input.grd2 -Ginput.grd3 -Fg100 -D4 -R$R

gmt grdimage  input.grd3  -R -J$J -BWseN -C$CPT -O -K -t80>> $PS
gmt psclip -R$R -J$J ~/Documents/mask.xy -BWseN -S10 -K -O -V >> $PS
gmt grdimage  input.grd3  -R -J$J  -BwseN -C$CPT -K  -O  >> $PS
gmt psclip -C -O -K >> $PS

gmt psxy ~/Documents/earifts.xy -R$R -J$J -W1p/black -O -K >> $PS
gmt psxy ~/Documents/tzcraton.xy -R$R -J$J -W1p/black -O -K>> $PS
gmt psxy ~/Documents/volcano.dat -R$R -J$J -St8p -Wblack -Gred -O -K >> $PS

DSCALE=1.5i/-0.12i/2.6i/0.1ih
gmt psscale -C$CPT -D$DSCALE  -O -X0 -B+l'Crustal depth (km)' >> $PS





gmt psconvert -A -P -Tf $PS
rm $PS
rm cptfile.cpt
rm cut.grd
rm cut.grd.gradient
