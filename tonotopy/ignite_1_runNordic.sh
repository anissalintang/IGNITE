#!/bin/bash

# The first step of pre-processing is to run NORDIC to lower the termal noise
# ref= https://www.nature.com/articles/s41467-021-25431-8
# Moeller 2021
data_path="/Volumes/gdrive4tb/IGNITE"

mkdir -p "/Volumes/gdrive4tb/IGNITE/tonotopy/log"
log_path="/Volumes/gdrive4tb/IGNITE/tonotopy/log"

# subj=($(ls /Volumes/gdrive4tb/IGNITE/data/nifti))
subj=(IGTTKA_00017)

###############################################################
# Preprocess only if functional data exist!
# This load the complex image data, not the imaginary nor real images
for s in ${subj[@]}; do
	# dat_tono=($(ls ${data_path}/data/nifti/${s}/*final_fMRI_MB2_sparse_tono*[^_]*.nii* | head -n 1))
    # dat_tono_j=($(ls ${data_path}/data/nifti/${s}/*final_fMRI_MB2_sparse_tono*[^_]*.json | head -n 1))
    # dat_tono_pe0=($(ls ${data_path}/data/nifti/${s}/*final_fMRI_MB2_sparse_pepolar_0_te35*[^_]*.nii* | head -n 1))
    # dat_tono_pe0_j=($(ls ${data_path}/data/nifti/${s}/*final_fMRI_MB2_sparse_pepolar_0_te35*[^_]*.json | head -n 1))
    # dat_tono_pe1=($(ls ${data_path}/data/nifti/${s}/*final_fMRI_MB2_sparse_pepolar1*[^_]*.nii* | head -n 1))
    # dat_tono_pe1_j=($(ls ${data_path}/data/nifti/${s}/*final_fMRI_MB2_sparse_pepolar1*[^_]*.json | head -n 1))

	# if [ -n "$dat_tono" ]; then

		#Make directories for the preprocessing files
		mkdir -p ${data_path}/tonotopy/preprocessed/$s
		analysis_path="/Volumes/gdrive4tb/IGNITE/tonotopy"

        # # Copying all the necessary files
		# cp $dat_tono ${analysis_path}/preprocessed/$s/${s}_sparse_tono_orig.nii.gz
        # cp $dat_tono_j ${analysis_path}/preprocessed/$s/${s}_sparse_tono_orig.json

        # cp $dat_tono_pe0 ${analysis_path}/preprocessed/$s/${s}_sparse_tono_pe0.nii.gz
        # cp $dat_tono_pe0_j ${analysis_path}/preprocessed/$s/${s}_sparse_tono_pe0.json

        # cp $dat_tono_pe1 ${analysis_path}/preprocessed/$s/${s}_sparse_tono_pe1.nii.gz
        # cp $dat_tono_pe1_j ${analysis_path}/preprocessed/$s/${s}_sparse_tono_pe1.json


		##############################################################
        files=($(ls ${analysis_path}/preprocessed/$s/${s}_sparse_tono_orig.nii.gz))
		
		echo "FILES = ${files[@]}"

 		for file in ${files[@]}; do
                matlab -batch "ARG = struct; \
                ARG.DIROUT = '${analysis_path}/preprocessed/${s}/'; \
                ARG.full_dynamic_range = 1; \
                ARG.magnitude_only = 1; \
                ARG.MP = 2; \
                NIFTI_NORDIC('$file',[],'${s}_sparse_tono_nordic',ARG)" -nojvm

        done

    # else
    #     echo "Sparse tonotopy image does not exist for ${s}"
	# fi

done