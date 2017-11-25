#! /bin/csh -f

#Source the eman2/Sparx environemtal file
source /gpfs/home/rkhayat/Applications/EMAN2/eman2.cshrc

if ( $#argv != 4 ) then
  echo "ExtractParticles.csh <KeepClasses> <ClassAverages> <originalstack> <output>"
  echo "e.g. ./ExtractParticles.csh keep.classes out_bin2_sxmref_32/multi_ref.hdf ../ali_ctf_120.hed Classes"
else 
    set SOURCE1 = $argv[1]
    set SOURCE2 = $argv[2]
    set SOURCE3 = $argv[3]
    set TARGET =  $argv[4]

sxheader.py $SOURCE2 --print --params=members > prtclsInClass

set classes = `wc -l $SOURCE1 | awk '{print $1}'`

set i = 1
while  ( $i <= $classes )
  set class = `head -{$i} $SOURCE1 | tail -1`
  # Correct for classes starting with 0 rather than 1.
  set class = `expr $class + 1`
  head -{$class} prtclsInClass | tail -1 | tr ',' '\n' | sed "s|\[| |g" | sed "s|\]| |g" | awk '{printf "%d \n", $1}'  >> temp_target
  set i = `expr $i + 1`
end

sort -n temp_target > {$TARGET}.list
rm -rf temp_target prtclsInClass

e2proc2d.py bdb:$SOURCE3 {$TARGET}.hdf --list={$TARGET}.list

endif
