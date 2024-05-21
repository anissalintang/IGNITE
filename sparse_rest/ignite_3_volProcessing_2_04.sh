#!/bin/bash

# Volumetric data processing script
# Here we create mat and warp files needed (inside registration folder)
volume_processing_2() {

	data_path="/Volumes/gdrive4tb/IGNITE";s=$1
	preproc_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/preprocessed"
	vol_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/volumetric"
	log_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/log"

	###############################################################
	#REGISTRATION
	###############################################################
	# struct2mni
	###############################################################

	mkdir -p ${vol_path}/registration/$s/struct2mni

	# Perform robust FOV of the structural, T1 image
	robustfov -i ${data_path}/data/nifti_sparse_secondVisit/IGTTMD_00004a/*SAG_T1*.nii* -r ${vol_path}/registration/$s/${s}_t1.nii.gz

	# Perform bias correction (nonpve prevents fast from performing segmentation of the image)
	fast -B --nopve ${vol_path}/registration/$s/${s}_t1.nii.gz

	# Perform spatial smoothing / noise reduction using SUSAN, whilst preserving the underlying structure of T1
	fwhm=2.5; sigma=$(bc -l <<< "$fwhm/(2*sqrt(2*l(2)))")
	susan ${vol_path}/registration/$s/${s}_t1.nii.gz -1 $sigma 3 1 0 ${vol_path}/registration/$s/${s}_t1.nii.gz

	#Remove the unecessary files
    imrm ${vol_path}/registration/$s/${s}_t1_*

	# Use flirt with 12 DOF with the structural image (T1) and MNI-2mm, with the default cost function --> corratio
	flirt \
	-in ${vol_path}/registration/$s/${s}_t1.nii.gz \
	-ref $FSLDIR/data/standard/MNI152_T1_2mm \
	-omat ${vol_path}/registration/$s/struct2mni/${s}_struct2mni.mat \
	-dof 12
 
	# Use fnirt with the structural image and MNI-152 (non-linear)
	fnirt \
	--in=${vol_path}/registration/$s/${s}_t1.nii.gz \
	--ref=$FSLDIR/data/standard/MNI152_T1_2mm \
	--refmask=$FSLDIR/data/standard/MNI152_T1_2mm_brain_mask_dil \
	--aff=${vol_path}/registration/$s/struct2mni/${s}_struct2mni.mat \
	--cout=${vol_path}/registration/$s/struct2mni/${s}_struct2mni_warp \
	--config=T1_2_MNI152_2mm \
	--warpres=10,10,10

	# Apply warp from fnirt step (above) to register the structural image to MNI space
	applywarp \
	-i ${vol_path}/registration/$s/${s}_t1.nii.gz \
	-w ${vol_path}/registration/$s/struct2mni/${s}_struct2mni_warp \
	-r $FSLDIR/data/standard/MNI152_T1_1mm \
	-o ${vol_path}/registration/$s/struct2mni/${s}_struct2mni.nii.gz 

	# Checkpoint for struct2mni
	echo "${s} registration of struct2mni has been performed" >> ${log_path}/2_volProcessing_2_LOG.txt

	##############################################################
	# mni2struct
	##############################################################
	# Produce inverse warp image, so we can transform back MNI-152 to native space (T1)
	# Reference image is the crop-smoothed t1 in this folder >> {s}_t1/.nii.gz
	mkdir -p ${vol_path}/registration/$s/mni2struct

	invwarp \
	-w ${vol_path}/registration/$s/struct2mni/${s}_struct2mni_warp \
	-r ${vol_path}/registration/$s/${s}_t1.nii.gz \
	-o ${vol_path}/registration/$s/mni2struct/${s}_mni2struct_warp

	# Checkpoint for mni2struct
	echo "${s} registration of mni2struct has been performed" >> ${log_path}/2_volProcessing_2_LOG.txt


	# ##############################################################
	# Registration of the mean functional image to native space (T1)
	# Do linear registration using flirt with 6 DOF (rigid, because both functional and T1 images are from the same subject)
	# meanfunc2struct - UNSMOOTHED
	##############################################################

	# If you need to take an FMRI data set where you only have a few slices (ie the field-of-view - FOV - is small in Z) then it is very hard to get a good registration with either the subject's structural or directly to a standard space image. This page describes our recommendations in such cases:

	# https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FLIRT/UserGuide#Using_FLIRT_to_Register_a_Few_FMRI_Slices

	mkdir -p ${vol_path}/registration/$s/meanfunc2struct

	bet ${vol_path}/registration/$s/${s}_t1.nii.gz ${vol_path}/registration/$s/${s}_t1_brain.nii.gz

	fast -t 1 -g -o ${vol_path}/registration/$s/${s}_t1_brain.nii.gz ${vol_path}/registration/$s/${s}_t1_brain.nii.gz

	flirt \
	-ref ${vol_path}/registration/$s/${s}_t1_brain.nii.gz \
	-in ${preproc_path}/$s/meanFunc/${s}_mean_func.nii.gz \
	-omat ${vol_path}/registration/$s/meanfunc2struct/${s}_meanfunc2struct.mat \
	-out ${vol_path}/registration/$s/meanfunc2struct/${s}_meanfunc2struct.nii.gz \
	-interp nearestneighbour \
	-cost bbr \
	-wmseg ${vol_path}/registration/$s/${s}_t1_brain_pve_2 \
	-dof 6 \
	-schedule ${FSLDIR}/etc/flirtsch/bbr.sch


	# Checkpoint for meanfunc2struct - UNSMOOTHED
	echo "${s} registration of meanfunc2struct - UNSMOOTHED image has been performed" >> ${log_path}/2_volProcessing_2_LOG.txt

	# ###############################################################
	# # struct2meanfunc - UNSMOOTHED
	# ###############################################################

	# Create the inverse of the mat file
	mkdir -p ${vol_path}/registration/$s/struct2meanfunc

	convert_xfm \
	-omat ${vol_path}/registration/$s/struct2meanfunc/${s}_struct2meanfunc.mat \
	-inverse ${vol_path}/registration/$s/meanfunc2struct/${s}_meanfunc2struct.mat

	# Checkpoint for struct2meanfunc
	echo "${s} creation of struct2meanfunc mat files has been done" >> ${log_path}/2_volProcessing_2_LOG.txt

	# ###############################################################
	# # func2mni - UNSMOOTHED
	# ###############################################################
	# Apply the warp fields to transform the functional timeseries from native to standard (MNI-152) space
	mkdir -p ${vol_path}/registration/$s/func2mni

	## ...continuing from meanfunc2struct
	# 4. Now combine the transforms:
	convert_xfm \
	-concat ${vol_path}/registration/$s/struct2mni/${s}_struct2mni.mat \
	-omat ${vol_path}/registration/$s/func2mni/${s}_meanfunc2mni.mat ${vol_path}/registration/$s/meanfunc2struct/${s}_meanfunc2struct.mat


	applywarp \
	--ref=${FSLDIR}/data/standard/MNI152_T1_2mm \
	--in=${vol_path}/temporalFiltering/filt_0.01-0.1/${s}/${s}_preprocessed_psc_filt01.nii.gz \
	--warp=${vol_path}/registration/$s/struct2mni/${s}_struct2mni_warp \
	--premat=${vol_path}/registration/$s/meanfunc2struct/${s}_meanfunc2struct.mat \
	--interp=nn \
	--out=${vol_path}/registration/$s/func2mni/${s}_func2mni.nii.gz

	# Checkpoint for func2mni - UNSMOOTHED
	echo "${s} registration of func2mni - UNSMOOTHED image has been performed" >> ${log_path}/2_volProcessing_2_LOG.txt


	# #############################################################################################################################
	# Registration of the mean functional image (filt_0.01-0.1) to native space (T1)
	# Do linear registration using flirt with 6 DOF (rigid, because both functional and T1 images are from the same subject)
	# meanfunc2struct - SMOOTHED
	# ##############################################################

	mkdir -p ${vol_path}/registration/$s/meanfunc2struct_smoothed

	flirt \
	-ref ${vol_path}/registration/$s/${s}_t1_brain.nii.gz \
	-in ${preproc_path}/$s/meanFunc_smoothed/${s}_mean_func_smoothed.nii.gz \
	-omat ${vol_path}/registration/$s/meanfunc2struct_smoothed/${s}_meanfunc2struct_smoothed.mat \
	-out ${vol_path}/registration/$s/meanfunc2struct_smoothed/${s}_meanfunc2struct_smoothed.nii.gz \
	-interp nearestneighbour \
	-cost bbr \
	-wmseg ${vol_path}/registration/$s/${s}_t1_brain_pve_2 \
	-dof 6 \
	-schedule ${FSLDIR}/etc/flirtsch/bbr.sch

	# Checkpoint for meanfunc2struct - SMOOTHED
	echo "${s} registration of meanfunc2struct - SMOOTHED image has been performed" >> ${log_path}/2_volProcessing_2_LOG.txt

	###############################################################
	# struct2meanfunc - SMOOTHED
	###############################################################

	# Create the inverse of the mat file
	mkdir -p ${vol_path}/registration/$s/struct2meanfunc_smoothed

	convert_xfm \
	-omat ${vol_path}/registration/$s/struct2meanfunc_smoothed/${s}_struct2meanfunc_smoothed.mat \
	-inverse ${vol_path}/registration/$s/meanfunc2struct_smoothed/${s}_meanfunc2struct_smoothed.mat

	# Checkpoint for struct2meanfunc
	echo "${s} creation of struct2meanfunc - SMOOTHED mat files has been done" >> ${log_path}/2_volProcessing_2_LOG.txt

	###############################################################
	# func2mni - SMOOTHED
	###############################################################
	# Apply the warp fields to transform the functional timeseries from native to standard (MNI-152) space
	mkdir -p ${vol_path}/registration/$s/func2mni_smoothed

	## ...continuing from meanfunc2struct
	# 4. Now combine the transforms:
	convert_xfm \
	-concat ${vol_path}/registration/$s/struct2mni/${s}_struct2mni.mat \
	-omat ${vol_path}/registration/$s/func2mni_smoothed/${s}_meanfunc2mni_smoothed.mat ${vol_path}/registration/$s/meanfunc2struct_smoothed/${s}_meanfunc2struct_smoothed.mat

	applywarp \
	--ref=${FSLDIR}/data/standard/MNI152_T1_2mm \
	--in=${vol_path}/temporalFiltering/filt_0.01-0.1_smoothed/${s}/${s}_preprocessed_psc_filt01_smoothed.nii.gz \
	--warp=${vol_path}/registration/$s/struct2mni/${s}_struct2mni_warp \
	--premat=${vol_path}/registration/$s/meanfunc2struct_smoothed/${s}_meanfunc2struct_smoothed.mat \
	--interp=nn \
	--out=${vol_path}/registration/$s/func2mni_smoothed/${s}_func2mni_smoothed.nii.gz


	# Checkpoint for func2mni - SMOOTHED
	echo "${s} registration of func2mni - SMOOTHED image has been performed" >> ${log_path}/2_volProcessing_2_LOG.txt

	# Checkpoint for all registration steps
	echo "${s} registration of mean functional images (UN-SMOOTHED and SMOOTHED) to T1 and T1 to MNI-152 are finished" >> ${log_path}/2_volProcessing_2_LOG.txt

}

# Exports the function
export -f volume_processing_2

# Create an array with subjects (as they are in preprocessed folder)
# s=($(ls /Volumes/gdrive4tb/IGNITE/sparse_rest/preprocessed | grep -vE "IGTTKA_00017"))
s=(IGTTMD_00004)

# Check the content of the subject array
echo ${s[@]}

# Run the analysis in parallel using GNU parallel
# Jobs is set to 0, which allows parallel to assign the jobs as it sees fit, and divide it across the CPUs itself
# Provide it with the name of the function, and specify it will take one argument, then provide this after the three colons

parallel --jobs 6 'volume_processing_2 {1}' ::: ${s[@]}