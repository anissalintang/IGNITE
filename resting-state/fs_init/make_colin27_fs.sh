#!/bin/bash
## run this script with "sudo --preserve-env ./make_colin27_fs.sh" if want to save the output path to "$FSLDIR/data/standard", otherwise just run normally "./make_colin27_fs.sh"

colin_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/colin27"

mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/colin27_fsavg"

out_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/colin27_fsavg"
export SUBJECTS_DIR="${out_path}"

hemi=(lh rh)

# reconstruct colin27 surface;
if [ ! -d $SUBJECTS_DIR/colin27 ]; then
    recon-all -i ${colin_path}/t1.nii.gz -s colin27 -all
fi


# project anatomical maps to fsaverage;
    for h in ${hemi[@]}; do
        # Heschl's Gyrus
        mri_vol2surf \
        --src ${colin_path}/anat/HO_HG_${h}_mask.nii.gz \
        --o $SUBJECTS_DIR/HO_HG_${h}_mask_fsavg.mgz \
        --hemi ${h} \
        --projfrac-max 0 1 0.1 \
        --regheader colin27

        mris_apply_reg \
        --src $SUBJECTS_DIR/HO_HG_${h}_mask_fsavg.mgz \
        --o $SUBJECTS_DIR/HO_HG_${h}_mask_fsavg.mgz \
        --streg $SUBJECTS_DIR/colin27/surf/${h}.fsaverage.sphere.reg $SUBJECTS_DIR/fsaverage/surf/${h}.sphere.reg

        # Planum Temporale
        mri_vol2surf \
        --src ${colin_path}/anat/HO_PT_${h}_mask.nii.gz \
        --o $SUBJECTS_DIR/HO_PT_${h}_mask_fsavg.mgz \
        --hemi ${h} \
        --projfrac-max 0 1 0.1 \
        --regheader colin27

        mris_apply_reg \
        --src $SUBJECTS_DIR/HO_PT_${h}_mask_fsavg.mgz \
        --o $SUBJECTS_DIR/HO_PT_${h}_mask_fsavg.mgz \
        --streg $SUBJECTS_DIR/colin27/surf/${h}.fsaverage.sphere.reg $SUBJECTS_DIR/fsaverage/surf/${h}.sphere.reg

        # Occipital Pole
        mri_vol2surf \
        --src ${colin_path}/anat/HO_OcPole_${h}_mask.nii.gz \
        --o $SUBJECTS_DIR/HO_OcPole_${h}_mask_fsavg.mgz \
        --hemi ${h} \
        --projfrac-max 0 1 0.1 \
        --regheader colin27

        mris_apply_reg \
        --src $SUBJECTS_DIR/HO_OcPole_${h}_mask_fsavg.mgz \
        --o $SUBJECTS_DIR/HO_OcPole_${h}_mask_fsavg.mgz \
        --streg $SUBJECTS_DIR/colin27/surf/${h}.fsaverage.sphere.reg $SUBJECTS_DIR/fsaverage/surf/${h}.sphere.reg

        # V1 
        mri_vol2surf \
        --src ${colin_path}/anat/Jue_V1_${h}_mask.nii.gz \
        --o $SUBJECTS_DIR/Jue_V1_${h}_mask_fsavg.mgz \
        --hemi ${h} \
        --projfrac-max 0 1 0.1 \
        --regheader colin27

        mris_apply_reg \
        --src $SUBJECTS_DIR/Jue_V1_${h}_mask_fsavg.mgz \
        --o $SUBJECTS_DIR/Jue_V1_${h}_mask_fsavg.mgz \
        --streg $SUBJECTS_DIR/colin27/surf/${h}.fsaverage.sphere.reg $SUBJECTS_DIR/fsaverage/surf/${h}.sphere.reg

        # V2
        mri_vol2surf \
        --src ${colin_path}/anat/Jue_V2_${h}_mask.nii.gz \
        --o $SUBJECTS_DIR/Jue_V2_${h}_mask_fsavg.mgz \
        --hemi ${h} \
        --projfrac-max 0 1 0.1 \
        --regheader colin27

        mris_apply_reg \
        --src $SUBJECTS_DIR/Jue_V2_${h}_mask_fsavg.mgz \
        --o $SUBJECTS_DIR/Jue_V2_${h}_mask_fsavg.mgz \
        --streg $SUBJECTS_DIR/colin27/surf/${h}.fsaverage.sphere.reg $SUBJECTS_DIR/fsaverage/surf/${h}.sphere.reg

done


exit 0
