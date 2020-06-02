#!/usr/local/bin/bash
# Please check BASH you use on your computer: $ which bash
# -----------------------------------------------------------------------------
# Basemap Plotter - Version 3.0 - Quickly Generate HQ basemaps covering
# Indonesia Region [-R93/143/-15/10] using GMT 5.4.5
#
# Author: Hendro Nugroho -- 2020/04/15
#
# -----------------------------------------------------------------------------

echo "+------------------------------------------------------------------------+"
echo "+                                                                        +"
echo "+                     Basemap Plotter - Version 1.0                      +"
echo "+                                                                        +"
echo "+                           by Hendro Nugroho                            +"
echo "+        The Seismology and Mathematical Geophysics Research Group       +"
echo "+    Research School of Earth Science - Australian National University   +"
echo "+                                                                        +"
echo "+  This script will plot basemap(s) of user defined region in Indonesia. +"
echo "+  Topography and bathymetry are based on SRTM15+V2.1                    +"
echo "+  If you do not have the grid file on your computer, option to download +"
echo "+  the file is provided.                                                 +"
echo "+                                                                        +"
echo "+  Main input file is maps.txt,  which contains eight variables: output  +"
echo "+  postscript file name, minimum & maximum longitude, minimum & maximum  +"
echo "+  latitude, switch of plain/fancy map frames, inset position and scale  +"
echo "+  position.                                                             +"
echo "+                                                                        +"
echo "+  Script Features:                                                      +"
echo "+                                                                        +"
echo "+   1. Quickly produce numbers of high quality basemaps for publication  +"
echo "+      or report. Landscape/Portrait mode is automatically set for you.  +"
echo "+      The layout is determined using simple Length/Width ratio.         +"
echo "+                                                                        +"
echo "+   2. Auto cutting and plotting SRTM15+V2.1 are based on region you set +"
echo "+      in the input file [maps.txt]                                      +"
echo "+                                                                        +"
echo "+   3. Coastlines resolution & map annotations are automatically adjus-  +"
echo "+      ted.                                                              +"
echo "+                                                                        +"
echo "+   4. Map inset and scale are plotted on the basemaps.                  +"
echo "+                                                                        +"
echo "+   5. Seismicity (0-300 km & 1971-2020), GCMT (0-300 km & 1976-2020),   +"
echo "+      volcanoes, Bird's plate boundaries are available for plotting.    +"
echo "+      Scientific Color Map version 6 is included as cpt options.        +"
echo "+                                                                        +"
echo "+   6. Slab 2.0 (Hayes et al., 2018) is available for plotting.          +"
echo "+                                                                        +"
echo "+   7. Produced postscript files are unclosed to enable additional la-   +"
echo "+      yer to be added using a different/personal script.                +"
echo "+                                                                        +"
echo "+------------------------------------------------------------------------+"

##### USER INPUT -----------------------------------------------------------------
##### maps.txt
##### filename.ps minlon maxlon minlat maxlat Plain-OR-Fancy-frame inset-position
##### example: Lombok.ps  115.25 117 -9.2 -7.9   1 TR  BR
###
# --------------------------------------------------------------------------------

input="data/map_test.txt"
#input="data/maps.txt"

if [ ! -f "$input" ]; then
    echo ""
    echo "Input file [ $input ] is NOT available"
    echo "Please CHECK the file and RERUN the script"
    echo ""
    exit
fi

#
# Grid files; Topo15
# If you want to plot a basemap without DEM, simply rename the files below
#
topo="grd/top15idn.grd"
topoi="grd/top15idni.grd"

if [ ! -f "$topo" ] || [ ! -f "$topoi" ]; then
    echo ""
    echo "+-----------------------------------------------------+"
    echo "+  ######  WARNING: grid file DOES NOT exist  ######  +"
    echo "             CHECK: $topo "
    echo "+                                                     +"
    echo "+-----------------------------------------------------+"
    echo ""

    source srtm15p_downloader.sh
fi

# ----------------------------------------------------------------------
#   Create several basemaps
#   data/maps.txt ==> file.ps min_lon max_lon min_lat max_lat iPos sPos
#                 ==> test.ps 100   105 0   5 TR  BR
#   filename = test.ps
#   minimum longitude = 100
#   maximum longitude = 105
#   minimum latitude = 0
#   maximum latitude = 5
#   inset position = TR [Top Right; BL = Bottom Left; etc.]
#   map scale position = TR [Map scale position - TL TC TR BL BC BR]
# ----------------------------------------------------------------------
#
while IFS=" " read -r out min_lon max_lon min_lat max_lat PoF iPos sPos
    do

