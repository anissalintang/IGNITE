#!/bin/bash


data_path="/Volumes/gdrive4tb/IGNITE"
preproc_path="/Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed"
vol_path="/Volumes/gdrive4tb/IGNITE/tonotopy/volumetric"

 # Set the subject you want to check
# subj=($(ls /Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed | grep -vE "IGTTHG_00064|IGNTMN_00051|IGTTKA_00017"))
# subj=(IGTTKA_00017 IGTTHG_00064 IGNTMN_00051)
# subj=(IGTTKA_00017 IGNTLX_00069 IGNTHS_00068 IGTTHA_00070 IGNTFM_00060 IGTTKA_00017 IGTTSM_00050 IGNTGS_00049)

# subj=($(ls /Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed | head -n 10))
# subj=($(ls /Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed | sed -n '10,20p'))
# subj=($(ls /Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed | sed -n '20,30p'))
# subj=($(ls /Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed | sed -n '30,40p'))
subj=($(ls /Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed | tail -n 10))

# QUALITY CONTROL FOR PREPROCESSING

for s in ${subj[@]}; do

# Check that the first 3 volumes have been removed
line_o=($(fslhd ${preproc_path}/${s}/${s}_sparse_tono_nordic.nii | grep dim4)); vol_orig=${line_o[1]}
line_p=($(fslhd ${preproc_path}/$s/${s}_preprocessed.nii.gz | grep dim4)); vol_preproc=${line_p[1]}

dif=$((${vol_orig}-${vol_preproc}))
        
    if [ $dif = 3 ]; then
        echo "$s 3 volumes removed"
    elif [ $dif != 3 ]; then
        echo "$s fslroi failed"
    fi

# Check that finding the original motion parameters has worked
#By checking that there are 80 lines in the original motion parameters absolute and 79 lines relative rms files
    abs=$(wc -l < ${preproc_path}/${s}/motionOrig/${s}_motionOrig_abs.rms)
    rel=$(wc -l < ${preproc_path}/${s}/motionOrig/${s}_motionOrig_rel.rms)
    
    if [ $abs = 80 ] && [ $rel = 79 ]; then
    echo " ${s} Original Motion Parameters were obtained"
    elif [ $abs != 80 ] && [ $rel != 79 ]; then
    echo " ${s} Original Motion Parameters were NOT obtained"
    fi

#Slice Time Correction

# # Check whether there are 25 lines in sliceTimingOrder.txt
# # Get the number of lines in the file
# num_lines=$(wc -l < "$preproc_path/$s/SliceTimingOrder.txt")

# # Check if the number of lines is 25
# if [ "$num_lines" -eq 25 ]; then
#     echo "The sliceTimingOrder has 25 lines."
# else
#     echo "The sliceTimingOrder does NOT have 25 lines. It has $num_lines lines."
# fi

# Check whether motion correction has worked
    # Check there are 80 files in the correction.mat file

    m_corr=$(ls -1 ${preproc_path}/${s}/MotionCorrection/${s}_motionCorrection.mat | wc -l)
    
    if [ $m_corr = 80 ]; then
    echo "${s} Motion Correction has been performed"
    elif [ $m_corr != 80 ]; then
    echo "${s} Motion Correction has NOT been performed"
    fi
    

# # Check Distortion Correction
#     # Check the created fmap files - have the pepolar0 and pepolar1 now got 1 volume, and has the combined file got 2
    
#     line_pepolar0=($(fslhd ${preproc_path}/${s}/topUp/fmap/${s}_aligned_pepolar0.nii.gz | grep dim4)); vol_pepolar0=${line_pepolar0[1]}
#     line_pepolar1=($(fslhd ${preproc_path}/${s}/topUp/fmap/${s}_aligned_pepolar1.nii.gz | grep dim4)); vol_pepolar1=${line_pepolar1[1]}
#     line_comb=($(fslhd ${preproc_path}/${s}/topUp/fmap/${s}_merge_pepolar.nii.gz | grep dim4)); vol_comb=${line_comb[1]}

#     if [ ${vol_pepolar0} = 1 ] && [ ${vol_pepolar1} = 1 ] && [ ${vol_comb} = 2 ]; then
#     echo "${s} Field maps created correctly"
#     elif [ ${vol_pepolar0} != 1 ] && [ ${vol_pepolar1} != 1 ] && [ ${vol_comb} != 2 ]; then
#     echo "${s} Field maps NOT created correctly"
#     else
#         echo "${s} NO Field maps alignment were done"
#     fi

done

#############################################################
# FSL EYES to check the application of TOPUP ##############################################################
for s in ${subj[@]}; do
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
