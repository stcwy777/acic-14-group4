import os
from subprocess import Popen, PIPE
from glob import glob
import sys

# read_coords() searches for a file named metadata*.txt in the current
# directory, or in the passed directory. It will iterate through all possible
# files that meet that name requirement. It will find the xmin, xmax, ymin, ymax,
# and the UTM zone from the file and store in it a dictionary that is passed to the
# convert_coords() function.
def read_coords():
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
        coords = dict()

        # Try to open the file and read contents
        for meta_file in glob(path):
            with open(meta_file) as meta:
                for line in meta.readlines():

                    # If the line contains xmin
                    if line.startswith("	Xmin: "):
                        data = line[7:]
                        data = data.strip()
                        coords['xmin'] = data

                    # If the line contains xmax
                    elif line.startswith("	Xmax: "):
                        data = line[7:]
                        data = data.strip()
                        coords['xmax'] = data

                    # If the line contains ymin
                    elif line.startswith("	Ymin: "):
                        data = line[7:]
                        data = data.strip()
                        coords['ymin'] = data

                    # If the line contains ymax
                    elif line.startswith("	Ymax: "):
                        data = line[7:]
                        data = data.strip()
                        coords['ymax'] = data

                    # If the line contains the EPSG Code
                    if line.startswith("Horizontal Coordinates:"):
                        coords['region'] = line[-8:-3]
                        coords['zone'] = coords['region'][-2:] + 'n'

    except IOError:
        print 'Unable to open file.'
        sys.exit(1)

    # Make sure that all of the data was read successfully
    if len(coords) != 6:
        print 'Coordinates not found. Verify that the metadata file exists in %s and is complete.' % os.getcwd()
        sys.exit(1)

    else:
        convert_coords(coords)
        convert_opentopo(coords)


# Takes a dictionary containing the xmin, xmax, ymin, ymax, and UTM zone, and
# converts the coordinates using the external utility GeoConvert. Will give two
# pairs of coords, the NW corner, and SE corner of the passed coords.
def convert_coords(coords):
    print coords
    # Convert NW Corner
    command = ['GeoConvert', '--input-string', coords.get('zone') + ' ' + coords.get('xmin') + ' ' + coords.get('ymax')]
    process = Popen(command, stdout=PIPE, shell=False)

    north_west, err = process.communicate()

    # Catch errors from GeoConvert
    if err is not None:
        print err
        sys.exit(1)

    # Convert SE Corner
    command = ['GeoConvert', '--input-string', coords.get('zone') + ' ' + coords.get('xmax') + ' ' + coords.get('ymin')]
    process = Popen(command, stdout=PIPE, shell=False)

    south_east, err = process.communicate()

    # Catch errors from GeoConvert
    if err is not None:
        print err
        sys.exit(1)

    # Format the results, NW First
    north_west = north_west.split()
    south_east = south_east.split()

    print 'NW Coordinates: ' + north_west
    print 'SE Coordinates: ' + south_east


# Creates another .tif file with the name .converted.tif for every .tif file located in the passed directory.
# The converted.tif file is supposed to be converted into the Daymet custom projection. Depends on the read_coords()
# method executing correctly.
def convert_opentopo(coords):
    # Command string to convert the DEM files from Open Topography to DAYMET's projection
    command = ['gdalwarp', '-s_srs', 'EPSG:' + coords['region'], '-t_srs',
               "+proj=lcc +lat_1=25 +lat_2=60 +lat_0=42.5 +lon_0=-100 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs",
               '-r', 'bilinear', '-of', 'GTiff']


    # Need to execute for each downloaded .tif file from OpenTopo
    path = os.path.join(os.getcwd(), "*.tif")

    for dem_file in glob(path):
        # Create the output file name
        dem_output = dem_file[:-4] + '.converted.tif'

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

read_coords()
