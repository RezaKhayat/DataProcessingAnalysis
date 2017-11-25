#!/gpfs/home/rkhayat/Applications/EMAN2/Python/bin/python

import sys
from sparx import *
from EMAN2 import *

stack0 = "projections.hdf"
stack1 = sys.argv[1]
out_ccc = sys.argv[2]

npcls = EMUtil.get_image_count(stack0)                                 #get number of particles from input stack

img = 0
# npcls = 10

of = open(out_ccc, 'w')

for img in xrange(0,npcls):
                img = int(img)
                prjdata = EMData()
                pcldata = EMData()
                prjdata.read_image(stack0,img)
                pcldata.read_image(stack1,img)
                sprx_ccc = ccc(prjdata,pcldata)
                # e2_frc = pcldata.cmp("frc",prjdata)
                # e2_phase = pcldata.cmp("phase",prjdata)
                # e2_dot = pcldata.cmp("dot",prjdata)
                # e2_lod = pcldata.cmp("lod",prjdata)
                #of.write("%6d %6.4f %6.4f %6.4f %6.4f %6.4f\n" % (img,sprx_ccc,e2_frc,e2_phase,e2_dot,e2_lod))
                of.write("%6d %6.4f \n" % (img,sprx_ccc))


