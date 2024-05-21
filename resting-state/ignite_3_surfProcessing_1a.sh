#!/bin/bash

# 1. check whether fsaverage_sym already exists in the current SUBJECTS_DIR; 
# if not, create a soft link (shortcut/alias) to the relevant folder in the freesurfer app folder:

fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"
export SUBJECTS_DIR="${fs_path}/recon"

if [ ! -d $SUBJECTS_DIR/fsaverage_sym ]; then
    ln -s $FREESURFER_HOME/subjects/fsaverage_sym $SUBJECTS_DIR
fi

# 2. create fsavg_sym registrations:

xhemi(){
    fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface";s=$1
    export SUBJECTS_DIR="${fs_path}/recon"

    if [ ! -d $SUBJECTS_DIR/$s/xhemi ]; then
        surfreg --s $s --t fsaverage_sym --lh --no-annot
        surfreg --s $s --t fsaverage_sym --lh --xhemi --no-annot
    fi

}
# Exports the function
export -f xhemi

# Create an array with subjects (as they are in preprocessed folder)
s=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# s=(IGNTBP_00072)

# Check the content of the subject array
echo ${s[@]}

# Run the analysis in parallel using GNU parallel
# Jobs is set to 0, which allows parallel to assign the jobs as it sees fit, and divide it across the CPUs itself
# Provide it with the name of the function, and specify it will take one argument, then provide this after the three colons

parallel --jobs 6 'xhemi {1}' ::: ${s[@]}