import os
import sys
from tiffparser import TiffParser

def main():
    
    """
    This script is used to split a geotiff file into pixels. 
    A new folder contain theses pixel tiff will be created
    Usage: Python split_tiff.py [path to tiff file]
    """

    # Default parameters
    inputTiff = 'output.mean.converted.tif'
     
    # allocate user specified parameters
    if len(sys.argv) == 2:
        if not sys.argv[1].endswith('.tif') or not os.path.exists(sys.argv[1]):
            print "File not exist or wrong type"
            sys.exit(1)
        else:
            inputTiff = sys.argv[1]
    else:
        print "Too many parameters"
        sys.exit(1)

    # Parse dem file
    demParser = TiffParser()
    demParser.loadTiff(inputTiff)
    demParser.split(1)

if __name__ == '__main__':
    
    main()
