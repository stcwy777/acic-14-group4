#!/bin/bash

# Bash script that will create tasks for Makeflow to create a 
# traditional EEMT model. Takes an input directory, output directory,
# and a project name if specified. If none of the arguments are given, 
# the input and output directories default to the current working directory. 
# The Makeflow project name defaults to trad_eemt. 

CUR_YEAR=$(date +%Y)

# Process arguments
while getopts ":i:o:p:s:e:" o ; do
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

		# s - Start year
		s)
			START_YEAR=${OPTARG}

			# Check that it is an integer
			if [ "$START_YEAR" -eq "$START_YEAR" ] ; then

				# Check lower bounds 
				if [ "$START_YEAR" -lt 1980 ] ; then
					echo "The starting year needs to be at least 1980. Defaulting to 1980."
				
				# Check upper bounds
				elif [ "$START_YEAR" -ge "$CUR_YEAR" ] ; then
					echo "The starting year needs to be less than this year. Aborting."
					exit 1
				fi

			# Not an integer. Exit.
			else
				echo "Invalid starting year $START_YEAR. Please check your input."
				exit 1
			fi
			;;

		# e - End Year
		e)
			END_YEAR=${OPTARG}
			
			# Check that it is an integer
			if [ "$END_YEAR" -eq "$END_YEAR" ] 2>/dev/null ; then

				# Check upper bounds 
				if [ "$END_YEAR" -gt "$(($CUR_YEAR - 1 ))" ] ; then
					END_YEAR=$(($CUR_YEAR - 1 ))
					echo "The starting year needs to be at most $(($CUR_YEAR - 1 )). Defaulting to $(($CUR_YEAR - 1 ))."
				
				# Check lower bounds
				elif [ "$END_YEAR" -lt 1980 ] ; then
					echo "The ending year needs to be greater than or equal to 1980. Aborting."
					exit 1
				fi

			# Not an integer. Exit.
			else
				echo "Invalid starting year $END_YEAR. Please check your input."
				exit 1
			fi
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

if [ -z $END_YEAR ] ; then 
	END_YEAR=$(($CUR_YEAR-1))
fi

if [ -z $START_YEAR ] ; then 
	START_YEAR=1980
fi

# Check that the starting year < ending year
if [ "$START_YEAR" -gt "$END_YEAR" ] 2>/dev/null ; then
	TEMP=$END_YEAR
	END_YEAR=$START_YEAR
	START_YEAR=$TEMP

	echo "Starting and Ending years were transposed. Ending year is now $END_YEAR. Starting year is now $START_YEAR"
fi

echo "Start = $START_YEAR"
echo "End   = $END_YEAR"
echo "Cur   = $CUR_YEAR"
echo "Input = $INPUT_DIR"
echo "Output= $OUTPUT_DIR"
echo "Proj  = $PROJ_NAME"

# Finished reading the command line input

# Process inputs to get ready for parallel commands

python read_meta.py $INPUT_DIR

# Download Daymet Information

python process_dem.py output.mean.converted.tif $START_YEAR $END_YEAR tmin tmax prcp

# Create the Makeflow/Work Queue tasks for Weifeng here

# Start makeflow 

# Finished creating model. Organize data.

# Remove temporary files
