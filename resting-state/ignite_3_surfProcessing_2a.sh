 #!/bin/bash

# Surface data processing script
# Step TWOa of surface processing is to projection of the individual functional timer series to the cortical surface of fsavg_hemi
# which is projecting lh to lh, and rh to lh of xhemi (they will have the same vertices so we can do calculate statistic for interaction >> interaction calculation needs the data to came from the same vertices)

# data_path="/Volumes/gdrive4tb/IGNITE"; s=$1
# preproc_path="/Volumes/gdrive4tb/IGNITE/resting-state/preprocessed"
# vol_path="/Volumes/gdrive4tb/IGNITE/resting-state/volumetric"
# fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"
# log_path="/Volumes/gdrive4tb/IGNITE/resting-state/log"

# export SUBJECTS_DIR="${fs_path}/recon"

# echo "subject directory is.. $SUBJECTS_DIR"

# # Subjects Array
# subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# # testing
# # subj=(IGTTFJ_00074)

# for s in ${subj[@]}; do
#     mkdir -p ${fs_path}/registration_fssym/${s}

#     # Obtain registration from T1 (fsl) to orig (fs), and concatenate with meanfunc2struct
#     # Output is mean2fs.lta which is needed to project the mean functional image to the cortical surface

#     tkregister2 --mov ${fs_path}/struct/$s/${s}_t1.nii.gz \
#     --targ $SUBJECTS_DIR/${s}/xhemi/mri/orig.mgz \
#     --s ${s} \
#     --reg ${fs_path}/registration_fssym/${s}/${s}_fsl2fs.dat \
#     --ltaout ${fs_path}/registration_fssym/${s}/${s}_fsl2fs.lta \
#     --noedit \
#     --regheader

#     lta_convert --inlta ${fs_path}/registration_fssym/${s}/${s}_fsl2fs.lta \
#     --outfsl ${fs_path}/registration_fssym/${s}/${s}_fsl2fs.mat

#     convert_xfm -omat ${fs_path}/registration_fssym/${s}/${s}_mean2fs.mat \
#     -concat ${fs_path}/registration_fssym/${s}/${s}_fsl2fs.mat ${vol_path}/registration/$s/meanfunc2struct/${s}_meanfunc2struct.mat


#     lta_convert --infsl ${fs_path}/registration_fssym/${s}/${s}_mean2fs.mat \
#     --outreg ${fs_path}/registration_fssym/${s}/${s}_mean2fs.dat \
#     --outlta ${fs_path}/registration_fssym/${s}/${s}_mean2fs.lta \
#     --subject ${s} \
#     --src ${preproc_path}/$s/meanFunc/${s}_mean_func.nii.gz \
#     --trg $SUBJECTS_DIR/$s/xhemi/mri/orig.mgz

# done

