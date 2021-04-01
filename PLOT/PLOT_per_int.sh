#!/bin/bash
gmt gmtset MAP_FRAME_TYPE plain
gmt gmtset FONT_LABEL 14p,Times-Roman
gmt gmtset FONT_ANNOT_PRIMARY 14p,Times-Roman
gmt gmtset PS_MEDIA a2
gmt gmtset MAP_TITLE_OFFSET 1.5p
gmt gmtset MAP_TICK_LENGTH_PRIMARY 3p
gmt gmtset MAP_TICK_LENGTH_SECONDARY 2p

R=25/42/-15/4
J=m0.2i
PS=~/Documents/plot/tomo_pert.ps

# period you should give your own
# per=( 7 21 37 )
per=( 5  7   9  13  17  21  25  29  33  37  41  45  49  53  57  61  65)
#id   0  1   2  3   4   5   6   7   8   9   10  11  12  13  14  15  16  17  18
CPT=cptfile.cpt
gmt grdcut  ~/Documents/global_xyz_2m.grd  -Gcut.grd  -R25/42/-15/6 -V
gmt grdgradient cut.grd  -A45 -Gcut.grd.gradient -Nt -V
gmt grdsample cut.grd.gradient -Gcut.grd.gradient2  -I0.025 -R25/42/-15/6 -V

for (( i=0; i<=10; i++ ))
do
   echo per[$i]
   INPUT_FILE=/mnt/home/jieyaqi/code/FMST/Shell_for_FMM/output_tomo/grid2dv."${per[$i]}".z
	gmt xyz2grd $INPUT_FILE -Ginput.grd2 -I0.025/0.025 -ZLB -R25/42/-15/6
   gmt makecpt -Cno_green -T-10/10/4 -D -Z -Ic > $CPT
   if  (( $i ==  0  )) ; then
       XOFF=1i
       YOFF=11i
       gmt psbasemap -R$R -J$J -B4f1 -BWseN -K -V -X$XOFF -Y$YOFF > $PS
       gmt psclip -R$R -J$J ~/Documents/mask.xy -BWseN -S10 -K -O -V >> $PS
	#    gmt psmask -R$R -J$J -I0.7 MASK.xyz -BWseN -K -O -V -S40 >> $PS
       gmt grdimage  input.grd2  -R -J$J -BWseN -V -C$CPT -Icut.grd.gradient2 -O -K >> $PS
    #    gmt psmask -C -O -K >> $PS
       gmt psclip -C -O -K >> $PS

   elif (( $i == 4 )) || (( $i == 8 )) || (( $i == 12 )) || (( $i == 16 )) ; 
   then
       XOFF=-10.5i
       YOFF=-4.9i
       gmt psbasemap -R$R -J$J -B4f1 -BWseN -K -O -X$XOFF -Y$YOFF >> $PS
       gmt psclip -R$R -J$J ~/Documents/mask.xy -BWseN -S10 -K -O -V >> $PS
	#    gmt psmask -R$R -J$J -I0.7 MASK.xyz -BWseN -K -O -V -S40 >> $PS
       gmt grdimage  input.grd2  -R -J$J  -BWseN -C$CPT  -Icut.grd.gradient2 -K  -O >> $PS
       gmt psclip -C -O -K >> $PS
    #    gmt psmask -C -O -K >> $PS

   else
       XOFF=3.5i
       YOFF=0i
       gmt psbasemap -R$R -J$J -B4f1 -BwseN -K -O -X$XOFF -Y$YOFF >> $PS
	#    gmt psmask -R$R -J$J -I0.7 MASK.xyz -BwseN -K -O -V -S40 >> $PS
       gmt psclip -R$R -J$J ~/Documents/mask.xy -BWseN -S10 -K -O -V >> $PS
       gmt grdimage  input.grd2  -R -J$J  -BwsseN -C$CPT -Icut.grd.gradient2 -K  -O  >> $PS
    #    gmt psmask -C -O -K >> $PS
       gmt psclip -C -O -K >> $PS
   fi
   gmt pscoast -R$R -J$J -W0.25p,grey -A1000 -K -O >> $PS
   gmt psxy ~/Documents/earifts.xy -R$R -J$J -W1p,black -O -K >> $PS
   gmt psxy ~/Documents/tzcraton.xy -R$R -J$J -W1p,black -O -K>> $PS
   gmt psxy ~/Documents/volcano_africa.txt -R$R -J$J -St8p -Wblack -Gred -O -K >> $PS
   echo 27.5 2.5 'T: '${per[$i]}' s' | gmt pstext -J$J -R$R -F+f16p -O -K >> $PS
   avg=`awk -F ',' '$1=='${per[$i]}' {print $2}' /mnt/home/jieyaqi/code/FMST/Shell_for_FMM_200924/output_tomo/avgvel.dat` 
   echo 31 -14 'Average: '$avg' km/s' | gmt pstext -J$J -R$R -F+f16p -O -K >> $PS
   DSCALE=1.7i/-0.12i/3i/0.07ih
	gmt psscale -C$CPT -D$DSCALE -O -K -X0 -B+l"perturbation (%)" >> $PS

done
gmt psconvert -A -Tf $PS
rm $PS
rm cptfile.cpt
# rm input.grd2
time 
