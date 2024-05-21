#!/bin/bash
### Make probabilistic activation map and cortical patch ###

# Use the path of already projected data from resting-state
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"
export SUBJECTS_DIR="${fs_path}/recon"

# This is the path to safe the registration and projected slab fmri to surface space
surf_path="/Volumes/gdrive4tb/IGNITE/tonotopy/surface"

# subj=($(ls /Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed))
# all young healthy hearing subjects (12) + normal hearing with tinnitus:
subj=(IGNTFA_00065 IGNTBR_00075 IGNTCA_00067 IGNTCK_00066 IGNTFM_00060 IGNTGS_00049 IGNTIV_00045 IGNTLX_00069 IGNTMN_00051 IGNTNF_00054 IGNTOH_00059 IGNTPO_00071 IGTTCW_00010 IGTTBA_00052 IGTTFJ_00074 IGTTHA_00042 IGTTHA_00070 IGTTKA_00017 IGTTLC_00002 IGTTMG_00032 IGTTRK_00006 IGTTSM_00028 IGTTSM_00050 IGTTSM_00058 IGTTWL_00073)


if [ ! -d  /Volumes/gdrive4tb/IGNITE/tonotopy/surface/probActMap ]; then
        mkdir -p /Volumes/gdrive4tb/IGNITE/tonotopy/surface/probActMap
fi

hemi=(lh rh)

## Make probabilistic activation map -FSSYM
if [ ! -f $surf_path/probActMap/probActMap.lh.fssym.mgz ]; then
    # merge zfstat maps across hemispheres;

    files=()
    for s in ${subj[@]}; do
        files+=($surf_path/projected/$s/e_8_smoothed5.fsf/?h.zfstat*.fssym.mgz)
    done 
    K=${#files[@]};

    cmd=$(printf "fsmerge(%s'%s','%s','t')" $(printf "'%s'," ${files[@]:0:$((K-1))}) ${files[$((K-1))]} "$surf_path/probActMap/probActMap.lh.fssym.mgz")
    matlab -batch $cmd -nojvm

    # echo "files " ${files[@]}
    # echo "cmd " $cmd

    # Calculate activation probabilities for pval;
    pval=0.05; zval=$(ptoz $pval)
    matlab -batch "fsmaths('$surf_path/probActMap/probActMap.lh.fssym.mgz','thr',$zval,'$surf_path/probActMap/probActMap.lh.fssym.mgz')" -nojvm
    matlab -batch "fsmaths('$surf_path/probActMap/probActMap.lh.fssym.mgz','bin','$surf_path/probActMap/probActMap.lh.fssym.mgz')" -nojvm
    matlab -batch "fsmaths('$surf_path/probActMap/probActMap.lh.fssym.mgz','Tmean','$surf_path/probActMap/probActMap.lh.fssym.mgz')" -nojvm
    matlab -batch "fsmaths('$surf_path/probActMap/probActMap.lh.fssym.mgz','mul',100,'$surf_path/probActMap/probActMap.lh.fssym.mgz')" -nojvm

    # smooth with fwhm = 5 mm;
    fwhm=5; 
    mri_surf2surf \
    --sval $surf_path/probActMap/probActMap.lh.fssym.mgz \
    --tval $surf_path/probActMap/probActMap_sm.lh.fssym.mgz \
    --s fsaverage_sym \
    --hemi lh \
    --fwhm $fwhm \
    --cortex
fi

# Make patch for FSSYM;
# # Create temporal lobe mask for FSSYM
# mri_surf2surf \
# --srcsubject fsaverage \
# --trgsubject fsaverage_sym \
# --hemi lh \
# --sval /Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/temporalLobe_mask_lh.mgh \
# --tval /Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/temporalLobe_mask_lh_fssym.mgh

# mkdir -p $surf_path/patch
# # if [ ! -f $surf_path/patch/surf_fssym.mat ] || [ ! -f $surf_path/patch/patch_fssym.mat ]; then
#     matlab -batch "make_patch_fssym('$surf_path',35,0,1,1)" -nojvm
    # -70,0,1 (50 thr)
    # -140,0,1 (25 thr)
    # 0,1,1 (35 thr)
# fi

# check patch orientation in matlab using check_patch(pth,AZ,FLIPX,FLIPY);
# start by setting all arguments to zero;
# after determining AZ, FLIPX and FLIPY, run make_patch again using these values;
# if the roi needs editing, apply "edit_roi.m" in matlab;







# # Make patch for FSAVG_LH;
# if [ ! -f $surf_path/patch/surf_fsavg_lh.mat ] || [ ! -f $surf_path/patch/patch_fsavg_lh.mat ]; then
#     matlab -batch "make_patch_fsavg_lh('$surf_path',0.5,180,1,0)" -nojvm
# fi

# # Make patch for FSAVG_RH;
# if [ ! -f $surf_path/patch/surf_fsavg_rh.mat ] || [ ! -f $surf_path/patch/patch_fsavg_rh.mat ]; then
#     matlab -batch "make_patch_fsavg_rh('$surf_path',0.5,-10,1,0)" -nojvm
# fi

# exit 0

# # Make probabilistic activation map -FSAVERAGE
# # Loop over hemispheres
# for h in ${hemi[@]}; do

#     # Compile list of all hemisphere-specific zfstat*.fsavg.mgz files across subjects
#     for s in ${subj[@]}; do
#         for f in $surf_path/projected/$s/e_8.fsf/${h}.zfstat*.fsavg.mgz; do
#             files+=($f)
#         done
#     done

#     K=${#files[@]}

#     # Check if the output file already exists, if not, merge
#     if [ ! -f "$surf_path/probActMap/probActMap.${h}.fsavg.mgz" ]; then
#         # Construct the merging command for Matlab's fsmerge function
#         cmd=$(printf "fsmerge(%s'%s','%s','t')" $(printf "'%s'," ${files[@]:0:$((K-1))}) ${files[$((K-1))]} "$surf_path/probActMap/probActMap.${h}.fsavg.mgz")
#         matlab -batch $cmd -nojvm
#     fi

#     # Calculate activation probabilities for pval;
#     pval=0.05; zval=$(ptoz $pval)
#     matlab -batch "fsmaths('$surf_path/probActMap/probActMap.${h}.fsavg.mgz','thr',$zval,'$surf_path/probActMap/probActMap.${h}.fsavg.mgz')" -nojvm
#     matlab -batch "fsmaths('$surf_path/probActMap/probActMap.${h}.fsavg.mgz','bin','$surf_path/probActMap/probActMap.${h}.fsavg.mgz')" -nojvm
#     matlab -batch "fsmaths('$surf_path/probActMap/probActMap.${h}.fsavg.mgz','Tmean','$surf_path/probActMap/probActMap.${h}.fsavg.mgz')" -nojvm
#     matlab -batch "fsmaths('$surf_path/probActMap/probActMap.${h}.fsavg.mgz','mul',100,'$surf_path/probActMap/probActMap.${h}.fsavg.mgz')" -nojvm

#     # smooth with fwhm = 5 mm;
#     fwhm=5; 
#     mri_surf2surf \
#     --sval $surf_path/probActMap/probActMap.${h}.fsavg.mgz \
#     --tval $surf_path/probActMap/probActMap.${h}.fsavg.mgz \
#     --s fsaverage \
#     --hemi ${h} \
#     --fwhm $fwhm \
#     --cortex

# done
