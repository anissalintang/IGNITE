#!/bin/bash

# Quality control script for volProcessing_2 for FSLeyes visual checking
data_path="/Volumes/gdrive4tb/IGNITE"
preproc_path="/Volumes/gdrive4tb/IGNITE/resting-state/preprocessed"
vol_path="/Volumes/gdrive4tb/IGNITE/resting-state/volumetric"
log_path="/Volumes/gdrive4tb/IGNITE/resting-state/log"

s=(IGNTFA_00065) # Set the subject ID that you want to check

###############################################################
# T1 image preparation: cropping
###############################################################
echo "Use FSLeyes to check the preparation of the T1 image"
fsleyes ${data_path}/data/nifti/${s}/*SAG_T1*.nii.* ${vol_path}/registration/${s}/${s}_t1.nii.gz &


###############################################################
# Reslicing of the T1 image to MNI space
###############################################################
# MNI at the bottom, with resliced T1 over the top
# Change the color of the resliced T1 and make less opaque to look at the accuracy of the reslicing
echo "Use FSLeyes to check the reslicing of T1 to MNI space"
fsleyes $FSLDIR/data/standard/MNI152_T1_2mm ${vol_path}/registration/$s/struct2mni/${s}_struct2mni.nii.gz &

###############################################################
# Reslicing of the functional time series to MNI space
# UNSMOOTHED image
###############################################################
# Load the images into fsleyes
# Change the color to Hot, contrast (-10,20) and opacity of the resliced functional time series
# Play the movie of the functional timeseries to check the reslicing of each volume to MNI space
echo "Use FSLeyes to check the reslicing of the functional time series to MNI space"
fsleyes $FSLDIR/data/standard/MNI152_T1_2mm ${vol_path}/registration/${s}/func2mni/${s}_func2mni.nii.gz -dr -10 20 -cm hot -a 50 -c 95 &

###############################################################
# Reslicing of the functional time series to MNI space
# SMOOTHED image
###############################################################
# Load the images into fsleyes
# Change the color to Hot, contrast (-10,20) and opacity of the resliced functional time series
# Play the movie of the functional timeseries to check the reslicing of each volume to MNI space
echo "Use FSLeyes to check the reslicing of the SMOOTHED functional time series to MNI space"
fsleyes $FSLDIR/data/standard/MNI152_T1_2mm ${vol_path}/registration/${s}/func2mni_smoothed/${s}_func2mni_smoothed.nii.gz &

