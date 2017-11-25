#! /bin/csh -f

#Source the eman2/Sparx environemtal file
source ~/Applications/EMAN2/eman2.cshrc

if ( $#argv != 7 ) then
  echo "ExtractParticles.csh <KeepClasses> <ClassAverages> <originalstack> <ctf_particles.sparx> <ctf_particles.frealign> <tilt_particles.tilt> <output>"
  echo "e.g. ./ExtractParticles.csh mT+KinParticles.classes out_bin2_sxmref_32/ ../ali_ctf_120.hed ctf_particles.sparx ctf_particles.frealign tilt_particles.tilt mT_Kin"
else 
    set SOURCE1 = $argv[1]
    set SOURCE2 = $argv[2]
    set SOURCE3 = $argv[3]
    set CTF_SPR = $argv[4]
    set CTF_FRE = $argv[5]
    set Tilt_Im = $argv[6]
    set TARGET =  $argv[7]

sxheader.py $SOURCE2/multi_ref.hdf --print --params=members > prtclsInClass
sort -n $SOURCE1 | uniq > $SOURCE1.temp

set classes = `wc -l $SOURCE1.temp | awk '{print $1}'`

set i = 1
while  ( $i <= $classes )
  set class = `head -{$i} $SOURCE1.temp | tail -1`
  proc2d $SOURCE2/multi_ref.hdf $SOURCE1.hed first=$class last=$class

  # Correct for classes starting with 0 rather than 1.
  set class = `expr $class + 1`
  head -{$class} prtclsInClass | tail -1 | tr ',' '\n' | sed "s|\[| |g" | sed "s|\]| |g" | awk '{printf "%d \n", $1}'  >> temp_target
  set i = `expr $i + 1`
end

sort -n temp_target > {$TARGET}.list
rm -rf temp_target prtclsInClass

awk '{printf "%15.5f %15.5f %15.5f %15.5f %15.5f %15.5f %10d %10.3f \n", $3, 0, 0, $1/1000, $2/1000, 0, 0, 1}' $CTF_FRE > ctf_fremod
awk '{print "0 0 0 " $1 " 0"}'  $Tilt_Im > tilts_micro

sxheader.py bdb:$SOURCE3 --zero --params=xform.projection --params=xform.align2d --params=xform.align3d

sxheader.py bdb:$SOURCE3 --import=$SOURCE2/fparamz.txt --params=xform.align2d
sxheader.py bdb:$SOURCE3 --import=ctf_fremod --params=xform.align3d
sxheader.py bdb:$SOURCE3 --import=$CTF_SPR --params=ctf
sxheader.py bdb:$SOURCE3 --import=tilts_micro --params=xform.projection
rm -rf ctf_fremod

e2proc2d.py bdb:$SOURCE3 {$TARGET}_keep.hdf --list={$TARGET}.list
sxheader.py {$TARGET}_keep.hdf --print --params=xform.align3d > ctf_frekept_1
sxheader.py {$TARGET}_keep.hdf --print --params=xform.projection > tilts_micro_keep.txt
awk '{print $4*1000 " " $5*1000 " " $3}' ctf_frekept_1 > {$CTF_FRE}_keep.txt 
rm -rf ctf_frekept_1

e2proc2d.py bdb:$SOURCE3 {$TARGET}_excl.hdf --exclude={$TARGET}.list
sxheader.py {$TARGET}_excl.hdf --print --params=xform.align3d > ctf_frekept_2
sxheader.py {$TARGET}_excl.hdf --print --params=xform.projection > tilts_micro_excl.txt
awk '{print $4*1000 " " $5*1000 " " $3}' ctf_frekept_2 > {$CTF_FRE}_excl.txt 
rm -rf ctf_frekept_2

endif
