#!/usr/bin/env python

# This program is a very simple example of how to use Work Queue.
# It reads in individual EEMT filesand combines them using workers
# A directory containing the files is passed on the command line

from work_queue import *

import os
import sys

#Error checking
try:
	os.chdir(sys.argv[1])
except:
	if len(sys.argv) < 2
		print "No directory specified"
		print "Usage: %s [directory]" % sys.argv[0]
		sys.exit(1)
	elif len(sys.argv) > 2
		print "Too many arguments passed"
		print "Usage: %s [directory]" % sys.argv[0]
		sys.exit(1)

#specify default port for workqueue to run on
port = WORK_QUEUE_DEFAULT_PORT

# record the location of GRASS in 'grass_path'
home_dir = os.getenv("HOME")
grass_path = home_dir + "/bin/grass64"
if not os.path.exists(gzip_path):
  print "grass64 was not found. Please modify the grasss_path variable accordingly. To determine the location of grass, from the terminal type: which grass64 "
  sys.exit(1)

#We create the tasks queue using the default port. If this port is already
# been used by another program, you can try setting port = 0 to use an
# available port.
try:
  q = WorkQueue(port)
except:
  print "Instantiation of Work Queue failed!" 
  sys.exit(1)

print "listening on port %d..." % q.port	

outfile = "trad_eemt.tif"
 
# Create the command to be sent to the gdal script with the specified parameters.
# Note that we write ./gdalwarp here, to guarantee that the gdal version we
# are using is the one being sent to the workers. 
 
command = ["./gdalwarp", "--config", "GDAL_CACHEMAX", "2000", '-wm", "2000"]
command.extend(os.listdir(sys.argv[1]))
command.append(outfile)

#create the variable for each task to be stored in.
t = Task(command)
 
# Loop through each file in the directory and check if it is the correct file type
# correct ext: assign that file to WorkQueue task
# wrong ext: ignore and let the user know it will be ignored.
 for filename in os.listdir(sys.argv[1])
    if filename.lower().endswith('.tif')
     	t.specify_file(filename, filename, WORK_QUEUE_INPUT, cache = False)
    elif
			print filename + "is not a .tif file. This file will be ignored."
# set the WorkQueue output file
 t.specify_file(outfile, outfile, WORK_QUEUE_OUTPUT, cache=False)

# Once all files has been specified, we are ready to submit the task to the queue.
taskid = q.submit(t)
 
print "submitted task (id# %d): %s" % (taskid, t.command)

print "waiting for tasks to complete..."
while not q.empty():
	t = q.wait(5)
  if t:
		print "task (id# %d) complete: %s (return code %d)" % (t.id, t.command, t.return_status)
			if t.return_status != 0:
        # The task failed. Error handling (e.g., resubmit with new parameters, examine logs, etc.) here
        print "The task failed with return status " + t.return_status
				None
			elif
				#task object will be garbage collected by Python automatically when it goes out of scope
				print "all tasks complete!"


#work queue object will be garbage collected by Python automatically when it goes out of scope
sys.exit(0)
 
