#!/usr/local/bin/bash
# -------------------
# Plotting Slab 2.0
# 2020-05-18
# by Hendro Nugroho
# -------------------

# If you have bathymetry grid file (GEBCO)
#bathy="$HOME/gmt_data/grd/bathy_idn.grd"
#cpt1="cpt/ghayes2.cpt"
#cpt1="globe.cpt"

if [ $slb == 1 ]; then

    # PEN; changed as needed
    #pen4="-W1p,white"

    # slab2 depth grid
    #sd="slab2/sum_slab2_depth.grd"
    #sd="slab2/sul_slab2_depth.grd"
    sd="slab2/hal_slab2_depth.grd"

    # regional slab
    sd_rgn="slab2/slab_rgn.grd"
    # slab cpt
    slabcpt="cpt/slabDepth.cpt"
    # scale position (x=0.2i for BL & x=9.47i for BR)
    slabscl="BL"

    # for sulawesi (z_max=-260.62)
    #gmt makecpt -Chot.cpt -T-380.0/0.0/20 -Z > $slabcpt
    # for sumatra (z_max=-673.276) & Halmahera: -675.542 >= z > -33.302
    #gmt makecpt -Chot.cpt -T-680.0/0.0/20 -Z > $slabcpt

    gmt grdcut $sd $rgn -G$sd_rgn
    gmt grdimage $sd_rgn -C$slabcpt -Q $ditto $open  >> $ps
    gmt grdcontour $sd_rgn $ditto $open -C50 -W0.5p,20 >> $ps
    gmt pscoast $ditto $pen2 $cres $open >> $ps
    gmt psscale -D0.2i/0.2i+w2.5i/0.25i+h+j$slabscl+m -C$slabcpt -Bx80+l"Slab Depth (km)" $open >> $ps
    # -DjBL+w4c+o0.2i/0.2i+h+ma
    # clean up
    rm -f $sd_rgn
fi
