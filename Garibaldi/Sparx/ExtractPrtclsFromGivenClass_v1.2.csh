#! /bin/csh -f

#Source the eman2/Sparx environemtal file
source ~/Applications/EMAN2/eman2.cshrc

if ( $#argv != 4 ) then
  echo "ExtrctPrtclsInEachClass_v1.2.csh <originalstackIn_bdb> <class_keep> <class_avgs> <output_prefix>"
  echo "e.g. ./ExtrctPrtclsInEachClass_v1.2.csh start out_bin1_sxmref_256.keep out_bin4_sxmref_16/multi_ref.hdf Class"
else 
    set SOURCE1 = $argv[1]
    set SOURCE2 = $argv[2]
    set SOURCE3 = $argv[3]
    set TARGET =  $argv[4]

set classes = `wc -l $SOURCE2 | awk '{print $1}'`

rm -rf prtclsInClass
sxheader.py $SOURCE3 --print --params=members > prtclsInClass

set class = 1
while  ( $class <= $classes )
  # Correct for classes starting with 0 rather than 1.
  set i_class = `head -{$class} $SOURCE2 | tail -1 | awk '{print $1}'`
  set ii_class = `echo $i_class | awk '{print $1+1}'`
  echo Extracting particles from Class $i_class
  head -{$ii_class} prtclsInClass | tail -1 | tr ',' '\n' | sed "s|\[| |g" | sed "s|\]| |g" | awk '{printf "%d \n", $1}'  | sort -n > {$TARGET}_{$i_class}.list
  e2proc2d.py $SOURCE1 {$TARGET}_{$i_class}.hdf --list={$TARGET}_{$i_class}.list
  sxheader.py {$TARGET}_{$i_class}.hdf --zero --params=xform.align2d
  awk '{print $1 " " $2*2 " " $3*2 " " $4 " " $5}' {$TARGET}_{$i_class}.pars_align2d > temp.ali2d
  sxheader.py {$TARGET}_{$i_class}.hdf --import=temp.ali2d --params=xform.align2d
  rm -rf temp.ali2d
  sxtransform2d.py {$TARGET}_{$i_class}.hdf {$TARGET}_{$i_class}_ali2d.hdf
  proc2d {$TARGET}_{$i_class}_ali2d.hdf Class_averages_ali2d.hdf average
  set class = `expr $class + 1`
end

endif

