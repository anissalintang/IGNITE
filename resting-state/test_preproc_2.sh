#!/bin/bash

#pre_processing script
data_preproc() {
	data_path="/Volumes/gdrive4tb/IGNITE";s=$1
	log_path="/Volumes/gdrive4tb/IGNITE/resting-state/log"

	###############################################################
	# Preprocess only if functional data exist!
	if ls ${data_path}/data/nifti/${s}/*final_fmri*fMRI_2mm*.nii* 1> /dev/null 2>&1; then

		# #Make directories for the preprocessing files
		# mkdir -p ${data_path}/resting-state/test_distortion_corratio/$s
		analysis_path="/Volumes/gdrive4tb/IGNITE/resting-state/test_distortion_corratio"

		# ###############################################################
		# #Remove the first 10 volumes from each image
		# fslroi ${data_path}/data/nifti/${s}/*final_fmri*fMRI_2mm*.nii* ${analysis_path}/$s/${s}_preprocessed.nii.gz 10 -1


		# ###############################################################
		# #Save the original motion parameters to be used separately (save in a different folder)
		# mkdir -p ${analysis_path}/$s/motionOrig
		# mcflirt -in ${analysis_path}/$s/${s}_preprocessed.nii.gz -out ${analysis_path}/$s/motionOrig/${s}_motionOrig -plots -rmsrel -rmsabs -spline_final
		# ###############################################################
		# #Slice timing correction
		# ##Selects the repetition time from the file header, using the fslhd function with grep
		# ##If using z-shell uses tr=${line[2]}
		# ##If using bash tr=${line[1]}
		# ##pixdim4 refers to the parameter which describes the repetition time
		# line=($(fslhd ${analysis_path}/$s/${s}_preprocessed.nii.gz | grep pixdim4)); tr=${line[1]}

		# ## Our fMRI data was acquired using multiband EPI, thus the slice timing would be different
		# ##Create a single-column file of slice timing order taken from the json files
		# ### Get all 54 lines starting with "SliceTiming"
		# grep -A54 '"SliceTiming"' ${data_path}/data/nifti/$s/*final_fmri*fMRI_2mm*.json | grep "[0-9]*" > ${data_path}/data/nifti/$s/rawSliceTiming.txt
		# ### Print all the numbers, and essentially removed the string, in this case the "SliceTiming"
		# awk '{print $0+0}' ${data_path}/data/nifti/$s/rawSliceTiming.txt > ${data_path}/data/nifti/$s/tempSliceTiming.txt
		# ### Remove the first 0 that was created from the awk step above
		# tail -n +2 ${data_path}/data/nifti/$s/tempSliceTiming.txt > ${analysis_path}/$s/SliceTimingOrder.txt

		# ## Remove temporary files
		# rm ${data_path}/data/nifti/$s/rawSliceTiming.txt ${data_path}/data/nifti/$s/tempSliceTiming.txt

		# #Perform the slice time correction -r is repetition time, --tcustom specifies a file of single-column slice timings order, in fractions of TR, +ve values shift slices towards in time (SliceTimingOrder.txt)
		# slicetimer -i ${analysis_path}/$s/${s}_preprocessed.nii.gz -o ${analysis_path}/$s/${s}_preprocessed.nii.gz -r $tr --tcustom=${analysis_path}/$s/SliceTimingOrder.txt


		# ##############################################################
		# # Motion correction
		# # This time it will actually perform the motion correction, rather than just saving the motion parameters (re: Original motion parameters)
		# mkdir -p ${analysis_path}/$s/MotionCorrection
		
		# ##Create a mean image to use as the reference for the motion correction
		# fslmaths ${analysis_path}/$s/${s}_preprocessed.nii.gz -Tmean ${analysis_path}/$s/MotionCorrection/${s}_preprocessed_mean

		# #Perform the motion correction
		# mcflirt -in ${analysis_path}/$s/${s}_preprocessed.nii.gz -out ${analysis_path}/$s/${s}_preprocessed -reffile ${analysis_path}/$s/MotionCorrection/${s}_preprocessed_mean -mats -spline_final -plots

		# ##Move the MAT file to the motion correction folder and rename
		# mv ${analysis_path}/$s/${s}_preprocessed.mat ${analysis_path}/$s/MotionCorrection/${s}_motionCorrection.mat

		# ##Move the PAR file to the motion correction folder and rename
		# mv ${analysis_path}/$s/${s}_preprocessed.par ${analysis_path}/$s/MotionCorrection/${s}_motionCorrection.par


		# # ###############################################################
		# # Distortion correction
		# mkdir -p ${analysis_path}/$s/topUp/fmap

		# # Calculate mean functional image from the last step (motion correction)
		# fslmaths ${analysis_path}/$s/${s}_preprocessed.nii.gz -Tmean ${analysis_path}/$s/topUp/${s}_preprocessed_mean

		# # Calculate mean of PEpolar 0 and PEpolar 1 images to create a single image file for each
		# fslmaths ${data_path}/data/nifti/$s/*b0_pepolar=0*.nii* -Tmean ${analysis_path}/$s/topUp/fmap/${s}_mean_pepolar0
		# fslmaths ${data_path}/data/nifti/$s/*b0_pepolar=1*.nii* -Tmean ${analysis_path}/$s/topUp/fmap/${s}_mean_pepolar1

		# # Do rigid transformation for each PEpolar images, in case of movements between two images acquisition
		# flirt \
		# -in ${analysis_path}/$s/topUp/fmap/${s}_mean_pepolar0 \
		# -ref ${analysis_path}/$s/topUp/${s}_preprocessed_mean \
		# -out ${analysis_path}/$s/topUp/fmap/${s}_aligned_pepolar0.nii.gz \
		# -omat ${analysis_path}/$s/topUp/fmap/${s}_aligned_pepolar0.mat \
		# -interp nearestneighbour \
		# -cost corratio \
		# -dof 6

		# flirt \
		# -in ${analysis_path}/$s/topUp/fmap/${s}_mean_pepolar1 \
		# -ref ${analysis_path}/$s/topUp/${s}_preprocessed_mean \
		# -out ${analysis_path}/$s/topUp/fmap/${s}_aligned_pepolar1.nii.gz \
		# -omat ${analysis_path}/$s/topUp/fmap/${s}_aligned_pepolar1.mat \
		# -interp nearestneighbour \
		# -cost corratio \
		# -dof 6

		# # Merge both PEpolar images into a single image
		# fslmerge -t ${analysis_path}/$s/topUp/fmap/${s}_merge_pepolar.nii.gz ${analysis_path}/$s/topUp/fmap/${s}_aligned_pepolar0.nii.gz ${analysis_path}/$s/topUp/fmap/${s}_aligned_pepolar1.nii.gz

		# # Create a directory to save the results from calling the TopUp function
		# mkdir -p ${analysis_path}/$s/topUp/topUpResults

		# #Create the config file, also called the acquisition parameters, which has 4 columns.
		# #The first three columns represents the PE direction. J = 0 1 0 and J- = 0 -1 0
		# #The last column represents the total readout time
		# PEdir_j=$(echo "0 1 0")
		# TotalReadoutTime_j=$(grep -A0 '"TotalReadoutTime"' ${data_path}/data/nifti/$s/*b0_pepolar=0*.json | grep -Eo '[0-9|.]+')
		# echo $PEdir_j $TotalReadoutTime_j > ${analysis_path}/$s/topUp/fmap/acqparam.txt

		# PEdir_jrev=$(echo "0 -1 0")
		# TotalReadoutTime_jrev=$(grep -A0 '"TotalReadoutTime"' ${data_path}/data/nifti/$s/*b0_pepolar=0*.json | grep -Eo '[0-9|.]+')
		# echo $PEdir_jrev $TotalReadoutTime_jrev >> ${analysis_path}/$s/topUp/fmap/acqparam.txt

		# # Call the TOP UP function to estimate the field inhomogeneity
		# topup \
		# --imain=${analysis_path}/${s}/topUp/fmap/${s}_merge_pepolar \
		# --datain=${analysis_path}/${s}/topUp/fmap/acqparam.txt \
		# --out=${analysis_path}/${s}/topUp/topUpResults/${s}_topUp_results

		# # Create a directory to save the results from calling the QC_ApplyTopUp function
		# mkdir -p ${analysis_path}/$s/topUp/QC_topUpApplied


		# # Call the ApplyTopUp to the functional image
		# applytopup \
		# --imain=${analysis_path}/${s}/${s}_preprocessed.nii.gz \
		# --inindex=1 \
		# --datain=${analysis_path}/${s}/topUp/fmap/acqparam.txt \
		# --topup=${analysis_path}/${s}/topUp/topUpResults/${s}_topUp_results \
		# --method=jac \
		# --out=${analysis_path}/${s}/${s}_preprocessed.nii.gz

		# # Checkpoint of motion correction
		# echo "${s} Distortion correction step has finished." >> ${log_path}/1_preproc_LOG.txt

		# ###############################################################
		# # Save mean and brain extracted images
		# # A. NON-SMOOTHED
		# mkdir -p ${analysis_path}/$s/meanFunc/bet

		# # Take the mean of the functional image
		# fslmaths ${analysis_path}/$s/${s}_preprocessed.nii.gz -Tmean ${analysis_path}/$s/meanFunc/${s}_mean_func.nii.gz

		# # Save a copy of the brain extracted image from the mean functional image
		# bet ${analysis_path}/$s/meanFunc/${s}_mean_func.nii.gz ${analysis_path}/$s/meanFunc/bet/${s}_mean_func_bet -f 0.25 -m


		# ###############################################################
		# # Perform robust FOV of the structural, T1 image
		# robustfov -i ${data_path}/data/nifti/$s/*SAG_T1*.nii* -r ${analysis_path}/$s/${s}_t1.nii.gz

		# # Perform bias correction (nonpve prevents fast from performing segmentation of the image)
		# fast -B --nopve ${analysis_path}/$s/${s}_t1.nii.gz

		# # Perform spatial smoothing / noise reduction using SUSAN, whilst preserving the underlying structure of T1
		# fwhm=2.5; sigma=$(bc -l <<< "$fwhm/(2*sqrt(2*l(2)))")
		# susan ${analysis_path}/$s/${s}_t1.nii.gz -1 $sigma 3 1 0 ${analysis_path}/$s/${s}_t1.nii.gz

		# #Remove the unecessary files
	    # imrm ${analysis_path}/$s/${s}_t1_*


    	###############################################################
		# mkdir -p ${analysis_path}/$s/meanfunc2struct

		# flirt -in ${analysis_path}/$s/meanFunc/${s}_mean_func.nii.gz \
		# -ref ${analysis_path}/$s/${s}_t1.nii.gz \
		# -out ${analysis_path}/$s/meanfunc2struct/${s}_meanfunc2struct.nii.gz \
		# -omat ${analysis_path}/$s/meanfunc2struct/${s}_meanfunc2struct.mat \
		# -interp nearestneighbour \
		# -cost mutualinfo \
		# -dof 6


	 else 
        echo "Whole brain rs-fMRI image does not exist for ${s}" >> ${log_path}/1_preproc_LOG.txt
    fi

}

# Exports the function
export -f data_preproc

# Create an array with subjects (as they are in nifti folder)
# s=($(ls /Volumes/gdrive4tb/IGNITE/data/nifti))
s=(IGTTAS_00062 IGTTDA_00063 IGTTHA_00042 IGTTHA_00070 IGTTKA_00017 IGTTMG_00032 IGNTCJ_00018 IGNTCK_00066 IGNTGS_00049 IGNTLX_00069 IGNTMN_00051)

# Check the content of the subject array
echo ${s[@]}

# Run the analysis in parallel using GNU parallel
# Jobs is set to 0, which allows parallel to assign the jobs as it sees fit, and divide it across the CPUs itself
# Provide it with the name of the function, and specify it will take one argument, then provide this after the three colons

parallel --jobs 6 'data_preproc {1}' ::: ${s[@]}