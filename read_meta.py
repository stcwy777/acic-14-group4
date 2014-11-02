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

	# Need to merge subfiles for each DEM output into a single TIFF

	# D Infinity Catchment Area
	path = os.path.join(os.getcwd(), "scap*.tif")
	merge_files(glob(path), 'scap_total.tif')

	# D Infinity Flow 
	path = os.path.join(os.getcwd(), "angp*.tif")
	merge_files(glob(path), 'angp_total.tif')

	# D Infinity Slope
	path = os.path.join(os.getcwd(), "slpp*.tif")
	merge_files(glob(path), 'slpp_total.tif')

	# Pit Remove 
	path = os.path.join(os.getcwd(), 'felp*.tif')
	merge_files(glob(path), 'felp_total.tif')

	# Total Wetness Index
	path = os.path.join(os.getcwd(), 'twi*.tif')
	merge_files(glob(path), 'twi_total.tif')

	# D Infinity 

	# Need to execute for each total .tif file from OpenTopo
	path = os.path.join(os.getcwd(), "*total.tif")

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

# End convert_opentopo() 57 - 68
	
def merge_files(path, output): 
	"""
	Merges the filenames passed into a single TIFF file with gdalwarp. Assumes that the system running the application has at least 2 GB of available memory.
	"""

	# Create the command to execute
	command = ['gdalwarp', '--config', 'GDAL_CACHEMAX', '2000', '-wm', '2000'] 
	command.extend(path)
	command.append(output)

	print command 

	# Execute the command
	process = Popen(command, stdout=PIPE, shell=False)
	stdout, stderr = process.communicate()

# End merge_files()
read_meta()
