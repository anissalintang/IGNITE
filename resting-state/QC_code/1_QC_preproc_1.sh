#!/bin/bash

# Quality control script for preprocessing_1

data_path="/Volumes/gdrive4tb/IGNITE"
preproc_path="/Volumes/gdrive4tb/IGNITE/resting-state/preprocessed"
log_path="/Volumes/gdrive4tb/IGNITE/resting-state/log"

subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed)) # Set the subject ID that you want to check

###############################################################
# Check that the first 10 volumes have been removed
for s in ${subj[@]}; do
	line_o=($(fslhd ${data_path}/data/nifti/${s}/*final_fmri*fMRI_2mm*.nii* | grep dim4)); vol_orig=${line_o[1]}
	line_p=($(fslhd ${preproc_path}/${s}/${s}_preprocessed.nii.gz | grep dim4)); vol_preproc=${line_p[1]}

	dif=$((${vol_orig}-${vol_preproc}))

	if [ $dif = 10 ]; then
		echo "$s 10 volumes removed" >> ${log_path}/1_QC_preproc_LOG.txt
	elif [ $dif != 10 ]; then
		echo "$s fslroi to remove 10 volumes FAILED" >> ${log_path}/1_QC_preproc_LOG.txt
	fi
done

###############################################################
# Check that finding the original motion parameters has worked
# By checking that there are 665 line in the original motion parameters absolute and 664 lines relative rms files
for s in ${subj[@]}; do
	abs=$(wc -l < ${preproc_path}/${s}/motionOrig/${s}_motionOrig_abs.rms)
	rel=$(wc -l < ${preproc_path}/${s}/motionOrig/${s}_motionOrig_rel.rms)

	if [ $abs = 665 ] && [ $rel = 664 ]; then
		echo "${s} Original motion parameters were obtained" >> ${log_path}/1_QC_preproc_LOG.txt
	elif [ $abs != 665 ] && [ $rel 1= 664 ]; then
		echo "${s} Original motion parameters NOT obtained" >> ${log_path}/1_QC_preproc_LOG.txt
	fi
done

###############################################################
# Check whether motion correction has worked
# There should be 665 files in the correction.mat folder

for s in ${subj[@]}; do
	m_corr=$(ls -1 ${preproc_path}/${s}/MotionCorrection/${s}_motionCorrection.mat | wc -l)

	if [ $m_corr = 665 ]; then
		echo "${s} Motion Correction has been performed" >> ${log_path}/1_QC_preproc_LOG.txt
	elif [ $m_corr != 665 ]; then
		echo "${s} Motion Correction has NOT been performed" >> ${log_path}/1_QC_preproc_LOG.txt
	fi
done

###############################################################
# Check for distortion correction
# By checking the fmap file: have the fmap pepolar0 and pepolar1 got 1 volume, and has the merged pepolar file got 2 volumes

for s in ${subj[@]}; do
	line_pepolar0=($(fslhd ${preproc_path}/${s}/topUp/fmap/${s}_aligned_pepolar0.nii.gz | grep dim4)); vol_pepolar0=${line_pepolar0[1]}
	line_pepolar1=($(fslhd ${preproc_path}/${s}/topUp/fmap/${s}_aligned_pepolar1.nii.gz | grep dim4)); vol_pepolar1=${line_pepolar1[1]}
	line_merge=($(fslhd ${preproc_path}/${s}/topUp/fmap/${s}_merge_pepolar.nii.gz | grep dim4)); vol_merge=${line_merge[1]}

	if [ ${vol_pepolar0} = 1 ] && [ ${vol_pepolar1} = 1 ] && [ ${vol_merge} = 2 ]; then
		echo "${s} Field maps has been created properly" >> ${log_path}/1_QC_preproc_LOG.txt
	elif [ ${vol_pepolar0} 1= 1 ] && [ ${vol_pepolar1} 1= 1 ] && [ ${vol_merge} != 2 ]; then
		echo "${s} Field maps has NOT been created properly" >> ${log_path}/1_QC_preproc_LOG.txt
	fi
done

###############################################################
# Check whether applytopup was performed successfully
# By checking whether folder topUpApplied is empty or not

for s in ${subj[@]}; do
	if [ "$(ls -A ${preproc_path}/${s}/topUp/QC_topUpApplied)" ]; then
		echo "${s} ApplyTopUp has been performed" >> ${log_path}/1_QC_preproc_LOG.txt
	else
		echo "${s} ApplyTopUp has NOT been performed" >> ${log_path}/1_QC_preproc_LOG.txt
	fi

done 


###############################################################
# Check whether dimensions of pepolar images are the same with functional image

for s in ${subj[@]}; do
	line_pepolar0=($(fslhd ${data_path}/data/nifti/${s}/*b0_pepolar=0*.nii* | grep dim1)); vol_pepolar0=${line_pepolar0[1]}
	line_pepolar1=($(fslhd ${data_path}/data/nifti/${s}/*b0_pepolar=1*.nii* | grep dim1)); vol_pepolar1=${line_pepolar1[1]}
	line_func=($(fslhd ${data_path}/data/nifti/${s}/*final_fmri*fMRI_2mm*.nii* | grep dim1)); vol_func=${line_func[1]}

	if [ ${vol_pepolar0} = ${vol_func} ]; then
		echo "${s} Dimensions of pepolar and functional images are the same" >> ${log_path}/1_QC_preproc_LOG.txt
	else
		echo "${s} Dimensions of pepolar and functional images are NOT the same. Pepolar = ${vol_pepolar0} and functional = ${vol_func}" >> ${log_path}/1_QC_preproc_LOG.txt
	fi
done










