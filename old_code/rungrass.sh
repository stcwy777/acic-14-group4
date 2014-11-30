#!/bin/bash
#Arg passing
reso=$1
dst_dem=$2
dst_dicatch=$3
prcp_tiff=$4
nadem_tiff=$5
tmax_tiff=$6
tmin_tiff=$7

#Naming
suffix=`echo -n n${north}s${south}e${east}w${west}|md5sum`

dst_dem="dst_dem.${suffix}.tiff"
dst_dicatch="dst_dicatch.${suffix}.tiff"
dicatchmentmap="dicatchmentmap.${suffix}"
demmap="demmap.${suffix}"
prcpmap="prcpmap.${suffix}"
nademmap="nademmap.${suffix}"
tminmap="tminmap.${suffix}"
tmaxmap="tmaxmap.${suffix}"
tempmap="tempmap.${suffix}"
slopeoutput="slopeoutput.${suffix}"
aspectoutput="aspectoutput.${suffix}"
beamradoutput="beamradoutput.${suffix}"
insoltimeoutput="insoltimeoutput.${suffix}"
diffradoutput="diffradoutput.${suffix}"
reflradoutput="reflradoutput.${suffix}"
globradradoutput="globradoutput.${suffix}"
tempoutput="tempoutput.${suffix}"
twioutput="twioutput.${suffix}"
meantwioutput="meantwioutput.${suffix}"
aioutput="aioutput.${suffix}"
nppoutput="nppoutput.${suffix}"
nppoutput="nppoutput.${suffix}"
eemtoutput="eemtoutput.${suffix}"
eemt_tif="eemt.${suffix}.tiff"

#Read tiff files
r.external input="${dst_dicatch}" band=1 output=$dicatchmentmap --overwrite -o -r
r.external input="${dst_dem}" band=1 output=$demmap --overwrite -o -r
r.external input="${prcp_tiff}" band=1 output=$prcpmap --overwrite -o -r
r.external input="${nadem_tiff}" band=1 output=$nademmap --overwrite -o -r
r.external input="${tmin_tiff}" band=1 output=$tminmap
r.external input="${tmax_tiff}" band=1 output=$tmaxmap

#specify the focal region
g.region raster=$demmap res=$reso
r.mapcalculator amap=$tminmap bmap=$tmaxmap formula="(A+B)/2" output=$tempmap
#Aspect & Slope
r.slope.aspect elevation=$demmap slope=$slopeoutput aspect=$aspectoutput
#Solar Radiation
aspmap=$aspectoutput
slopemap=$slopeoutput
r.sun elevin=$demmap aspin=$aspmap slopein=$slopemap day="1" step="0.5" dist="1" -s beam_rad=$beamradoutput insol_time=$insoltimeoutput diff_rad=$diffradoutput refl_rad=$reflradoutput glob_rad=$globradoutput 
#Localizationg of temp
dem10=$demmap
dem1k=$nademmap
simap=$globradoutput
r.mapcalculator amap=$tempmap bmap=$dem10 cmap=$dem1k dmap=$simap formula="A-6.49/1000*(B-C)+(D-1/D)" output=$tempoutput
#PET Calculation
#r.mapcalculator amap=$tminlocmap bmap=$tmaxlocmap formula="(0.6108*exp((12.27*A)/(A+273.3))+0.6108*exp((12.27*B)/(B+273.3)))/2" output=$vpsoutput
#r.mapcalculator amap=$tminlocmap bmap=$tmaxlocmap formula="(A+B)/2" output=$tmeanoutput
#$daylighthours=$insoltimeoutput
#$satvpmap=$vpsoutput
#$tmeanmap=$tmeanoutput
#r.mapcalculator amap=$daylighthours bmap=$satvpmap cmap=$tmeanmap formula="(2.1*(A^2)*B)/(C+273.2)" output=$petoutput
#AET Calculation
#$petmap=$petoutput
#r.mapcalculator amap=$petmap bmap=$prcpmap formula="B*(1+A/B-(1+(A/B)^2.63)^(1/2.63))" output=$aetoutput
#TWI Calculation
r.mapcalculator amap=$dicatchmentmap bmap=$slopmap formula="log(A/(tan(B)))" output=$twioutput
r.average base=$dicatchmentmap cover=$twimap output=$meantwioutput
#a_i Calculation
twimap=$twioutput
meantwimap=$meantwioutput
r.mapcalculator amap=$twimap bmap=$meantwimap formula="A/B" output=$aioutput
#NPP Calculation
meanannualtemp=$tempmap
r.mapcalculator amap=$meanannualtemp formula="3000*(1+exp(1.315-0.119*A))^(-1)" output=$nppoutput
#Traditional EEMT
aimap=$aioutput
peffmap=$prcpmap
tempmap=$tempoutput
nnpmap=$nppoutput
r.mapcalculator amap=$aimap bmap=$peffmap cmap=$tempmap dmap=$nnpmap formula="A*B*4185.5*(C-273.15)+D*22*10^6" output=$eemtoutput
#Output file
g.region rast=$eemtoutput
r.out.gdal -c createopt="TFW=YES,COMPRESS=LZW" input=$eemtoutput output=$eemt_tif
