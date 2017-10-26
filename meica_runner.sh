#!/bin/sh
subnum=$1 #This must match the extracted dicoms folder name
#in other words - this will be used to name the files
# so make sure the folder is called what you want the data to be called as well.
datadir='/mnt/data0/tbs_opiate/data/'
tr=1.35;

#-------------------
#Order of Ops
#	Run meica on pain data
#	create figures from matlab
#	repeat for post TMS pain, rest, post TMS rest. 
#	move all outputs to derivatives folder. 
#	prefix for pain data: pain
#	label for pain data: .pain
#That should make it easy to see what is what. 

cd ${datadir}sub-${subnum}/ses-preTMS/derivatives/sub-${subnum}_ses-preTMS_T1w.anat/
cp ./T1_biascorr_brain.nii.gz ../denoised_pain/
cp ./T1_biascorr_brain.nii.gz ../../../ses-pstTMS/derivatives/denoised_pain/

cd ${datadir}sub-${subnum}/ses-preTMS/derivatives/denoised_pain/
#in the pre tms func folder. 
~/soft/code/python/prantikk_meica/meica.py -d dn_pain_e1.nii.gz,dn_pain_e2.nii.gz,dn_pain_e3.nii.gz -e 15.40,33.66,51.92 -a T1_biascorr_brain.nii.gz --no_skullstrip --tpattern=@/mnt/data1/non_study/20170913_New_Thermode_Test/slice_times.txt --cpus=12 --skip_check --OVERWRITE -b 3v --prefix pain --label .pain 

#Next, go ahead and create compoent figures, assuming it all worked. 
matlab -nodesktop -nosplash -softwareopengl -r "addpath(genpath('/home/dowdlelt/soft/code')); term_meica_component_displayer('${datadir}sub-${subnum}/ses-preTMS/derivatives/denoised_pain/meica.dn_pain_e1.pain',$tr); exit"

#These files were getting a bit out of hand. So compressing them down seems real good. 

cd ${datadir}sub-${subnum}/ses-preTMS/derivatives/denoised_pain/meica.dn_pain_e1.pain
pigz --best dn_pain_e*
pigz --best e*_ts+orig*

cd ./TED
pigz --best *.nii



#and for post tms
cd ${datadir}sub-${subnum}/ses-pstTMS/derivatives/denoised_pain/
#in the pre tms func folder. 
~/soft/code/python/prantikk_meica/meica.py -d dn_pain_e1.nii.gz,dn_pain_e2.nii.gz,dn_pain_e3.nii.gz -e 15.40,33.66,51.92 -a T1_biascorr_brain.nii.gz --no_skullstrip --tpattern=@/mnt/data1/non_study/20170913_New_Thermode_Test/slice_times.txt --cpus=12 --skip_check --OVERWRITE -b 3v --prefix pain --label .pain 

#Next, go ahead and create compoent figures, assuming it all worked. 
matlab -nodesktop -nosplash -softwareopengl -r "addpath(genpath('/home/dowdlelt/soft/code')); term_meica_component_displayer('${datadir}sub-${subnum}/ses-pstTMS/derivatives/denoised_pain/meica.dn_pain_e1.pain',$tr); exit"

cd ${datadir}sub-${subnum}/ses-pstTMS/derivatives/denoised_pain/meica.dn_pain_e1.pain
pigz --best dn_pain_e*
pigz --best e*_ts+orig*

cd ./TED
pigz --best *.nii


