#!/bin/bash

# Directory paths
BASE_DIR="/Volumes/gdrive4tb/IGNITE/resting-state/preprocessed"
OUTPUT_DIR="/Volumes/gdrive4tb/IGNITE/resting-state"

ABS_FILE="${OUTPUT_DIR}/IGNITE_resting-state_motionOrig_abs.txt"
REL_FILE="${OUTPUT_DIR}/IGNITE_resting-state_motionOrig_rel.txt"

# Empty previous files if they exist
> "${ABS_FILE}"
> "${REL_FILE}"

# Add headers to output files
echo "SubjectID, MotionAbsMean" >> "${ABS_FILE}"
echo "SubjectID, MotionRelMean" >> "${REL_FILE}"

# Loop through each subject
for sub in $(ls "${BASE_DIR}"); do
    # Check if the directory actually exists before trying to read from it
    if [[ -d "${BASE_DIR}/${sub}/motionOrig" ]]; then

        # Read values from the files and append to the respective output files
        if [[ -f "${BASE_DIR}/${sub}/motionOrig/${sub}_motionOrig_abs_mean.rms" ]]; then
            motion_abs_mean=$(cat "${BASE_DIR}/${sub}/motionOrig/${sub}_motionOrig_abs_mean.rms")
            echo "${sub}, ${motion_abs_mean}" >> "${ABS_FILE}"
        fi

        if [[ -f "${BASE_DIR}/${sub}/motionOrig/${sub}_motionOrig_rel_mean.rms" ]]; then
            motion_rel_mean=$(cat "${BASE_DIR}/${sub}/motionOrig/${sub}_motionOrig_rel_mean.rms")
            echo "${sub}, ${motion_rel_mean}" >> "${REL_FILE}"
        fi
    fi
done

echo "Processing complete. Check the output directory for results."
