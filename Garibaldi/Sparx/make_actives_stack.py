#This script makes a substack consisiting of the particles with header attribute 'active'=1 from an input stack.


import sys

import EMAN2

from sparx import *

pcls = sys.argv[1]								#input stack

out = sys.argv[2]								#output stack name

npcls = EMAN2.EMUtil.get_image_count( pcls )					#get number of particles from input stack

i=0

j=0
for pc in xrange(0,npcls):							#for each particle
		pcldata = EMAN2.EMData()
		pc = int(pc)
		pcldata.read_image( pcls, pc )
		active = pcldata.get_attr( 'active' )				#read active attribute

		if int(1) == int(active) :					#if active is turned on, write image to output stack
       			pcldata.write_image( out, j )
			j+=1



