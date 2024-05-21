#!/bin/bash

# Directory paths
BASE_DIR="/Volumes/gdrive4tb/IGNITE/resting-state/preprocessed"
OUTPUT_DIR="/Volumes/gdrive4tb/IGNITE/resting-state"

ABS_FILE_TT="${OUTPUT_DIR}/IGNITE_resting-state_motionOrig_abs_TT.txt"
ABS_FILE_NT="${OUTPUT_DIR}/IGNITE_resting-state_motionOrig_abs_NT.txt"
REL_FILE_TT="${OUTPUT_DIR}/IGNITE_resting-state_motionOrig_rel_TT.txt"
REL_FILE_NT="${OUTPUT_DIR}/IGNITE_resting-state_motionOrig_rel_NT.txt"

# Empty previous files if they exist
> "${ABS_FILE_TT}"
> "${ABS_FILE_NT}"
> "${REL_FILE_TT}"
> "${REL_FILE_NT}"

# Loop through each subject
for sub in $(ls "${BASE_DIR}"); do
    # Check if the directory actually exists before trying to read from it
    if [[ -d "${BASE_DIR}/${sub}/motionOrig" ]]; then
        
        # Check if the subject contains TT or NT and set the appropriate output file
        if [[ ${sub} == *TT* ]]; then
            ABS_FILE=${ABS_FILE_TT}
            REL_FILE=${REL_FILE_TT}
        elif [[ ${sub} == *NT* ]]; then
            ABS_FILE=${ABS_FILE_NT}
            REL_FILE=${REL_FILE_NT}
        else
            continue  # Skip to next iteration if neither TT nor NT is found
        fi

        # Read values from the files and append to the respective output files
        if [[ -f "${BASE_DIR}/${sub}/motionOrig/${sub}_motionOrig_abs_mean.rms" ]]; then
            cat "${BASE_DIR}/${sub}/motionOrig/${sub}_motionOrig_abs_mean.rms" >> "${ABS_FILE}"
        fi

        if [[ -f "${BASE_DIR}/${sub}/motionOrig/${sub}_motionOrig_rel_mean.rms" ]]; then
            cat "${BASE_DIR}/${sub}/motionOrig/${sub}_motionOrig_rel_mean.rms" >> "${REL_FILE}"
        fi
    fi
done

echo "Processing complete. Check the output directory for results."
