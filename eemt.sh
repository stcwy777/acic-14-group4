#!/bin/bash
#conf
stepsize=0.5
interval=1
#set up envvar for UAHPC only
export GISBASE=/gsfs1/xdisk/nirav/grass/grass-6.4.4
export PATH="$GISBASE/bin:$GISBASE/scripts:$PATH"
export LD_LIBRARY_PATH="/gsfs1/xdisk/nirav/grass/grass-6.4.4/lib:/gsfs1/xdisk/nirav/grass-6.4.4/ext/lib:/gsfs1/xdisk/nirav/lib"
export GRASS_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export GISRC=$HOME/.grassrc
#update project info
g.proj -c proj4="+proj=lcc +lat_1=25 +lat_2=60 +lat_0=42.5 +lon_0=-100 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
#loop head
#input
g.mremove -f "*"
r.in.gdal input=$1 output=dem_10m
r.in.gdal input=$2 output=tmin
r.in.gdal input=$3 output=tmax
r.in.gdal input=$4 output=twi
r.in.gdal input=$5 output=prcp
r.in.gdal input=$6 output=dem_1km
tmincount=`g.mlist type=rast pattern="tmin.*"|wc -l`
tmaxcount=`g.mlist type=rast pattern="tmax.*"|wc -l`
prcpcount=`g.mlist type=rast pattern="prcp.*"|wc -l`
iter=1
if [ $tmincount -lt $tmaxcount]
then
iter=$tmincount
else
iter=$tmaxcount
fi
if [ $iter -lt $prcpcount]
then
iter=$prcpcount
fi
#set region
g.region rast=dem_10m
#run model
r.slope.aspect elevation=dem_10m slope=slope aspect=aspect
#r.sun -s elevin=dem_10m aspin=aspect slopein=slope day="1" step="0.05" dist="1" insol_time=hours_sun glob_rad=total_sun
r.mapcalc "zeros=if(dem_10m>0,0,null())"
#r.sun elevin=dem_10m aspin=zeros slopein=zeros day="1" step="0.05" dist="1" glob_rad=flat_total_sun  
#r.mapcalc "S_i=total_sun/flat_total_sun"
r.mapcalc "a_i=twi/((max(twi)+min(twi))/2)"
r.mapcalc "c_w=4185.5"
#r.mapcalc "NPP=0"
r.mapcalc "h_bio=22*10^6"
#loop over days on temp
for((t=1;t<=365;t++))
do
day=$(($t*$interval))
echo "t=${t}\tday=${day}\n"
eemt_tif="eemt_${t}.tif"
r.sun -s elevin=dem_10m aspin=aspect slopein=slope day="${day}" step="${stepsize}" dist="1" insol_time=hours_sun_${t} glob_rad=total_sun_${t}
r.sun elevin=dem_10m aspin=zeros slopein=zeros day="${day}" step="${stepsize}" dist="1" glob_rad=flat_total_sun_${t}
r.mapcalc "S_i_${t}=total_sun_${t}/flat_total_sun_${t}"
r.mapcalc "tmin_loc_${t}=tmin.${t}-0.00649*(dem_10m-dem_1km)"
r.mapcalc "tmax_loc_${t}=tmax.${t}-0.00649*(dem_10m-dem_1km)"
r.mapcalc "tmin_topo_${t}=tmin_loc_${t}*(S_i_${t}-(1/S_i_${t}))"
r.mapcalc "tmax_topo_${t}=tmax_loc_${t}*(S_i_${t}-(1/S_i_${t}))"
#r.mapcalc "total_sun_joules = total_sun/(3600*hours_sun)"
#r.mapcalc "g_psy=0.001013*(101.3*((293-0.00649*dem_10m)/293)^5.26)/(0.622*2.45)"
#r.mapcalc "m_vp=0.04145*exp(0.06088*(tmax_topo+tmin_topo/2))"
#r.mapcalc "ra=(4.72*(ln(2/0.00137))2)/(1+0.536*5)"
#r.mapcalc "vp_loc=6.11*10(7.5*tmin_topo)/(237.3+tmin_topo)"
#r.mapcalc "f_tmin_topo=0.6108*exp((12.27*tmin_topo)/(tmin_topo+237.3))"
#r.mapcalc "f_tmax_topo=0.6108*exp((12.27*tmax_topo)/(tmax_topo+237.3))"
#r.mapcalc "vp_s_topo=(f_tmax_topo+f_tmin_topo)/2"
#r.mapcalc "p_a=101325*exp(9.80665*0.289644*dem_10m/(8.31447*288.15))/287.35*((tmax_topo+tmin_topo/2)273.125)"
#r.mapcalc "PET=total_sun_joules+p_a*0.001013*(vp_s_topo-vp_loc)/ra))/(2.45*(m_vp+g_psy)"
#r.mapcalc "AET=prcp*(1+PET/prcp(1(PET/prcp)2.63)(1/2.63))"
r.mapcalc "DT_${t}=((tmax_topo_${t}+tmin_topo_${t})/2)-273.15"
r.mapcalc "F_${t}=a_i*prcp.${t}"
r.mapcalc "npp_trad_${t}=3000*(1+exp(1.315-0.119*(tmax_loc_${t}+tmin_loc_${t})/2)^-1)"
r.mapcalc "NPP_${t}=npp_trad_${t}"
r.mapcalc "EEMT_${t}=F_${t}*c_w*DT_${t}+NPP_${t}*h_bio"
#output
g.region rast=EEMT_${t}
r.out.gdal -c createopt="TFW=YES,COMPRESS=LZW" input=EEMT_${t} output=$eemt_tif
done
g.mremove -f "*"
