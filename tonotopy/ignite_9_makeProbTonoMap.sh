#!/bin/bash
### Extract signal changes and make probabilistic tonotopic maps ###

surf_path="/Volumes/gdrive4tb/IGNITE/tonotopy/surface"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"
export SUBJECTS_DIR="${fs_path}/recon"

subj=($(ls /Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed))
# subj=(IGNTBP_00072)

hemi=(lh rh)

# # Extract signal changes for patch vertices;
# if [ ! -f $surf_path/patch/schavg.mat ]; then
#     matlab -batch "xtrct_sigch('$surf_path')" -nojvm
# fi


# # Make individual pfi (preferred-frequency-index) maps;
# for s in ${subj[@]}; do
#     if [ -z "$(ls 2>/dev/null $surf_path/projected/$s/e_8.fsf/*.pfi*.mgz)" ]; then
#         for h in ${hemi[@]}; do
#             matlab -batch "fsmaths('$surf_path/projected/$s/e_8.fsf/$h.sigch.avg.lh.fssym.mgz','Tmaxn','$surf_path/projected/$s/e_8.fsf/$h.pfi.lh.fssym.mgz')" -nojvm
#             matlab -batch "fsmaths('$surf_path/projected/$s/e_16.fsf/$h.sigch.avg.lh.fssym.mgz','Tmaxn','$surf_path/projected/$s/e_16.fsf/$h.pfi.lh.fssym.mgz')" -nojvm
#         done
#     fi
# done

# Make max-prob pfi maps; from NH only
# if [ ! -d  /Volumes/gdrive4tb/IGNITE/tonotopy/surface/pfimax ]; then
#         mkdir -p /Volumes/gdrive4tb/IGNITE/tonotopy/surface/pfimax
# fi

