#!/bin/bash
gmt gmtset MAP_FRAME_TYPE plain
gmt gmtset FONT_LABEL 12p, Times-Roman
gmt gmtset FONT_ANNOT_PRIMARY 12p,Times-Roman
gmt gmtset FONT_TITLE  12p,Times-Roman,black
gmt gmtset FONT_LABEL  10p,Times-Roman,black
gmt gmtset PS_MEDIA a4

OFN=test.ps

flagZH=1
flagSD=1


####Overall PD#####
gmt makecpt -Cseis -T0/1/0.25 -D -Z -I > pdf.cpt
gmt psbasemap -R0/5/0/200 -JX2i/-4.75i -Bx1f0.5+l"Vs: km/s" -By10f5+l"Depth: km" -BSWne+t"PDF" -K -P -X0.6i -Y5i >$OFN
awk '{print $1, $2, $3}' proCr.lst | gmt surface -R  -I0.02/0.5 -Gpdf.grd 
gmt grdimage pdf.grd   -R -J  -Bx -By  -Cpdf.cpt  -P  -K -O >> $OFN
cat max_prob.lst | awk '{print $2, $1}' | gmt psxy  -R -J -W1p,black -O -K -P >>$OFN 
cat mean_prob.lst | awk '{print $2, $1}' | gmt psxy  -R -J -W1p,grey,- -O -K -P >>$OFN 
gmt psscale  -Cpdf.cpt -P -D1.i/-0.5i/2.i/0.1ih -O -K  -L  >> $OFN

### PH and ZH ratio fitting ####
gmt psbasemap -R5/150/1.0/5.0 -JX2.0i/2i -Bx40f20+l"Period: s" -By1f0.5+l"phase velocity: km/s" -BWSne+t"PH fitting" -K -P -O -X2.75i -Y2.75i >>$OFN
grep RPH  BEST_MODEL.fitting | awk '{print $3, $5}' | gmt psxy -J -R -Bx -By -St0.075i -W1p,black  -P -K -O>> $OFN
grep RPH  BEST_MODEL.fitting | awk '{print $3, $4}' | gmt psxy  -R -J -W0.5p,red -O -K -P >>$OFN


gmt psbasemap -R5/30/0/2 -JX2.0i/2.0i -Bx5f2.5+l"Period: s" -By1f0.5+l"ZHratio: km/s" -BWSne+t"ZH fitting" -K -P -O  -Y-3.1i >>$OFN
if (( flagZH ==1 )) ; then
	grep ZH  BEST_MODEL.fitting | awk '{print $2, $4}' | gmt psxy -J -R -Bx -By -St0.075i -W1p,black  -P -K -O>> $OFN
	grep ZH  BEST_MODEL.fitting | awk '{print $2, $3}' | gmt psxy  -R -J -W0.5p,red -O -K -P >>$OFN
   
fi


gmt psbasemap -R0/30/-1.2/1.2 -JX2.0i/2.0i -Bx3f1.5+l"Times: s" -By1f0.5+l"Amplitude" -BWSne+t"BW fitting" -K -P -O -X2.75i -Y0i >>$OFN
a=`grep BW BEST_MODEL.fitting | awk '{print ($4^2)^0.5}' | awk 'BEGIN{maxa=0}{if(maxa<$1) maxa=$1}END{print maxa}'`
b=`grep BW BEST_MODEL.fitting | awk '{print ($5^2)^0.5}' | awk 'BEGIN{maxa=0}{if(maxa<$1) maxa=$1}END{print maxa}'`
grep BW BEST_MODEL.fitting | awk '{print $3*0.1, $4/'$a'}' | gmt psxy  -R -J -W0.5p,black -O -K -P >>$OFN 
grep BW BEST_MODEL.fitting | awk '{print $3*0.1, $5/'$b'}' | gmt psxy  -R -J -W0.5p,red,- -O -K -P >>$OFN 


######Moho and Sediments PDF#######
gmt psbasemap -R20/70/0/2000 -JX2.0i/2.0i -Bx10f5+l"Moho depth: km" -By400f200+l"counts" -BWSne+t"Moho distribution" -K -P -O -X-5.5i -Y-3.1i >>$OFN
gmt pshistogram moho.lst -JX -R -Bx -By  -G200 -L1.0p -W2.5  -K -P  -O >>$OFN

gmt psbasemap -R0/10/0/1000 -JX2.0i/2.0i -Bx2f1+l"Sediment depth: km" -By200f100+l"counts" -BWSne+t"Sediment distribution" -K -P -O  -X3i >>$OFN
if (( flagSD ==1 )) ; then
awk '{print $1}' Sediment.info | gmt pshistogram -JX -R -Bx -By  -G200 -L1.0p -W0.5  -K -P  -O >>$OFN
fi

gmt psconvert -A -Tf $OFN
rm $OFN
rm pdf.cpt
rm pdf.grd
rm gmt.conf
rm gmt.history
