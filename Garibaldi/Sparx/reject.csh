#! /bin/csh -f

set stack1 = bdb:start
set stack2 = bdb:start_2
set keep = 0.84

set vol = `ls -lt refine/* | grep "vol0" | head -1 | awk '{print $8}'`
sxheader.py $stack1 --print --params=xform.projection > refine_01.parameters
sxheader.py $stack1 --print --params=ctf > ctf_01.parameters

sxproject3d.py $vol projections.hdf --angles=refine_01.parameters --CTF=ctf_01.parameters
chmod u+x refine_statistics.py

./refine_statistics.py $stack1

set ptcls = `wc -l statistics_ori.txt | awk '{print $1}'`
set keep_ptcls = `echo $ptcls | awk '{print int('"$keep"'*$1)}'`
set rej_ptcls = `echo $ptcls $keep_ptcls | awk '{print ($1-$2)}'`

sort -nk +2 statistics_ori.txt | tail -{$keep_ptcls} | awk '{print $1 "\t" $2 "\t" 1}' > temp_list
sort -nk +2 statistics_ori.txt | head -{$rej_ptcls} | awk '{print $1 "\t" $2 "\t" 0}' >> temp_list

sort -n temp_list > particles.results
awk '{print $3}' particles.results > particles.activity

sxheader.py $stack1 $stack2 --import=particles.activity --params=activity
