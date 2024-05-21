#!/bin/bash

# Plot the flat map of ALFF, ALFF norm, and ReHo

patch_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/patch"
alff_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/stimEffect/smooth5"
reho_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/stimEffect/smooth5"
output_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/keyFigures"

AZ=0
flipx=0
flipy=0

# ======================================================================= #
#for ALFF use clim([0, 1.5]);

# alff_orig_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFFall/merge_mean"

# # ALFF noTin
# matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${alff_orig_path}/allSubj_lh_ALFFall_merged_mean_noTin_smooth5.mgz','${alff_orig_path}/allSubj_rh_ALFFall_merged_mean_noTin_smooth5.mgz','${output_path}/flatMap_ALFFall_noTin.png')"

# # ALFF tin
# matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${alff_orig_path}/allSubj_lh_ALFFall_merged_mean_Tin_smooth5.mgz','${alff_orig_path}/allSubj_rh_ALFFall_merged_mean_Tin_smooth5.mgz','${output_path}/flatMap_ALFFall_Tin.png')"

# ALFF tin-noTin, use clim(0, 0.5)
alff_tinEff_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFFall/tinEffect/smooth5"
matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${alff_tinEff_path}/ALFF_lh_tinEffect_tin_noTin_smooth5.mgz','${alff_tinEff_path}/ALFF_rh_tinEffect_tin_noTin_smooth5.mgz','${output_path}/flatMap_ALFFall_tin-noTin.png')"

# ======================================================================= #
#for ReHo use clim([0, 0.1]);

# reho_orig_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/merge_mean"

# # ReHo noTin --rest
# matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${reho_orig_path}/allSubj_lh_ReHo_merged_mean_noTin_rest_smooth5.mgz','${reho_orig_path}/allSubj_rh_ReHo_merged_mean_noTin_rest_smooth5.mgz','${output_path}/flatMap_ReHo_noTin_rest.png')"

# # ReHo tin --rest
# matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${reho_orig_path}/allSubj_lh_ReHo_merged_mean_Tin_rest_smooth5.mgz','${reho_orig_path}/allSubj_rh_ReHo_merged_mean_Tin_rest_smooth5.mgz','${output_path}/flatMap_ReHo_Tin_rest.png')"

# # ReHo noTin --vis
# matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${reho_orig_path}/allSubj_lh_ReHo_merged_mean_noTin_vis_smooth5.mgz','${reho_orig_path}/allSubj_rh_ReHo_merged_mean_noTin_vis_smooth5.mgz','${output_path}/flatMap_ReHo_noTin_vis.png')"

# # ReHo tin --vis
# matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${reho_orig_path}/allSubj_lh_ReHo_merged_mean_Tin_vis_smooth5.mgz','${reho_orig_path}/allSubj_rh_ReHo_merged_mean_Tin_vis_smooth5.mgz','${output_path}/flatMap_ReHo_Tin_vis.png')"

# ======================================================================= #
#for ALFF use clim([-0.15, 0.1]);
# # ALFF VS_NS TIN
# matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${alff_path}/ALFF_lh_stimEffect_NS_VS_TIN_smooth5.mgz','${alff_path}/ALFF_rh_stimEffect_NS_VS_TIN_smooth5.mgz','${output_path}/flatMap_ALFF_vs_ns_TIN.png')"

# # ALFF VS_NS noTIN
# matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${alff_path}/ALFF_lh_stimEffect_NS_VS_noTIN_smooth5.mgz','${alff_path}/ALFF_rh_stimEffect_NS_VS_noTIN_smooth5.mgz','${output_path}/flatMap_ALFF_vs_ns_noTIN.png')"

# # ALFF VS_NS ave TIN
# matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${alff_path}/ALFF_lh_stimEffect_NS_VS_ave_TIN_smooth5.mgz','${alff_path}/ALFF_rh_stimEffect_NS_VS_ave_TIN_smooth5.mgz','${output_path}/flatMap_ALFF_vs_ns_ave_TIN.png')"

# # ALFF VS_NS ave noTIN
# matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${alff_path}/ALFF_lh_stimEffect_NS_VS_ave_noTIN_smooth5.mgz','${alff_path}/ALFF_rh_stimEffect_NS_VS_ave_noTIN_smooth5.mgz','${output_path}/flatMap_ALFF_vs_ns_ave_noTIN.png')"


# # for ReHo use clim([-0.03, 0.03]);
# # ReHo VS_NS TIN
# matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${reho_path}/ReHo_lh_stimEffect_NS_VS_TIN_smooth5.mgz','${reho_path}/ReHo_rh_stimEffect_NS_VS_TIN_smooth5.mgz','${output_path}/flatMap_ReHo_vs_ns_TIN.png')"

# # ReHo VS_NS noTIN
# matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${reho_path}/ReHo_lh_stimEffect_NS_VS_noTIN_smooth5.mgz','${reho_path}/ReHo_rh_stimEffect_NS_VS_noTIN_smooth5.mgz','${output_path}/flatMap_ReHo_vs_ns_noTIN.png')"

# # for ReHo ave use clim([-0.3, 0.3]);
# # ReHo VS_NS ave TIN
# matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${reho_path}/ReHo_lh_stimEffect_NS_VS_ave_TIN_smooth5.mgz','${reho_path}/ReHo_rh_stimEffect_NS_VS_ave_TIN_smooth5.mgz','${output_path}/flatMap_ReHo_vs_ns_ave_TIN.png')"

# # ReHo VS_NS ave noTIN
# matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${reho_path}/ReHo_lh_stimEffect_NS_VS_ave_noTIN_smooth5.mgz','${reho_path}/ReHo_rh_stimEffect_NS_VS_ave_noTIN_smooth5.mgz','${output_path}/flatMap_ReHo_vs_ns_ave_noTIN.png')"


# # ======================================================================= #
# # Tin vs noTin

# alfftin_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/tinEffect/smooth5"

# # for ALFF use clim([0, 0.5]);
# # ALFF TIN noTin --rest
# matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${alfftin_path}/ALFF_lh_tinEffect_tin_noTin_rest_smooth5.mgz','${alfftin_path}/ALFF_rh_tinEffect_tin_noTin_rest_smooth5.mgz','${output_path}/flatMap_ALFF_tin_noTin_rest.png')"

# # ALFF TIN noTin --vis
# matlab -batch "plotmetric_onpatch_both('${patch_path}',${AZ},${flipx},${flipy},'${alfftin_path}/ALFF_lh_tinEffect_tin_noTin_vis_smooth5.mgz','${alfftin_path}/ALFF_rh_tinEffect_tin_noTin_vis_smooth5.mgz','${output_path}/flatMap_ALFF_tin_noTin_vis.png')"