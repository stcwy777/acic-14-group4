echo "GISDBASE: ${HOME}/grassdata" > ${HOME}/.grassrc6
echo "LOCATION_NAME: loc1" >> ${HOME}/.grassrc6
echo "MAPSET: test" >> ${HOME}/.grassrc6
echo "DIGITIZER: none" >> ${HOME}/.grassrc6
echo "GRASS_GUI: text" >> ${HOME}/.grassrc6

#GISBASE=${HOME}/grass-6.4.4
echo "export GISBASE=${HOME}/grass-6.4.4" >> ${HOME}/.bashrc
echo "export PATH=$PATH:\$GISBASE/bin:\$GISBASE/scripts:$HOME/lib" >> ${HOME}/.bashrc
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:\$GISBASE/lib:$HOME/lib" >> ${HOME}/.bashrc
echo "export GISRC=${HOME}/.grassrc6" >> ${HOME}/.bashrc
echo "export PYTHONPATH=\$GISBASE/etc/python" >> ${HOME}/.bashrc
echo "export SHELL=/bin/bash" >> ${HOME}/.bashrc
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