surface_processing_fssym() {

data_path="/Volumes/gdrive4tb/IGNITE"; s=$1
preproc_path="/Volumes/gdrive4tb/IGNITE/resting-state/preprocessed"
vol_path="/Volumes/gdrive4tb/IGNITE/resting-state/volumetric"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"
log_path="/Volumes/gdrive4tb/IGNITE/resting-state/log"

export SUBJECTS_DIR="${fs_path}/recon"

# Hemisphere array
hemi=(lh rh)

# Project the functional time series without smoothing to fsaverage (MNI 305)

# # Restricted filter 0.01-0.1
# mkdir -p $fs_path/projected/fssym/nonSmoothed/filt_0.01-0.1/${s}/

# for h in ${hemi[@]}; do
#     mri_vol2surf --mov ${vol_path}/temporalFiltering/filt_0.01-0.1/${s}/${s}_preprocessed_psc_filt01.nii.gz \
#     --hemi ${h} \
#     --o ${fs_path}/projected/fssym/nonSmoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_fs_onlh_fssym.mgz \
#     --projfrac-avg 0 1 0.1 \
#     --reg ${fs_path}/registration_fssym/$s/${s}_mean2fs.lta \
#     --srcsubject ${s}

#     if [ $h = "lh" ]; then
#         mris_apply_reg --src ${fs_path}/projected/fssym/nonSmoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_fs_onlh_fssym.mgz \
#          --o ${fs_path}/projected/fssym/nonSmoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_fsavg_onlh_fssym.mgz \
#         --streg $SUBJECTS_DIR/${s}/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
#     else
#         mris_apply_reg --src ${fs_path}/projected/fssym/nonSmoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_fs_onlh_fssym.mgz \
#          --o ${fs_path}/projected/fssym/nonSmoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_fsavg_onlh_fssym.mgz \
#         --streg $SUBJECTS_DIR/${s}/xhemi/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
#     fi
# done



# ## Wide filter 0-0.25
# mkdir -p $fs_path/projected/fssym/nonSmoothed/filt_0-0.25/${s}/

# for h in ${hemi[@]}; do
#     mri_vol2surf --mov ${vol_path}/temporalFiltering/filt_0-0.25/${s}/${s}_preprocessed_psc_filt025.nii.gz \
#     --hemi ${h} \
#     --o ${fs_path}/projected/fssym/nonSmoothed/filt_0-0.25/${s}/${s}_${h}_filt025_fs_onlh_fssym.mgz \
#     --projfrac-avg 0 1 0.1 \
#     --reg ${fs_path}/registration_fssym/$s/${s}_mean2fs.lta \
#     --srcsubject ${s}

#     if [ $h = "lh" ]; then
#         mris_apply_reg --src ${fs_path}/projected/fssym/nonSmoothed/filt_0-0.25/${s}/${s}_${h}_filt025_fs_onlh_fssym.mgz \
#          --o ${fs_path}/projected/fssym/nonSmoothed/filt_0-0.25/${s}/${s}_${h}_filt025_fsavg_onlh_fssym.mgz \
#         --streg $SUBJECTS_DIR/${s}/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
#     else
#         mris_apply_reg --src ${fs_path}/projected/fssym/nonSmoothed/filt_0-0.25/${s}/${s}_${h}_filt025_fs_onlh_fssym.mgz \
#          --o ${fs_path}/projected/fssym/nonSmoothed/filt_0-0.25/${s}/${s}_${h}_filt025_fsavg_onlh_fssym.mgz \
#         --streg $SUBJECTS_DIR/${s}/xhemi/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
#     fi
# done


# Additionally project the functional time series to fsaverage space, and to smoothe the image during this process

# Restricted filter 0.01-0.1
mkdir -p $fs_path/projected/fssym/Smoothed/filt_0.01-0.1/${s}/

for h in ${hemi[@]}; do
    mri_vol2surf --mov ${vol_path}/temporalFiltering/filt_0.01-0.1/${s}/${s}_preprocessed_psc_filt01.nii.gz \
    --hemi ${h} \
    --o ${fs_path}/projected/fssym/Smoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_smoothed_fs_onlh_fssym.mgz \
    --projfrac-avg 0 1 0.1 \
    --reg ${fs_path}/registration_fssym/$s/${s}_mean2fs.lta \
    --srcsubject ${s}

    # Smooth the vol2surf projected image with FWHM=5
    fwhm=5

    mri_surf2surf --sval ${fs_path}/projected/fssym/Smoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_smoothed_fs_onlh_fssym.mgz \
    --tval ${fs_path}/projected/fssym/Smoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_smoothed_fsavg_onlh_fssym.mgz \
    --s ${s} \
    --hemi ${h} \
    --fwhm $fwhm \
    --cortex

    if [ $h = "lh" ]; then
        mris_apply_reg --src ${fs_path}/projected/fssym/Smoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_smoothed_fsavg_onlh_fssym.mgz \
         --o ${fs_path}/projected/fssym/Smoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_smoothed_fsavg_onlh_fssym.mgz \
        --streg $SUBJECTS_DIR/${s}/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
    else
        mris_apply_reg --src ${fs_path}/projected/fssym/Smoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_smoothed_fsavg_onlh_fssym.mgz \
         --o ${fs_path}/projected/fssym/Smoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_smoothed_fsavg_onlh_fssym.mgz \
        --streg $SUBJECTS_DIR/${s}/xhemi/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
    fi
done


## Wide filter 0-0.25
mkdir -p $fs_path/projected/fssym/Smoothed/filt_0-0.25/${s}/

for h in ${hemi[@]}; do
    mri_vol2surf --mov ${vol_path}/temporalFiltering/filt_0-0.25/${s}/${s}_preprocessed_psc_filt025.nii.gz \
    --hemi ${h} \
    --o ${fs_path}/projected/fssym/Smoothed/filt_0-0.25/${s}/${s}_${h}_filt025_smoothed_fs_onlh_fssym.mgz \
    --projfrac-avg 0 1 0.1 \
    --reg ${fs_path}/registration_fssym/$s/${s}_mean2fs.lta \
    --srcsubject ${s}

    # Smooth the vol2surf projected image with FWHM=5
    fwhm=5

    mri_surf2surf --sval ${fs_path}/projected/fssym/Smoothed/filt_0-0.25/${s}/${s}_${h}_filt025_smoothed_fs_onlh_fssym.mgz \
    --tval ${fs_path}/projected/fssym/Smoothed/filt_0-0.25/${s}/${s}_${h}_filt025_smoothed_fsavg_onlh_fssym.mgz \
    --s ${s} \
    --hemi ${h} \
    --fwhm $fwhm \
    --cortex

    if [ $h = "lh" ]; then
        mris_apply_reg --src ${fs_path}/projected/fssym/Smoothed/filt_0-0.25/${s}/${s}_${h}_filt025_smoothed_fsavg_onlh_fssym.mgz \
         --o ${fs_path}/projected/fssym/Smoothed/filt_0-0.25/${s}/${s}_${h}_filt025_smoothed_fsavg_onlh_fssym.mgz \
        --streg $SUBJECTS_DIR/${s}/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
    else
        mris_apply_reg --src ${fs_path}/projected/fssym/Smoothed/filt_0-0.25/${s}/${s}_${h}_filt025_smoothed_fsavg_onlh_fssym.mgz \
         --o ${fs_path}/projected/fssym/Smoothed/filt_0-0.25/${s}/${s}_${h}_filt025_smoothed_fsavg_onlh_fssym.mgz \
        --streg $SUBJECTS_DIR/${s}/xhemi/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
    fi
done


}


# Exports the function
export -f surface_processing_fssym

# Create an array with subjects (as they are in preprocessed folder)
s=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# s=(IGTTFJ_00074)

# Check the content of the subject array
echo ${s[@]}

# Run the analysis in parallel using GNU parallel
# Jobs is set to 0, which allows parallel to assign the jobs as it sees fit, and divide it across the CPUs itself
# Provide it with the name of the function, and specify it will take one argument, then provide this after the three colons

parallel --jobs 6 'surface_processing_fssym {1}' ::: ${s[@]}
