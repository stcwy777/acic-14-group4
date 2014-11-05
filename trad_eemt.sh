#!/bin/bash

# Usage Statement

# Process arguments

while getopts "i:o:p:" o ; do
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
			echo "       [-p makeflow_project]"
			echo
			echo "-i    Specifies the directory that contains the Open Topography data. "
			echo "      Files can be stored as a .tif or still be archived as .tar.gz. The"
			echo "      metadata file needs to be included. Defaults to current directory."
			echo
			echo "-o    Specifies the directory where the completed transfer model should "
			echo "      be stored. Defaults to the current directory."
			echo
			echo "-p    Specifies the project name used by makeflow. Workers will need the "
			echo "      project name to connect to the makeflow process. Defaults to "
			echo "      trad_eemt."
			echo
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

# Generate the workflow tasks
echo "Generating makeflow commands.... "
echo

python create_tasks.py $INPUT_DIR

# If script failed, exit
if [ $? -ne 0 ] ; then
	echo
	echo "Failed to generate makeflow commands. Please check errors for more information."
	echo
	exit 1

# Otherwise, keep going
else
	echo
	echo "Finished generating makeflow."
	echo
fi

# Start makeflow specifying the makeflow command file
echo "Starting makeflow process with project name '$PROJ_NAME'. "
echo

cd $INPUT_DIR

$HOME/cctools/bin/makeflow --batch-type wq --project-name $PROJ_NAME --wq-schedule files trad.makeflow

# If makeflow fails, try running again. The input file check sometimes fails for 
# files that do not exist yet. 
if [ $? -ne 0 ] ; then

	echo 
	echo "Makeflow failed. Retrying...."
	echo
	$HOME/cctools/bin/makeflow --batch-type wq --project-name $PROJ_NAME --wq-schedule files trad.makeflow

fi

# If makeflow fails again, exit
if [ $? -ne 0 ] ; then
	echo "Makeflow failed. Please see errors for more information. Aborting."
	exit 1

# Otherwise start organize the output data. 
else
	echo 
	echo "Makeflow finished processing data. Organizing output files...."
	echo
fi
# Finished creating model. Organize data.

# Remove temporary files
