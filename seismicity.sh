#!/usr/local/bin/bash

# -----------------------------------------------------------------------------
# Seismicity data plotter - Covering Indonesia Region [93/143/-15/10]
# Data were downloaded from IRIS Wilber3 [1971-2020] and NEIC-USGS [1970-2020]
# GCMT data acquired from globalcmt.org
#
# Author: Hendro Nugroho -- 2020/04/15
#
# -----------------------------------------------------------------------------
# GCMT
cmts=("gcmt/gcmt_11_20.gmt" "gcmt/gcmt_01_10.gmt" "gcmt/gcmt_91_00.gmt" "gcmt/gcmt_81_90.gmt" "gcmt/gcmt_76_80.gmt")
gyrs=("2011 to 2020" "2001 to 2010" "1991 to 2000" "1981 to 1990" "1976 to 1980")
# IRIS and USGS
fn="seism/iris_710101-200416_gtm3_le300km_"
fn2="seism/usgs_700101-200602_gtm3_le300km_"

# check earthquake files
#
if [ $yr1 -lt 1970 ] || [ $yr1 -gt 2020 ] || [ $yr2 -lt 1970 ] || [ $yr2 -gt 2020 ]; then
    echo ""
    echo "Requested data out of range"
    echo ""
    exit
fi

echo ""
echo "Checking requested earthquake data files from IRIS and NEIC"

c1=0; c2=0
uchk=`eval echo seism/usgs_700101-200602_gtm3_le300km_{$yr1..$yr2}.txt`
ichk=`eval echo seism/iris_710101-200416_gtm3_le300km_{$yr1..$yr2}.txt`

test=($uchk $ichk)

#for f in $uchk; do
for f in "${test[@]}"; do

    if [ ! -f "$f" ]; then
        echo "$f file does not exist"
        let c1++
    else
        #echo "$f file exist"
        let c2++
    fi

done

if [ $c2 == 0 ]; then
    echo ""
    echo "Data you requested is not available. Please check the directory ..."
    echo ""
elif [ $c1 == 0 ]; then
    echo ""
    echo "All earthquake data files are available for plotting"
    echo ""
else
    echo ""
    echo "Mising $c1 files"
    echo ""
fi

### CPT for seismicity
# scm6
#cptf2="cpt/scm6/roma.cpt"

#cptf2="viridis.cpt"
# default [now]
cptf2="no_green"

# if s1 or s2 = 1
# if seis data exist and shallow eq switch is ON
n_iris=`ls -1 $fn* 2>/dev/null | wc -l`
n_usgs=`ls -1 $fn2* 2>/dev/null | wc -l`

if [ $iris == 1 ] && [ $n_iris -eq 50 ] || [ $usgs == 1 ] && [ $n_usgs -eq 51 ]; then

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


    if [ $s1 == 1 ] && [ $iris == 1 ]; then
        echo "Plotting shallow earthquake data from ISC catalog covering period of $yr1 to $yr2"
        for ((y=$yr1; y<=$yr2; ++y));
            do
            awk -F"|"  'NR > 1 && $5 <= 50 {print $4, $3, $5, $11}' $fn$y.txt | gmt psxy $rgn $prj $open -C$eqcpt -Sci -Wfaint -i0,1,2,3+s0.015 >> $ps
        done

    elif [ $s2 == 1 ] && [ $iris == 1 ]; then
        echo "Plotting intermediate depth data from ISC catalog covering period of $yr1 to $yr2"
        for ((y=$yr1; y<=$yr2; ++y));
            do
            awk -F"|"  'NR > 1 && $5 > 50 {print $4, $3, $5, $11}' $fn$y.txt | gmt psxy $rgn $prj $open -C$eqcpt -Sci -Wfaint -i0,1,2,3+s0.015 >> $ps
        done
    elif [ $s1 == 1 ] && [ $usgs == 1 ]; then
        echo "Plotting shallow earthquake data from NEIC catalog covering period of $yr1 to $yr2"
        for ((y=$yr1; y<=$yr2; ++y));
            do
            awk -F","  'NR > 1 && $4 <= 50 {print $3, $2, $4, $5}' $fn2$y.txt | gmt psxy $rgn $prj $open -C$eqcpt -Sci -Wfaint -i0,1,2,3+s0.015 >> $ps
        done
    elif [ $s2 == 1 ] && [ $usgs == 1 ]; then
        echo "Plotting intermediate depth data from NEIC catalog covering period of $yr1 to $yr2"
        for ((y=$yr1; y<=$yr2; ++y));
            do
            awk -F","  'NR > 1 && $4 > 50 {print $3, $2, $4, $5}' $fn2$y.txt | gmt psxy $rgn $prj $open -C$eqcpt -Sci -Wfaint -i0,1,2,3+s0.015 >> $ps
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
elif [ $iris == 1 ] && [ $n_iris -gt 0 ] && [ $n_iris -lt 50 ] || [ $usgs == 1 ] && [ $n_usgs -gt 0 ] && [ $n_usgs -lt 51 ]; then
    echo "Earthquake data is not complete for plotting"
else
    echo "No earthquake data available for plotting"
fi
