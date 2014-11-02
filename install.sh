#!/bin/bash

# Check for CC Tools
~/cctools/bin/work_queue_status -v &> /dev/null

if [ $? -ne 0 ] ; then 

	echo "Installing CCTools..."

	# Download the source files
	cd 
	wget "http://ccl.cse.nd.edu/software/files/cctools-4.2.2-source.tar.gz"

	# If the download completed successfully
	if [ $? -eq 0 ] ; then
		
		# Extract
		tar xzf cctools-4.2.2-source.tar.gz
		cd cctools-4.2.2-source

		echo "Configuring CCTools...."
		./configure > /dev/null
		make > /dev/null

		echo "Installing to ~/cctools/bin...."
		make install > /dev/null

		cd 
		echo "Finished installing CCTools ~/cctools/bin."

	else 
		echo "Failed to download and install CCTools from Notre Dame." 
	fi

else

	echo "CCTools detected."

fi

# Check for gdal packages
~/bin/gdal-config --version &> /dev/null

if [ $? -ne 0 ] ; then

	echo "Installing GDAL...."

	# Download source files
	cd 
	wget http://download.osgeo.org/gdal/1.11.1/gdal-1.11.1.tar.gz

	if [ $? -eq 0 ] ; then
		# Extract files
		tar -zxf gdal-1.11.1.tar.gz
		cd gdal-1.11.1

		echo "Configuring GDAL...."
		echo "Be patient, this takes a couple of minutes."
		./configure --prefix=$HOME > /dev/null
		make > /dev/null

		echo "Installing GDAL in ~/bin...."
		make install > /dev/null
		cd $HOME

		echo "Finished installing GDAL to ~/bin."

	else
		echo "Failed to download GDAL from OSGeo.org."
	fi

else
	echo "GDAL detected." 
fi

# iCommands
~/icommands/ils -v &> /dev/null

if [ $? -eq 0 ] ; then 

	echo "Installing iCommands...."

	cd $HOME
	wget http://www.iplantcollaborative.org/sites/default/files/irods/icommands.x86_64.tar.bz2
	
	if [ $? -ne 0 ] ; then
		echo "Extracting iCommands...."
		tar -jxf icommands.x86_64.tar.bz2

		echo "Finished installing iCommands to ~/icommands."
		cd $HOME

	else
		echo "Unable to download iCommands from iPlant."
	fi

else
	echo "iCommands detected."
fi

# Check for FFTW
test -f ~/lib/libfftw3.la &> /dev/null
# Installs into ~/bin and ~/include

if [ $? -ne 0 ] ; then 

	echo "Installing FFTW...."
	cd $HOME
	wget http://www.fftw.org/fftw-3.3.4.tar.gz
	
	if [ $? -eq 0 ] ; then 
		echo "Extracting FFTW...."
		tar -zxf fftw-3.3.4.tar.gz

		cd fftw-3.3.4

		echo "Configuring FFTW...."
		./configure --prefix=$HOME > /dev/null

		echo "Installing FFTW to ~/bin...."
		make > /dev/null
		make install > /dev/null
		cd $HOME

		echo "Finished installing FFTW."

	else
		echo "Unable to download FFTW from FFTW.org."
	fi

else
	echo "FFTW detected."
fi

# Check for Proj.4
test -f ~/bin/proj &> /dev/null
# # Installs into ~/bin, ~/include, and ~/share/proj

if [ $? -ne 0 ] ; then
	echo "Installing Proj-4...."
	cd $HOME 
	wget http://download.osgeo.org/proj/proj-4.8.0.tar.gz
	
	if [ $? -eq 0 ] ; then 

		echo "Extracting Proj-4...."
		tar -zxf proj-4.8.0.tar.gz
		cd proj-4.8.0

		echo "Configuring Proj-4...."
		./configure --prefix=$HOME > /dev/null
		make > /dev/null

		echo "Installing Proj-4 to ~/bin...."
		make install > /dev/null
		cd $HOME

		echo "Finished installing Proj-4 to ~/bin."

	else
		echo "Unable to download Proj-4 from OSGeo."
	fi

else
	echo "Proj-4 detected."
fi


# Check for Grass
# Installs into ~/bin
~/bin/grass64 --version >& /dev/null

if [ $? -ne 0 ] ; then 
	echo "Installing Grass...." 

	cd $HOME
	wget http://grass.osgeo.org/grass64/source/grass-6.4.4.tar.gz
	
	if [ $? -eq 0 ] ; then 
		echo "Extracting Grass...."
		tar -zxf grass-6.4.4.tar.gz
		cd grass-6.4.4

		echo "Configuring Grass...."
		echo "Be patient. Grass is a massive toolset. This will take a couple of minutes."
		./configure --prefix=$HOME --with-proj-includes=$HOME/include --with-proj-libs=$HOME/lib \
			--with-proj-share=$HOME/share/proj --with-fftw-libs=$HOME/lib \
			--with-fftw-includes=$HOME/include > /dev/null
		make > /dev/null
		
		echo "Installing Grass to ~/bin...."
		make install > /dev/null
		cd $HOME

		echo "Finished installing Grass to ~/bin."

	else
		echo "Unable to download Grass from OSGeo."
	fi

else
	echo "Grass detected." 
fi

echo "Cleaning up...."

cd $HOME

# CCTools
rm cctools-4.2.2-source.tar.gz
rm -r cctools-4.2.2-source

# GDAL
rm gdal-1.11.1.tar.gz >& /dev/null
rm -fr gdal-1.11.1 >& /dev/null

# iCommands
rm icommands.x86_64.tar.bz2 >& /dev/null

# Grass
rm grass-6.4.4.tar.gz >& /dev/null

# FFTW
rm fftw-3.3.4.tar.gz >& /dev/null
rm -fr fftw-3.3.4 >& /dev/null

# proj.4
rm proj-4.8.0.tar.gz >& /dev/null
rm -fr proj-4.8.0 >& /dev/null

echo "Finished removing unneeded files." 

echo "Updating path variable."

echo "export PATH=$PATH:~/bin:~/cctools/bin" >> .bashrc

echo -n "New path is : " 
echo $PATH
