#! /bin/csh -f

#Source the eman2/Sparx environemtal file
source ~/Applications/EMAN2/eman2.cshrc

if ( $#argv != 6 ) then
  echo "ExtractPrtclsFromGivenClass_v1.3.csh <originalstackIn_bdb> <class_keep> <class_avgs> <bin_factor> <output_directory> <output_prefix>"
  echo "e.g. ./ExtractPrtclsFromGivenClass_v1.3.csh start out_bin4_sxmref_256.keep out_bin4_sxmref_256/ integer Class_avgs Class_256"
else 
    set SOURCE1 = $argv[1]
    set SOURCE2 = $argv[2]
    set SOURCE3 = $argv[3]
    set BIN     = $argv[4]
    set DIRCTRY = $argv[5]
    set TARGET =  $argv[6]

set classes = `wc -l $SOURCE2 | awk '{print $1}'`

mkdir $DIRCTRY

rm -rf prtclsInClass
# Get information for particles in each class then import the aligned parameters for those particles
sxheader.py {$SOURCE3}/multi_ref.hdf --print --params=members > prtclsInClass
awk '{print $1 " " $2*'"$BIN"' " " $3*'"$BIN"' " " $4 " " $5}' {$SOURCE3}/fparamz.txt > fparamz_corr.txt
sxheader.py bdb:{$SOURCE1} --import=fparamz_corr.txt --params=xform.align2d 

set class = 1
while  ( $class <= $classes )
  # Correct for classes starting with 0 rather than 1.
  set i_class = `head -{$class} $SOURCE2 | tail -1 | awk '{print $1}'`
  set ii_class = `echo $i_class | awk '{print $1+1}'`
  echo Extracting particles from Class $i_class
  head -{$ii_class} prtclsInClass | tail -1 | tr ',' '\n' | sed "s|\[| |g" | sed "s|\]| |g" | awk '{printf "%d \n", $1}'  | sort -n > {$DIRCTRY}/{$TARGET}_{$i_class}.list
  e2proc2d.py bdb:{$SOURCE1} {$DIRCTRY}/{$TARGET}_{$i_class}.hdf --list={$DIRCTRY}/{$TARGET}_{$i_class}.list
  sxtransform2d.py {$DIRCTRY}/{$TARGET}_{$i_class}.hdf {$DIRCTRY}/{$TARGET}_{$i_class}_ali2d.hdf
  e2proc2d {$DIRCTRY}/{$TARGET}_{$i_class}_ali2d.hdf {$DIRCTRY}/{$TARGET}_{$i_class}_avg.mrc --average
  set class = `expr $class + 1`
end

endif

