#! /bin/csh -f

setenv RUNPAR_RSH 'rsh'

set map = Jap57_CR6261_trimer_7A.mrc
set sym = C3
set delta_theta = 2.5
set prefix = Jap75_CR6261

# Don't change things below here
rm -rf log proj.* start.* threed.1* *log cls* classes* tmp* euler_{$delta_theta}.log 
rm -rf threed.0a.mrc 
rm -rf {$prefix}_{$delta_theta}_{$sym}.mrc

project3d $map out=start.hed prop=$delta_theta sym=$sym > log
grep -v "Cluster" log | grep -v Run > euler_{$delta_theta}.log

ln -s $map threed.0a.mrc

refine 1 proc=4 mask=65 ang=2.5 sym=$sym hard=50 classkeep=0.8 classiter=8 phasecls
mv threed.1a.mrc {$prefix}_{$delta_theta}_{$sym}.mrc
mkdir TEMP
cp cls.1.tar TEMP
cd TEMP
tar -xvf cls.1.tar
set orientations = `wc -l *lst | grep -v " 2 " | grep -v total | wc -l | awk '{print $1}'`
echo $orientations orientations >> ../euler_{$delta_theta}.log
cd ../
rm -rf TEMP/
gzip euler_{$delta_theta}.log