gmt set PS_MEDIA A4
gmt set FORMAT_GEO_MAP DD
gmt set MAP_ANNOT_OFFSET_PRIMARY 0.1c
gmt set FONT_ANNOT_PRIMARY 10p
gmt set FONT_LABEL 10p

# Check if the map boundaries are within the grid file
#
if (( $(echo "$min_lon < 93" | bc -l) )) || (( $(echo "$max_lon > 143" | bc -l) )) || (( $(echo "$min_lat < -15" | bc -l) )) || (( $(echo "$max_lat > 10" | bc -l) )); then
    echo "Region is wider than maximum defined region [93/143/-15/10]"
    echo "Please edit the $input file"
    cat $input
    exit
fi

# Data files [data/*]
#
volc="data/world_volcanoes.gmt"

# PBIRD2003
#plate="data/bird2003.xy"

# NUVEL
# http://jules.unavco.org/GMT/Eurasian_plate
# and Australian_plate
plate="data/nuvel.gmt"
icity="data/cities-ins.gmt"
mcity="data/idn-36-cities.gmt"

# ------------------------------------------------------------------------------
###
#### USER INPUT ==> Switch ON/OFF to volcanoes (v), plate boundaries (p),
####                shallow crustal events (s1), intermediate earthquakes (s2),
####                shallow events gcmt (g1), intermediate events gcmt (g2),
###                 start (yr1) - end (yr2) year of seismicity data
####                (1971-2020 data are available), slab2 model (slb), major
####                cities (ct), inset
####
### 1=ON; 0=OFF; s1=shallow EQ (50km <=); s2=intermediate EQ (300km > eq > 50km)
# ------------------------------------------------------------------------------
################################################################################

v=0
p=0
# Seismicity and GCMT
s1=1; s2=0; iris=0; usgs=1
g1=0; g2=0

# If s == 1; start - end yr of seismicity data to be plotted
# available data: 1971-2020
yr1=1970
yr2=2020

# If s or g == 1; Position of erthquake depth scale
dPos="BL"

# slab2
slb=0

# Cities
ct=0
# Inset [On/Off]; default inset=1 [On]
inset=0

### INSET CPTs
#iLandC=olivedrab
#iLandC=gainsboro
#iLandC=255/239/219
iLandC=white
#iLandC=lightgoldenrod1
iSeaC=lightblue1

################################################################################
# ------------------------------------------------------------------------------
#
# Output directory
#
ps="outputs/$out"

# Option fancy or plain border; set up in maps.txt 6th column
#
if [[ $PoF == 1 ]]; then
    gmt set MAP_FRAME_TYPE fancy
else
    gmt set MAP_FRAME_TYPE plain
fi

# Automatic P or L layout determination based on simple Length/Width ratio;
# if layout >= ldet => Landscape, otherwise plot set in Portrait
#
tlon=`echo $max_lon - $min_lon | bc`
tlat=`echo $max_lat - $min_lat | bc`
layout=`bc -l <<< $tlon/$tlat`
ldet=1.33
# fitting in slim layout plot to A4
maxP1=0.08  # too narrow 2/25 deg
maxP2=0.12  #  2/25 deg
maxP3=0.16  #  3/25 deg
maxP4=0.20  #  4/25 deg
maxP5=0.24  #  5/25 deg
maxP6=0.28  #  6/25 deg
maxP7=0.32  #  7/25 deg
maxP8=0.48  # 12/25 deg
maxP9=0.53  # 13/25 deg
maxP10=0.56

# set initial size of volcano symbol
#
vsize="-St0.5c"

# Defined region [from inputted data via maps.txt]
#
rgn="-R$min_lon/$max_lon/$min_lat/$max_lat"

# inset box
#
echo "$min_lon $min_lat" > ibox
echo "$max_lon $min_lat" >> ibox
echo "$max_lon $max_lat" >> ibox
echo "$min_lon $max_lat" >> ibox
echo "$min_lon $min_lat" >> ibox

# Indo
#
rgi="-R93/142/-15/10"

#
###
#### optional USER INPUT == pen [default: black]
#
pen1="-Wthinnest" # default
pen2="-Wthinner"
pen3="-Wthinnest,gray" # inset
pen4="-W1p,white"

