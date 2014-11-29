#!/bin/bash

# Assumes the user is on an Ubuntu machine with root permissions.
# Downloads and installs all of the necessary software for 
# generating the EEMT model, including the group's code.

# User needs to update the Repo List manually first for R 3.1+
# Add this line to /etc/apt/sources.list
# deb http://cran.rstudio.com/bin/linux/ubuntu trusty/

# Pull new updates
sudo apt-get update -y

# Install Applications
sudo apt-get install -y grass-dev coop-computing-tools python-rpy2 git


# Get R 3.1+ 
	# Add keys for new repo
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y r-base

# Get DaymetR and install it 
wget https://bitbucket.org/khufkens/daymetr/get/master.zip
unzip master.zip

# Get iCommands 
wget http://www.iplantcollaborative.org/sites/default/files/irods/icommands.x86_64.tar.bz2
tar jxf icommands.x86_64.tar.bz2
	# Update PATH
echo "export PATH=$PATH:~/icommands"
source .bashrc

# Clean up extra
cd 
rm master.zip
rm icommands.x86_64.tar.bz2

# Download the code and change to directory
git init
git clone https://github.com/bstreete/acic-14-group4.git

#Install packages for DaymetR
cd khufkens-daymetr*

echo "To finish installing DaymetR, follow these instructions:"
echo
echo "sudo R"
echo "install.packages(\"sp\")"
echo "86"
echo "install.packages(\"rgeos\")"
echo "install.packages(\"rgdal\")"
echo "q()"
echo "n"
echo "sudo R CMD INSTALL DaymetR.tar.gz"
echo
echo "Add this line to .bashrc for icommands:"
echo "export PATH=$PATH:~/icommands"
echo "source .bashrc"
