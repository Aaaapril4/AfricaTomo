#!/bin/bash
gmt gmtset MAP_FRAME_TYPE plain
gmt gmtset MAP_TICK_LENGTH_PRIMARY 3p
gmt gmtset MAP_TICK_LENGTH_SECONDARY 2p

R=25/42/-15/4
Rg=-20/60/-35/40
J=m0.2i
Jg=m0.01i
PS=profilemap.ps

if [ -e ~/Documents/plot/profile ]
then
    rm -r ~/Documents/plot/profile
    mkdir ~/Documents/plot/profile
fi

# plot map
gmt gmtset FONT_ANNOT_PRIMARY 10p

gmt grdcut @earth_relief_03m.grd -R$R -GAfrica.grd

gmt grdgradient Africa.grd -A0 -Nt -Gint.grad

gmt psbasemap -R$R -J$J -B4f2 -BWSen -K -P> $PS
gmt makecpt -Cetopo1 -T-3000/3000 -D -Z  > 123.cpt

gmt grdimage -R$R -J$J Africa.grd -C123.cpt -K -O -t50 >> $PS
gmt psclip -R$R -J$J ~/Documents/mask.xy -BWseN -S10 -K -O -V >> $PS
gmt grdimage -R$R -J$J Africa.grd -C123.cpt -K -O >> $PS
gmt psclip -C -O -K >> $PS

gmt pscoast -R25/38/-15/4 -J$J -W0.25p,grey -A1000 -K -O >> $PS

gmt psxy ~/Documents/earifts.xy -R$R -J$J -W0.5p,black -O -K >> $PS
gmt psxy ~/Documents/tzcraton.xy -R$R -J$J -W0.5p,black -O -K>> $PS
gmt psxy ~/Documents/volcano_africa.txt -R$R -J$J -St8p -Wblack -Gred -O -K >> $PS
awk '$3=="phzh" || $3=="phwf" || $3=="phzhwf" {print $1, $2}' ~/Documents/invinfo.txt| gmt psxy -R$R -J$J -St8p -Wblack -Ggrey -O -K >> $PS

gmt psxy -R$R -J$J -W2p,black -O -K profileline.txt >> $PS 

gmt psscale -R$R -J$J -D3.45i/1.5i/3i/0.3iv -C123.cpt -B1000 -O >> $PS --MAP_LABEL_OFFSET=-0.15i --FONT_ANNOT_PRIMARY=8p --FONT_LABEL=8p --MAP_TICK_LENGTH_PRIMARY=0.04i

rm gmt.* Africa.grd int.grad

gmt psconvert -A -P -Tf $PS

mv ./${PS/ps/pdf} ~/Documents/plot/profile

# plot profiles
N=`awk 'END {print NR}' profileline.txt`
for (( i=1; i<=N; i=i+3 ))
do
    start=`awk 'NR=='$i' {print $0}' profileline.txt`
    end=`awk 'NR=='$[i+1]' {print $0}' profileline.txt`
    echo $start $end
    sh PLOT_profile.sh $start $end
done