# Define coastline resolution & frame annotations+tick marks # For X-axis
#
if (( $(echo "$tlon <= 60" | bc -l) && $(echo "$tlon > 20" | bc -l) )); then
    cres="-Dl"
    frx="-Bxa10f10"
    scl="-Lj$sPos+c0+w1000k+l+f+o0.17i/0.25i"
    vsize="-St0.3c"
elif (( $(echo "$tlon <= 20" | bc -l) && $(echo "$tlon > 10" | bc -l) )); then
    cres="-Di"
    frx="-Bxa5f5"
    scl="-Lj$sPos+c0+w500k+l+f+o0.17i/0.25i"
    vsize="-St0.3c"
elif (( $(echo "$tlon <= 10" | bc -l) && $(echo "$tlon > 5" | bc -l) )); then
    cres="-Dh"
    frx="-Bxa2f2"
    scl="-Lj$sPos+c0+w250k+l+f+o0.17i/0.25i"
elif (( $(echo "$tlon <= 5" | bc -l) && $(echo "$tlon > 2" | bc -l) )); then
    cres="-Df"
    frx="-Bxa1f1"
    scl="-Lj$sPos+c0+w75k+l+f+o0.17i/0.25i"
elif (( $(echo "$tlon <= 2" | bc -l) && $(echo "$tlon > 1" | bc -l) )); then
    cres="-Df"
    frx="-Bxa0.5f0.5"
    scl="-Lj$sPos+c0+w25k+l+f+o0.17i/0.25i"
else
    cres="-Df"
    frx="-Bxa0.25f0.25"
    scl="-Lj$sPos+c0+w10k+l+f+o0.17i/0.25i"
fi

#
# Define coasline and frame annotations+tick marks # For Y-axis
#

if (( $(echo "$tlat <= 60" | bc -l) && $(echo "$tlat > 20" | bc -l) )); then
    fry="-Bya10f10"
elif (( $(echo "$tlat <= 20" | bc -l) && $(echo "$tlat > 10" | bc -l) )); then
    fry="-Bya5f5"
elif (( $(echo "$tlat <= 10" | bc -l) && $(echo "$tlat > 5" | bc -l) )); then
    fry="-Bya2f2"
elif (( $(echo "$tlat <= 5" | bc -l) && $(echo "$tlat > 2" | bc -l) )); then
    fry="-Bya1f1"
elif (( $(echo "$tlat <= 2" | bc -l) && $(echo "$tlat > 1" | bc -l) )); then
    fry="-Bya0.5f0.5"
else
    fry="-Bya0.25f0.25"
fi

# Frame annotations
# frame label
#frl="-BWESN"
frl="-BWeSn" # default
#frl="-BwEsN"
#frl="-BwESn"
#frl="-BWesN"
#frl="-bwesn"

# Color palette
#
cpt1="cpt/asym.cpt" # default
#cpt1="cpt/gray10.cpt" #

# Abyss & mod. Arctic [topo default]
# cpt1="cpt/asym.cpt"
# gmt makecpt -Cabyss -T-7500/0/250 -Z -N > $cpt1
# gmt makecpt -Cmod_arctic.cpt -T0/3000/500 -Z >> $cpt1

# Eq cpt [based on no_green.cpt; 0: for eq <= 300 km, 1: eq <= 50 km, and 3: 50 km < eq <= 300 km]
#
eqcpt0="cpt/eq_d_upto300.cpt"
eqcpt1="cpt/eq_dle50.cpt"
eqcpt2="cpt/eq_dlt300.cpt"

# Centering and offset
#
ctr="-Xc"
yctr="-Yc"
xctr="-Xc -Yc" # default
xoff="-X0i"
yoff="-Y2.5i"

# Postscript layers
#
ditto="-R -J"
add="-K"
open="-O -K"
close="-O"

# Grid file
#
#topo_rgn="grd/any-filename-not-in-the-dir.grd"      # uncomment if you don't want to plot DEM
topo_rgn="grd/topo_rgn.grd"                         # default [temporary grid]
topo_rgni="grd/topo_rgni.grd"                       # used if clipping is on

# Second check if grid files exist
#
if [ -f "$topo" ] && [ -f "$topoi" ]; then
    echo ""
    echo ""
    t=1
    gmt grdcut $topo $rgn -G$topo_rgn

    # comment out if you want gray scale topo with abyss sea
    #
    #gmt grdgradient $topo_rgn -A345 -Ne0.6 -G$topo_rgni
    #gmt grd2cpt $topo_rgn -Cgray > $gcpt    # gray cpt

