#!/gpfs/home/rkhayat/Applications/EMAN2/Python/bin/python

# Moves a map according to the matrices output by Chimera as
# a result of a fitting.

from EMAN2 import *
from sparx import *
from math import sqrt
import sys

from os import system
from sys import argv
from sys import exit
from string import atof,atoi


def chi2sx(tchi, nx, ny, nz):
        if nx % 2 == 0:
                na = nx/2
        else:
                na = (nx-1)/2
        if ny % 2 == 0:
                nb = ny/2
        else:
                nb = (ny-1)/2
        if nz % 2 == 0:
                nc = nz/2
        else:
                nc = (nz-1)/2
        vcenter = Vec3f(na,nb,nc)
        shift_sx = tchi*vcenter - vcenter
        txlist = tchi.get_matrix()
        txlist[3]  = shift_sx[0]
        txlist[7]  = shift_sx[1]
        txlist[11] = shift_sx[2]
        tsx = Transform(txlist)
        return tsx


def sx2chi(tsx, nx, ny, nz):
        if nx % 2 == 0:
                na = nx/2
        else:
                na = (nx-1)/2
        if ny % 2 == 0:
                nb = ny/2
        else:
                nb = (ny-1)/2
        if nz % 2 == 0:
                nc = nz/2
        else:
                nc = (nz-1)/2
        vcenter = Vec3f(na,nb,nc)
        shift_chi = tsx*(-vcenter) + vcenter
        txlist = tsx.get_matrix()
        txlist[3]  = shift_chi[0]
        txlist[7]  = shift_chi[1]
        txlist[11] = shift_chi[2]
        tchi = Transform(txlist)
        return tchi


# map to be fitted:
mapf_file = "vol_in.spi"
mapf = get_image(mapf_file)

# pixel size of mapf (in Angstrom):
pixf = 2.18

# size of mapf:
nx = mapf.get_xsize()
ny = mapf.get_ysize()
nz = mapf.get_zsize()

# paste here the entries of the matrices output by Chimera:
# (Note: the units of the translation vector are Angstrom;
# remember to set the correct pixel sizes in Chimera before
# doing the fit)

# reference map:
mat_r  = [1.0, 0.0, 0.0, 0.0, \
        0.0, 1.0, 0.0, 0.0, \
        0.0, 0.0, 1.0, 0.0]

# fitted map:
mat_f = [0.97154718, -0.10788079, 0.21085021, -21.62215734, \
     0.11578052, 0.99294872, -0.02545004, -27.04488000, \
    -0.20661788, 0.04913826, 0.97718703, -26.56006740 ]

###########################################################

# change translation units to pixels of map to be fitted:
mat_r[3] /= pixf; mat_f[3] /= pixf
mat_r[7] /= pixf; mat_f[7] /= pixf
mat_r[11] /= pixf; mat_f[11] /= pixf

chi_r = Transform(mat_r)
chi_f = Transform(mat_f)

# relative transformation:
chi_c = chi_r.inverse()*chi_f

sx_c = chi2sx(chi_c,nx,ny,nz)

params_mov = sx_c.get_params("spider")
map_moved  = rot_shift3D(mapf, params_mov["phi"],params_mov["theta"],params_mov["psi"],params_mov["tx"],params_mov["ty"],params_mov["tz"])

print  params_mov["phi"] 
print params_mov["theta"] 
print params_mov["psi"] 
print params_mov["tx"] 
print params_mov["ty"] 
print params_mov["tz"]

drop_image(map_moved,"volf.spi","s")

cmat = sx_c.get_matrix()

matfile = open("vol-to-ecol_sx.matrix","w")

# note that shift units are Angstrom:
for i in range(3):
        row = "    %9.6f %9.6f %9.6f %8.4f\n" % (cmat[4*i],cmat[4*i+1],cmat[4*i+2],cmat[4*i+3]*pixf)
        euler = " %3.2f %3.2f %3.2f\n" % ( params_mov["phi"],params_mov["theta"],params_mov["psi"])
        matfile.write(row)

matfile.write(euler)
matfile.close()

exit(0)

