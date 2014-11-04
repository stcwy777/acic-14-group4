#!/bin/bash
echo "GISDBASE: ${HOME}/acicteam/grassdata" > ${HOME}/.grassrc.6.4.4
echo "LOCATION_NAME: loc1" >> ${HOME}/.grassrc.6.4.4
echo "MAPSET: test" >> ${HOME}/.grassrc.6.4.4
echo "DIGITIZER: none" >> ${HOME}/.grassrc.6.4.4
echo "GRASS_GUI: text" >> ${HOME}/.grassrc.6.4.4


export GISBASE=~/grass-6.4.4
export PATH="$PATH:$GISBASE/bin:$GISBASE/scripts"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GISBASE/lib"
export GISRC=~/.grassrc.6.4.4
export PYTHONPATH="$GISBASE/etc/python"
export SHELL=/bin/bash
# path to GRASS binaries and libraries:
#export GISBASE=$HOME/grass-6.4.4
#export GISDBASE=$HOME/acicteam
#export PATH=$PATH:$GISBASE/bin:$GISBASE/scripts
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$GISBASE/lib

# use process ID (PID) as lock file number:
#export GIS_LOCK=$$
# settings for graphical output to PNG file (optional)
#export GRASS_PNGFILE=/tmp/grass6output.png
#export GRASS_TRUECOLOR=TRUE
#export GRASS_WIDTH=900
#export GRASS_HEIGHT=1200
#export GRASS_PNG_COMPRESSION=1
#export GRASS_MESSAGE_FORMAT=plain

# path to GRASS settings file
#export GISRC=$HOME/.grassrc-6.4.4
