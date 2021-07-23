#!/bin/bash
gmt gmtset MAP_FRAME_TYPE plain
gmt gmtset MAP_TICK_LENGTH_PRIMARY 3p
gmt gmtset MAP_TICK_LENGTH_SECONDARY 2p

R=20/54/-20/20
Rg=-20/60/-35/40
J=m0.095i
Jg=m0.01i
PS=~/Documents/plot/Africa.ps
D=earth_relief_03m.grd
stationfile=~/Documents/station_allregion.txt

gmt gmtset FONT_ANNOT_PRIMARY 10p

gmt grdcut $D -R$R -GAfrica.grd

gmt grdgradient Africa.grd -A0 -Nt -Gint.grad

gmt psbasemap -R$R -J$J -B10f2 -BWSen -K > $PS

gmt grdimage -R$R -J$J Africa.grd -Iint.grad -C123.cpt -K -O >> $PS

gmt pscoast -R$R -J$J -W0.25p -S90/189/255 -K -O >> $PS

#gmt psmeca ~/Documents/earthquake.dat -J$J -R$R -Sm6.5p -Z234.cpt -K -O >> $PS

#gmt psmeca ~/Documents/earthquake2.dat -J$J -R$R -Sa6.5p -Z234.cpt -K -O >> $PS

awk '{print $2, $3}' /mnt/home/jieyaqi/Documents/mystationwll.lst | 
#awk -F '|' '{print $4,$3}' $stationfile | \
gmt psxy -R$R -J$J -St4p -Wblack -Ggrey -K -O >> $PS

gmt psxy -R$R -J$J -W1.5p -K -O >>$PS <<EOF
25 4
42 4
42 -15
25 -15
25 4
EOF

gmt psxy ~/Documents/earifts.xy -R$R -J$J -W1p,black -O -K >> $PS
gmt psxy ~/Documents/tzcraton.xy -R$R -J$J -W1p,black -O -K>> $PS

# gmt pstext -R$R -J$J -F+fTimes-Roman -K -O >>$PS <<EOF
# 25 -4 Western
# 25 -3 Branch
# 40 2 Eastern
# 40 1 Branch
# 34 -3 Tanzanian
# 34 -4 Craton
# 32 -10 RVP
# 38 -12 Malawi Rift
# EOF

#gmt psbasemap -R$R -J$J -B10f2 -BwsEN -K -O >> $PS --MAP_FRAME_TYPE=plain --MAP_FRAME_PEN=1p

gmt pscoast -R$Rg -J$Jg -W0.25p -B0 -Ggrey -B+gwhite -A -X0.1i -Y3.005i -K -O >> $PS --MAP_FRAME_TYPE=plain --MAP_FRAME_PEN=0.25p

gmt psbasemap -R$Rg -J$Jg -D$R -F+p1.5p -O >> $PS --MAP_FRAME_WIDTH=3p --MAP_TICK_LENGTH_PRIMARY=0

rm gmt.* Africa.grd int.grad

gmt psconvert -A -P -Tf ~/Documents/plot/Africa.ps
rm $PS