else
    echo ""
    echo "+--------------------------------------------------+"
    echo "+  ######  WARNING: topo15 DOES NOT exist  ######  +"
    echo " Check: $topo "
    echo "+ Plotting without topography and bathymetry data  +"
    echo "+--------------------------------------------------+"
    echo ""
    t=0
fi

# Cleaning
#
if [ -f "$ps" ]; then
    #echo "Deleting old $ps if any..."
    rm -f $ps
fi

echo "Plotting [ $out ] basemap"

# Layout determination --> P or L; # Max width; P=6.25i L=9.67i
# if t=1, plot dem
if (( $(echo "$layout <= $maxP1" | bc -l) )); then
    echo "Map layout is too narrow to plot..."
    echo "You better do it manually"
    exit
elif (( $(echo "$layout > $maxP1" | bc -l) )) && (( $(echo "$layout <= $maxP2" | bc -l) )); then
    prj="-JM1i"
    prji="-JM0.75i"
    scl="-Lj$sPos+c0+w250k+l+f+o0.17i/0.25i"
    add="-K -P"
elif (( $(echo "$layout > $maxP2" | bc -l) )) && (( $(echo "$layout <= $maxP3" | bc -l) )); then
    prj="-JM1.5i"
    prji="-JM1.25i"
    iPos="TC"
    scl="-Lj$sPos+c0+w250k+l+f+o0.17i/0.25i"
    add="-K -P"
elif (( $(echo "$layout > $maxP3" | bc -l) )) && (( $(echo "$layout <= $maxP4" | bc -l) )); then
    prj="-JM2i"
    prji="-JM1.5i"
    iPos="TC"   #5
    scl="-Lj$sPos+c0+w250k+l+f+o0.17i/0.25i"
    add="-K -P"
elif (( $(echo "$layout > $maxP4" | bc -l) )) && (( $(echo "$layout <= $maxP5" | bc -l) )); then
    prj="-JM2.5i"
    prji="-JM2i"
    iPos="TC" # 6 deg ; decent map
    add="-K -P"
elif (( $(echo "$layout > $maxP5" | bc -l) )) && (( $(echo "$layout <= $maxP6" | bc -l) )); then
    prj="-JM3i"
    prji="-JM2i"
    add="-K -P"
elif (( $(echo "$layout > $maxP6" | bc -l) )) && (( $(echo "$layout <= $maxP7" | bc -l) )); then
    prj="-JM3.5i"
    prji="-JM2i"
    add="-K -P"
elif (( $(echo "$layout > $maxP7" | bc -l) )) && (( $(echo "$layout <= $maxP8" | bc -l) )); then
    prj="-JM4i"
    prji="-JM2i"
    add="-K -P"
elif (( $(echo "$layout > $maxP8" | bc -l) )) && (( $(echo "$layout <= $maxP9" | bc -l) )); then
    prj="-JM5.25i"
    prji="-JM2i"
    add="-K -P"
elif (( $(echo "$layout > $maxP9" | bc -l) )) && (( $(echo "$layout <= $maxP10" | bc -l) )); then
    prj="-JM6i"
    prji="-JM2i"
    add="-K -P"
elif (( $(echo "$layout > $maxP10" | bc -l) )) && (( $(echo "$layout < $ldet" | bc -l) )); then
    prj="-JM6.25i"
    prji="-JM2i"
    add="-K -P"
else
    prj="-JM9.67i"
    prji="-JM3i"
fi

# Determine size of insert map of Indonesia
# result: x0, y0, (w)idth (h)eight
#
gmt mapproject $rgi $prji -W > tmp

var="-Glightgray -N1,0.25p,blue,-" # used if no grid file available
#var="-N1,0.25p,blue,-"
gmt psbasemap $rgn $prj $frx $fry $frl $ctr $add > $ps

if (( $t == 1 )) && (( $slb == 0 )); then
    var=""
    gmt grdimage $topo_rgn $ditto $open -C$cpt1 -I+a45+nt1 $ctr >> $ps
    #
    # Preparing a map clipper
    #gmt pscoast $ditto $ctr -Di -Gc $open >> $ps
    #gmt grdimage $topo_rgn $ditto $ctr -I+a45+nt1 -C$gcpt $open >> $ps
    #gmt pscoast $ditto -B $ctr $open -Q >> $ps
fi

#
gmt pscoast $ditto $pen1 $cres $frx $fry $frl $scl $var $ctr $open >> $ps

