#!/usr/local/bin/bash

# -----------------------------------------------------------------------------
# Seismicity data plotter - Covering Indonesia Region [93/143/-15/10]
# Data were downloaded from IRIS Wilber3
# GCMT data acquired from globalcmt.org
#
# Author: Hendro Nugroho -- 2020/04/15
#
# -----------------------------------------------------------------------------

cmts=("gcmt/gcmt_11_20.gmt" "gcmt/gcmt_01_10.gmt" "gcmt/gcmt_91_00.gmt" "gcmt/gcmt_81_90.gmt" "gcmt/gcmt_76_80.gmt")
gyrs=("2011 to 2020" "2001 to 2010" "1991 to 2000" "1981 to 1990" "1976 to 1980")

### CPT for seismicity
# scm6
#cptf2="cpt/scm6/roma.cpt"

#cptf2="viridis.cpt"
# default [now]
cptf2="no_green"

# if s1 or s2 = 1
# if seis data exist and shallow eq switch is ON
if [ `ls -1 seism/seism_710101-200416_gtm3_le300km_* 2>/dev/null | wc -l` -eq 50 ]; then

    fn="seism/seism_710101-200416_gtm3_le300km_"

    gmt makecpt -C$cptf2 -I -T0/300/5 > $eqcpt0
    gmt makecpt -C$cptf2 -I -T0/50/5 > $eqcpt1
    gmt makecpt -C$cptf2 -I -T50/300/50 > $eqcpt2

    if [ $s2 == 0 ] && [ $g2 == 0 ]; then
        eqcpt=$eqcpt1
    elif [ $s1 == 0 ] && [ $g1 == 0 ]; then
        eqcpt=$eqcpt2
    else
        eqcpt=$eqcpt0
    fi


    if [ $s1 == 1 ]; then
        echo "Plotting shallow earthquake data from ISC catalog covering period of $yr1 to $yr2"
        for ((y=$yr1; y<=$yr2; ++y));
            do
            awk -F"|"  'NR > 1 && $5 <= 50 {print $4, $3, $5, $11}' $fn$y.txt | gmt psxy $rgn $prj $open -C$eqcpt -Sci -Wfaint -i0,1,2,3+s0.015 >> $ps
        done
    fi
    if [ $s2 == 1 ]; then
        echo "Plotting intermediate depth data from ISC catalog covering period of $yr1 to $yr2"
        for ((y=$yr1; y<=$yr2; ++y));
            do
            awk -F"|"  'NR > 1 && $5 > 50 {print $4, $3, $5, $11}' $fn$y.txt | gmt psxy $rgn $prj $open -C$eqcpt -Sci -Wfaint -i0,1,2,3+s0.015 >> $ps
        done
    fi
    c=0
    if [ $g1 == 1 ]; then
        for n in "${cmts[@]}";
            do
            echo "Plotting GCMT of shallow earthquake from ${gyrs[$c]}"
            awk '$3 <= 50 {print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' $n | gmt psmeca $rgn $prj $ctr -Sd0.4 -Z$eqcpt -h13 $open >> $ps
            let c++
        done
        #echo "Done plotting  1976-2020!"
    fi
    c=0
    if [ $g2 == 1 ]; then
        for n in "${cmts[@]}";
            do
            echo "Plotting GCMT of intermediate depth earthquake from ${gyrs[$c]}"
            awk '$3 > 50 {print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' $n | gmt psmeca $rgn $prj $ctr -Sd0.4 -Z$eqcpt -h13 $open >> $ps
            let c++
        done
    fi

    if [ $s2 == 0 ] && [ $g2 == 0 ]; then
        gmt psscale -Dj$dPos+w4c+o0.2i/0.2i+h+ma $rgn $prj $ctr -C$eqcpt1 -Bx10f5 -By+lKm $open -I --FONT_ANNOT_PRIMARY=8p >> $ps
    elif [ $s1 == 0 ] && [ $g1 == 0 ]; then
        gmt psscale -Dj$dPos+w4c+o0.2i/0.2i+h+ma $rgn $prj $ctr -C$eqcpt2 -Bx50f25 -By+lKm $open -I --FONT_ANNOT_PRIMARY=8p >> $ps
    else
        gmt psscale -Dj$dPos+w4c+o0.2i/0.2i+h+ma $rgn $prj $ctr -C$eqcpt0 -Bx50f25 -By+lKm $open -I --FONT_ANNOT_PRIMARY=8p >> $ps
    fi

else
    echo "No earthquake data available for plotting"
fi









