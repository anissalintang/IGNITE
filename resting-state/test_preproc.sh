#!/bin/bash

#pre_processing script
data_preproc() {
	data_path="/Volumes/gdrive4tb/IGNITE";s=$1
	log_path="/Volumes/gdrive4tb/IGNITE/resting-state/log"
	vol_path="/Volumes/gdrive4tb/IGNITE/resting-state/volumetric"

	###############################################################
	# Preprocess only if functional data exist!
	if ls ${data_path}/data/nifti/${s}/*final_fmri*fMRI_2mm*.nii* 1> /dev/null 2>&1; then

	# 	# #Make directories for the preprocessing files
	# 	mkdir -p ${data_path}/resting-state/test_distortion/$s
		analysis_path="/Volumes/gdrive4tb/IGNITE/resting-state/test_distortion"

	# 	###############################################################
	# 	#Remove the first 10 volumes from each image
	# 	fslroi ${data_path}/data/nifti/${s}/*final_fmri*fMRI_2mm*.nii* ${analysis_path}/$s/${s}_preprocessed.nii.gz 10 -1

	# 	###############################################################
	# 	#Save the original motion parameters to be used separately (save in a different folder)
	# 	mkdir -p ${analysis_path}/$s/motionOrig
	# 	mcflirt -in ${analysis_path}/$s/${s}_preprocessed.nii.gz -out ${analysis_path}/$s/motionOrig/${s}_motionOrig -plots -rmsrel -rmsabs -spline_final

	# 	# Checkpoint of saving the original motion parameters
	# 	echo "${s} Original motion parameters are now saved" >> ${log_path}/1_preproc_LOG.txt

	# 	###############################################################
	# 	#Slice timing correction
	# 	#Selects the repetition time from the file header, using the fslhd function with grep
	# 	#If using z-shell uses tr=${line[2]}
	# 	#If using bash tr=${line[1]}
	# 	#pixdim4 refers to the parameter which describes the repetition time
	# 	line=($(fslhd ${analysis_path}/$s/${s}_preprocessed.nii.gz | grep pixdim4)); tr=${line[1]}

	# 	## Our fMRI data was acquired using multiband EPI, thus the slice timing would be different
	# 	##Create a single-column file of slice timing order taken from the json files
	# 	### Get all 54 lines starting with "SliceTiming"
	# 	grep -A54 '"SliceTiming"' ${data_path}/data/nifti/$s/*final_fmri*fMRI_2mm*.json | grep "[0-9]*" > ${data_path}/data/nifti/$s/rawSliceTiming.txt
	# 	### Print all the numbers, and essentially removed the string, in this case the "SliceTiming"
	# 	awk '{print $0+0}' ${data_path}/data/nifti/$s/rawSliceTiming.txt > ${data_path}/data/nifti/$s/tempSliceTiming.txt
	# 	### Remove the first 0 that was created from the awk step above
	# 	tail -n +2 ${data_path}/data/nifti/$s/tempSliceTiming.txt > ${analysis_path}/$s/SliceTimingOrder.txt

	# 	## Remove temporary files
	# 	rm ${data_path}/data/nifti/$s/rawSliceTiming.txt ${data_path}/data/nifti/$s/tempSliceTiming.txt

	# 	#Perform the slice time correction -r is repetition time, --tcustom specifies a file of single-column slice timings order, in fractions of TR, +ve values shift slices towards in time (SliceTimingOrder.txt)
	# 	slicetimer -i ${analysis_path}/$s/${s}_preprocessed.nii.gz -o ${analysis_path}/$s/${s}_preprocessed.nii.gz -r $tr --tcustom=${analysis_path}/$s/SliceTimingOrder.txt

	# 	# # Checkpoint of slice timing correction
	# 	# echo "${s} Finished slice timing correction" >> ${log_path}/1_preproc_LOG.txt

	# 	##############################################################
	# 	# Motion correction
	# 	# This time it will actually perform the motion correction, rather than just saving the motion parameters (re: Original motion parameters)
	# 	mkdir -p ${analysis_path}/$s/MotionCorrection
		
	# 	##Create a mean image to use as the reference for the motion correction
	# 	fslmaths ${analysis_path}/$s/${s}_preprocessed.nii.gz -Tmean ${analysis_path}/$s/MotionCorrection/${s}_preprocessed_mean

	# 	#Perform the motion correction
	# 	mcflirt -in ${analysis_path}/$s/${s}_preprocessed.nii.gz -out ${analysis_path}/$s/${s}_preprocessed -reffile ${analysis_path}/$s/MotionCorrection/${s}_preprocessed_mean -mats -spline_final -plots

	# 	##Move the MAT file to the motion correction folder and rename
	# 	mv ${analysis_path}/$s/${s}_preprocessed.mat ${analysis_path}/$s/MotionCorrection/${s}_motionCorrection.mat
                                                              
	# 	##Move the PAR file to the motion correction folder and rename
	# 	mv ${analysis_path}/$s/${s}_preprocessed.par ${analysis_path}/$s/MotionCorrection/${s}_motionCorrection.par

	# 	# Checkpoint of motion correction
	# 	echo "${s} Motion correction step has finished." >> ${log_path}/1_preproc_LOG.txt

	# 	###############################################################
	# 	# Distortion correction
	# 	mkdir -p ${analysis_path}/$s/ANTs

	# 	# Perform robust FOV of the structural, T1 image
	# 	robustfov -i ${data_path}/data/nifti/$s/*SAG_T1*.nii* -r ${analysis_path}/$s/ANTs/${s}_t1.nii.gz

	# 	# Perform bias correction (nonpve prevents fast from performing segmentation of the image)
	# 	fast -B --nopve ${analysis_path}/$s/ANTs/${s}_t1.nii.gz

	# 	# Get the brain only area
    # 	bet ${analysis_path}/$s/ANTs/${s}_t1.nii.gz ${analysis_path}/$s/ANTs/${s}_t1_brain.nii.gz -f 0.5 -g 0 -m

    # 	###############################################################
    # 	# Invert T1 image (skull-stripped, bias corrected)
    # 	# Calculate the minimum and maximum intensity values for the T1 image
    # 	T1min=$(fslstats ${analysis_path}/$s/ANTs/${s}_t1_brain.nii.gz -R | awk '{print $1}')
	# 	T1max=$(fslstats ${analysis_path}/$s/ANTs/${s}_t1_brain.nii.gz -R | awk '{print $2}')

	# 	# Create average functional image
    # 	fslmaths ${analysis_path}/$s/${s}_preprocessed.nii.gz -Tmean ${analysis_path}/$s/${s}_mean_func.nii.gz

	# 	# Calculate the minimum and maximum intensity values for the fmri image
	# 	fmin=$(fslstats ${analysis_path}/$s/${s}_mean_func.nii.gz -R | awk '{print $1}')
	# 	fmax=$(fslstats ${analysis_path}/$s/${s}_mean_func.nii.gz -R | awk '{print $2}')

	# 	# Calculate the division part of the equation (i.e., [T1max - T1min] / [fmax - fmin]) and save it to a constant
	# 	div=$(echo "scale=6; ($T1max - $T1min) / ($fmax - $fmin)" | bc -l)

		# Perform the last calculation
		# fslmaths ${analysis_path}/$s/ANTs/${s}_t1_brain.nii.gz -mul -1 -add $T1max -mul $div ${analysis_path}/$s/ANTs/${s}_t1_brain_inv.nii.gz


		###############################################################
    	# how to run antsRegistrationSyn
    	# `basename $0` -d ImageDimension -f FixedImage -m MovingImage -o OutputPrefix

    	# dim=3 

    	# /opt/ANTs/bin/antsRegistrationSyn.sh \
    	# -d $dim \
    	# -f ${analysis_path}/$s/ANTs/${s}_t1_brain_inv.nii.gz \
    	# -m ${analysis_path}/$s/${s}_mean_func.nii.gz \
    	# -o ${analysis_path}/${s}/${s}_B0_2_t1.nii.gz
    	

    	# Split the 4D image into 3D volumes
		# fslsplit ${analysis_path}/${s}/${s}_preprocessed.nii.gz ${analysis_path}/${s}/${s}_preprocessed_split -t


		# Loop over each volume and apply the transformation to all volumes of the fMRI images
		for vol in ${analysis_path}/${s}/${s}_preprocessed_split*.nii.gz; do
			/opt/ANTs/bin/antsApplyTransforms \
	    	-i $vol \
	    	-r ${analysis_path}/$s/ANTs/${s}_t1_brain_inv.nii.gz \
	    	-t [${analysis_path}/${s}/${s}_B0_2_t10GenericAffine.mat,1] \
	    	-t ${analysis_path}/${s}/${s}_B0_2_t11InverseWarp.nii.gz \
	    	-o ${vol%.nii.gz}_reg.nii.gz
		done

		# Merge the transformed volumes back into a 4D image
		fslmerge -t ${analysis_path}/${s}/${s}_preprocessed_reg.nii.gz ${analysis_path}/${s}/${s}_preprocessed_split*_reg.nii.gz

		# Clean up the intermediate files
		rm ${analysis_path}/${s}/${s}_preprocessed_split*.nii.gz

		
		###############################################################
		# Save mean and brain extracted images
		# A. NON-SMOOTHED
		# mkdir -p ${analysis_path}/$s/meanFunc/bet

		# # Take the mean of the functional image
		# fslmaths ${analysis_path}/$s/${s}_preprocessed.nii.gz -Tmean ${analysis_path}/$s/meanFunc/${s}_mean_func.nii.gz

		# # Save a copy of the brain extracted image from the mean functional image
		# bet ${analysis_path}/$s/meanFunc/${s}_mean_func.nii.gz ${analysis_path}/$s/meanFunc/bet/${s}_mean_func_bet -f 0.25 -m

	


	 else 
        echo "Whole brain rs-fMRI image does not exist for ${s}" >> ${log_path}/1_preproc_LOG.txt
    fi

}

# Exports the function
export -f data_preproc

# Create an array with subjects (as they are in nifti folder)
# s=($(ls /Volumes/gdrive4tb/IGNITE/data/nifti))
# s=(IGTTAS_00062 IGTTDA_00063 IGTTHA_00042 IGTTHA_00070 IGTTKA_00017 IGTTMG_00032 IGNTCJ_00018 IGNTCK_00066 IGNTGS_00049 IGNTLX_00069 IGNTMN_00051)
s=(IGTTAS_00062)

# Check the content of the subject array
echo ${s[@]}

# Run the analysis in parallel using GNU parallel
# Jobs is set to 0, which allows parallel to assign the jobs as it sees fit, and divide it across the CPUs itself
# Provide it with the name of the function, and specify it will take one argument, then provide this after the three colons

parallel --jobs 6 'data_preproc {1}' ::: ${s[@]}