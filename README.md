# GMT Basemap Plotter

by **Hendro Nugroho**

## **Purpose:**

Quickly plot multiple basemaps from inputted region of interests (ROIs) using [GMT version 5.4.5](https://github.com/GenericMappingTools/gmt/releases/tag/5.4.5) on A4 size media (595 by 842 points ~ 793.34 by 1,122.67 pixels). Grid file included is only covering Indonesia region [Lon.: 93-143; Lat.:-15-10].

## **Features:**
   * Plot is designed to maximize space usage on A4 size media [8.27 x 11.69 in or 210 x 297 mm; gmt set PS_MEDIA A4].
   * Portrait and landscape mode is automatically set based on simple length/width ratio of Longitude/Latitude.
   * Portrait mode produces 6.25 inches plot with 2.02 inches total margin (left and right margin).
   * Landscape mode outputs 9.67 inches plot with similar margin size to the portrait mode.
   * If script couldn't find grid file on your computer, it will give you option to download it from [topex.ucsc.edu](ftp://topex.ucsd.edu/pub/srtm15_plus) or continue plotting the basemap without DEM.
   * Main input file is **maps.txt** in which output filenames, ROIs, PoF switch (Plain [0] or Fancy [1] map frame switch), iPos (inset map position), sPos (map scale position) are set.
   * Coastline resolution, annotation and minor tick, and map scale are determined from total length of ROI Longitude/Latitude. Following table shows the assigned values:

| ROI length | Coastline Resolution | Annotation & Minor Tick | Map Scale |
|:----------:|:--------------------:|:-----------------------:|:---------:|
| 60 - >20   | Low                  | 10&deg;              | 1000 km   |
| 20 - >10   | Intermediate         |  5&deg;              |  500 km   |
| 10 -  >5   | High                 |  2&deg;              |  250 km   |
|  5 -  >2   | Full                 |  1&deg;               |   75 km   |
|  2 -  >1   | Full                 |  0.5&deg;            |   25 km   |
|  1 -  >0   | Full                 |  0.25&deg;           |   10 km   |

   * **Seismicity** data downloaded from [IRIS Wilber3](http://ds.iris.edu/wilber3/find_event) website with the following criteria
      1. Covering Longitude from 93&deg; to 143&deg; East, Latitude from -15&deg; South to 10&deg; North,
      2. Events dated from 1971-01-01 to 2010-04-16
      3. Magnitude >3.0 and depth range from 0-300 km [shallow to medium earthquakes only]. There are 167349 total events recorded.
      4. Earthquake events grouped into two categories: *Shallow Events (0-50 km depth)* and *Intermediate Events (>50-300 km depth)

* **Volcanoes** data are downloaded from Global Volcanism Program ([Global Volcanism Program, 2013. Volcanoes of the World, v. 4.7.6. Venzke, E (ed.). Smithsonian Institution]( https://doi.org/10.5479/si.GVP.VOTW4-2013). Downloaded 25 Feb 2019).

* [**Global CMT**](https://www.globalcmt.org) data is available from 1976 to 2016 ( [Dziewonski et al., 1981](https://doi:10.1029/JB086iB04p02825); [Ekstrom et al., 2012](https://doi:10.1016/j.pepi.2012.04.002) ).

* [**Scientific colour-maps.** Crameri, F. (2018)](http://doi.org/10.5281/zenodo.1243862)

## **Files and Folders:**

Currently there are two main scripts: **_basemap_plotter.sh_** and **_srtm15p_downloader.sh_** and **_README.md_** (This file) in the main folder. Four folders are there to put cpt files (**cpt** folder), grid files (**grd** folder), various input data (**data** folder), postscript results (**outputs**), and images of this document (**images** folder).

<div align="center"><img src="./images/ff.jpg" alt="files and folders" style="zoom:30%;" /></div>

<div align="center"><b>Figure 1.</b> Files and folders structure</div>

## **Examples:**
It is quite simple to create several basemaps. Let say we want to have four basemaps plotted: Bali and Lombok Island to the extent of Java Trench, Lombok Island, Banda Arc transitional zone, and Singapore. First, we need to edit **maps.txt** located in **data folder** and input six parameters: 1) file names, minimum longitudes, maximum longitudes, minimum latitudes, maximum latitudes, and logical switch for map frames. Following is the content input file listed four maps we are going to make:

```
Bali_and_Lombok.ps  112 120 -12 -4   0   TR  BR
Bali.ps 114.4   115.8   -9.05    -7.95    0   BL  TR
Lombok.ps  115.25 117 -9.2 -7.9   1   TL  BR
Banda.ps   118.5   127.5   -12.5   -7   1   BR  BC
Singapore.ps 100    105 0   5   0   TR  BR
Indo.ps 93  143 -15 10  0   TR  BR
Aceh.ps 94.88   98.32   1.28    6.21    0   BL  BR
Sumut.ps   96.83   100.66  -1.00    4.33    0   TR  BL
```

If you don't have SRTM15 plus grid file, **_srtm15p_downloader.sh_** will download and prepare the file in the grd directory. Please be patient **SRTM15+V2.1.nc** is a big file (~6Gb). After download process is completed, two new grid files will be created: **srtm15idn.grd** (DEM file covering Indonesia region) and **srtm15idni.grd** (for illumination).

To run the script, simply type in the script name in the terminal windows:

``` bash
$ ./srtm15p_downloader.sh

SRTM15+V2.1 file is available to download from topex.ucsd.edu
Do you wish to get it now?
1) Yes
2) No
3) Exit
#? 1
~/gmt-basemap-plotter/grd ~/basemap_plotter
Downloading SRTM15 plus version 2.1 into /Users/seismo/gmt-basemap-plotter/grd
Depending on your internet speed, the process will take some times to complete
.
. showing details of downloading process and progress
.
Working inside /Users/seismo/gmt-basemap-plotter/grd to cut the grid file
and to create illumination file
Done! Going back to main directory now
```

Running the script below will produce maps we wants.

```bash
$ ./basemap_plotter.sh

Plotting [ Bali_and_Lombok.ps ] basemap

Plotting [ Bali.ps ] basemap

Plotting [ Lombok.ps ] basemap

Plotting [ Banda.ps ] basemap

Plotting [ Singapore.ps ] basemap

Plotting [ Indo.ps ] basemap

Plotting [ Aceh.ps ] basemap

Plotting [ Sumut.ps ] basemap

Done!

$
```

Following are the results:

<img src="./images/Bali_and_Lombok.jpg" alt="Bali_and_Lombok" style="zoom:50%;" />

<div align="center"><b>Figure 2.</b> Basemap of Bali and Lombok Island with plain map frames.</div>

<img src="./images/basic-maps-asym/Bali.jpg" alt="Bali" style="zoom:50%;" />

<div align="center"><b>Figure 3.</b> Basemap of Bali Island in fancy map frames.</div>

<img src="./images/basic-maps-asym/Lombok.jpg" alt="Lombok Island" style="zoom:32%;" />

<div align="center"><b>Figure 4.</b> Basemap of Lombok Island plotted in landscape mode inside fancy frames.</div>

<img src="./images/basic-maps-asym/Singapore.jpg" alt="Singapore" style="zoom:50%;" />

<div align="center"><b>Figure 5.</b> Basemap of Singapore region plotted automatically in portrait mode using plain map frames.</div>

<img src="./images/basic-maps-asym/Indo.jpg" alt="Indonesia" style="zoom:70%;" />

<div align="center"><b>Figure 6.</b> Basemap of Indonesia region plotted automatically in landscape mode using plain map frames.</div>

<img src="./images/basic-maps-asym/Aceh.jpg" alt="Aceh Province" style="zoom:50%;" />

<div align="center"><b>Figure 7.</b> Basemap of Aceh Province plotted automatically in portrait mode using plain map frames.</div>

<img src="./images/basic-maps-asym/Sumut.jpg" alt="North Sumatra Province" style="zoom:50%;" />

<div align="center"><b>Figure 8.</b> Basemap of North Sumatra Province (Propinsi Sumatera Utara) plotted automatically in portrait mode using plain map frames.</div>

## **Other Features:**

<img src="./images/Indo.jpg" alt="Indonesia" style="zoom:70%;" />

<div align="center"><b>Figure 9.</b> Basemap of Indonesia region plotted automatically in lanscape mode without DEM using plain map frames. Major cities Indonesia are plotted.</div>

<img src="./images/seismicity/Indo-eq15to20.jpg" alt="Indonesia" style="zoom:70%;" />

<div align="center"><b>Figure 9.</b> Basemap of Indonesia region plotted automatically in lanscape mode without DEM using plain map frames. Shallow crustal event (depth of < 50km) in 5 year periods (2015-2020) are plotted on the map.</div>

<img src="./images/seismicity/Indo-gcmt.jpg" alt="Indonesia" style="zoom:70%;" />

<div align="center"><b>Figure 10.</b> Basemap of Indonesia region plotted automatically in lanscape mode without DEM using plain map frames. GCMT data are plotted on the map.</div>

<img src="./images/basic-maps-gray10/Indo.jpg" alt="Indonesia" style="zoom:70%;" />

<div align="center"><b>Figure 11.</b> Basemap of Indonesia region plotted automatically in lanscape mode in plain map frames. Gray10 color palette is implemented.</div>

## **REFERENCES:**

Bird, P. (2003). An updated digital model of plate boundaries. *Geochemistry, Geophysics, Geosystems*, *4*(3).

Crameri, F. (2019, January). Scientific Colour Maps: Reducing error across the Geodynamics community. In *Geophysical Research Abstracts* (Vol. 21).

Dziewonski, A. M.,  Chou, T.‐A., and  Woodhouse, J. H. ( 1981),  Determination of earthquake source parameters from waveform data for studies of global and regional seismicity, *J. Geophys. Res.*,  86( B4),  2825– 2852, doi:[10.1029/JB086iB04p02825](https://doi.org/10.1029/JB086iB04p02825).

Ekström, G., Nettles, M., & Dziewoński, A. M. (2012). The global CMT project 2004–2010: Centroid-moment tensors for 13,017 earthquakes. *Physics of the Earth and Planetary Interiors*, *200*, 1-9. doi: [10.1016/j.pepi.2012.04.002](https://doi.org/10.1016/j.pepi.2012.04.002)

Wessel, P.,  Smith, W. H. F.,  Scharroo, R.,  Luis, J. and  Wobbe, F. ( 2013),  Generic Mapping Tools: Improved Version Released, *Eos Trans. AGU*,  94( 45),  409.

