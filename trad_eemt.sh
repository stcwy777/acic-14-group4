#!/bin/bash

# Bash script that will create tasks for Makeflow to create a 
# traditional EEMT model. Takes an input directory, output directory,
# and a project name if specified. If none of the arguments are given, 
# the input and output directories default to the current working directory. 
# The Makeflow project name defaults to trad_eemt. 

# Process arguments
while getopts ":i:o:p:" o ; do
	case "${o}" in 
		# i = Input directory
		i)
			INPUT_DIR=${OPTARG}
			;;

		# o - Output directory
		o)
			OUTPUT_DIR=${OPTARG}
			;;

		# p - Makeflow project name
		p)
			PROJ_NAME=${OPTARG}
			;;

		# Unknown entry, print usage and exit with a non-zero status
		*)
			echo "Usage: trad_eemt.sh [-i input_directory] [-o output_directory] "
			echo $'       [-p makeflow_project]\n'
			
			echo "-i    Specifies the directory that contains the Open Topography data. "
			echo "      Files can be stored as a .tif or still be archived as .tar.gz. The"
			echo $'      metadata file needs to be included. Defaults to current directory.\n'
			

			echo "-o    Specifies the directory where the completed transfer model should "
			echo $'      be stored. Defaults to the current directory.\n'
			
			echo "-p    Specifies the project name used by makeflow. Workers will need the "
			echo "      project name to connect to the makeflow process. Defaults to "
			echo $'      trad_eemt.\n'

			exit 1	
	esac
done

# Check if the arguments need default values
if [ -z $INPUT_DIR ] ; then
	INPUT_DIR=./
fi

if [ -z $OUTPUT_DIR ] ; then
	OUTPUT_DIR=./
fi

if [ -z $PROJ_NAME ] ; then
	PROJ_NAME="trad_eemt"
fi

# Finished reading the command line input

# Process inputs to get ready for parallel commands

python read_meta.py $INPUT_DIR

# Call Yun's script here

# Create the Makeflow/Work Queue tasks for Weifeng here

# Start makeflow 

# Finished creating model. Organize data.

# Remove temporary files