# subjs=(IGNTFA_00065 IGNTBR_00075 IGNTCA_00067 IGNTCK_00066 IGNTFM_00060 IGNTGS_00049 IGNTIV_00045 IGNTLX_00069 IGNTMN_00051 IGNTNF_00054 IGNTOH_00059 IGNTPO_00071 IGTTCW_00010 IGTTBA_00052 IGTTFJ_00074 IGTTHA_00042 IGTTHA_00070 IGTTKA_00017 IGTTLC_00002 IGTTMG_00032 IGTTRK_00006 IGTTSM_00028 IGTTSM_00050 IGTTSM_00058 IGTTWL_00073)
# 34 nh
subjs=(IGNTBP_00072 IGNTBR_00075 IGNTCA_00067 IGNTCJ_00018 IGNTCK_00066 IGNTFA_00065 IGNTFJ_00015 IGNTFM_00060 IGNTGS_00049 IGNTHS_00068 IGNTIV_00045 IGNTLX_00069 IGNTMN_00051 IGNTNF_00054 IGNTOH_00059 IGNTPO_00071 IGTTAS_00062 IGTTBA_00052 IGTTCW_00010 IGTTFJ_00074 IGTTHA_00042 IGTTHG_00064 IGTTKA_00017 IGTTKK_00041 IGTTLC_00002 IGTTMD_00004 IGTTMG_00032 IGTTPS_00044 IGTTRE_00043 IGTTRK_00006 IGTTSM_00028 IGTTSM_00050 IGTTSM_00058 IGTTWL_00073)
if [ ! -f $surf_path/pfimax/NH_pfimax_8.lh.fssym.mgz ]; then
    files=()
    for s in ${subjs[@]}; do
        files+=($surf_path/projected/$s/e_8.fsf/?h.pfi*.mgz)
    done 
    K=${#files[@]};
    cmd=$(printf "fsmerge(%s'%s','%s','t')" $(printf "'%s'," ${files[@]:0:$((K-1))}) ${files[$((K-1))]} "$surf_path/pfimax/NH_pfimax_8.lh.fssym.mgz")
    matlab -batch $cmd -nojvm
    matlab -batch "make_pfimax('$surf_path/pfimax/NH_pfimax_8.lh.fssym.mgz','$surf_path/pfimax/NH_pfimax_8.lh.fssym.mgz')" -nojvm
fi

fwhm=5;
    mri_surf2surf \
    --sval $surf_path/pfimax/NH_pfimax_8.lh.fssym.mgz \
    --tval $surf_path/pfimax/NH_pfimax_8.lh_sm.fssym.mgz \
    --s fsaverage_sym \
    --hemi lh \
    --fwhm $fwhm \
    --cortex


# # Make max-prob pfi maps; from HL only
# # 14 hl
# subjs=(IGNTFB_00027 IGNTMA_00025 IGTTAJ_00061 IGTTBA_00003 IGTTBC_00014 IGTTDA_00063 IGTTHA_00070 IGTTJG_00008 IGTTJI_00009 IGTTMD_00029 IGTTMD_00076 IGTTPG_00055 IGTTPP_00040 IGTTSJ_00007)

# if [ ! -f $surf_path/pfimax/HL_pfimax_8.lh.fssym.mgz ]; then
#     files=()
#     for s in ${subjs[@]}; do
#         files+=($surf_path/projected/$s/e_8.fsf/?h.pfi*.mgz)
#     done 
#     K=${#files[@]};
#     cmd=$(printf "fsmerge(%s'%s','%s','t')" $(printf "'%s'," ${files[@]:0:$((K-1))}) ${files[$((K-1))]} "$surf_path/pfimax/HL_pfimax_8.lh.fssym.mgz")
#     matlab -batch $cmd -nojvm
#     matlab -batch "make_pfimax('$surf_path/pfimax/HL_pfimax_8.lh.fssym.mgz','$surf_path/pfimax/HL_pfimax_8.lh.fssym.mgz')" -nojvm
# fi

# fwhm=5;
#     mri_surf2surf \
#     --sval $surf_path/pfimax/HL_pfimax_8.lh.fssym.mgz \
#     --tval $surf_path/pfimax/HL_pfimax_8_sm.lh.fssym.mgz \
#     --s fsaverage_sym \
#     --hemi lh \
#     --fwhm $fwhm \
#     --cortex


# # Make jack-knife max-prob pfi maps for individual hemispheres; NH only
# # 34 nh
# subjs=(IGNTBP_00072 IGNTBR_00075 IGNTCA_00067 IGNTCJ_00018 IGNTCK_00066 IGNTFA_00065 IGNTFJ_00015 IGNTFM_00060 IGNTGS_00049 IGNTHS_00068 IGNTIV_00045 IGNTLX_00069 IGNTMN_00051 IGNTNF_00054 IGNTOH_00059 IGNTPO_00071 IGTTAS_00062 IGTTBA_00052 IGTTCW_00010 IGTTFJ_00074 IGTTHA_00042 IGTTHG_00064 IGTTKA_00017 IGTTKK_00041 IGTTLC_00002 IGTTMD_00004 IGTTMG_00032 IGTTPS_00044 IGTTRE_00043 IGTTRK_00006 IGTTSM_00028 IGTTSM_00050 IGTTSM_00058 IGTTWL_00073)

# files=()
# for s in ${subjs[@]}; do
#     files+=($surf_path/projected/$s/e_8.fsf/?h.pfi*.mgz)
# done

# # echo ${files[@]}

# for subj in ${subjs[@]}; do
#     if [ ! -f $surf_path/projected/$subj/pfimax.lh.fssym.mgz ]; then
#         i=0; echo 'i= ' $i
#         for file in ${files[@]}; do
#             if [[ $file != *$subj* ]]; then
#                 i=$((i+1))
#                 echo 'i2 = ' $i
#                 echo 'file = ' $file

#                 if [ $i -eq 1 ]; then
#                     cp $file $surf_path/projected/$subj/pfimax.lh.fssym.mgz
#                 else
#                     matlab -batch "fsmerge('$surf_path/projected/$subj/pfimax.lh.fssym.mgz','$file','$surf_path/projected/$subj/pfimax.lh.fssym.mgz','t')" -nojvm
#                 fi
#             fi
#         done
#         matlab -batch "make_pfimax('$surf_path/projected/$subj/pfimax.lh.fssym.mgz','$surf_path/projected/$subj/pfimax.lh.fssym.mgz')" -nojvm
#     fi
# done


# # Make jack-knife max-prob pfi maps; from NH only

# files=()
# for s in ${subjs[@]}; do
#     files+=($surf_path/projected/$s/e_8.fsf/?h.pfi*.mgz)
# done

# for s in ${subjs[@]}; do
#     if [ ! -f $surf_path/pfimax/pfimax_8_jack.lh.fssym.mgz ]; then
#         echo ${files[@]}

#         i=0; for file in ${files[@]}; do
#             if [[ $file != *$s* ]]; then
#                 i=$((i+1))
#                 if [ $i -eq 1 ]; then
#                     cp $file $surf_path/pfimax/pfimax_8_jack.lh.fssym.mgz
#                 else
#                     matlab -batch "fsmerge('$surf_path/pfimax/pfimax_8_jack.lh.fssym.mgz','$file','$surf_path/pfimax/pfimax_8_jack.lh.fssym.mgz','t')" -nojvm
#                 fi
#             fi
#         done
#         matlab -batch "make_pfimax('$surf_path/pfimax/pfimax_8_jack.lh.fssym.mgz','$surf_path/pfimax/pfimax_8_jack.lh.fssym.mgz')" -nojvm
#     fi
# done


# fwhm=5;
#     mri_surf2surf \
#     --sval $surf_path/pfimax/pfimax_8_jack.lh.fssym.mgz \
#     --tval $surf_path/pfimax/pfimax_8_jack_smoothed.lh.fssym.mgz \
#     --s fsaverage_sym \
#     --hemi lh \
#     --fwhm $fwhm \
#     --cortex
