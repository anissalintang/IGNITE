#!/bin/bash

#pre_processing script
data_preproc() {
	data_path="/Volumes/gdrive4tb/IGNITE";s=$1
	log_path="/Volumes/gdrive4tb/IGNITE/tonotopy/log"
	analysis_path="/Volumes/gdrive4tb/IGNITE/tonotopy"

	###############################################################
	# Preprocess only if functional data after NORDIC exist!
	if ls ${analysis_path}/preprocessed/${s}/${s}*_nordic.nii 1> /dev/null 2>&1; then

		###############################################################
		#Remove the first 3 volumes (dummy) from each image
		fslroi ${analysis_path}/preprocessed/${s}/${s}_sparse_tono_nordic.nii ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz 3 -1

		# Checkpoint of 3 volumes (dummy) removal
		echo "${s} The first 3 volumes (dummy) has been removed" >> ${log_path}/1_preproc_LOG.txt

		###############################################################
		#Save the original motion parameters to be used separately (save in a different folder)
		mkdir -p ${analysis_path}/preprocessed/$s/motionOrig
		mcflirt -in ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz -out ${analysis_path}/preprocessed/$s/motionOrig/${s}_motionOrig -plots -rmsrel -rmsabs -spline_final

		# Checkpoint of saving the original motion parameters
		echo "${s} Original motion parameters are now saved" >> ${log_path}/1_preproc_LOG.txt

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
		fslmaths ${analysis_path}/preprocessed/$s/${s}_sparse_tono_pe0.nii.gz -Tmean ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_mean_pepolar0
		fslmaths ${analysis_path}/preprocessed/$s/${s}_sparse_tono_pe1.nii.gz -Tmean ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_mean_pepolar1

		# Do rigid transformation for each PEpolar images, in case of movements between two images acquisition
		flirt -in ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_mean_pepolar0 -ref ${analysis_path}/preprocessed/$s/topUp/${s}_preprocessed_mean -out ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_aligned_pepolar0.nii.gz -omat ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_aligned_pepolar0.mat -interp nearestneighbour -cost corratio -dof 6

		flirt -in ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_mean_pepolar1 -ref ${analysis_path}/preprocessed/$s/topUp/${s}_preprocessed_mean -out ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_aligned_pepolar1.nii.gz -omat ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_aligned_pepolar1.mat -interp nearestneighbour -cost corratio -dof 6

		# Merge both PEpolar images into a single image
		fslmerge -t ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_merge_pepolar.nii.gz ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_aligned_pepolar0.nii.gz ${analysis_path}/preprocessed/$s/topUp/fmap/${s}_aligned_pepolar1.nii.gz

		# Create a directory to save the results from calling the TopUp function
		mkdir -p ${analysis_path}/preprocessed/$s/topUp/topUpResults

		#Create the config file, also called the acquisition parameters, which has 4 columns.
		#The first three columns represents the PE direction. J = 0 1 0 and J- = 0 -1 0
		#The last column represents the total readout time
		PEdir_j=$(echo "0 1 0")
		TotalReadoutTime_j=$(grep -A0 '"TotalReadoutTime"' ${analysis_path}/preprocessed/$s/${s}_sparse_tono_pe0.json | grep -Eo '[0-9|.]+')
		echo $PEdir_j $TotalReadoutTime_j > ${analysis_path}/preprocessed/$s/topUp/fmap/acqparam.txt

		PEdir_jrev=$(echo "0 -1 0")
		TotalReadoutTime_jrev=$(grep -A0 '"TotalReadoutTime"' ${analysis_path}/preprocessed/$s/${s}_sparse_tono_pe1.json | grep -Eo '[0-9|.]+')
		echo $PEdir_jrev $TotalReadoutTime_jrev >> ${analysis_path}/preprocessed/$s/topUp/fmap/acqparam.txt

		# Call the TOP UP function to estimate the field inhomogeneity
		topup \
		--imain=${analysis_path}/preprocessed/${s}/topUp/fmap/${s}_merge_pepolar \
		--datain=${analysis_path}/preprocessed/${s}/topUp/fmap/acqparam.txt \
		--out=${analysis_path}/preprocessed/${s}/topUp/topUpResults/${s}_topUp_results

		# Create a directory to save the results from calling the QC_ApplyTopUp function
		mkdir -p ${analysis_path}/preprocessed/$s/topUp/QC_topUpApplied
	

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

		# fwhm = 2.5 seemed insufficient
	    fwhm=5; sigma=$(bc -l <<< "$fwhm/(2*sqrt(2*l(2)))")

	    susan ${analysis_path}/preprocessed/$s/${s}_preprocessed.nii.gz -1 $sigma 3 1 1 ${analysis_path}/preprocessed/$s/meanFunc/${s}_mean_func.nii.gz -1 ${analysis_path}/preprocessed/$s/${s}_preprocessed_smoothed5.nii.gz

	    fslmaths ${analysis_path}/preprocessed/$s/${s}_preprocessed_smoothed5.nii.gz -Tmin -bin ${analysis_path}/preprocessed/$s/${s}_mean_func_smoothed5_mask0 -odt char

	    fslmaths ${analysis_path}/preprocessed/$s/${s}_preprocessed_smoothed5.nii.gz -mas ${analysis_path}/preprocessed/$s/${s}_mean_func_smoothed5_mask0 ${analysis_path}/preprocessed/$s/${s}_preprocessed_smoothed5.nii.gz

	    imrm ${analysis_path}/preprocessed/$s/*usan_size.nii.gz
	    imrm ${analysis_path}/preprocessed/$s/${s}_mean_func_smoothed5_mask0

	    # Take the mean of the functional image_smoothed5
	    mkdir -p ${analysis_path}/preprocessed/$s/meanFunc_smoothed5/bet

	    fslmaths ${analysis_path}/preprocessed/$s/${s}_preprocessed_smoothed5.nii.gz -Tmean ${analysis_path}/preprocessed/$s/meanFunc_smoothed5/${s}_mean_func_smoothed5.nii.gz

	    # Save a copy of the brain extracted image from the mean functional image
		bet ${analysis_path}/preprocessed/$s/meanFunc_smoothed5/${s}_mean_func_smoothed5.nii.gz ${analysis_path}/preprocessed/$s/meanFunc_smoothed5/bet/${s}_mean_func_smoothed5_bet -f 0.25 -m

		# Last checkpoint, prepropressing step is finished
		echo "${s} Data preprocessing step is now done" >> ${log_path}/1_preproc_LOG.txt


	 else 
        echo "Sparse rest image does not exist for ${s}" >> ${log_path}/1_preproc_LOG.txt
    fi

}

# Exports the function
export -f data_preproc

# Create an array with subjects (as they are in nifti folder)
# s=($(ls /Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed | grep -vE "IGTTHG_00064|IGNTMN_00051|IGTTKA_00017"))

s=(IGTTKA_00017)

# Check the content of the subject array
echo ${s[@]}

# Run the analysis in parallel using GNU parallel
# Jobs is set to 0, which allows parallel to assign the jobs as it sees fit, and divide it across the CPUs itself
# Provide it with the name of the function, and specify it will take one argument, then provide this after the three colons

parallel --jobs 6 'data_preproc {1}' ::: ${s[@]}