#!/usr/local/bin/bash
# Get earthquake data from USGS using the curl)
# The setup is to get M > 3.0, depth < 300 km, and covering lon.-lat. [93/143/-15/10]
#
# by Hendro Nugroho
# 2020-06-01
#
# USAGE: ./fetch_eq.sh
# Downloaded data will be in the SEISM folder

site="https://earthquake.usgs.gov/fdsnws/event/1/query.csv"
lon="minlatitude=-15&maxlatitude=10"
lat="minlongitude=93&maxlongitude=143"
mag="minmagnitude=3"
maxDEP="maxdepth=300"
#ORDER="orderby=magnitude"
order="orderby=time"

if [ `ls -1 seism/usgs_700101-200602_gtm3_le300km_* 2>/dev/null | wc -l` -eq 0 ]; then

    #for st in {1970..2020..5}; do # data grouped into 5-year chunks
    for st in {1970..2020}; do

        et=`echo $(( ${st} + 1 ))`
        endt="$et-01-01"
        #endt="$et-12-31"

        if (( $st == 2020 )); then
            endt=`echo $(date '+%Y-%m-%d')`
            et=$endt
        fi

        TIME="starttime=$st-01-01%2000:00:00&endtime=$endt%2000:00:00"
        URL="${site}?${TIME}&${lon}&${lat}&${maxDEP}&${mag}&${order}"
        out="seism/usgs_700101-200602_gtm3_le300km_$st.txt"
        echo ""
        echo "Fetching earthquake data from USGS starting in $st to $et"

        curl -s $URL > $out
    done
else
    echo ""
    echo "Data exists. Do you want to fetch the latest events?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) echo "Please wait while the latest events are fetched...";

            endt=`echo $(date '+%Y-%m-%d')`
            yr=`echo $(date +%Y)`
            TIME="starttime=2020-01-01%2000:00:00&endtime=$endt%2000:00:00"
            URL="${site}?${TIME}&${lon}&${lat}&${maxDEP}&${mag}&${order}"

            curl -s $URL > seism/usgs_700101-200602_gtm3_le300km_$yr.txt

            break;;

            No ) echo "";echo "All is well... Goodbye!" ;echo "";exit;;
        esac
    done
fi

echo ""
echo "Done!"
echo ""
