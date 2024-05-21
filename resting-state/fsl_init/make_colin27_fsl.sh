#!/bin/bash
## run this script with "sudo --preserve-env ./make_colin27_fsl.sh" if want to save the output path to "$FSLDIR/data/standard", otherwise just run normally "./make_colin27_fsl.sh"

in_path="./mni_colin27_1998_nifti"
out_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis"
export SUBJECTS_DIR="$FREESURFER_HOME/subjects"

# Copy and clean up colin27's t1;
if [ ! -f $out_path/colin27/t1.nii.gz ]; then
    mkdir -p $out_path/colin27
    
    fslmaths $in_path/colin27_t1_tal_lin -mas $in_path/colin27_t1_tal_lin_headmask $out_path/colin27/t1
    robustfov -i $out_path/colin27/t1 -r $out_path/colin27/t1

    fast -B --nopve $out_path/colin27/t1
    fwhm=2.5; sigma=$(bc -l <<< "$fwhm/(2*sqrt(2*l(2)))");
    susan $out_path/colin27/t1_restore -1 $sigma 3 1 0 $out_path/colin27/t1

    imrm $out_path/colin27/t1_*
fi

# register colin27 with mni152;
if [ ! -f $out_path/colin27/t12std.nii.gz ]; then
    bet $out_path/colin27/t1 $out_path/colin27/t1_brain -f 0.25

    flirt \
    -in $out_path/colin27/t1 \
    -ref $FSLDIR/data/standard/MNI152_T1_2mm \
    -omat $out_path/colin27/t12std.mat \
    -cost mutualinfo \
    -dof 12
    
    fnirt \
    --in=$out_path/colin27/t1 \
    --ref=$FSLDIR/data/standard/MNI152_T1_2mm \
    --refmask=$FSLDIR/data/standard/MNI152_T1_2mm_brain_mask_dil \
    --aff=$out_path/colin27/t12std.mat \
    --cout=$out_path/colin27/t12std_warp \
    --config=T1_2_MNI152_2mm \
    --warpres=10,10,10
    
    applywarp \
    -i $out_path/colin27/t1 \
    -r $FSLDIR/data/standard/MNI152_T1_1mm \
    -o $out_path/colin27/t12std \
    -w $out_path/colin27/t12std_warp
    
    invwarp \
    --ref=$out_path/colin27/t1 \
    --warp=$out_path/colin27/t12std_warp \
    --out=$out_path/colin27/std2t1_warp

fi

hemi=(lh rh)
# create anatomical probability maps in colin27 space;
if [ ! -f $out_path/colin27/anat/HO_HG_mask.nii.gz ]; then
    mkdir -p $out_path/colin27/anat

    # Extract the Heschl's Gyrus
    fslmaths $FSLDIR/data/atlases/HarvardOxford/HarvardOxford-cort-maxprob-thr25-2mm.nii.gz -thr 45 -uthr 45 $out_path/colin27/anat/HO_HG_mask.nii.gz

    # Extract the individual hemispheres
    line=($(fslinfo $out_path/colin27/anat/HO_HG_mask.nii.gz | grep dim1)); dim1=${line[1]}

    fslmaths $out_path/colin27/anat/HO_HG_mask.nii.gz -roi $(($dim1/2)) $(($dim1/2)) 0 -1 0 -1 0 -1 $out_path/colin27/anat/HO_HG_lh_mask.nii.gz
    fslmaths $out_path/colin27/anat/HO_HG_mask.nii.gz -roi 0 $(($dim1/2)) 0 -1 0 -1 0 -1 $out_path/colin27/anat/HO_HG_rh_mask.nii.gz    

    # Binarised the mask
    fslmaths $out_path/colin27/anat/HO_HG_lh_mask.nii.gz -bin $out_path/colin27/anat/HO_HG_lh_mask.nii.gz
    fslmaths $out_path/colin27/anat/HO_HG_rh_mask.nii.gz -bin $out_path/colin27/anat/HO_HG_rh_mask.nii.gz

    applywarp \
    -i $out_path/colin27/anat/HO_HG_lh_mask.nii.gz \
    -r $out_path/colin27/t1 \
    -o $out_path/colin27/anat/HO_HG_lh_mask.nii.gz \
    -w $out_path/colin27/std2t1_warp

    applywarp \
    -i $out_path/colin27/anat/HO_HG_rh_mask.nii.gz \
    -r $out_path/colin27/t1 \
    -o $out_path/colin27/anat/HO_HG_rh_mask.nii.gz \
    -w $out_path/colin27/std2t1_warp

    # Extract the Planum Temporale
    fslmaths $FSLDIR/data/atlases/HarvardOxford/HarvardOxford-cort-maxprob-thr25-2mm.nii.gz -thr 46 -uthr 46 $out_path/colin27/anat/HO_PT_mask.nii.gz

    # Extract the individual hemispheres
    line=($(fslinfo $out_path/colin27/anat/HO_PT_mask.nii.gz | grep dim1)); dim1=${line[1]}

    fslmaths $out_path/colin27/anat/HO_PT_mask.nii.gz -roi $(($dim1/2)) $(($dim1/2)) 0 -1 0 -1 0 -1 $out_path/colin27/anat/HO_PT_lh_mask.nii.gz
    fslmaths $out_path/colin27/anat/HO_PT_mask.nii.gz -roi 0 $(($dim1/2)) 0 -1 0 -1 0 -1 $out_path/colin27/anat/HO_PT_rh_mask.nii.gz

    # Binarised the mask
    fslmaths $out_path/colin27/anat/HO_PT_lh_mask.nii.gz -bin $out_path/colin27/anat/HO_PT_lh_mask.nii.gz
    fslmaths $out_path/colin27/anat/HO_PT_rh_mask.nii.gz -bin $out_path/colin27/anat/HO_PT_rh_mask.nii.gz

    applywarp \
    -i $out_path/colin27/anat/HO_PT_lh_mask.nii.gz \
    -r $out_path/colin27/t1 \
    -o $out_path/colin27/anat/HO_PT_lh_mask.nii.gz \
    -w $out_path/colin27/std2t1_warp

    applywarp \
    -i $out_path/colin27/anat/HO_PT_rh_mask.nii.gz \
    -r $out_path/colin27/t1 \
    -o $out_path/colin27/anat/HO_PT_rh_mask.nii.gz \
    -w $out_path/colin27/std2t1_warp

    # Extract the Occipital Pole
    fslmaths $FSLDIR/data/atlases/HarvardOxford/HarvardOxford-cort-maxprob-thr25-2mm.nii.gz -thr 48 -uthr 48 $out_path/colin27/anat/HO_OcPole_mask.nii.gz

    # Extract the individual hemispheres
    line=($(fslinfo $out_path/colin27/anat/HO_OcPole_mask.nii.gz | grep dim1)); dim1=${line[1]}

    fslmaths $out_path/colin27/anat/HO_OcPole_mask.nii.gz -roi $(($dim1/2)) $(($dim1/2)) 0 -1 0 -1 0 -1 $out_path/colin27/anat/HO_OcPole_lh_mask.nii.gz
    fslmaths $out_path/colin27/anat/HO_OcPole_mask.nii.gz -roi 0 $(($dim1/2)) 0 -1 0 -1 0 -1 $out_path/colin27/anat/HO_OcPole_rh_mask.nii.gz

    # Binarised the mask
    fslmaths $out_path/colin27/anat/HO_OcPole_lh_mask.nii.gz -bin $out_path/colin27/anat/HO_OcPole_lh_mask.nii.gz
    fslmaths $out_path/colin27/anat/HO_OcPole_rh_mask.nii.gz -bin $out_path/colin27/anat/HO_OcPole_rh_mask.nii.gz

    applywarp \
    -i $out_path/colin27/anat/HO_OcPole_lh_mask.nii.gz \
    -r $out_path/colin27/t1 \
    -o $out_path/colin27/anat/HO_OcPole_lh_mask.nii.gz \
    -w $out_path/colin27/std2t1_warp

    applywarp \
    -i $out_path/colin27/anat/HO_OcPole_rh_mask.nii.gz \
    -r $out_path/colin27/t1 \
    -o $out_path/colin27/anat/HO_OcPole_rh_mask.nii.gz \
    -w $out_path/colin27/std2t1_warp
    
