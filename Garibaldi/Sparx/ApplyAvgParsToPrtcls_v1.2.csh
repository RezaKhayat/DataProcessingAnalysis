#! /bin/csh -f

# This is a script to apply the transformation parameters attained from alignment of 2D class averages to a 3D reference
# to the particles that make the 2D class average. This was used for the SOSIP.681 case.
#Source the eman2/Sparx environemtal file
source ~/Applications/EMAN2/eman2.cshrc

if ( $#argv != 6 ) then
  echo "ExtractParticles.csh <Kept_Classes> <Class_Averages> <Align_Parameters_for_Kept_Classes> <original_stack> <output>"
  echo "e.g. ./ExtractParticles.csh mT+KinParticles.classes out_bin2_sxmref_64/multi_ref.hdf fparamz.txt ../ali_ctf_120.hed bin_factor mT_Kin"
else 
    set SOURCE1 = $argv[1]
    set SOURCE2 = $argv[2]
    set SOURCE3 = $argv[3]
    set SOURCE4 = $argv[4]
    set BIN = $argv[5]
    set TARGET =  $argv[6]

rm -rf prtclsInClass parameters.txt alignment_parameters.txt {$TARGET}.hdf
sxheader.py $SOURCE2 --print --params=members > prtclsInClass
cp $SOURCE3 parameters.txt
touch alignment_parameters.txt
touch alignment_parameters_unbin.txt
touch temp_target
touch Particles.list

set classes = `wc -l $SOURCE1 | awk '{print $1}'`

set i = 1
while  ( $i <= $classes )
  set class = `head -{$i} $SOURCE1 | tail -1`
  # Correct for classes starting with 0 rather than 1.
  set class = `expr $class + 1`
  head -{$class} prtclsInClass | tail -1 | tr ',' '\n' | sed "s|\[| |g" | sed "s|\]| |g" | awk '{print int($1)}' >> temp_target
  set phi = `head -{$i} parameters.txt | tail -1 | awk '{print $1}'`
  set theta = `head -{$i} parameters.txt | tail -1 | awk '{print $2}'`
  set psi = `head -{$i} parameters.txt | tail -1 | awk '{print $3}'`
  set x = `head -{$i} parameters.txt | tail -1 | awk '{print $4}'`
  set y = `head -{$i} parameters.txt | tail -1 | awk '{print $5}'`
  awk '{print " " 1*'"$phi"' " " 1*'"$theta"' " " 1*'"$psi"' " " 1*'"$x"' " " 1*'"$y"'}' temp_target >> alignment_parameters.txt 
  awk '{print " " 1*'"$phi"' " " 1*'"$theta"' " " 1*'"$psi"' " " '"$BIN"'*'"$x"' " " '"$BIN"'*'"$y"'}' temp_target >> alignment_parameters_unbin.txt
  e2proc2d.py $SOURCE4 Averages.hdf --list=temp_target
  cat temp_target >> Particles.list
  rm -rf temp_target
  set i = `expr $i + 1`
end

# Make the stack
e2proc2d.py $SOURCE4 {$TARGET}.hdf --list=Particles.list
rm -rf Particles.list
sxheader.py {$TARGET}.hdf --zero --params=xform.align2d --params=xform.projection
sxheader.py {$TARGET}.hdf --import=alignment_parameters_unbin.txt --params=xform.projection
sxheader.py {$TARGET}.hdf --one --params=active
set i = `expr $i + 1`

endif
