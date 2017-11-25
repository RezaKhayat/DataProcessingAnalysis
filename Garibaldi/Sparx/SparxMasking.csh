#! /bin/csh -f
echo e2proc2d.py Class_256_12_ali2d.hdf Class_256_12_ali2d_ma.hdf --process=mask.sharp:dx=-8:dy=-3:dz=0.0:inner_radius=14:outer_radius=60:value=0.0

foreach file (*ali2d.hdf)
  set b = $file:r
  if(! -e {$b}_avg.mrc) then
    proc2d $file {$b}_avg.mrc average
    v2 {$b}_avg.mrc
  endif
end

