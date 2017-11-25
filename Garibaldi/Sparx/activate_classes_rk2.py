#This script operates on a stack of particles that (in most cases) has each particle's active attribute set to zero. It then uses the averages.hdf (or perhaps another appropriate file with averages containing 'members' list headers) file output by sparx k-means (sxk_means.py) and a list of clusters (integer values) to activate particles in the specified clusters.


import sys

import EMAN2

avgs = sys.argv[1]                                #averages.hdf file output from sparx k-means

pcls = sys.argv[2]				  #particle stack to be (partially) activated

actives = sys.argv[3]				  #clusters from k-means to activate



navgs = EMAN2.EMUtil.get_image_count( avgs )	  #get number of averages

active = int(actives)                     #RK line
avgdata = EMAN2.EMData()
avgdata.read_image( avgs, active )        #RK line
memberlist = avgdata.get_attr( 'members' )  #get the list of particles that contribute to the average

for pc in memberlist:			                #for each particle in the average

	pc = int(pc)			                #activate the particle
	pcldata = EMAN2.EMData()
	pcldata.read_image( pcls, pc )

	pcldata.set_attr( 'active',1 )
	pcldata.write_image( pcls, pc )
