#!/bin/bash

# Quality control script for volProcessing_1 for FSLeyes visual checking
data_path="/Volumes/gdrive4tb/IGNITE"
preproc_path="/Volumes/gdrive4tb/IGNITE/resting-state/preprocessed"
vol_path="/Volumes/gdrive4tb/IGNITE/resting-state/volumetric"

subj=(IGNTFA_00065) # Set the subject ID that you want to check

###############################################################
# Visual checking using FSL EYES to check the application of TOPUP
###############################################################
# Check the initial shift between the pepolar0 and pepolar1 images, play as a movie, and then compare to the TOPUP applied images
for s in ${subj[@]}; do
	echo "Use FSLeyes to check the application of TOPUP"
	fsleyes ${preproc_path}/${s}/topUp/fmap/${s}_merge_pepolar.nii.gz ${preproc_path}/${s}/topUp/QC_topUpApplied/${s}_topUp_pepolar0.nii.gz ${preproc_path}/${s}/topUp/QC_topUpApplied/${s}_topUp_pepolar1.nii.gz &
done


###############################################################
# Visual checking using FSL EYES to check the conversion to percentage signal change (PSC)
###############################################################
# Open the preproc and PSC images in fsleyes
# Use the view option and select time series
# Select the preproc image and use the drop down menu to select percent change and then the plus button to add to the axis below
# Deselect the preproc image and now select the PSC image
# Use the drop down menu to select the normal -no scaling option
# Press the add button
# Check that these line completely overlap

echo "Use FSLeyes to check the conversion to Percentage Signal Change"
fsleyes ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc.nii.gz -dr -10 20 ${preproc_path}/${s}/${s}_preprocessed.nii.gz -dr -500 5000 &


###############################################################
# Visual checking using FSL EYES to check the temporal filtering
###############################################################
# Open the PSC and temporally filtered images in FSLeyes
# Select the power spectra view
# Check that the signal has been filtered between the desired frequencies

echo "Use FSLeyes to check the temporal filtering"
fsleyes ${vol_path}/temporalFiltering/filt_0.01-0.1/${s}/${s}_preprocessed_psc_filt01.nii.gz ${vol_path}/temporalFiltering/filt_0-0.25/${s}/${s}_preprocessed_psc_filt025.nii.gz ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc.nii.gz &




###############################################################
###############################################################
#
# Visual checking using FSL EYES FOR SMOOTHED VERSION
#
###############################################################
###############################################################

###############################################################
# Visual checking using FSL EYES to check the conversion to percentage signal change (PSC)
###############################################################
# Open the preproc and PSC images in fsleyes
# Use the view option and select time series
# Select the preproc image and use the drop down menu to select psc and then the plus button to add to the axis below
# Deselect the preproc image and now select the PSC image
# Use the drop down menu to select the normal -no scaling option
# Press the add button
# Check that these line completely overlap

echo "Use FSLeyes to check the conversion to Percentage Signal Change for SMOOTHED image"
fsleyes ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc_smoothed.nii.gz ${preproc_path}/${s}/${s}_preprocessed_smoothed.nii.gz &


###############################################################
# Visual checking using FSL EYES to check the temporal filtering
###############################################################
# Open the PSC and temporally filtered images in FSLeyes
# Select the power spectra view
# Check that the signal has been filtered between the desired frequencies

echo "Use FSLeyes to check the temporal filtering for SMOOTHED image"
fsleyes ${vol_path}/temporalFiltering/filt_0.01-0.1_smoothed/${s}/${s}_preprocessed_psc_filt01_smoothed.nii.gz ${vol_path}/temporalFiltering/filt_0-0.25_smoothed/${s}/${s}_preprocessed_psc_filt025_smoothed.nii.gz ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc_smoothed.nii.gz &
