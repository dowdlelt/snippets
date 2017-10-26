#!/bin/sh

subnum=$1 #This must match the extracted dicoms folder name
#in other words - this will be used to name the files
# so make sure the folder is called what you want the data to be called as well.
datadir='/mnt/data0/tbs_opiate/data/'
modeldir='/mnt/data0/tbs_opiate/model_params/fsl/'


#This will run FEAT with the selected settings. 

DATA4D=${datadir}sub-${subnum}/ses-preTMS/derivatives/denoised_pain/pain_medn_nat.nii.gz
CONFOUNDS=${datadir}sub-${subnum}/ses-preTMS/derivatives/denoised_pain/meica.dn_pain_e1.pain/motion.1D
FMAPFEAT=${datadir}sub-${subnum}/ses-preTMS/derivatives/sub-${subnum}_ses-preTMS_magnitude.anat/fmap_FEAT.nii.gz
MAGBRAINFEAT=${datadir}sub-${subnum}/ses-preTMS/derivatives/sub-${subnum}_ses-preTMS_magnitude.anat/T1_biascorr_brain.nii.gz
E1SBREF=${datadir}sub-${subnum}/ses-preTMS/derivatives/denoised_pain/sub-${subnum}_ses-preTMS_task-pain_echo-1_sbref.nii.gz
BRAINFEAT=${datadir}sub-${subnum}/ses-preTMS/derivatives/sub-${subnum}_ses-preTMS_T1w.anat/T1_biascorr_brain.nii.gz

for i in '3_seconds_removed.fsf'; do
  sed -e 's@DATA4D@'$DATA4D'@g' \ #These match the variable names I placed in the .fsf file. 
   	-e 's@CONFOUNDS@'$CONFOUNDS'@g' \
   	-e 's@FMAPFEAT@'$FMAPFEAT'@g' \
	-e 's@MAGBRAINFEAT@'$MAGBRAINFEAT'@g' \
	-e 's@E1SBREF@'$E1SBREF'@g' \
	-e 's@BRAINFEAT@'$BRAINFEAT'@g' <$i> ${datadir}sub-${subnum}/ses-preTMS/derivatives/${subnum}_feat.fsf
done

# I have pre and post data, I run them seperate - hence the copy paste job here. 


cd ${datadir}sub-${subnum}/ses-preTMS/derivatives/denoised_pain/
feat ${datadir}sub-${subnum}/ses-preTMS/derivatives/${subnum}_feat.fsf &

DATA4D=${datadir}sub-${subnum}/ses-pstTMS/derivatives/denoised_pain/pain_medn_nat.nii.gz
CONFOUNDS=${datadir}sub-${subnum}/ses-pstTMS/derivatives/denoised_pain/meica.dn_pain_e1.pain/motion.1D
FMAPFEAT=${datadir}sub-${subnum}/ses-pstTMS/derivatives/sub-${subnum}_ses-pstTMS_magnitude.anat/fmap_FEAT.nii.gz
MAGBRAINFEAT=${datadir}sub-${subnum}/ses-pstTMS/derivatives/sub-${subnum}_ses-pstTMS_magnitude.anat/T1_biascorr_brain.nii.gz
E1SBREF=${datadir}sub-${subnum}/ses-pstTMS/derivatives/denoised_pain/sub-${subnum}_ses-pstTMS_task-pain_echo-1_sbref.nii.gz
BRAINFEAT=${datadir}sub-${subnum}/ses-preTMS/derivatives/sub-${subnum}_ses-preTMS_T1w.anat/T1_biascorr_brain.nii.gz
cd ${modeldir}
for i in '3_seconds_removed.fsf'; do
  sed -e 's@DATA4D@'$DATA4D'@g' \
   	-e 's@CONFOUNDS@'$CONFOUNDS'@g' \
   	-e 's@FMAPFEAT@'$FMAPFEAT'@g' \
	-e 's@MAGBRAINFEAT@'$MAGBRAINFEAT'@g' \
	-e 's@E1SBREF@'$E1SBREF'@g' \
	-e 's@BRAINFEAT@'$BRAINFEAT'@g' <$i> ${datadir}sub-${subnum}/ses-pstTMS/derivatives/${subnum}_feat.fsf
done
cd ${datadir}sub-${subnum}/ses-pstTMS/derivatives/denoised_pain/
feat ${datadir}sub-${subnum}/ses-pstTMS/derivatives/${subnum}_feat.fsf &
