#!/bin/bash


data_path="/Volumes/gdrive4tb/IGNITE"
preproc_path="/Volumes/gdrive4tb/IGNITE/resting-state/preprocessed"
vol_path="/Volumes/gdrive4tb/IGNITE/resting-state/volumetric"

 # Set the subject you want to check
subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))

# QUALITY CONTROL FOR PREPROCESSING

for s in ${subj[@]}; do

# Check that the first 10 volumes have been removed
line_o=($(fslhd ${data_path}/data/nifti/${s}/*final_fmri*fMRI_2mm*.nii* | grep dim4)); vol_orig=${line_o[1]}
line_p=($(fslhd ${preproc_path}/$s/${s}_preprocessed.nii.gz | grep dim4)); vol_preproc=${line_p[1]}

dif=$((${vol_orig}-${vol_preproc}))
        
    if [ $dif = 10 ]; then
        echo "$s 10 volumes removed"
    elif [ $dif != 10 ]; then
        echo "$s fslroi failed"
    fi

# Check that finding the original motion parameters has worked
#By checking that there are 665 lines in the original motion parameters absolute and 664 lines relative rms files
    abs=$(wc -l < ${preproc_path}/${s}/motionOrig/${s}_motionOrig_abs.rms)
    rel=$(wc -l < ${preproc_path}/${s}/motionOrig/${s}_motionOrig_rel.rms)
    
    if [ $abs = 665 ] && [ $rel = 664 ]; then
    echo " ${s} Original Motion Parameters were obtained"
    elif [ $abs != 665 ] && [ $rel != 664 ]; then
    echo " ${s} Original Motion Parameters were NOT obtained"
    fi

#Slice Time Correction

# Check whether motion correction has worked
    # Check there are 665 files in the correction.mat file

    m_corr=$(ls -1 ${preproc_path}/${s}/MotionCorrection/${s}_motionCorrection.mat | wc -l)
    
    if [ $m_corr = 665 ]; then
    echo "${s} Motion Correction has been performed"
    elif [ $m_corr != 665 ]; then
    echo "${s} Motion Correction has NOT been performed"
    fi
    

# Check Distortion Correction
    # Check the created fmap files - have the pepolar0 and pepolar1 now got 1 volume, and has the combined file got 2
    
    line_pepolar0=($(fslhd ${preproc_path}/${s}/topUp/fmap/${s}_aligned_pepolar0.nii.gz | grep dim4)); vol_pepolar0=${line_pepolar0[1]}
    line_pepolar1=($(fslhd ${preproc_path}/${s}/topUp/fmap/${s}_aligned_pepolar1.nii.gz | grep dim4)); vol_pepolar1=${line_pepolar1[1]}
    line_comb=($(fslhd ${preproc_path}/${s}/topUp/fmap/${s}_merge_pepolar.nii.gz | grep dim4)); vol_comb=${line_comb[1]}

    if [ ${vol_pepolar0} = 1 ] && [ ${vol_pepolar1} = 1 ] && [ ${vol_comb} = 2 ]; then
    echo "${s} Field maps created correctly"
    elif [ ${vol_pepolar0} != 1 ] && [ ${vol_pepolar1} != 1 ] && [ ${vol_comb} != 2 ]; then
    echo "${s} Field maps NOT created correctly"
    fi

done

##############################################################
# FSL EYES to check the application of TOPUP ##############################################################
for s in ${subj[@]}; do
    # Check the initial shift between the pepolar0 and pepolar1 images, play as a movie, and then compare to the topup applied images
    echo "Use FSLeyes to check the application of topup"
    fsleyes ${preproc_path}/${s}/${s}_preprocessed.nii.gz -dr -500 5000 &
done

# ##############################################################
# # Use FSL EYES to check the conversion to percentage signal change ##############################################################
# for s in ${subj[@]}; do
# # Check the conversion of the data into percentage signal change
#     # Open the preproc and percentage signal change images in fsleyes
#     # Use the view option and select time series
#     # Select the preproc image, and use the drop down menu to select percent changed, and then the plus button to add to the axis below
#     # Deselect the preproc image, and now select the psc image
#     # Use the drop down menu to select the normal -no scaling option
#     # Press the add button
#     # Check that these lines completely overlap

#     echo "Use FSLeyes to check the conversion to Percentage Signal Change"
#     fsleyes ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc.nii.gz -dr -10 20 ${preproc_path}/${s}/${s}_preprocessed.nii.gz -dr -500 5000 &
# done

# ##############################################################
# # Use FSL EYES to check the temporal filtering ##############################################################
# for s in ${subj[@]}; do
# # Check the temporal filtering
#     # Open the psc and temporally filtered images in fsleyes
#     # Select the power spectra view
#     # Check that the signal has been filtered between the desired frequencies

#     echo "Use FSLeyes to check the Temporal Filtering"
#     fsleyes ${vol_path}/temporalFiltering/filt_0.01-0.1/${s}/${s}_preprocessed_psc_filt01.nii.gz -dr -10 20 ${vol_path}/temporalFiltering/filt_0-0.25/${s}/${s}_preprocessed_psc_filt025.nii.gz -dr -10 20 ${vol_path}/percent_signal_change/${s}/${s}_preprocessed_psc.nii.gz -dr -10 20 &

# done
