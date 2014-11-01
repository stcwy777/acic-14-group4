import os
from subprocess import Popen, PIPE
from glob import glob
import sys
import decimal
import ConfigParser


def read_meta():
	"""
	Opens up any metadata*.txt files in the local directory or specified directory if there is one.
	It will search the files for the EPSG code defining the projection as well as the current zone.
	This data is saved in a dictionary named coords that is passed to the next functions.
	"""

	# Change to passed directory, if applicable
	try:
		if len(sys.argv) == 2:
			os.chdir(sys.argv[1])

		elif len(sys.argv) > 2:
			print "Too many arguments passed."
			print "Usage: %s [directory]" % sys.argv[0]
			sys.exit(1)

	except OSError:
		print "Directory not found."
		print "Usage: %s [directory]" % sys.argv[0]
		sys.exit(1)

	# Try opening the file and searching
	try:
		path = os.path.join(os.getcwd(), "metadata*.txt")
		proj_info = dict()

		# Try to open the file and read contents
		for meta_file in glob(path):
			with open(meta_file) as meta:
				for line in meta.readlines():

					# If the line contains the EPSG Code
					if line.startswith("Horizontal Coordinates:"):
						proj_info['region'] = line[-8:-3]
						proj_info['zone'] = proj_info['region'][-2:] + 'n'
						print proj_info
	except IOError:
		print 'Unable to open file.'
		sys.exit(1)

	# Make sure that all of the data was read successfully
	if len(proj_info) != 2:
		print 'Coordinates not found. Verify that the metadata file exists in %s and is complete.' % os.getcwd()
		sys.exit(1)

	else:
		# Convert the DEMs to Daymet's projection
		coords = convert_opentopo(proj_info)

		print "Coordinates are: "
		print coords

		# Save the coordinates to file
		save_coords(coords)


# End read_meta()



def convert_opentopo(proj_info):
	"""
	Creates another .tif file with the name .converted.tif for every .tif file located
	in the passed directory.The converted.tif file is supposed to be converted into the Daymet
	custom projection. Depends on theread_meta() method executing correctly. It doesn't check
	for the converted files before executing. Once the files are generated, script will call
	gdalinfo and try to parse the new coordinates from the output. The corner coordinates are
	returned in a list. Since everything is related to Daymet, it assumes the data is in the
	North and West hemispheres.
	"""

	# Command string to convert the DEM files from Open Topography to DAYMET's projection
	command = ['gdalwarp', '-s_srs', 'EPSG:' + proj_info['region'], '-t_srs',
			   "+proj=lcc +lat_1=25 +lat_2=60 +lat_0=42.5 +lon_0=-100 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs",
			   '-r', 'bilinear', '-of', 'GTiff']


	# Need to execute for each downloaded .tif file from OpenTopo
	path = os.path.join(os.getcwd(), "*.tif")
	for dem_file in glob(path):
		# Create the output file name
		dem_output = dem_file[:-4] + '.converted.tif'

		print "Creating %s" % dem_output

		# Add the filenames to the end of the list
		command.append(dem_file)
		command.append(dem_output)

		# Execute the gdalwarp command
		process = Popen(command, stdout=PIPE, shell=False)

		# Check for errors
		stdout, stderr = process.communicate()

		if stderr is not None:
			print stderr
			sys.exit(1)

		# Remove the filenames for next iteration
		command.remove(dem_file)
		command.remove(dem_output)

	# Call gdalinfo and parse the output for updated coordinates
	path = os.path.join(os.getcwd(), "*.converted.tif")
	for dem_file in glob(path):
		# Setup the command
		command = ['gdalinfo', dem_file]

		# Execute the command
		process = Popen(command, stdout=PIPE, shell=False)
		output, err = process.communicate()

		# Separate the lines and save a small subsection
		output = output.splitlines()
		output = output[-7:-3]

		result = dict()

		
		# Parse the upper left geocoordinates
		result['ullon'] = convert_decimal(output[0][41:53])
		result['ullat'] = convert_decimal(output[0][56:68])

		# Parse the lower left coordinates
		result['lllon'] = convert_decimal(output[1][41:53])
		result['lllat'] = convert_decimal(output[1][56:68])

		# Parse the upper right coordinates
		result['urlon'] = convert_decimal(output[2][41:53])
		result['urlat'] = convert_decimal(output[2][56:68])

	
		# Parse the lower right coordinates
		result['lrlon'] = convert_decimal(output[3][41:53])
		result['lrlat'] = convert_decimal(output[3][56:68])

	 
		return result

# End convert_opentopo() 57 - 68

def convert_decimal(value):
	"""
	Takes a string of output from gdalinfo, and converts the latitude and longitude 	measurements from degrees,
	minutes, seconds to decimal degrees.
	"""

	# Do the math
	output = decimal.Decimal(value[:3]) + (decimal.Decimal(value[4:6]) / 60) + (decimal.Decimal(value[7:]) / 3600)
	
	# Round to .00000
	output = "%3.5f" % output

	return output

# End convert_decimal()

def save_coords(coords):
	"""
	Saves the passed coordinates to a file named coords.txt using RawConfigParser
	"""

	# Initialize a config parser with the dictionary of data
	config = ConfigParser.RawConfigParser(coords)

	# Write to file and close
	with open('coords.txt', 'w') as config_file:
		config.write(config_file)

# End save_coords()
	
read_meta()
