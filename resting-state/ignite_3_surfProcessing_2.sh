#!/bin/bash

# Surface data processing script
# Step TWO of surface processing is to create the lta fields which will enable the projection of the individual functional time series to the cortical surface


data_path="/Volumes/gdrive4tb/IGNITE"; s=$1
preproc_path="/Volumes/gdrive4tb/IGNITE/resting-state/preprocessed"
vol_path="/Volumes/gdrive4tb/IGNITE/resting-state/volumetric"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"
log_path="/Volumes/gdrive4tb/IGNITE/resting-state/log"

export SUBJECTS_DIR="${fs_path}/recon"

echo "subject directory is.. $SUBJECTS_DIR"

# Subjects Array
subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# testing
# subj=(IGTTFJ_00074)

for s in ${subj[@]}; do
	mkdir -p ${fs_path}/registration/${s}

	# Obtain registration from T1 (fsl) to orig (fs), and concatenate with meanfunc2struct
	# Output is mean2fs.lta which is needed to project the mean functional image to the cortical surface

	tkregister2 --mov ${fs_path}/struct/$s/${s}_t1.nii.gz \
	--targ $SUBJECTS_DIR/${s}/mri/orig.mgz \
	--s ${s} \
	--reg ${fs_path}/registration/${s}/${s}_fsl2fs.dat \
	--ltaout ${fs_path}/registration/${s}/${s}_fsl2fs.lta \
	--noedit \
	--regheader

	# Checkpoint for tkregister2
	echo "${s} tkregister2 step has been performed" >> ${log_path}/5_surfProcessing_2_LOG.txt

	lta_convert --inlta ${fs_path}/registration/${s}/${s}_fsl2fs.lta \
	--outfsl ${fs_path}/registration/${s}/${s}_fsl2fs.mat

	# Checkpoint for lta_convert
	echo "${s} lta_convert step has been performed" >> ${log_path}/5_surfProcessing_2_LOG.txt

	convert_xfm -omat ${fs_path}/registration/${s}/${s}_mean2fs.mat \
	-concat ${fs_path}/registration/${s}/${s}_fsl2fs.mat ${vol_path}/registration/$s/meanfunc2struct/${s}_meanfunc2struct.mat

	# Checkpoint for convert_xfm
	echo "${s} convert_xfm step has been performed" >> ${log_path}/5_surfProcessing_2_LOG.txt

	lta_convert --infsl ${fs_path}/registration/${s}/${s}_mean2fs.mat \
	--outreg ${fs_path}/registration/${s}/${s}_mean2fs.dat \
	--outlta ${fs_path}/registration/${s}/${s}_mean2fs.lta \
	--subject ${s} \
	--src ${preproc_path}/$s/meanFunc/${s}_mean_func.nii.gz \
	--trg $SUBJECTS_DIR/$subj/mri/orig.mgz

	# Checkpoint for lta_convert
	echo "${s} lta_convert step has been performed" >> ${log_path}/5_surfProcessing_2_LOG.txt
done

# Project the functional time series to the subject specific cortical surface
# Following steps are completed using GNU parallel

