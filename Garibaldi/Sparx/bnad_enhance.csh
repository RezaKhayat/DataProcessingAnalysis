#! /bin/csh -f

#Source the eman2/Sparx environemtal file
source ~/Applications/EMAN2/eman2.cshrc

if ( $#argv != 2 ) then
  echo "bnad_enhance.csh <in_stack> <out_stack>"
else 
    set SOURCE1 = $argv[1]
    set SOURCE2 = $argv[2]

set images = `iminfo $SOURCE1 | grep contains | awk '{print $3}'`

echo There are $images images

set i = 0
while  ( $i <= $images )
  rm -rf te.mrc out.mrc
  proc2d $SOURCE1 te.mrc first=$i last=$i
  bnad -lambda 0.1 -iterations 200 -output 200 te.mrc out.mrc
  proc2d out.mrc $SOURCE2
  rm -rf te.mrc out.mrc
  set i = `expr $i + 1`
end

endif
