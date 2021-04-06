#!/bin/bash
R=25/40/-15/6
Rg=-20/60/-35/40
J=m0.2i
Jg=m0.01i
PS=myregion2.ps

stationfile=~/Documents/mystationwll.lst

gmt5 gmtset FONT_ANNOT_PRIMARY 10p


cat << EOF > 234.cpt
 0   0-1-1   10   0-1-1
10  60-1-1   20  60-1-1
20 120-1-1   30 120-1-1
30 240-1-1   40 240-1-1
F 240-1-1
EOF


gmt5 grdcut @earth_relief_03m.grd -R$R -GAfrica.grd
gmt5 grdgradient Africa.grd -A0 -Nt -Gint.grad
gmt5 psbasemap -R$R -J$J -B4f2 -BWSen -K -P> $PS --MAP_FRAME_WIDTH=4p --MAP_TICK_LENGTH_PRIMARY=0
gmt5 grdimage -R$R -J$J Africa.grd -Iint.grad -C123.cpt -K -O >> $PS
gmt5 pscoast -R$R -J$J -W0.25p -S90/189/255 -K -O >> $PS

gmt5 psxy ~/Documents/earifts.xy -R$R -J$J -W1p,black -O -K >> $PS
gmt5 psxy ~/Documents/tzcraton.xy -R$R -J$J -W1p,black -O -K>> $PS
gmt5 psxy ~/Documents/volcano_africa.txt -R$R -J$J -St8p -Wblack -Gred -O -K >> $PS
awk '{print $2,$3}' $stationfile |
gmt5 psxy -R$R -J$J -St6p -Wblack -Ggrey -O -K -t10 >> $PS
awk '$9!="" {print $1, $2, $3, $4, $5, $6, $7, $8}' ~/Documents/seis_mechanism.txt |
gmt5 psmeca  -J$J -R$R -Sa7p -Z234.cpt -K -O -t10 >> $PS

gmt5 psscale -R$R -J$J -DjBR+w4.5c/0.2c+o0.07i/0.13i+h -C123.cpt -B1000 -G0/6000 -Bx+l'Elevation (m)' -F+gwhite+c-0.06i/-0.06i/-0.13i/0.12i -K -O >> $PS --FONT_ANNOT_PRIMARY=8p --MAP_FRAME_TYPE=inside --MAP_FRAME_WIDTH=0.5p --MAP_TICK_LENGTH_PRIMARY=0.04i --MAP_LABEL_OFFSET=-0.15i --FONT_LABEL=8p

#gmt psbasemap -R$R -J$J -B10f2 -BwsEN -K -O >> $PS --MAP_FRAME_TYPE=plain --MAP_FRAME_PEN=1p

gmt5 pscoast -R$Rg -J$Jg -W0.25p -B0 -Ggrey -B+gwhite -A -X0.05i -Y3.35i -K -O >> $PS --MAP_FRAME_TYPE=plain --MAP_FRAME_PEN=0.25p
gmt5 psbasemap -R$Rg -J$Jg -D$R -F+p1.5p -O -P>> $PS --MAP_FRAME_WIDTH=1p --MAP_TICK_LENGTH_PRIMARY=0

gmt5 psconvert -A -P -Tf $PS
mv ./${PS/ps/pdf} ~/Documents/plot
rm gmt.* Africa.grd int.grad
rm $PS
rm 234.cpt
