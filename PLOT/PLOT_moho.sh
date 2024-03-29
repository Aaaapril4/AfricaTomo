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
PS=~/Documents/plot/moho.ps
site=~/Documents/mystation.txt

gmt grdcut  @earth_relief_03m.grd  -Gcut.grd  -R$R
gmt grdgradient cut.grd -A45 -Nt -Gcut.grd.gradient
gmt grdsample cut.grd.gradient -Gcut.grd.gradient2  -I0.1 -R$R



CPT=cptfile.cpt
CPT2=cptfile2.cpt
gmt makecpt -Cjet -T30/45/3 -D -Ic -Z > cptfile.cpt
gmt makecpt -Cwhite,lightgray -T0,1500,3000 -N > $CPT2
INPUT_FILE=/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/moho.xyz
INPUT_FILE2=/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion/uncertaintyms.xyz

# Plot as dot
Plot_dot()
{
    gmt grdimage cut.grd -R -J$J -Icut.grd.gradient -C$CPT2 -K -Y1i > $PS

    gmt pscoast -R$R -J$J -W0.5p,darkgrey -A1000 -K -O >> $PS


    gmt psxy ~/Documents/earifts.xy -R$R -J$J -W1p/black -O -K >> $PS
    gmt psxy ~/Documents/tzcraton.xy -R$R -J$J -W1p/black -O -K>> $PS
    gmt psxy ~/Documents/volcano_africa.txt -R$R -J$J -St8p -Wblack  -Gred -O -K >> $PS

    for sta in `awk '$3=="phwf" || $3=="phzhwf" {print $4}' /mnt/home/jieyaqi/Documents/invinfo.txt`
    do
        awk '$4=="'$sta'" {print $1,$2,$3}' $INPUT_FILE | #>> stamoho.xyz
        gmt psxy -R$R -J$J -Sc8p -Wblack -C$CPT -K -O >> $PS
    done

    gmt psbasemap -R$R -J$J -B5f1 -BWseN -K -O >> $PS

    DSCALE=1.5i/-0.2i/2.6i/0.1ih
    gmt psscale -C$CPT -D$DSCALE -K -O -B+l'Crustal thickness (km)' >> $PS
}

# Plot as map
Plot_map()
{
    gmt surface $INPUT_FILE -R$R -I0.1 -Ginput.grd -T0.5
    gmt grdimage input.grd -R -J$J -C$CPT -K -O -t80 -Icut.grd.gradient2 -X3.5i -Y0i >>$PS
    gmt psclip -R$R -J$J ~/Documents/mask.xy -S10 -K -O -V >> $PS
    gmt grdimage input.grd -R -J$J  -C$CPT -Icut.grd.gradient2 -K -O >> $PS
    gmt psclip -C -O -K >> $PS
    gmt pscoast -R$R -J$J -W0.5p,darkgrey -A1000 -K -O >> $PS

    awk '$3=="phwf" || $3=="phzhwf" {print $1, $2}' /mnt/home/jieyaqi/Documents/invinfo.txt | gmt psxy -R$R -J$J -Sc8p -W0.5p,black -K -O >> $PS

    gmt psxy ~/Documents/earifts.xy -R$R -J$J -W1p/black -O -K >> $PS
    gmt psxy ~/Documents/tzcraton.xy -R$R -J$J -W1p/black -O -K>> $PS
    gmt psxy ~/Documents/volcano_africa.txt -R$R -J$J -St8p -Wblack  -Gred -O -K >> $PS

    gmt psbasemap -R$R -J$J -B5f1 -BwseN -K -O >> $PS
    DSCALE=1.5i/-0.2i/2.6i/0.1ih
    gmt psscale -C$CPT -D$DSCALE -K -O -B+l'Crustal thickness (km)' >> $PS
}

# Plot uncertainty
Plot_uncert()
{
    # Plot_uncert input_file range X Y text
    INPUT_FILE=$1

    gmt makecpt -Cjet -T$2 -D -Ic -Z > cptfile.cpt
    gmt surface $INPUT_FILE -R$R -I0.1 -Ginput.grd -T0.5
    gmt grdimage input.grd -R -J$J -C$CPT -K -O -t80 -Icut.grd.gradient2 -X$3 -Y$4 >> $PS
    gmt psclip -R$R -J$J ~/Documents/mask.xy -S10 -K -O -V >> $PS
    gmt grdimage input.grd -R -J$J  -C$CPT -Icut.grd.gradient2 -K -O >> $PS
    gmt psclip -C -O -K >> $PS
    gmt pscoast -R$R -J$J -W0.5p,darkgrey -A1000 -K -O >> $PS

    awk '$3=="phwf" || $3=="phzhwf" {print $1, $2}' /mnt/home/jieyaqi/Documents/invinfo.txt | gmt psxy -R$R -J$J -Sc8p -W0.5p,black -K -O >> $PS

    gmt psxy ~/Documents/earifts.xy -R$R -J$J -W1p/black -O -K >> $PS
    gmt psxy ~/Documents/tzcraton.xy -R$R -J$J -W1p/black -O -K>> $PS
    gmt psxy ~/Documents/volcano_africa.txt -R$R -J$J -St8p -Wblack  -Gred -O -K >> $PS

    gmt psbasemap -R$R -J$J -B5f1 -BwseN -K -O >> $PS
    DSCALE=1.5i/-0.2i/2.6i/0.1ih
    gmt psscale -C$CPT -D$DSCALE -K -O -B+l"$5" >> $PS
}

Plot_dot
Plot_map
awk '{print $1, $2, $4}' $INPUT_FILE2 > temp
Plot_uncert temp 1/5/1 3.5i 0i "@~s@~ (km)"
awk '{print $1, $2, $7}' $INPUT_FILE2 > temp
Plot_uncert temp 0/0.2/0.05 3.5i 0i "@~s@~/(crustal thickness) (km)"
awk '{print $1, $2, $8}' $INPUT_FILE2 > temp
Plot_uncert temp 30/45/3 3.5i 0i "crustal thickness-@~s@~ (km)"
awk '{print $1, $2, $9}' $INPUT_FILE2 > temp
Plot_uncert temp 30/45/3 3.5i 0i "crustal thickness+@~s@~ (km)"


gmt psconvert -A -P -Tf $PS
rm $PS
rm cptfile.cpt
rm cut.grd
rm cut.grd.gradient
