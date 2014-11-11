#!/bin/bash

# Bash script that will create tasks for Makeflow to create a 
# traditional EEMT model. Takes an input directory, output directory,
# and a project name if specified. If none of the arguments are given, 
# the input and output directories default to the current working directory. 
# The Makeflow project name defaults to trad_eemt. 

# Define default values for variables
clear 

CUR_YEAR=$(date +%Y)
INPUT_DIR=./
OUTPUT_DIR=./
PROJ_NAME="trad_eemt"
END_YEAR=$(($CUR_YEAR-1))
START_YEAR=1980

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
					START_YEAR=1980
				
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
			echo $' 	[-p makeflow_project] [-s starting year] [-e ending year]\n'
			
			echo "-i 	Specifies the directory that contains the Open Topography data. "
			echo "   	files can be stored as a .tif or still be archived as .tar.gz. The"
			echo $'  	metadata file needs to be included. Defaults to current directory.\n'

			echo "-o 	Specifies the directory where the completed transfer model should "
			echo $'   	be stored. Defaults to the current directory.\n'
			
			echo "-p 	Specifies the project name used by makeflow. Workers will need the "
			echo "   	project name to connect to the makeflow process. Defaults to "
			echo $'   	trad_eemt.\n'

			echo "-s 	Specifies the starting year for generating the EEMT model. Dayment "
			echo "   	data starts in 1980. If a year is not specified, or the year is too "
			echo $'   	early, 1980 is used. \n'

			echo "-e 	Specifies the end year for generating the EEMT model. Yearly Daymet "
			echo "   	data is posted in the following June. If a year is not specified or "
			echo "   	the year is in the current year or later, it will default to last "
			echo $'   	year.\n'

			exit 1	
	esac
done	# End argument reading

# Sanity check the arguments

# Check that the starting year < ending year
if [ "$START_YEAR" -gt "$END_YEAR" ] 2>/dev/null ; then
	TEMP=$END_YEAR
	END_YEAR=$START_YEAR
	START_YEAR=$TEMP

	echo "Starting and Ending years were transposed. Ending year is now $END_YEAR. Starting year is now $START_YEAR"
fi

# Print selected values, give user option to abort
echo $'\n\t---- Values Used ----\n'
echo "Start Year 		= $START_YEAR"
echo "End Year   		= $END_YEAR"
echo "Input Directory 	= $INPUT_DIR"
echo "Output Directory 	= $OUTPUT_DIR"
echo "Project Name 		= $PROJ_NAME"

echo
read -p "Hit [Ctrl]-[C] to abort, or any key to start processing...."
echo

wait
# Finished reading the command line input

# Process inputs to prepare for parallel commands

python read_meta.py $INPUT_DIR

# If read_meta.py failed, don't continue executing
if [ $? -ne 0 ] ; then
	echo $'\nFailed processing the inputs. Please check errors. Aborting....\n'
	exit 1
fi

# Download Daymet Information

python process_dem.py output.mean.converted.tif $START_YEAR $END_YEAR tmin tmax prcp

# If process_dem.py failed, don't continue executing
if [ $? -ne 0 ] ; then
	echo $'\nFailed downloading the Daymet data. Please check errors. Aborting....\n'
	exit 1
fi
# Create the Makeflow/Work Queue tasks for Weifeng here

# Start makeflow 
#workflow -T wq -N $PROJ_NAME 

# Finished creating model. Organize data.

# Remove temporary files
