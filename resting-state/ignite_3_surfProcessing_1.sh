#!/bin/bash

# Surface data processing script
# Here we run recon-all to create subject specific cortical surfaces
surface_processing_1() {

	mkdir -p /Volumes/gdrive4tb/IGNITE/resting-state/surface

	data_path="/Volumes/gdrive4tb/IGNITE";s=$1
    vol_path="/Volumes/gdrive4tb/IGNITE/resting-state/volumetric"
    log_path="/Volumes/gdrive4tb/IGNITE/resting-state/log"
    fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"

	mkdir -p ${fs_path}/struct/$s

	# Copy the T1 image which has previously undergone robustFOV, bias correction and slight smoothing (from the volume_processing.sh --registration step)
	cp ${vol_path}/registration/$s/${s}_t1.nii.gz ${fs_path}/struct/$s/${s}_t1.nii.gz

	# FREESURFER
	mkdir -p ${fs_path}/recon

	# export the subjects_dir to the folder desired, make sure there are no subject folders already here (recon-all won't like that!)
	export SUBJECTS_DIR="${fs_path}/recon"

	# execute freesurfer (as long as it hasn't previously done)
	if [ ! -d $SUBJECTS_DIR/${s} ]; then
		recon-all -i ${fs_path}/struct/$s/${s}_t1.nii.gz -s ${s} -all
	fi
	
	# Checkpoint for recon-all
	echo "Recon-all has finished" >> ${log_path}/5_surfProcessing_1_LOG.txt
	
}


# Exports the function
export -f surface_processing_1

# Create an array with subjects (as they are in preprocessed folder)
# s=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
s=(IGTTFJ_00074)

# Check the content of the subject array
echo ${s[@]}

# Run the analysis in parallel using GNU parallel
# Jobs is set to 0, which allows parallel to assign the jobs as it sees fit, and divide it across the CPUs itself
# Provide it with the name of the function, and specify it will take one argument, then provide this after the three colons

parallel --jobs 6 'surface_processing_1 {1}' ::: ${s[@]}