#!/bin/csh
set working_directory = `pwd`
setenv NCPUS 16
#
mkdir scratch

set first = $1
set last = $2
set start = $3
#
set target      = `grep thresh_refine mparameters_run | awk '{print $2}'`
set thresh      = `grep thresh_reconst mparameters_run | awk '{print $2}'`
set pbc         = `grep PBC mparameters_run | awk '{print $2}'`
set boff        = `grep BOFF mparameters_run | awk '{print $2}'`
set dang        = `grep DANG mparameters_run | awk '{print $2}'`
set itmax       = `grep ITMAX mparameters_run | awk '{print $2}'`
set mode        = `grep MODE mparameters_run | awk '{print $2}'`
set fpart       = `grep FPART mparameters_run | awk '{print $2}'`
set dfstd       = `grep DFSTD mparameters_run | awk '{print $2}'`
set rrec        = `grep res_reconstruction mparameters_run | awk '{print $2}'`
set rref        = `grep res_refinement mparameters_run | awk '{print $2}'`
set rlowref     = `grep res_low_refinement mparameters_run | awk '{print $2}'`
set data_input  = `grep data_input mparameters_run | awk '{print $2}'`
set raw_images  = `grep raw_images mparameters_run | awk '{print $2}'`
set pixel_s     = `grep pixel_size mparameters_run | awk '{print $2}'`
set dstep       = `grep dstep mparameters_run | awk '{print $2}'`
set w_gh        = `grep WGH mparameters_run | awk '{print $2}'`
set kV1         = `grep kV1 mparameters_run | awk '{print $2}'`
set cs          = `grep Cs mparameters_run | awk '{print $2}'`
set xstd        = `grep XSTD mparameters_run | awk '{print $2}'`
set fmag        = `grep FMAG mparameters_run | awk '{print $2}'`
set fdef        = `grep FDEF mparameters_run | awk '{print $2}'`
set fastig      = `grep FASTIG mparameters_run | awk '{print $2}'`
set rbfact      = `grep RBFACT mparameters_run | awk '{print $2}'`
set iewald      = `grep IEWALD mparameters_run | awk '{print $2}'`
set asym        = `grep ASYM mparameters_run | awk '{print $2}'`
set alpha       = `grep ALPHA mparameters_run | awk '{print $2}'`
set rise        = `grep RISE mparameters_run | awk '{print $2}'`
set nsubunits   = `grep NSUBUNITS mparameters_run | awk '{print $2}'`
set nstarts     = `grep NSTARTS mparameters_run | awk '{print $2}'`
set stiffness   = `grep STIFFNESS mparameters_run | awk '{print $2}'`
set FBEAUT      = `grep FBEAUT mparameters_run | awk '{print $2}'`
set FCREF       = `grep FCREF mparameters_run | awk '{print $2}'`
set fmatch      = `grep FMATCH mparameters_run | awk '{print $2}'`
set IBLOW       = `grep IBLOW mparameters_run | awk '{print $2}'`
set ro          = `grep ROUT mparameters_run | awk '{print $2}'`
set ri          = `grep RIN mparameters_run | awk '{print $2}'`

set frealign_1 = /gpfs/home/rkhayat/Applications/frealign_v8.09_111001/bin/frealign_v8_mp.exe
set frealign_2 = /gpfs/home/rkhayat/Applications/frealign_v8.09b/frealign_v8_mp.exe
set frealign_3 =  /gpfs/home/rkhayat/Applications/frealign_v8.09_111001/bin/frealign_v8.exe
set frealign_4 = /gpfs/home/rkhayat/Applications/frealign_v8.09_111001/bin_dist/frealign_v8_mp.exe

set SCRATCH = ${working_directory}/scratch

@ prev = $start - 1
cd $SCRATCH

# cp ${working_directory}/${data_input}_${prev}.par ${data_input}_${prev}.par_$1_$2
cp ${working_directory}/${data_input}_${prev}.par ${data_input}_${start}.par_$1_$2
cp ${working_directory}/${data_input}_${prev}.par ${working_directory}/scratch/temp.par
cp ${working_directory}/${data_input}_${prev}.spi ${data_input}_${start}.spi_$1_$2
# rm ${data_input}_${start}.par_${1}_${2} >& /dev/null

${frealign_4} << eot >& ${data_input}_${start}_mrefine_n.log_${1}_${2}
S,${mode},${fmag},${fdef},${fastig},${fpart},${iewald},${FBEAUT},${FCREF},${fmatch},0,F,${IBLOW}	!CFORM,IFLAG,FMAG,FDEF,FASTIG,FPART,IEWALD,FBEAUT,FCREF,FMATCH,IFSC,FSTAT,IBLOW
${ro},${ri},${pixel_s},${w_gh},${xstd},${pbc},${boff},${dang},${itmax},10		!RO,RI,PSIZE,WGH,XSTD,PBC,BOFF,DANG,ITMAX,IPMAX
1 1 1 1 1										!MASK
${1},${2}										!IFIRST,ILAST 
${asym}											!ASYM symmetry card
1.0, ${dstep}, ${target}, ${thresh}, ${cs}, ${kV1}, 0., 0.				!RELMAG,DSTEP,TARGET,THRESH,CS,AKV,TX,TY
${rrec},${rlowref},${rref},${dfstd},${rbfact}						!RREC,RMAX1,RMAX2,DFSTD,RBFACT
${working_directory}/${raw_images}.spi
${data_input}_${start}_match.spi_${1}_${2}
temp.par
${data_input}_${start}.par_${1}_${2}
${data_input}_${start}.shft_${1}_${2}
0., 0., 0., 0., 0., 0., 0., 0.								!terminator with RELMAG=-100.0 to skip 3D reconstruction
${data_input}_${start}.spi_$1_$2
${data_input}_${start}_weights_${1}_${2}
${data_input}_${start}_qfactor_${1}_${2}
${data_input}_${start}_amplitudes_${1}_${2}
${data_input}_${start}_phasediffs_${1}_${2}
${data_input}_${start}_pointspread_${1}_${2}
eot

#
mv $SCRATCH/${data_input}_${start}.par_${first}_${last} ${working_directory}/${data_input}_${start}.par
mv $SCRATCH/${data_input}_${start}.spi_${first}_${last} ${working_directory}/${data_input}_${start}.spi
rm -rf $SCRATCH/temp.par


echo Job on $HOST finished >> $SCRATCH/stderr
#
