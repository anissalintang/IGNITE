#!/bin/bash


data_path="/Volumes/gdrive4tb/IGNITE"
preproc_path="/Volumes/gdrive4tb/IGNITE/resting-state/preprocessed"
vol_path="/Volumes/gdrive4tb/IGNITE/resting-state/volumetric"

 # Set the subject you want to check
subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# subj=(IGTTKA_00017)


# QUALITY CONTROL FOR VOLUME PROCESSING
for s in ${subj[@]}; do
    # # Check the preparation of the T1 image
    # echo "Use FSLeyes to check the preparation of the T1 image"
    # fsleyes ${data_path}/data/nifti/$s/*SAG_T1*.nii* ${vol_path}/registration/$s/${s}_t1.nii.gz -cm hot -a 50 -c 55 &

    # # Check the reslicing of the T1 image to MNI space
    #     # MNI at the bottom, with resliced T1 over the top
    #     # Change the colour of the resliced T1 and make less opaque to look at the accuracy of the reslicing
    # echo "Use FSLeyes to check the reslicing of T1 to MNI space"
    # fsleyes $FSLDIR/data/standard/MNI152_T1_2mm ${vol_path}/registration/$s/struct2mni/${s}_struct2mni.nii.gz -cm hot -a 50 -c 55 &

    # Check the reslicing of the functional time series to T1
    echo "Use FSLeyes to check the reslicing of the functional time series to T1"
    fsleyes ${vol_path}/registration/$s/${s}_t1.nii.gz ${vol_path}/registration/$s/meanfunc2struct/${s}_meanfunc2struct.nii.gz -dr 100 3000 -cm hot -a 50 -c 95 &

    # # Check the reslicing of the functional time series to MNI space
    #     # Load the images into fsleyes
    #     # Change the colour (Hot), image (-10, 20) and opacity of the resliced functional time series
    #     # Play the movie of the functional timeseries to check the reslicing of each volume to MNI space
    # echo "Use FSLeyes to check the reslicing of the functional time series to MNI space"
    # fsleyes $FSLDIR/data/standard/MNI152_T1_2mm ${vol_path}/registration/$s/func2mni/${s}_func2mni.nii.gz -dr -10 20 -cm hot -a 50 -c 95 &

done