# if seis. or gcmt plot requested
#
if [ $s1 == 1 ] || [ $s2 == 1 ] || [ $g1 == 1 ] || [ $g2 == 1 ]; then
    # run the seismicity script
    source seismicity.sh
fi

################### YOUR PLOT ON TOP OF BASEMAP ####################
# source lombok.sh
####################################################################
# DCW option for TL boundary
#
#gmt pscoast $ditto $pen1 $cres $frx $fry $frl $scl $var -ETL+pthinnest $ctr $open >> $ps

# TIMOR-LESTE --- DCW
#
#gmt pscoast $ditto $pen1 $cres $frx $fry $frl $scl $var -ETL+pthinnest $ctr $open >> $ps

# if slab plot is requested
if [ $slb == 1 ]; then
    source slab2-plotter.sh
fi

# TIMOR-LESTE BORDER (USED ONLY IF TIMOR ISLAND is plotted)
#
if [ $t == 0 ]; then
  gmt psxy data/tles_idn_border.gmt $ditto $ctr $pen1 $open >> $ps
  #gmt psxy $HOME/Downloads/tl_adm.gmt $ditto $ctr $pen1 $open >> $ps
fi

# if volc. data exist, and v switch is on
if [ -f "$volc" ] && [ $v == 1 ]; then
    echo "Plotting volcano of the world"
    gmt psxy $volc $ditto $vsize -h1 -Gred $ctr $open >> $ps
fi

# if $plate is exist, and p switch is ON
if [ -f "$plate" ] && [ $p == 1 ]; then
    echo "Plotting Bird's Plate Boundaries"
    gmt psxy $plate $rgn $prj $ctr -W0.5p,red $open >> $ps
fi

# if $mcity is exist and ct switch is ON
if [ -f "$mcity" ] && [ $ct == 1 ]; then
    echo "Plotting major cities in Indonesia"
    awk '{print $1, $2}' $mcity | gmt psxy $mcity $ditto -Sc-0.1c -Gbrown1 $open >> $ps
    gmt pstext $mcity $ditto -F+f8p,Helvetica-Narrow+a0+j $open -D0.1c/0.0c >> $ps
    # 6p,Helvetica-Narrow 0 LM
fi

if (( $(echo "$inset == 1" | bc -l) )); then

# INSET
# check if it is a big area; use global map
#
    if (( $(echo "$tlon > 40" | bc -l) )); then
        # -F+gwhite+p0.25p,white+c0.1c # <== if you need a white bounding box
        gmt psbasemap $ditto $open -Dj$iPos+o0.2c+w1.5i+o0.15i/0.1i+stmp -F+c0.1c --MAP_FRAME_TYPE=plain >> $ps
        read x0 y0 w h < tmp
        gmt pscoast -Rg -JG120/5S/$w -Da -Ggray -A5000 -Swhite -Bg -Wfaint -EID+gbisque $open -X$x0 -Y$y0 >> $ps
        # inset box
        gmt psxy ibox $ditto -W1p,red $open >> $ps
    else
        read w h < tmp
        #-Dj$iPos+o0.2c+w$w/$h+o0.15i/0.1i+stmp -F+gwhite+p0.25p,white+c0.1c
        gmt psbasemap $ditto $open -Dj$iPos+o0.2c+w$w/$h+stmp -F+gwhite --MAP_FRAME_TYPE=plain >> $ps
        read x0 y0 w h < tmp
        # Da = auto
        gmt pscoast $rgi -JM$w -B0 -Dl $pen3 $open -G$iLandC -S$iSeaC -X$x0 -Y$y0 --MAP_FRAME_TYPE=plain >> $ps
        # Toponimi
        gmt pstext $icity $ditto -F+f+a+j $open -D0.05c/0.0c >> $ps
        awk '{print $1, $2}' $icity | gmt psxy $ditto -Sc-0.09c -Gbrown1 $open >> $ps
        # inset box
        gmt psxy ibox $ditto -W1p,red $open >> $ps
    fi
fi

# cleaning up
rm -f gmt.conf gmt.history $topo_rgn tmp ibox #$eqcpt0 $eqcpt1 $eqcpt2 $sd_rgn

done < "$input"

echo ""
echo "Done!"
echo ""

### Reminder: PS file is NOT closed to allow you adding specific plots from your own script
### If you want to close it (to avoid gmt psconvert complain), simply replace $open on the last line (# 553) with $close.
###
#
# macOS
open $ps

#linux
# gs $ps
# gv $ps
