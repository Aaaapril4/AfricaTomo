#!/bin/bash
gmt --version
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
Rg=-20/60/-35/40
J=m0.2i
Jg=m0.01i
PS=~/Documents/plot/network.ps

stationfile=~/Documents/mystationwll.lst


gmt grdcut @earth_relief_03m.grd -R$R -GAfrica.grd
gmt grdgradient Africa.grd -A0 -Nt -Gint.grad

gmt makecpt -Cetopo1 -T-5000/5000 -D -Z  > 123.cpt

gmt grdimage -R$R -J$J Africa.grd -C123.cpt -Iint.grad -K  > $PS

gmt pscoast -R$R -J$J -W0.5p,darkgrey -S90/189/255 -A1000 -K -O >> $PS
#gmt psmeca earthquake.dat -J$J -R$R -Sm7p -Z234.cpt -K -O >> $PS

#gmt psmeca earthquake2.dat -J$J -R$R -Sa7p -Z234.cpt -K -O >> $PS


gmt psxy ~/Documents/earifts.xy -R$R -J$J -W1p/black -O -K >> $PS
gmt psxy ~/Documents/tzcraton.xy -R$R -J$J -W1p/black -O -K>> $PS
gmt psxy ~/Documents/volcano_africa.txt -R$R -J$J -St6p -Wblack -Gred -O -K >> $PS

i=0
for net in `awk '{print $1}' ~/Documents/network.dat`
do
    color=`awk '$1=="'$net'" {print $3}' netcolor.dat`
    shape=`awk '$1=="'$net'" {print $2}' netcolor.dat`
    awk '{print $1, $2, $3}' $stationfile | grep "$net." | awk '{print $2, $3}' | \
    gmt psxy -R$R -J$J -S"$shape"5p -Wblack -G$color -K -O >> $PS
    text=`awk '$1=="'$net'" {print $2,"-",$4}' ~/Documents/network.dat`
    YOFF=`echo "5 - $i * 1" |bc`
gmt pslegend -R$R -J$J -D60/$YOFF/10 -O -K >> $PS <<EOF
S 0.1i $shape 5p $color 0.5p 0.2i $net $text
EOF
i=`echo $i + 1 | bc -l`
done


gmt psbasemap -R$R -J$J -B5f1 -BWseN -K -O >> $PS 

gmt pscoast -R$Rg -J$Jg -W0.25p -B0 -Ggrey -B+gwhite -A -X0.05i -Y2.95i -K -O >> $PS 

gmt psbasemap -R$Rg -J$Jg -D$R -F+p1.5p -O  -K -P>> $PS 

# dx1 symbol size fill pen dx2 text 
gmt psscale -R$R -J$J -D3.6i/0i/3i/0.2iv -C123.cpt -B3000 -K -O >> $PS

rm gmt.* Africa.grd int.grad

gmt psconvert -A -P -Tf $PS

#open ./$PS
