#!/bin/bash

#pre_processing script
data_preproc() {
	data_path="/Volumes/gdrive4tb/IGNITE";s=$1
	log_path="/Volumes/gdrive4tb/IGNITE/resting-state/log"

	###############################################################
	# Preprocess only if functional data exist!
	if ls ${data_path}/data/nifti/${s}/*final_fmri*fMRI_2mm*.nii* 1> /dev/null 2>&1; then

		# #Make directories for the preprocessing files
		# mkdir -p ${data_path}/resting-state/preprocessed/$s
		analysis_path="/Volumes/gdrive4tb/IGNITE/resting-state"

		###############################################################
		#Remove the first 10 volumes from each image
		fslroi ${data_path}/data/nifti/${s}/*final_fmri*fMRI_2mm*.nii* ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz 10 -1

		# Checkpoint of 10 volumes removal
		echo "${s} The first 10 volumes has been removed" >> ${log_path}/1_preproc_LOG.txt

		###############################################################
		#Save the original motion parameters to be used separately (save in a different folder)
		mkdir -p ${analysis_path}/preprocessed/$s/motionOrig
		mcflirt -in ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz -out ${analysis_path}/preprocessed/$s/motionOrig/${s}_motionOrig -plots -rmsrel -rmsabs -spline_final

		# Checkpoint of saving the original motion parameters
		echo "${s} Original motion parameters are now saved" >> ${log_path}/1_preproc_LOG.txt

		###############################################################
		#Slice timing correction
		##Selects the repetition time from the file header, using the fslhd function with grep
		##If using z-shell uses tr=${line[2]}
		##If using bash tr=${line[1]}
		##pixdim4 refers to the parameter which describes the repetition time
		line=($(fslhd ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz | grep pixdim4)); tr=${line[1]}

		## Our fMRI data was acquired using multiband EPI, thus the slice timing would be different
		##Create a single-column file of slice timing order taken from the json files
		### Get all 54 lines starting with "SliceTiming"
		grep -A54 '"SliceTiming"' ${data_path}/data/nifti/$s/*final_fmri*fMRI_2mm*.json | grep "[0-9]*" > ${data_path}/data/nifti/$s/rawSliceTiming.txt
		### Print all the numbers, and essentially removed the string, in this case the "SliceTiming"
		awk '{print $0+0}' ${data_path}/data/nifti/$s/rawSliceTiming.txt > ${data_path}/data/nifti/$s/tempSliceTiming.txt
		### Remove the first 0 that was created from the awk step above
		tail -n +2 ${data_path}/data/nifti/$s/tempSliceTiming.txt > ${analysis_path}/preprocessed/$s/SliceTimingOrder.txt

		## Remove temporary files
		rm ${data_path}/data/nifti/$s/rawSliceTiming.txt ${data_path}/data/nifti/$s/tempSliceTiming.txt

		#Perform the slice time correction -r is repetition time, --tcustom specifies a file of single-column slice timings order, in fractions of TR, +ve values shift slices towards in time (SliceTimingOrder.txt)
		slicetimer -i ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz -o ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz -r $tr --tcustom=${analysis_path}/preprocessed/$s/SliceTimingOrder.txt

		# Checkpoint of slice timing correction
		echo "${s} Finished slice timing correction" >> ${log_path}/1_preproc_LOG.txt

		##############################################################
		Motion correction
		# This time it will actually perform the motion correction, rather than just saving the motion parameters (re: Original motion parameters)
		mkdir -p ${analysis_path}/preprocessed/$s/MotionCorrection
		
		##Create a mean image to use as the reference for the motion correction
		fslmaths ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz -Tmean ${analysis_path}/preprocessed/$s/MotionCorrection/${s}_preprocessed_mean

		#Perform the motion correction
		mcflirt -in ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz -out ${analysis_path}/preprocessed/$s/${s}_preprocessed -reffile ${analysis_path}/preprocessed/$s/MotionCorrection/${s}_preprocessed_mean -mats -spline_final -plots

		##Move the MAT file to the motion correction folder and rename
		mv ${analysis_path}/preprocessed/$s/${s}_preprocessed.mat ${analysis_path}/preprocessed/$s/MotionCorrection/${s}_motionCorrection.mat

		##Move the PAR file to the motion correction folder and rename
		mv ${analysis_path}/preprocessed/$s/${s}_preprocessed.par ${analysis_path}/preprocessed/$s/MotionCorrection/${s}_motionCorrection.par

		# Checkpoint of motion correction
		echo "${s} Motion correction step has finished." >> ${log_path}/1_preproc_LOG.txt

		# ###############################################################
		# Distortion correction
		mkdir -p ${analysis_path}/preprocessed/$s/topUp/fmap

		# Calculate mean functional image from the last step (motion correction)
		fslmaths ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz -Tmean ${analysis_path}/preprocessed/$s/topUp/${s}_preprocessed_mean

		# Calculate mean of PEpolar 0 and PEpolar 1 images to create a single image file for each
		fslmaths ${data_path}/data/nifti/$s/*b0_pepolar=0*.nii* -Tmean ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_mean_pepolar0
		fslmaths ${data_path}/data/nifti/$s/*b0_pepolar=1*.nii* -Tmean ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_mean_pepolar1

		# Do rigid transformation for each PEpolar images, in case of movements between two images acquisition
		flirt -in ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_mean_pepolar0 -ref ${analysis_path}/preprocessed/$s/topUp/${s}_preprocessed_mean -out ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_aligned_pepolar0.nii.gz -omat ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_aligned_pepolar0.mat -interp nearestneighbour -cost mutualinfo -dof 6

		flirt -in ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_mean_pepolar1 -ref ${analysis_path}/preprocessed/$s/topUp/${s}_preprocessed_mean -out ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_aligned_pepolar1.nii.gz -omat ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_aligned_pepolar1.mat -interp nearestneighbour -cost mutualinfo -dof 6

		# Merge both PEpolar images into a single image
		fslmerge -t ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_merge_pepolar.nii.gz ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_aligned_pepolar0.nii.gz ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_aligned_pepolar1.nii.gz

		# Create a directory to save the results from calling the TopUp function
		mkdir -p ${analysis_path}/preprocessed/$s/topUp/topUpResults

		#Create the config file, also called the acquisition parameters, which has 4 columns.
		#The first three columns represents the PE direction. J = 0 1 0 and J- = 0 -1 0
		#The last column represents the total readout time
		PEdir_j=$(echo "0 1 0")
		TotalReadoutTime_j=$(grep -A0 '"TotalReadoutTime"' ${data_path}/data/nifti/$s/*b0_pepolar=0*.json | grep -Eo '[0-9|.]+')
		echo $PEdir_j $TotalReadoutTime_j > ${analysis_path}/preprocessed/$s/topUp/fmap/acqparam.txt

		PEdir_jrev=$(echo "0 -1 0")
		TotalReadoutTime_jrev=$(grep -A0 '"TotalReadoutTime"' ${data_path}/data/nifti/$s/*b0_pepolar=0*.json | grep -Eo '[0-9|.]+')
		echo $PEdir_jrev $TotalReadoutTime_jrev >> ${analysis_path}/preprocessed/$s/topUp/fmap/acqparam.txt

		# Call the TOP UP function to estimate the field inhomogeneity
		topup \
		--imain=${analysis_path}/preprocessed/${s}/topUp/fmap/${s}_merge_pepolar \
		--datain=${analysis_path}/preprocessed/${s}/topUp/fmap/acqparam.txt \
		--out=${analysis_path}/preprocessed/${s}/topUp/topUpResults/${s}_topUp_results

		# Create a directory to save the results from calling the QC_ApplyTopUp function
		mkdir -p ${analysis_path}/preprocessed/$s/topUp/QC_topUpApplied

		# Check whether dimensions of pepolar images are the same with functional image
		line_pepolar0=($(fslhd ${data_path}/data/nifti/${s}/*b0_pepolar=0*.nii* | grep dim1)); vol_pepolar0=${line_pepolar0[1]}
		line_func=($(fslhd ${data_path}/data/nifti/${s}/*final_fmri*fMRI_2mm*.nii* | grep dim1)); vol_func=${line_func[1]}

		if [ ${vol_pepolar0} = ${vol_func} ]; then
			# Call the ApplyTopUp to each of the PEpolar images as a quality control check
			## The results should show less distortion in these images. Do this before applying TopUp to the actual functional image
			pepolar0=$(ls 2>/dev/null ${data_path}/data/nifti/${s}/*b0_pepolar=0*.nii*)
			applytopup \
			--imain=${pepolar0} \
			--inindex=1 \
			--datain=${analysis_path}/preprocessed/${s}/topUp/fmap/acqparam.txt \
			--topup=${analysis_path}/preprocessed/${s}/topUp/topUpResults/${s}_topUp_results \
			--method=jac \
			--out=${analysis_path}/preprocessed/${s}/topUp/QC_topUpApplied/${s}_topUp_pepolar0.nii.gz

			pepolar1=$(ls 2>/dev/null ${data_path}/data/nifti/${s}/*b0_pepolar=1*.nii*)
			applytopup \
			--imain=${pepolar1} \
			--inindex=2 \
			--datain=${analysis_path}/preprocessed/${s}/topUp/fmap/acqparam.txt \
			--topup=${analysis_path}/preprocessed/${s}/topUp/topUpResults/${s}_topUp_results \
			--method=jac \
			--out=${analysis_path}/preprocessed/${s}/topUp/QC_topUpApplied/${s}_topUp_pepolar1.nii.gz

			echo "${s} QC_topUpApplied was performed" >> ${log_path}/1_preproc_LOG.txt
		else
			echo "${s} Dimensions of pepolar and functional images are NOT the same. Pepolar = ${vol_pepolar0} and functional = ${vol_func}. QC_topUpApplied was not performed." >> ${log_path}/1_preproc_LOG.txt
		fi		

		# Call the ApplyTopUp to the functional image
		applytopup \
		--imain=${analysis_path}/preprocessed/${s}/${s}_preprocessed.nii.gz \
		--inindex=1 \
		--datain=${analysis_path}/preprocessed/${s}/topUp/fmap/acqparam.txt \
		--topup=${analysis_path}/preprocessed/${s}/topUp/topUpResults/${s}_topUp_results \
		--method=jac \
		--out=${analysis_path}/preprocessed/${s}/${s}_preprocessed.nii.gz

		# Checkpoint of motion correction
		echo "${s} Distortion correction step has finished." >> ${log_path}/1_preproc_LOG.txt

		###############################################################
		# Save mean and brain extracted images
		# A. NON-SMOOTHED
		mkdir -p ${analysis_path}/preprocessed/$s/meanFunc/bet

		# Take the mean of the functional image
		fslmaths ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz -Tmean ${analysis_path}/preprocessed/$s/meanFunc/${s}_mean_func.nii.gz

		# Save a copy of the brain extracted image from the mean functional image
		bet ${analysis_path}/preprocessed/$s/meanFunc/${s}_mean_func.nii.gz ${analysis_path}/preprocessed/$s/meanFunc/bet/${s}_mean_func_bet -f 0.25 -m

		#######################
		# B. SPATIALLY SMOOTHED

		# fwhm = 5  2.5 seemed insufficient
	    fwhm=5; sigma=$(bc -l <<< "$fwhm/(2*sqrt(2*l(2)))")

	    susan ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz -1 $sigma 3 1 1 ${analysis_path}/preprocessed/$s/meanFunc/${s}_mean_func.nii.gz -1 ${analysis_path}/preprocessed/$s/${s}_preprocessed_smoothed.nii.gz

	    fslmaths ${analysis_path}/preprocessed/$s/${s}_preprocessed_smoothed.nii.gz -Tmin -bin ${analysis_path}/preprocessed/$s/${s}_mean_func_smoothed_mask0 -odt char

	    fslmaths ${analysis_path}/preprocessed/$s/${s}_preprocessed_smoothed.nii.gz -mas ${analysis_path}/preprocessed/$s/${s}_mean_func_smoothed_mask0 ${analysis_path}/preprocessed/$s/${s}_preprocessed_smoothed.nii.gz

	    imrm ${analysis_path}/preprocessed/$s/*usan_size.nii.gz
	    imrm ${analysis_path}/preprocessed/$s/${s}_mean_func_smoothed_mask0

	    # Take the mean of the functional image_smoothed
	    mkdir -p ${analysis_path}/preprocessed/$s/meanFunc_smoothed/bet

	    fslmaths ${analysis_path}/preprocessed/$s/${s}_preprocessed_smoothed.nii.gz -Tmean ${analysis_path}/preprocessed/$s/meanFunc_smoothed/${s}_mean_func_smoothed.nii.gz

	    # Save a copy of the brain extracted image from the mean functional image
		bet ${analysis_path}/preprocessed/$s/meanFunc_smoothed/${s}_mean_func_smoothed.nii.gz ${analysis_path}/preprocessed/$s/meanFunc_smoothed/bet/${s}_mean_func_smoothed_bet -f 0.25 -m

		# Last checkpoint, prepropressing step is finished
		echo "${s} Data preprocessing step is now done" >> ${log_path}/1_preproc_LOG.txt


	 else 
        echo "Whole brain rs-fMRI image does not exist for ${s}" >> ${log_path}/1_preproc_LOG.txt
    fi

}

# Exports the function
export -f data_preproc

# Create an array with subjects (as they are in nifti folder)
s=($(ls /Volumes/gdrive4tb/IGNITE/data/nifti))
# s=(IGTTHA_00070)

# Check the content of the subject array
echo ${s[@]}

# Run the analysis in parallel using GNU parallel
# Jobs is set to 0, which allows parallel to assign the jobs as it sees fit, and divide it across the CPUs itself
# Provide it with the name of the function, and specify it will take one argument, then provide this after the three colons

parallel --jobs 6 'data_preproc {1}' ::: ${s[@]}