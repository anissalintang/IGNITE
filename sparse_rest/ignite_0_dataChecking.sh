#!/bin/bash

data_checking () {
    data_path="/Volumes/gdrive4tb/IGNITE";s=$1

    mkdir -p "/Volumes/gdrive4tb/IGNITE/sparse_rest/datChecking"
    datChecking_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/datChecking"

    if ls ${data_path}/data/nifti/${s}/*final_fMRI_MB2_sparse_rest*.nii.gz 1> /dev/null 2>&1; then
        echo "Sparse rest image exists for ${s}" >> ${datChecking_path}/datChecking.txt
    else 
        echo "Sparse rest image DOES NOT exist for ${s}" >> ${datChecking_path}/datChecking.txt
    fi

}



# Exports the function
export -f data_checking

# Create an array with subjects (as they are in nifti folder)
s=($(ls /Volumes/gdrive4tb/IGNITE/data/nifti))

# Check the content of the subject array
echo ${s[@]}

# Run the analysis in parallel using GNU parallel
# Jobs is set to 0, which allows parallel to assign the jobs as it sees fit, and divide it across the CPUs itself
# Provide it with the name of the function, and specify it will take one argument, then provide this after the three colons

parallel --jobs 0 'data_checking {1}' ::: ${s[@]}