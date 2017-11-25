#This script is used after tilt pairs have been picked and untilted particles have been aligned. It takes the aligned untilted particle stack, the tilted particle stack, information about the format of the dcb (tilt angles) files, and information about the far edge of the micros. It uses these to write the appropriate xform.projection parameters in each tilted particle's header.

import sys

import EMAN2

import sparx

from EMAN2_cppwrap import *

tilt=sys.argv[1]               					#tilted particle stack

untilt=sys.argv[2]						#untilted particle stack

dcb_tmpl=sys.argv[3]						#dcb file template

tilt_list=sys.argv[4]						#list of tilted particles with micro number in the fourth column as read by python; expects first row commented

dcb_ext=sys.argv[5]						#extension on dcb (or other tilted angles document) file e.g. .spi or .txt

dcb_line=sys.argv[6]						#line number of dcb file where tilt parameters are stored

dcb_theta=sys.argv[7]						#column number in dcb file where theta (tilt angle) is stored

dcb_gamma=sys.argv[8]						#column number in dcb file where gamma (left image axis) value is stored

dcb_ph=sys.argv[9]						#column number in dcb file where phi (right image axis) value is stored

far_edge=sys.argv[10]						#far-from-focus edge of micro 1=left, 2=right, 3=top, and 4=bottom

npcls = EMAN2.EMUtil.get_image_count( untilt )

tilt_stack = EMAN2.EMData()

untilted_stack = EMAN2.EMData()


for pc in xrange(npcls):
        pc = int(pc)
        line = pc + 1
	micro=int(float(open( tilt_list, "r").readlines()[line].split()[3]))
        micro_n='%.4d' % micro
	dcb_string=dcb_tmpl + str(micro_n) + dcb_ext
        fff = open ('stringplace', 'a')
        sss = str(micro_n)
        fff.write(sss)
        fff.write('\n')
	dcb_tta=-abs((float((open(dcb_string, "r").readlines())[int(dcb_line)].split()[int(dcb_theta)])))
	dcb_gma=float((open(dcb_string, "r").readlines())[int(dcb_line)].split()[int(dcb_gamma)])
	dcb_phi=float((open(dcb_string, "r").readlines())[int(dcb_line)].split()[int(dcb_ph)])
	if int(far_edge) == 2 :
		dcb_gma = dcb_gma + 180
		dcb_phi = dcb_phi + 180
	elif int(far_edge) == 3 :
		if dcb_gma > 0 :
			dcb_gma = dcb_gma - 180
		if dcb_phi > 0 :
			dcb_phi = dcb_phi - 180
	elif int(far_edge) == 4 :
		if dcb_gma < 0 :
			dcb_gma = dcb_gma + 180
		if dcb_phi < 0 :
			dcb_phi = dcb_phi + 180

	untilted_stack.read_image( untilt, pc )
	angle, sx, sy, mirror, scale = sparx.get_params2D( untilted_stack )
	phi=-(dcb_gma + float(angle))
	tta=dcb_tta
	psi=dcb_phi
	
	if int(mirror) == int(1) :
                        phi= -phi - 180
                        tta= -tta + 180
			psi= psi + 180
	
	tilt_stack.read_image( tilt, pc )
	sparx.set_params_proj(tilt_stack, [phi, tta, psi, 0, 0])
	tilt_stack.write_image( tilt, pc )


#for each particle in tilted stack


	#read in the corresponding line of the tilt list file

	#read the corresponding dcb file info

	#copy dcb file info combined with untilted alignment params into tilted particle xform.projection header





