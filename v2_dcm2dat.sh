#!/bin/bash
subnum=$1 #This must match the extracted dicoms folder name
#in other words - this will be used to name the files
# so make sure the folder is called what you want the data to be called as well.
dcmdir='/mnt/data0/tbs_opiate/dicoms/'
rawdcmdir='/mnt/data0/tbs_opiate/dicoms/'${subnum}'/'
sortdcmdir=${rawdcmdir}/.dcmsorted/
datadir='/mnt/data0/tbs_opiate/data/'

echo 'Start'
cd ${dcmdir}
mkdir ${subnum}
echo '-------------------------------------'
echo '-----Unzipping files-----'
echo '-------------------------------------'
unzip -q -d ${subnum} ./${subnum}.zip

cd ${datadir}
mkdir sub-${subnum}
cd sub-${subnum}
echo '-----Making Directories-----'
mkdir ses-preTMS
cd ses-preTMS
mkdir anat
mkdir fmap
mkdir func
mkdir derivatives
cd ..

mkdir ses-pstTMS
cd ses-pstTMS
mkdir fmap
mkdir func
mkdir derivatives
cd ..

cd ${rawdcmdir}

#First, convert and organize the dicoms, within their home dir. 
echo 'Running ' dicomsort.py ${rawdcmdir} ./.dcmsorted/%SeriesDescription/%SOPInstanceUID.dcm -k
~/soft/code/python/dicomsort-master/dicomsort.py ${rawdcmdir} ./.dcmsorted/%SeriesDescription/%SOPInstanceUID.dcm -k
#SOPInstanceUID is just certain to be unique for each and every image. 

cd ${sortdcmdir}
echo '-------------------------------------'
echo '-----dcm2niix-----'
echo '-------------------------------------'
#Convert each thing, as required. 
#as long as the names stay the same on the scanner, this will work. 
dcm2niix -b y -i y -z y -f sub-${subnum}_ses-preTMS_T1w -o ${datadir}sub-${subnum}/ses-preTMS/anat/ ./mprage
dcm2niix -b y -i y -z y -f sub-${subnum}_ses-preTMS_task-pain_echo-%e_bold -o ${datadir}sub-${subnum}/ses-preTMS/func/ ./mbme_thermal_pre
dcm2niix -b y -i y -z y -f sub-${subnum}_ses-pstTMS_task-pain_echo-%e_bold -o ${datadir}sub-${subnum}/ses-pstTMS/func/ ./mbme_thermal_post
dcm2niix -b y -i y -z y -f sub-${subnum}_ses-preTMS_task-rest_echo-%e_bold -o ${datadir}sub-${subnum}/ses-preTMS/func/ ./mbme_rest_pre
dcm2niix -b y -i y -z y -f sub-${subnum}_ses-pstTMS_task-rest_echo-%e_bold -o ${datadir}sub-${subnum}/ses-pstTMS/func/ ./mbme_rest_post
#Note that for SBRefs - the ignore flag in dcm2niix must be turned off. 
dcm2niix -b y -z y -f sub-${subnum}_ses-preTMS_task-pain_echo-%e_sbref -o ${datadir}sub-${subnum}/ses-preTMS/func/ ./mbme_thermal_pre_SBRef
dcm2niix -b y -z y -f sub-${subnum}_ses-pstTMS_task-pain_echo-%e_sbref -o ${datadir}sub-${subnum}/ses-pstTMS/func/ ./mbme_thermal_post_SBRef
dcm2niix -b y -z y -f sub-${subnum}_ses-preTMS_task-rest_echo-%e_sbref -o ${datadir}sub-${subnum}/ses-preTMS/func/ ./mbme_rest_pre_SBRef
dcm2niix -b y -z y -f sub-${subnum}_ses-pstTMS_task-rest_echo-%e_sbref -o ${datadir}sub-${subnum}/ses-pstTMS/func/ ./mbme_rest_post_SBRef
dcm2niix -b y -z y -f sub-${subnum}_ses-preTMS_renameme_%e -o ${datadir}sub-${subnum}/ses-preTMS/fmap/ ./fmap_pre
dcm2niix -b y -z y -f sub-${subnum}_ses-pstTMS_renameme_%e -o ${datadir}sub-${subnum}/ses-pstTMS/fmap/ ./fmap_post
dcm2niix -b y -i y -z y -f sub-${subnum}_ses-preTMS_dir-PA_echo-%e_epi -o ${datadir}sub-${subnum}/ses-preTMS/fmap/ ./mbme_pa_pre
dcm2niix -b y -z y -f sub-${subnum}_ses-preTMS_dir-PA_echo-%e_sbref -o ${datadir}sub-${subnum}/ses-preTMS/fmap/ ./mbme_pa_pre_SBRef
dcm2niix -b y -i y -z y -f sub-${subnum}_ses-pstTMS_dir-PA_echo-%e_epi -o ${datadir}sub-${subnum}/ses-pstTMS/fmap/ ./mbme_pa_post
dcm2niix -b y -z y -f sub-${subnum}_ses-pstTMS_dir-PA_echo-%e_sbref -o ${datadir}sub-${subnum}/ses-pstTMS/fmap/ ./mbme_pa_post_SBRef

