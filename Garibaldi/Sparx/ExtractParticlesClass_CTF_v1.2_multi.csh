#! /bin/csh -f

#Source the eman2/Sparx environemtal file
source ~/Applications/EMAN2/eman2.cshrc

if ( $#argv != 7 ) then
  echo "ExtractParticles.csh <KeepClasses> <ClassAverages> <originalstack_prfx> <bin_factor> <totalStacks> <ctf_particles.frealign> <output>"
  echo "e.g. ./ExtractParticles.csh out_bin2_sxmref_32.keep out_bin2_sxmref_32/ Full_Stack  2 3 ctf_particles.frealign Keep_Particles"
else 
    set SOURCE1 = $argv[1]
    set SOURCE2 = $argv[2]
    set SOURCE3 = $argv[3]
    set BIN_FCT = $argv[4]
    set STACKS  = $argv[5]
    set CTF_FRE = $argv[6]
    set TARGET =  $argv[7]

# Collect what particles belong to each class average
sxheader.py $SOURCE2/multi_ref.hdf --print --params=members > prtclsInClass
sort -n $SOURCE1 | uniq > $SOURCE1.temp

set classes = `wc -l $SOURCE1.temp | awk '{print $1}'`

# Collect what class averages are kept. This is used for projection matching against RF class averages.
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

# Combine the multiple stacks into a single stack for particle extraction
set stack = 1
touch COMBINED_STACKS_ctf.frealign
while ( $stack <= $STACKS )
  e2proc2d.py bdb:$SOURCE3{$stack} bdb:COMBINED_STACKS --meanshrink=$BIN_FCT
  cat $CTF_FRE{$stack} >> COMBINED_STACKS_ctf.frealign
  set stack = `expr $stack + 1`
end

awk '{printf "%15.5f %15.5f %15.5f %15.5f %15.5f %15.5f %10d %10.3f \n", $3, 0, 0, $1/1000, $2/1000, 0, 0, 1}' COMBINED_STACKS_ctf.frealign > ctf_fremod

sxheader.py bdb:COMBINED_STACKS --zero --params=xform.projection --params=xform.align2d --params=xform.align3d

sxheader.py bdb:COMBINED_STACKS --import=$SOURCE2/fparamz.txt --params=xform.align2d 
sxheader.py bdb:COMBINED_STACKS--import=ctf_fremod --params=xform.align3d
rm -rf ctf_fremod

e2proc2d.py bdb:COMBINED_STACKS {$TARGET}_keep.hdf --list={$TARGET}.list
sxheader.py {$TARGET}_keep.hdf --print --params=xform.align3d > ctf_frekept_1
sxheader.py {$TARGET}_keep.hdf --print --params=xform.align2d > RF_2D_align.params
awk '{print $4*1000 " " $5*1000 " " $3}' ctf_frekept_1 > {$CTF_FRE}_keep.txt 
rm -rf ctf_frekept_1

e2proc2d.py bdb:COMBINED_STACKS {$TARGET}_excl.hdf --exclude={$TARGET}.list
sxheader.py {$TARGET}_excl.hdf --print --params=xform.align3d > ctf_frekept_2
awk '{print $4*1000 " " $5*1000 " " $3}' ctf_frekept_2 > {$CTF_FRE}_excl.txt 
rm -rf ctf_frekept_2

endif
