
from EMAN2_cppwrap import *
from global_def import *


# use the following syntax to invoke these filters: --function="[.,rk_functions,filter3D]"
ref_ali2d_counter = -1
	
def helical3c( ref_data ):
	from utilities      import print_msg
	from filter         import fit_tanh, filt_tanl
	from morphology     import threshold
	from utilities import sym_vol
	#  Prepare the reference in helical refinement, i.e., low-pass filter .
	#  Input: list ref_data
	#   0 - raw volume
	#  Output: filtered, and masked reference image

	global  ref_ali2d_counter
	ref_ali2d_counter += 1
	print_msg("filter    #%6d\n"%(ref_ali2d_counter))
	stat = Util.infomask(ref_data[0], None, True)
	volf = ref_data[0] #- stat[0]
	fl = 0.4
	aa = 0.11
	volf = filt_tanl(volf, fl, aa)
	
	return  volf

def ref_ali3d( ref_data ):
        from utilities      import print_msg
        from filter         import fit_tanh, filt_tanl
        from fundamentals   import fshift
        from morphology     import threshold
        #  Prepare the reference in 3D alignment, i.e., low-pass filter and center.
        #  Input: list ref_data
        #   0 - mask
        #   1 - center flag
        #   2 - raw average
        #   3 - fsc result
        #  Output: filtered, centered, and masked reference image
        #  apply filtration (FSC) to reference image:

        print_msg("ref_ali3d\n")
        cs = [0.0]*3


        stat = Util.infomask(ref_data[2], ref_data[0], False)
        volf = ref_data[2] - stat[0]
        Util.mul_scalar(volf, 1.0/stat[1])
        #volf = threshold(volf)
        Util.mul_img(volf, ref_data[0])
        fl, aa = fit_tanh(ref_data[3])
        msg = "Tangent filter:  cut-off frequency = %10.3f        fall-off = %10.3f\n"%(fl, aa)
        print_msg(msg)
        volf = filt_tanl(volf, fl, aa)
        if ref_data[1] == 1:
                cs = volf.phase_cog()
                msg = "Center x = %10.3f        Center y = %10.3f        Center z = %10.3f\n"%(cs[0], cs[1], cs[2])
                print_msg(msg)
                volf  = fshift(volf, -cs[0], -cs[1], -cs[2])
        return  volf, cs

def ref_ali2d( ref_data ):
        from utilities    import print_msg
        from filter       import fit_tanh, filt_tanl
        from utilities    import center_2D
        #  Prepare the reference in 2D alignment, i.e., low-pass filter and center.
        #  Input: list ref_data
        #   0 - mask
        #   1 - center flag
        #   2 - raw average
        #   3 - fsc result
        #  Output: filtered, centered, and masked reference image
        #  apply filtration (FRC) to reference image:
        global  ref_ali2d_counter
        ref_ali2d_counter += 1
        print_msg("ref_ali2d   #%6d\n"%(ref_ali2d_counter))
        fl, aa = fit_tanh(ref_data[3])
        msg = "Tangent filter:  cut-off frequency = %10.3f        fall-off = %10.3f\n"%(fl, aa)
        print_msg(msg)
        tavg = filt_tanl(ref_data[2], fl, aa)
        cs = [0.0]*2
        tavg, cs[0], cs[1] = center_2D(tavg, ref_data[1])
        if(ref_data[1] > 0):
                msg = "Center x =      %10.3f        Center y       = %10.3f\n"%(cs[0], cs[1])
                print_msg(msg)
        return  tavg, cs