#This solves the fieldmap naming issue. 
#however, there are still echo time errors - that don't meet BIDS spec. 
mv ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_renameme_1.nii.gz ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_magnitude.nii.gz 
mv ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_renameme_1.json ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_magnitude.json

maxint=$(fslstats ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_renameme_2a.nii.gz -p 100) #Find the phase map by looking at max intensity. 
if ((${maxint%.*} > 4000)); then 
	echo 2a is phasediff
	mv ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_renameme_2a.nii.gz ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_phasediff.nii.gz 
	mv ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_renameme_2a.json ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_phasediff.json
	else
	mv ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_renameme_2.nii.gz ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_phasediff.nii.gz 
	mv ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_renameme_2.json ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_phasediff.json
fi

#if there is a renameme remaining, it is likely the magnitude image, so lets convert it if it exists. This will break probably. 
rm ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_r*.nii.gz 
rm ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_r*.json

#Correct the fieldmap names for the post condition



mv ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_renameme_1.nii.gz ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_magnitude.nii.gz 
mv ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_renameme_1.json ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_magnitude.json

maxint=$(fslstats ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_renameme_2a.nii.gz -p 100) #Find the phase map by looking at max intensity. 
if ((${maxint%.*} > 4000)); then 
	echo 2a is phasediff
	mv ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_renameme_2a.nii.gz ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_phasediff.nii.gz 
	mv ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_renameme_2a.json ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_phasediff.json
	else
	mv ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_renameme_2.nii.gz ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_phasediff.nii.gz 
	mv ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_renameme_2.json ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_phasediff.json	
fi


#same as above, deal with a renameme still sticking around. 
rm ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_r*.nii.gz 
rm ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_r*.json 

echo '-------------------------------------'
echo '-----removing extra dirs-----'
echo '-------------------------------------'
rm -r ${sortdcmdir} #Remove the sorted dicoms, so that twice as much space isn't being taken up
chmod -R 777 ${rawdcmdir}*
rm -r ${rawdcmdir} #and remove the unzipped files leaving on the original compressed thing.
#Need to go to the directory where things are happening. 

#Start with denoising, since that proceeds relatively quickly


cd ${datadir}sub-${subnum}/ses-preTMS/func/
echo '-------------------------------------'
echo '-----dwidenoise: pain-----'
echo '-------------------------------------'
#Denoising with dwidenoise, and default settings.
mkdir  ${datadir}sub-${subnum}/ses-preTMS/func/denoised_pain
echo '-----denoising e1 pre-----'
dwidenoise ${datadir}sub-${subnum}/ses-preTMS/func/sub-${subnum}_ses-preTMS_task-pain_echo-1_bold.nii.gz ${datadir}sub-${subnum}/ses-preTMS/func/denoised_pain/dn_pain_e1.nii.gz -noise ${datadir}sub-${subnum}/ses-preTMS/func/denoised_pain/noise_map_e1.nii.gz -quiet
echo '-----denoising e2 pre-----'
dwidenoise ${datadir}sub-${subnum}/ses-preTMS/func/sub-${subnum}_ses-preTMS_task-pain_echo-2_bold.nii.gz ${datadir}sub-${subnum}/ses-preTMS/func/denoised_pain/dn_pain_e2.nii.gz -noise ${datadir}sub-${subnum}/ses-preTMS/func/denoised_pain/noise_map_e2.nii.gz -quiet
echo '-----denoising e3 pre-----'
dwidenoise ${datadir}sub-${subnum}/ses-preTMS/func/sub-${subnum}_ses-preTMS_task-pain_echo-3_bold.nii.gz ${datadir}sub-${subnum}/ses-preTMS/func/denoised_pain/dn_pain_e3.nii.gz -noise ${datadir}sub-${subnum}/ses-preTMS/func/denoised_pain/noise_map_e3.nii.gz -quiet

mv ./denoised_pain ../derivatives/

