#!/usr/bin/env python

import os
import sys
from glob import glob
import tarfile
from subprocess import Popen

def gen_commands(): 
	"""
	Driver function that generates the command strings for makeflow. 
	Writes the entire list of strings to trad_eemt.makeflow. 

	Syntax is: 
		output files: input files binaries
			shell command
	"""	

	# Check for sufficient arguments
	if len(sys.argv) != 2:
		print "Incorrect number of arguments passed."
		print "Usage: %s [input_directory] " % sys.argv[0]
		sys.exit(1)

	input_dir = sys.argv[1]

	try:

		os.chdir(input_dir)

	except OSError:
		print 'Unable to change to directory %s.' % input_dir
		sys.exit(1)

	command_list = list()

	# Generate the commands to decompress Open Topo Data
	command_list.extend(decompress())

	# Generate the commands to merge partitioned TIFs 
	command_list.append(merge_raw('catch.tif', 'scap*.tif'))

	# Warp the tifs to the Daymet projection
	convert_list = ['catch.tif', 'output.mean.tif']

	for tif in convert_list:
		command_list.append(change_proj(tif))

	# Split the tifs


	# Calculations on each pixel


	# Merge the composite images


	# Generate the final project
	create_makeflow(command_list)

	sys.exit(0)

# End gen_commands()

def create_makeflow(command): 
	"""
	Generates a file named starting_dir/trad.makeflow with all of the commands
	needed to completely generate the model.
	"""

	# Remove the old makeflow configuration file if it exists
	try:
		os.remove('trad.makeflow')
	except OSError:
		pass

	# Open the makeflow file, write the commands, close the file
	output = open('trad.makeflow', 'w')
	output.write('\n\n'.join(command))
	# End on a newline
	output.write('\n') 
	output.close()

# End create_makeflow()

def change_proj(tif):
	"""
	Creates a makeflow command to convert the specified tif file into Daymet's projections
	while maintaining the original pixel size from Open Topography.
	"""

	# Read the metadata to determine projection information
	proj_info = read_meta()

	# Create the command to execute with makeflow

	# Output file name
	output = tif[:-4] + '.converted.tif'

	# Daymet projection values
	daymet = '"+proj=lcc +lat_1=25 +lat_2=60 +lat_0=42.5 +lon_0=-100 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"'
	
	# Full shell command
	command = ['gdalwarp', '-s_srs', 'EPSG:' + proj_info['region'], 
		'-overwrite', '-t_srs', daymet, '-r', 'bilinear', '-of', 'GTiff', 
		'-tr', proj_info['resolution'], '-' + proj_info['resolution'], tif, output]

	# First line of makeflow
	result = output + ': $HOME/bin/gdalwarp ' + tif

	# Second line of makeflow
	result += '\n\t' + ' '.join(command)

	return result
# End change_proj()

def read_meta():
	"""
	Opens up any metadata*.txt files in the local directory or specified directory if there is one.
	It will search the files for the EPSG code defining the projection, the current zone, and the
	resolution of the DEMs. This data is saved in a dictionary named coords that is passed to the next functions.
	"""

	# Try opening the file and searching
	try:
		path = os.path.join(os.getcwd(), "metadata*.txt")
		proj_info = dict()

		# Try to open the file and read contents
		for meta_file in glob(path):
			with open(meta_file) as meta:
				for line in meta.readlines():

					# If the line contains the resolution, and it hasn't been set
					if line.startswith('\tResolution:') and 'resolution' not in proj_info:						
						proj_info['resolution'] = line[12:18].strip(' \t\nmetr')

					# If the line contains the EPSG Code
					if line.startswith("Horizontal Coordinates:"):
						proj_info['region'] = line[-8:-3]
						proj_info['zone'] = proj_info['region'][-2:] + 'n'
	except IOError:
		print 'Unable to open file.'
		sys.exit(1)

	# Make sure that all of the data was read successfully
	if len(proj_info) != 3:
		print proj_info
		print 'Coordinates not found. Verify that the metadata file exists in %s and is complete.' % os.getcwd()
		sys.exit(1)

	else:
		# Returnn the information
		return proj_info 

# End read_meta()

def merge_raw(result, file_wild):
	"""
	Creates makeflow commands that will merge separate pieces of the same dataset into a single TIF file. 
	"""

	# Generate the first line
	command = result + ': '
	files = glob(os.path.join(os.getcwd(), file_wild))

	# For every file that matches the wildcard
	for path in files:
		# Add it to the command string
		command += path + ' '

	command += '$HOME/bin/gdalwarp\n'

	# Generate the second line
	command += '\tgdalwarp --config GDAL_CACHEMAX 2000 -wm 2000 -overwrite ' + ' '.join(files) + ' ' + result

	return command

# end merge_raw()

def decompress(): 
	"""
	Generate the makeflow commands that will uncompress all of the tar.gz
	"""
	archives = ['Dinfarea.tar.gz', 'dems.tar.gz']
	output = list()

	for arch in archives: 
		try:
			# For each .tar.gz read the contents as a list
			arch_files = list_arch(arch)

			# Put those files into makeflow syntax
			# First line
			command = ' '.join(arch_files) + ': ' + arch + ' /bin/tar'

			# Second Line
			command += '\n\t /bin/tar zxf ' + arch

			# Add the new command to the command list
			output.append(command)

		except IOError: 
			print 'Archive %s not found. Skipping.' % arch

	return output

def list_arch(archive):
	"""
	Generates a list of contents of the passed .tar.gz, returns them as a list.
	"""
	results = list()
	tar = tarfile.open(archive)

	for member in tar:
		results.append(member.name)

	return results

# End list_arch()
gen_commands()
	