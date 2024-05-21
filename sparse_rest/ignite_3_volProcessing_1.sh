#!/bin/bash

# Volumetric data processing script
# Here we do conversion to percentage signal change, temporal filtering for both
# A. Non-smoothed data and B. Smoothed data
volume_processing_1() {

	mkdir -p /Volumes/gdrive4tb/IGNITE/sparse_rest/volumetric

	data_path="/Volumes/gdrive4tb/IGNITE";s=$1
	vol_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/volumetric"
	log_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/log"
	preproc_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/preprocessed"


	###############################################################
	# A. NON-SMOOTHED VERSION
	###############################################################
	# RAW SIGNAL CONVERSION TO PERCENTAGE SIGNAL CHANGE (functional data is still in native space)
	mkdir -p ${vol_path}/percent_signal_change/${s}

	# Subtract functional image - mean functional image >> psc
	fslmaths ${data_path}/sparse_rest/preprocessed/$s/${s}_preprocessed.nii.gz -sub ${data_path}/sparse_rest/preprocessed/$s/meanFunc/${s}_mean_func.nii.gz ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc.nii.gz

	# (func-mean)/mean = percentage signal change (psc)
	fslmaths ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc.nii.gz -div ${data_path}/sparse_rest/preprocessed/$s/meanFunc/${s}_mean_func.nii.gz ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc.nii.gz

	# psc * 100
	fslmaths ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc.nii.gz -mul 100 ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc.nii.gz

	# Apply the brain mask to the psc image
	fslmaths ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc.nii.gz -mas ${data_path}/sparse_rest/preprocessed/$s/meanFunc/bet/${s}_mean_func_bet_mask.nii.gz ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc.nii.gz

	# Take the mean of the functional image
	fslmaths ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc.nii.gz -Tmean ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc_mean.nii.gz

	# Checkpoint for PSC conversion
	echo "${s} raw signal conversion to percent signal change is finished" >> ${log_path}/2_volProcessing_1_LOG.txt

	###############################################################
	# TEMPORAL FILTERING
	# Two separate strands: a) filtering 0.01 - 0.1 Hz and b) Filtering 0-0.25 Hz
	# We also do non-smoothed and smoothed version

	## line >> sets the repetition time from the file header, using fslhd with grep, pixdim4 is the repetition time variable
	## if using z-shell tr=${}line[2]}, if using bash tr=${line[1]}
	# thp >> temporal high pass, expressed as time as multiple of repetition time * 2
	# tlp >> temporal lower pass, expressed as time as multiple of repetition time * 2

	##########################################
	# A. NON-SMOOTHED
	# Filter between 0.01 to 0.1
	mkdir -p ${vol_path}/temporalFiltering/filt_0.01-0.1/${s}
	line=($(fslhd ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc.nii.gz | grep pixdim4)); tr=${line[1]}; thp=$(bc -l <<< "100/($tr*2)"); tlp=$(bc -l <<< "10/($tr*2)")

	fslmaths ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc.nii.gz -bptf $thp $tlp ${vol_path}/temporalFiltering/filt_0.01-0.1/${s}/${s}_preprocessed_psc_filt01.nii.gz

	# Take the mean of the filtered functional data, for calculating ALFF
	mkdir -p ${vol_path}/temporalFiltering/filt_0.01-0.1/${s}/mean

	fslmaths ${vol_path}/temporalFiltering/filt_0.01-0.1/${s}/${s}_preprocessed_psc_filt01.nii.gz -Tmean ${vol_path}/temporalFiltering/filt_0.01-0.1/${s}/mean/${s}_preprocessed_psc_filt01_mean.nii.gz


	##########################################
	# Filter between 0 to 0.25
	mkdir -p ${vol_path}/temporalFiltering/filt_0-0.25/${s}
	line=($(fslhd ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc.nii.gz | grep pixdim4)); tr=${line[1]}; thp=(-1); tlp=$(bc -l <<< "4/($tr*2)")

	fslmaths ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc.nii.gz -bptf $thp $tlp ${vol_path}/temporalFiltering/filt_0-0.25/${s}/${s}_preprocessed_psc_filt025.nii.gz
		
	# Take the mean of the filtered functional data, for calculating ALFF
	mkdir -p ${vol_path}/temporalFiltering/filt_0-0.25/${s}/mean

	fslmaths ${vol_path}/temporalFiltering/filt_0-0.25/${s}/${s}_preprocessed_psc_filt025.nii.gz -Tmean ${vol_path}/temporalFiltering/filt_0-0.25/${s}/mean/${s}_preprocessed_psc_filt025_mean.nii.gz

	# Checkpoint for temporal filtering
	echo "${s} temporal filtering step for the NON-SMOOTHED version is finished" >> ${log_path}/2_volProcessing_1_LOG.txt





	###############################################################
	###############################################################
	# B. SPATIALLY SMOOTHED
	###############################################################
	# RAW SIGNAL CONVERSION TO PERCENTAGE SIGNAL CHANGE (functional data is still in native space)
	mkdir -p ${vol_path}/percent_signal_change/${s}

	# Subtract functional image - mean functional image >> psc
	fslmaths ${data_path}/sparse_rest/preprocessed/$s/${s}_preprocessed_smoothed.nii.gz -sub ${data_path}/sparse_rest/preprocessed/$s/meanFunc_smoothed/${s}_mean_func_smoothed.nii.gz ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc_smoothed.nii.gz

	# (func-mean)/mean = percentage signal change (psc)
	fslmaths ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc_smoothed.nii.gz -div ${data_path}/sparse_rest/preprocessed/$s/meanFunc_smoothed/${s}_mean_func_smoothed.nii.gz ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc_smoothed.nii.gz

	# psc * 100
	fslmaths ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc_smoothed.nii.gz -mul 100 ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc_smoothed.nii.gz

	# Apply the brain mask to the psc image
	fslmaths ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc_smoothed.nii.gz -mas ${data_path}/sparse_rest/preprocessed/$s/meanFunc_smoothed/bet/${s}_mean_func_smoothed_bet_mask ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc_smoothed.nii.gz

	# Take the mean of the functional image
	fslmaths ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc_smoothed.nii.gz -Tmean ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc_smoothed_mean.nii.gz

	# Checkpoint for PSC conversion
	echo "${s} raw signal conversion to percent signal change is finished" >> ${log_path}/2_volProcessing_1_LOG.txt

	###############################################################
	# TEMPORAL FILTERING
	# Two separate strands: a) filtering 0.01 - 0.1 Hz and b) Filtering 0-0.25 Hz

	## line >> sets the repetition time from the file header, using fslhd with grep, pixdim4 is the repetition time variable
	## if using z-shell tr=${}line[2]}, if using bash tr=${line[1]}
	# thp >> temporal high pass, expressed as time as multiple of repetition time * 2
	# tlp >> temporal lower pass, expressed as time as multiple of repetition time * 2

	##########################################
	# Filter between 0.01 to 0.1
	mkdir -p ${vol_path}/temporalFiltering/filt_0.01-0.1_smoothed/${s}
	line=($(fslhd ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc_smoothed.nii.gz | grep pixdim4)); tr=${line[1]}; thp=$(bc -l <<< "100/($tr*2)"); tlp=$(bc -l <<< "10/($tr*2)")

	fslmaths ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc_smoothed.nii.gz -bptf $thp $tlp ${vol_path}/temporalFiltering/filt_0.01-0.1_smoothed/${s}/${s}_preprocessed_psc_filt01_smoothed.nii.gz

	# Take the mean of the filtered functional data, for calculating ALFF
	mkdir -p ${vol_path}/temporalFiltering/filt_0.01-0.1_smoothed/${s}/mean

	fslmaths ${vol_path}/temporalFiltering/filt_0.01-0.1_smoothed/${s}/${s}_preprocessed_psc_filt01_smoothed.nii.gz -Tmean ${vol_path}/temporalFiltering/filt_0.01-0.1_smoothed/${s}/mean/${s}_preprocessed_psc_filt01_mean_smoothed.nii.gz


	##########################################
	# Filter between 0 to 0.25
	mkdir -p ${vol_path}/temporalFiltering/filt_0-0.25_smoothed/${s}
	line=($(fslhd ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc_smoothed.nii.gz | grep pixdim4)); tr=${line[1]}; thp=(-1); tlp=$(bc -l <<< "4/($tr*2)")

	fslmaths ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc_smoothed.nii.gz -bptf $thp $tlp ${vol_path}/temporalFiltering/filt_0-0.25_smoothed/${s}/${s}_preprocessed_psc_filt025_smoothed.nii.gz
		
	# Take the mean of the filtered functional data, for calculating ALFF
	mkdir -p ${vol_path}/temporalFiltering/filt_0-0.25_smoothed/${s}/mean

	fslmaths ${vol_path}/temporalFiltering/filt_0-0.25_smoothed/${s}/${s}_preprocessed_psc_filt025_smoothed.nii.gz -Tmean ${vol_path}/temporalFiltering/filt_0-0.25_smoothed/${s}/mean/${s}_preprocessed_psc_filt025_mean_smoothed.nii.gz

	# Checkpoint for temporal filtering
	echo "${s} temporal filtering step for the SMOOTHED version is finished"  >> ${log_path}/2_volProcessing_1_LOG.txt

	


}

# Exports the function
export -f volume_processing_1

# Create an array with subjects (as they are in nifti folder)
# s=($(ls /Volumes/gdrive4tb/IGNITE/sparse_rest/preprocessed))
s=(IGTTHG_00064 IGNTMN_00051 IGTTKA_00017)

# Check the content of the subject array
echo ${s[@]}

# Run the analysis in parallel using GNU parallel
# Jobs is set to 0, which allows parallel to assign the jobs as it sees fit, and divide it across the CPUs itself
# Provide it with the name of the function, and specify it will take one argument, then provide this after the three colons

parallel --jobs 6 'volume_processing_1 {1}' ::: ${s[@]}