cd ${datadir}sub-${subnum}/ses-pstTMS/func/
#Denoising the pst TMS condition
mkdir  ${datadir}sub-${subnum}/ses-pstTMS/func/denoised_pain
echo '-----denoising e1 post-----'
dwidenoise ${datadir}sub-${subnum}/ses-pstTMS/func/sub-${subnum}_ses-pstTMS_task-pain_echo-1_bold.nii.gz ${datadir}sub-${subnum}/ses-pstTMS/func/denoised_pain/dn_pain_e1.nii.gz -noise ${datadir}sub-${subnum}/ses-pstTMS/func/denoised_pain/noise_map_e1.nii.gz -quiet
echo '-----denoising e2 post-----'
dwidenoise ${datadir}sub-${subnum}/ses-pstTMS/func/sub-${subnum}_ses-pstTMS_task-pain_echo-2_bold.nii.gz ${datadir}sub-${subnum}/ses-pstTMS/func/denoised_pain/dn_pain_e2.nii.gz -noise ${datadir}sub-${subnum}/ses-pstTMS/func/denoised_pain/noise_map_e2.nii.gz -quiet
echo '-----denoising e3 post-----'
dwidenoise ${datadir}sub-${subnum}/ses-pstTMS/func/sub-${subnum}_ses-pstTMS_task-pain_echo-3_bold.nii.gz ${datadir}sub-${subnum}/ses-pstTMS/func/denoised_pain/dn_pain_e3.nii.gz -noise ${datadir}sub-${subnum}/ses-pstTMS/func/denoised_pain/noise_map_e3.nii.gz -quiet

mv ./denoised_pain ../derivatives/

echo '-------------------------------------'
echo '-----fsl_anat on Anat-----'
echo '-------------------------------------'
fsl_anat -i ${datadir}sub-${subnum}/ses-preTMS/anat/sub-${subnum}_ses-preTMS_T1w.nii.gz
#This will create a folder that is suffiex '.anat'
#This can easily be moved. 
cd ${datadir}sub-${subnum}/ses-preTMS/anat/
mv *.anat ../derivatives/
cd ..

#Next, we need to skull strip the fieldmaps
#fsl_anat again has very good performance

echo '-------------------------------------'
echo '-----Prepping fieldmap pre-----'
echo '-------------------------------------'
fsl_anat -i ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_magnitude.nii.gz --nocrop --noseg --nosubcortseg --strongbias --noreg --nononlinreg
#This reorients the data, which also needs to be done to the fieldmap. 
cp ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_phasediff.nii.gz ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_magnitude.anat/
cd ${datadir}sub-${subnum}/ses-preTMS/fmap/sub-${subnum}_ses-preTMS_magnitude.anat/
fslreorient2std sub-${subnum}_ses-preTMS_phasediff.nii.gz sub-${subnum}_ses-preTMS_phasediff_standard.nii.gz

#Then run fslprepare fieldmap for this data. 

fsl_prepare_fieldmap SIEMENS sub-${subnum}_ses-preTMS_phasediff_standard.nii.gz T1_biascorr_brain.nii.gz fmap_FEAT.nii.gz 2.46

cd ..
mv *.anat ../derivatives/
#Move everything to the derivatives folder - this means nothing is left in there but BIDs compatable data. 

#Now have to do the same thing for pstTMS. 

echo '-------------------------------------'
echo '-----Prepping fieldmap post-----'
echo '-------------------------------------'
fsl_anat -i ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_magnitude.nii.gz --nocrop --noseg --nosubcortseg --strongbias --noreg --nononlinreg
#This reorients the data, which also needs to be done to the fieldmap. 
cp ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_phasediff.nii.gz ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_magnitude.anat/
cd ${datadir}sub-${subnum}/ses-pstTMS/fmap/sub-${subnum}_ses-pstTMS_magnitude.anat/
fslreorient2std sub-${subnum}_ses-pstTMS_phasediff.nii.gz sub-${subnum}_ses-pstTMS_phasediff_standard.nii.gz

#Then run fslprepare fieldmap for this data. 

fsl_prepare_fieldmap SIEMENS sub-${subnum}_ses-pstTMS_phasediff_standard.nii.gz T1_biascorr_brain.nii.gz fmap_FEAT.nii.gz 2.46

cd ..
mv *.anat ../derivatives/

echo '-----copying SBRefs-----'
cp ${datadir}sub-${subnum}/ses-preTMS/func/sub-${subnum}_ses-preTMS_task-pain_echo-1_sbref.nii.gz ${datadir}sub-${subnum}/ses-preTMS/derivatives/denoised_pain/
cp ${datadir}sub-${subnum}/ses-pstTMS/func/sub-${subnum}_ses-pstTMS_task-pain_echo-1_sbref.nii.gz ${datadir}sub-${subnum}/ses-pstTMS/derivatives/denoised_pain/




