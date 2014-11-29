Traditional EEMT Model Generator
==============

For more information and tutorials, please visit the Wiki hosted on Git Hub:

https://github.com/bstreete/acic-14-group4/wiki


# Application Overview

The Open Topography data needs to be downloaded and stored in a single directory ahead of time. Currently, the metadata file provided by Open Topography needs to be included in the folder to ensure that the projections are warped correctly. 

* Data is extracted and merged into single files if required
* .tif files are converted to the LCC projection used by Daymet
* Weather data for that region is downloaded from Daymet 
* Weather data is upscaled to match the resolution of the Open Topography data using known algorithms
* Upscaled Daymet data is combined with the Open Topography data to calculate the final model


# Software Requirements

The Grass and GDAL utilities from OSGeo.org are required. If Grass is installed through a package manager, GDAL should be installed as well. Testing was done with Grass64 6.4.3. Python 2.7 is needed for running various scripts that handle data ingestion and formatting. Makeflow from the CCTools package from the Cooperative Computing Labs at Notre Dame is needed to handle execution on a variety of remote systems simultaneously. The iCommands toolset is also needed to support storing and retrieving data from iPlant. 

# Installation Process

# Script Information

trad_eemt.sh
----

This is the main script that drives the application. It will call each subscript in turn with the appropriate passed parameters. It takes a number of command line arguments:

* -i 	Specifies the directory that contains the Open Topography data. Files can be stored as a .tif or still be archived as .tar.gz. The metadata file needs to be included. Defaults to current directory.
* -o 	Specifies the directory where the completed transfer model should be stored. Defaults to the current directory.
* -p 	Specifies the project name used by makeflow. Workers will need the project name to connect to the makeflow process. Defaults to trad_eemt.
* -s 	Specifies the starting year for generating the EEMT model. Dayment data starts in 1980. If a year is not specified, or the year is too early, 1980 is used.
* -e 	Specifies the end year for generating the EEMT model. Yearly Daymet data is posted in the following June. If a year is not specified or the year is in the current year or later, it will default to last year.
* -d 	Specifies the location of the Daymet national DEM. The filename must be na_dem.tif. 

read_meta.py
----

This script is responsible for finding and extracting the Open Topography data in the specified directory. Once extracted, broken up .tif files will be merged into a single .tif file and converted to use the Daymet's LCC projection. A small subsection of Daymet's national DEM is downloaded and extracted from iPlant to use in later calculations. It takes only two optional command line arguments. If nothing is specified, the application assumes that all of the data is located in the current working directory. 

* The directory that contains the Open Topography data. 
* The location of the Daymet national DEM, must be named na_dem.tif (If this is specified, the first option must be specified as well) 

process_dem.py
--- 

tiffparser.py
----

eemt.sh
---

Name of Merge Script 
---
