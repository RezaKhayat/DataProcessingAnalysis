#! /bin/csh -f

#Source the eman2/Sparx environemtal file
# source ~/Applications/EMAN2/eman2.cshrc

if ( $#argv != 3 ) then
  echo "ExtrctPrtclsInEachClass_v1.2.csh <originalstackIn_bdb> <class_avgs> <output_prefix>"
  echo "e.g. ./ExtrctPrtclsInEachClass_v1.2.csh start out_bin4_sxmref_16/multi_ref.hdf Class"
else 
    set SOURCE1 = $argv[1]
    set SOURCE2 = $argv[2]
    set TARGET =  $argv[3]

set classes = `iminfo $SOURCE2 | grep 'images in' | awk '{print $3}'`
mkdir Classes_refine/

rm -rf prtclsInClass
sxheader.py $SOURCE2 --print --params=members > prtclsInClass

set class = 1
while  ( $class <= $classes )
  # Correct for classes starting with 0 rather than 1.
  set pclass = `expr $class - 1`
  head -{$class} prtclsInClass | tail -1 | tr ',' '\n' | sed "s|\[| |g" | sed "s|\]| |g" | awk '{printf "%d \n", $1}'  | sort -n > Classes_refine/{$TARGET}_{$pclass}.list
  e2proc2d.py bdb:$SOURCE1 Classes_refine/{$TARGET}_{$pclass}.hdf --list=Classes_refine/{$TARGET}_{$pclass}.list
  sxheader.py Classes_refine/{$TARGET}_{$pclass}.hdf --zero --params=xform.align2d 
  sxali2d.py Classes_refine/{$TARGET}_{$pclass}.hdf Classes_refine/{$TARGET}_{$pclass}_ali2d/ --ir=1 --ou=32 --rs=1 --xr="9 4 2 1" --yr="9 4 2 1" --ts="3 2 1 0.5"
  sxheader.py Classes_refine/{$TARGET}_{$pclass}.hdf --print --params=xform.align2d > Classes_refine/{$TARGET}_{$pclass}.pars_align2d
  e2proc2d.py Classes_refine/{$TARGET}_{$pclass}_ali2d/aqfinal.hdf Classes_refine/Class_averages_ali2d.hdf
  set class = `expr $class + 1`
end

endif

