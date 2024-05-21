#!/bin/bash

#pre_processing script
data_preproc() {
	data_path="/Volumes/gdrive4tb/IGNITE";s=$1
	log_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/log"
	analysis_path="/Volumes/gdrive4tb/IGNITE/sparse_rest"

	###############################################################
	# Preprocess only if functional data after NORDIC exist!
	if ls ${analysis_path}/preprocessed/${s}/${s}*_nordic.nii 1> /dev/null 2>&1; then

		###############################################################
		#Remove the first 3 volumes (dummy) from each image
		fslroi ${analysis_path}/preprocessed/${s}/${s}_sparse_rest_nordic.nii ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz 3 -1

		# Checkpoint of 3 volumes (dummy) removal
		echo "${s} The first 3 volumes (dummy) has been removed" >> ${log_path}/1_preproc_LOG.txt

		###############################################################
		#Save the original motion parameters to be used separately (save in a different folder)
		mkdir -p ${analysis_path}/preprocessed/$s/motionOrig
		mcflirt -in ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz -out ${analysis_path}/preprocessed/$s/motionOrig/${s}_motionOrig -plots -rmsrel -rmsabs -spline_final

		# Checkpoint of saving the original motion parameters
		echo "${s} Original motion parameters are now saved" >> ${log_path}/1_preproc_LOG.txt

		##############################################################
		# Slice timing correction
		#Selects the repetition time from the file header, using the fslhd function with grep
		#If using z-shell uses tr=${line[2]}
		#If using bash tr=${line[1]}
		#pixdim4 refers to the parameter which describes the repetition time
		# line=($(fslhd ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz | grep pixdim4)); tr=${line[1]}

		# ## Our fMRI data was acquired using multiband EPI, thus the slice timing would be different
		# ##Create a single-column file of slice timing order taken from the json files
		# ### Get all 25 lines starting with "SliceTiming"
		# grep -A25 '"SliceTiming"' ${analysis_path}/preprocessed/$s/${s}_sparse_tono_orig.json | grep "[0-9]*" > ${data_path}/data/nifti/$s/rawSliceTiming.txt
		# ### Print all the numbers, and essentially removed the string, in this case the "SliceTiming"
		# awk '{print $0+0}' ${data_path}/data/nifti/$s/rawSliceTiming.txt > ${data_path}/data/nifti/$s/tempSliceTiming.txt
		# ### Remove the first 0 that was created from the awk step above
		# tail -n +2 ${data_path}/data/nifti/$s/tempSliceTiming.txt > ${analysis_path}/preprocessed/$s/SliceTimingOrder.txt

		# ## Remove temporary files
		# rm ${data_path}/data/nifti/$s/rawSliceTiming.txt ${data_path}/data/nifti/$s/tempSliceTiming.txt

		#Perform the slice time correction -r is repetition time, --tcustom specifies a file of single-column slice timings order, in fractions of TR, +ve values shift slices towards in time (SliceTimingOrder.txt)
		# slicetimer -i ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz -o ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz -r $tr --tcustom=${analysis_path}/preprocessed/$s/SliceTimingOrder.txt

		slicetimer \
		-i ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz \
		-o ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz \
		-r 7.5 \
		--odd

		# Checkpoint of slice timing correction
		echo "${s} Finished slice timing correction" >> ${log_path}/1_preproc_LOG.txt

		###############################################################
		#Motion correction
		## This time it will actually perform the motion correction, rather than just saving the motion parameters (re: Original motion parameters)
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

		###############################################################
		# Distortion correction
		mkdir -p ${analysis_path}/preprocessed/$s/topUp/fmap

		# Calculate mean functional image from the last step (motion correction)
		fslmaths ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz -Tmean ${analysis_path}/preprocessed/$s/topUp/${s}_preprocessed_mean

		# Calculate mean of PEpolar 0 and PEpolar 1 images to create a single image file for each
		fslmaths ${analysis_path}/preprocessed/$s/${s}_sparse_rest_pe0.nii.gz -Tmean ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_mean_pepolar0
		fslmaths ${analysis_path}/preprocessed/$s/${s}_sparse_rest_pe1.nii.gz -Tmean ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_mean_pepolar1


		# Merge both PEpolar images into a single image
		fslmerge -t ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_merge_pepolar.nii.gz ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_mean_pepolar0.nii.gz ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_mean_pepolar1.nii.gz

		# Create a directory to save the results from calling the TopUp function
		mkdir -p ${analysis_path}/preprocessed/$s/topUp/topUpResults

		# Create the config file, also called the acquisition parameters, which has 4 columns.
		# The first three columns represents the PE direction. J = 0 1 0 and J- = 0 -1 0
		# The last column represents the total readout time
		PEdir_j=$(echo "0 1 0")
		TotalReadoutTime_j=$(grep -A0 '"TotalReadoutTime"' ${analysis_path}/preprocessed/$s/${s}_sparse_rest_pe0.json | grep -Eo '[0-9|.]+')
		echo $PEdir_j $TotalReadoutTime_j > ${analysis_path}/preprocessed/$s/topUp/fmap/acqparam.txt

		PEdir_jrev=$(echo "0 -1 0")
		TotalReadoutTime_jrev=$(grep -A0 '"TotalReadoutTime"' ${analysis_path}/preprocessed/$s/${s}_sparse_rest_pe1.json | grep -Eo '[0-9|.]+')
		echo $PEdir_jrev $TotalReadoutTime_jrev >> ${analysis_path}/preprocessed/$s/topUp/fmap/acqparam.txt

		# Call the TOP UP function to estimate the field inhomogeneity
		topup \
		--imain=${analysis_path}/preprocessed/${s}/topUp/fmap/${s}_merge_pepolar \
		--datain=${analysis_path}/preprocessed/${s}/topUp/fmap/acqparam.txt \
		--out=${analysis_path}/preprocessed/${s}/topUp/topUpResults/${s}_topUp_results

	

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

		######################
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
        echo "Sparse rest image does not exist for ${s}" >> ${log_path}/1_preproc_LOG.txt
    fi

}

# Exports the function
export -f data_preproc

# Create an array with subjects (as they are in nifti folder)
# s=($(ls /Volumes/gdrive4tb/IGNITE/sparse_rest/preprocessed))
s=(IGTTHG_00064 IGNTMN_00051 IGTTKA_00017)
# s=(IGNTGS_00049 IGNTFM_00060 IGNTBR_00075 IGNTCA_00067)

# Check the content of the subject array
echo ${s[@]}

# Run the analysis in parallel using GNU parallel
# Jobs is set to 0, which allows parallel to assign the jobs as it sees fit, and divide it across the CPUs itself
# Provide it with the name of the function, and specify it will take one argument, then provide this after the three colons

parallel --jobs 6 'data_preproc {1}' ::: ${s[@]}