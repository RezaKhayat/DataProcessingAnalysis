#!/bin/csh
#
set i = 20

/gpfs/home/rkhayat/Applications/bfactor/bfactor.exe << eof
S
volume_$i.spi
-500.0		!B-factor
2		!Low-pass filter option (1=Gaussian, 2=Cosine edge)
7.00		!Filter radius
5		!Width of cosine edge (if cosine edge used)
2.18    	!Pixel size
out.spi
eof
#
