#!/usr/local/bin/bash

# -----------------------------------------------------------------------------
# SRTM15 plus version 2.1 Downloader - You can run the script independently to
# get the grid file or otherwise it will be called from basemap_plotter.sh
# when you don't have the grid file it's looking for.
#
#
# Author: Hendro Nugroho -- 2020/04/15
#
# -----------------------------------------------------------------------------

#
# Download gridfile from TOPEX.UCSD.EDU (Y/N?)
#
# SRTM15+V2.1 - February 10, 2020
# Details on the improvements in V2 are described in following publication.
# http://topex.ucsd.edu/sandwell/publications/180_Tozer_SRTM15+.pdf
#

echo "SRTM15+V2.1 file is available to download from topex.ucsd.edu"
echo "Do you wish to get it now? [1 = download, 2 = plot without DEM, and 3 = exit]"
select yn in "Yes" "No" "Exit"; do
    case $yn in
        Yes )
            dir=`pwd`/grd
            pushd $dir

            echo "Downloading SRTM15 plus version 2.1 into $dir"
            echo "Depending on your internet speed, the process will take some times to complete"
            echo ""

            srtm15="SRTM15+V2.1.nc"

            if [ ! -f "$srtm15" ]; then
                wget -c ftp://topex.ucsd.edu/pub/srtm15_plus/SRTM15+V2.1.nc
            fi

            popd

            echo "Working inside $dir to cut the grid file"
            echo "and to create illumination file"

            topo="grd/top15idn.grd"
            topoi="grd/top15idni.grd"

            if [ ! -f "$topo" ]; then
                gmt grdcut grd/$srtm15 -R93/143/-15/10 -G$topo
            fi

            if [ ! -f "$topoi" ]; then
                gmt grdgradient $topo -A345 -Ne0.6 -G$topoi
            fi

            break;;

        No ) echo "Continue plotting without DEM ..." ;break;;
        Exit ) echo "Exit" ;exit;;

    esac
done