surface_processing_2() {

data_path="/Volumes/gdrive4tb/IGNITE"; s=$1
preproc_path="/Volumes/gdrive4tb/IGNITE/resting-state/preprocessed"
vol_path="/Volumes/gdrive4tb/IGNITE/resting-state/volumetric"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"
log_path="/Volumes/gdrive4tb/IGNITE/resting-state/log"

export SUBJECTS_DIR="${fs_path}/recon"

# Hemisphere array
hemi=(lh rh)

# Project the functional time series without smoothing to fsaverage (MNI 305)

# Restricted filter 0.01-0.1
mkdir -p $fs_path/projected/nonSmoothed/filt_0.01-0.1/${s}/

for h in ${hemi[@]}; do
	mri_vol2surf --mov ${vol_path}/temporalFiltering/filt_0.01-0.1/${s}/${s}_preprocessed_psc_filt01.nii.gz \
	--hemi ${h} \
	--o ${fs_path}/projected/nonSmoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_fs.mgz \
	--projfrac-avg 0 1 0.1 \
	--reg ${fs_path}/registration/$s/${s}_mean2fs.lta \
	--srcsubject ${s}
done

for h in ${hemi[@]}; do
	mris_apply_reg --src ${fs_path}/projected/nonSmoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_fs.mgz \
	--o ${fs_path}/projected/nonSmoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_fsavg.mgz \
	--streg $SUBJECTS_DIR/${s}/surf/${h}.fsaverage.sphere.reg $SUBJECTS_DIR/fsaverage/surf/${h}.sphere.reg
done


## Wide filter 0-0.25
mkdir -p $fs_path/projected/nonSmoothed/filt_0-0.25/${s}/

for h in ${hemi[@]}; do
	mri_vol2surf --mov ${vol_path}/temporalFiltering/filt_0-0.25/${s}/${s}_preprocessed_psc_filt025.nii.gz \
	--hemi ${h} \
	--o ${fs_path}/projected/nonSmoothed/filt_0-0.25/${s}/${s}_${h}_filt025_fs.mgz \
	--projfrac-avg 0 1 0.1 \
	--reg ${fs_path}/registration/$s/${s}_mean2fs.lta \
	--srcsubject ${s}
done

for h in ${hemi[@]}; do
	mris_apply_reg --src ${fs_path}/projected/nonSmoothed/filt_0-0.25/${s}/${s}_${h}_filt025_fs.mgz \
	--o ${fs_path}/projected/nonSmoothed/filt_0-0.25/${s}/${s}_${h}_filt025_fsavg.mgz \
	--streg $SUBJECTS_DIR/${s}/surf/${h}.fsaverage.sphere.reg $SUBJECTS_DIR/fsaverage/surf/${h}.sphere.reg
done


# Additionally project the functional time series to fsaverage space, and to smoothe the image during this process

# Restricted filter 0.01-0.1
mkdir -p $fs_path/projected/Smoothed/filt_0.01-0.1/${s}/

for h in ${hemi[@]}; do
	mri_vol2surf --mov ${vol_path}/temporalFiltering/filt_0.01-0.1/${s}/${s}_preprocessed_psc_filt01.nii.gz \
	--hemi ${h} \
	--o ${fs_path}/projected/Smoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_smoothed_fs.mgz \
	--projfrac-avg 0 1 0.1 \
	--reg ${fs_path}/registration/$s/${s}_mean2fs.lta \
	--srcsubject ${s}
done

# Smooth the vol2surf projected image with FWHM=5
fwhm=5

for h in ${hemi[@]}; do
	mri_surf2surf --sval ${fs_path}/projected/Smoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_smoothed_fs.mgz \
	--tval ${fs_path}/projected/Smoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_smoothed_fsavg.mgz \
	--s ${s} \
	--hemi ${h} \
	--fwhm $fwhm \
	--cortex
done

for h in ${hemi[@]}; do
	mris_apply_reg --src ${fs_path}/projected/Smoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_smoothed_fsavg.mgz \
	--o ${fs_path}/projected/Smoothed/filt_0.01-0.1/${s}/${s}_${h}_filt01_smoothed_fsavg.mgz \
	--streg $SUBJECTS_DIR/${s}/surf/${h}.fsaverage.sphere.reg $SUBJECTS_DIR/fsaverage/surf/${h}.sphere.reg
done


## Wide filter 0-0.25
mkdir -p $fs_path/projected/Smoothed/filt_0-0.25/${s}/

for h in ${hemi[@]}; do
	mri_vol2surf --mov ${vol_path}/temporalFiltering/filt_0-0.25/${s}/${s}_preprocessed_psc_filt025.nii.gz \
	--hemi ${h} \
	--o ${fs_path}/projected/Smoothed/filt_0-0.25/${s}/${s}_${h}_filt025_smoothed_fs.mgz \
	--projfrac-avg 0 1 0.1 \
	--reg ${fs_path}/registration/$s/${s}_mean2fs.lta \
	--srcsubject ${s}
done

# Smooth the vol2surf projected image with FWHM=5
fwhm=5

for h in ${hemi[@]}; do
	mri_surf2surf --sval ${fs_path}/projected/Smoothed/filt_0-0.25/${s}/${s}_${h}_filt025_smoothed_fs.mgz \
	--tval ${fs_path}/projected/Smoothed/filt_0-0.25/${s}/${s}_${h}_filt025_smoothed_fsavg.mgz \
	--s ${s} \
	--hemi ${h} \
	--fwhm $fwhm \
	--cortex
done

for h in ${hemi[@]}; do
	mris_apply_reg --src ${fs_path}/projected/Smoothed/filt_0-0.25/${s}/${s}_${h}_filt025_smoothed_fsavg.mgz \
	--o ${fs_path}/projected/Smoothed/filt_0-0.25/${s}/${s}_${h}_filt025_smoothed_fsavg.mgz \
	--streg $SUBJECTS_DIR/${s}/surf/${h}.fsaverage.sphere.reg $SUBJECTS_DIR/fsaverage/surf/${h}.sphere.reg
done

}


# Exports the function
export -f surface_processing_2

# Create an array with subjects (as they are in preprocessed folder)
s=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# s=(IGTTFJ_00074)

# Check the content of the subject array
echo ${s[@]}

# Run the analysis in parallel using GNU parallel
# Jobs is set to 0, which allows parallel to assign the jobs as it sees fit, and divide it across the CPUs itself
# Provide it with the name of the function, and specify it will take one argument, then provide this after the three colons

parallel --jobs 6 'surface_processing_2 {1}' ::: ${s[@]}