fi

# Extract V1 from the Juelich Atlas
fslmaths $FSLDIR/data/atlases/Juelich/Juelich-maxprob-thr25-2mm.nii.gz -thr 81 -uthr 81 $out_path/colin27/anat/Jue_V1_lh_mask.nii.gz
fslmaths $FSLDIR/data/atlases/Juelich/Juelich-maxprob-thr25-2mm.nii.gz -thr 82 -uthr 82 $out_path/colin27/anat/Jue_V1_rh_mask.nii.gz

# Binarised the mask
fslmaths $out_path/colin27/anat/Jue_V1_lh_mask.nii.gz -bin $out_path/colin27/anat/Jue_V1_lh_mask.nii.gz
fslmaths $out_path/colin27/anat/Jue_V1_rh_mask.nii.gz -bin $out_path/colin27/anat/Jue_V1_rh_mask.nii.gz

applywarp \
-i $out_path/colin27/anat/Jue_V1_lh_mask.nii.gz \
-r $out_path/colin27/t1 \
-o $out_path/colin27/anat/Jue_V1_lh_mask.nii.gz \
-w $out_path/colin27/std2t1_warp

applywarp \
-i $out_path/colin27/anat/Jue_V1_rh_mask.nii.gz \
-r $out_path/colin27/t1 \
-o $out_path/colin27/anat/Jue_V1_rh_mask.nii.gz \
-w $out_path/colin27/std2t1_warp


# Extract V2 from the Juelich Atlas
fslmaths $FSLDIR/data/atlases/Juelich/Juelich-maxprob-thr25-2mm.nii.gz -thr 83 -uthr 83 $out_path/colin27/anat/Jue_V2_lh_mask.nii.gz
fslmaths $FSLDIR/data/atlases/Juelich/Juelich-maxprob-thr25-2mm.nii.gz -thr 84 -uthr 84 $out_path/colin27/anat/Jue_V2_rh_mask.nii.gz

# Binarised the mask
fslmaths $out_path/colin27/anat/Jue_V2_lh_mask.nii.gz -bin $out_path/colin27/anat/Jue_V2_lh_mask.nii.gz
fslmaths $out_path/colin27/anat/Jue_V2_rh_mask.nii.gz -bin $out_path/colin27/anat/Jue_V2_rh_mask.nii.gz

applywarp \
-i $out_path/colin27/anat/Jue_V2_lh_mask.nii.gz \
-r $out_path/colin27/t1 \
-o $out_path/colin27/anat/Jue_V2_lh_mask.nii.gz \
-w $out_path/colin27/std2t1_warp

applywarp \
-i $out_path/colin27/anat/Jue_V2_rh_mask.nii.gz \
-r $out_path/colin27/t1 \
-o $out_path/colin27/anat/Jue_V2_rh_mask.nii.gz \
-w $out_path/colin27/std2t1_warp



exit 0
