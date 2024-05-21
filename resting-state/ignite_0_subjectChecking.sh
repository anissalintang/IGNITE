#!/bin/bash

# This script have a list of all IGNITE participants ID and their HL/Tin status and will check whether in this particular analysis (resting-state, cortMyelin, dTI ...) the participant has the proper data or not. Some subjects only have few images, and it is then normal to have different list of participants between different analysis.

# Please modify the list for each analysis after checking

data_path="/Volumes/gdrive4tb/IGNITE"
preproc_path="/Volumes/gdrive4tb/IGNITE/resting-state/preprocessed"
log_path="/Volumes/gdrive4tb/IGNITE/resting-state/log"
analysis_path="/Volumes/gdrive4tb/IGNITE/resting-state/volumetric/analysis"
compare_path="/Volumes/gdrive4tb/IGNITE/resting-state/volumetric/analysis/comparison/ALFF"

region=(AC HG PT MGB V1 thalamus)
region_GM=(AC HG PT V1)
hemi=(lh rh)

mkdir -p /Volumes/gdrive4tb/IGNITE/resting-state/subList
subList_path="/Volumes/gdrive4tb/IGNITE/resting-state/subList"

######################################################################################################
## Original list of participants ID
sub_tin_HL_orig=(IGTTAJ_00061 IGTTBA_00003 IGTTGA_00005 IGTTMD_00004 IGTTSJ_00007 IGTTJG_00008 IGTTJI_00009 IGTTBC_00014 IGTTCP_00020 IGTTSM_00028 IGTTPG_00055 IGTTPP_00040 IGTTRE_00043 IGTTKK_00041 IGTTPS_00044 IGTTMD_00029 IGTTDA_00063 IGTTHG_00064 IGTTMD_00076 IGNTFJ_00015 IGTTAS_00062)

sub_tin_NH_orig=(IGTTLC_00002 IGTTRK_00006 IGTTCW_00010 IGTTKA_00017 IGTTSM_00050 IGTTHA_00042 IGTTSM_00058 IGTTMG_00032 IGTTHA_00070 IGTTWL_00073 IGTTFJ_00074 IGTTBA_00052)

sub_HL_orig=(IGNTEP_00023 IGNTMA_00025 IGNTFB_00027 IGNTBP_00072 IGNTHS_00068)

sub_NH_orig=(IGNTCJ_00018 IGNTQI_00033 IGNTGS_00049 IGNTIV_00045 IGNTNF_00054 IGNTMN_00051 IGNTOH_00059 IGNTFM_00060 IGNTFA_00065 IGNTCK_00066 IGNTCE_00067 IGNTLX_00069 IGNTBR_00075 IGNTPO_00071)

######################################################################################################
# Check whether in the ID exist in resting-state preprocessed data

###############################################################
# Hearing loss with Tinnitus
for s in ${sub_tin_HL_orig[@]}; do
	if ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed/${s} 1> /dev/null 2>&1; then
        echo "sub_tin_HL_orig exists for ${s}"
    else 
        echo "sub_tin_HL_orig does NOT exist for ${s}"
    fi
done

# Available participant
sub_tin_HL=(IGTTAJ_00061 IGTTBA_00003 IGTTMD_00004 IGTTSJ_00007 IGTTJG_00008 IGTTJI_00009 IGTTBC_00014 IGTTSM_00028 IGTTPG_00055 IGTTPP_00040 IGTTRE_00043 IGTTKK_00041 IGTTPS_00044 IGTTMD_00029 IGTTDA_00063 IGTTHG_00064 IGTTMD_00076 IGNTFJ_00015 IGTTAS_00062) 

echo "${sub_tin_HL[@]}" >> ${subList_path}/sub_tin_HL.txt

###############################################################
# Tinnitus with normal hearing (Tinnitus only)
for s in ${sub_tin_NH_orig[@]}; do
    if ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed/${s} 1> /dev/null 2>&1; then
        echo "sub_tin_NH_orig exists for ${s}"
    else 
        echo "sub_tin_NH_orig does NOT exist for ${s}"
    fi
done

# Available participant
sub_tin_NH=(IGTTLC_00002 IGTTRK_00006 IGTTCW_00010 IGTTKA_00017 IGTTSM_00050 IGTTHA_00042 IGTTSM_00058 IGTTMG_00032 IGTTHA_00070 IGTTWL_00073 IGTTBA_00052) 

echo "${sub_tin_NH[@]}" >> ${subList_path}/sub_tin_NH.txt

###############################################################
# Hearing loss only
for s in ${sub_HL_orig[@]}; do
	if ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed/${s} 1> /dev/null 2>&1; then
        echo "sub_HL_orig exists for ${s}"
    else 
        echo "sub_HL_orig does NOT exist for ${s}"
    fi
done

# Available participant
sub_HL=(IGNTEP_00023 IGNTMA_00025 IGNTFB_00027 IGNTBP_00072 IGNTHS_00068)

echo "${sub_HL[@]}" >> ${subList_path}/sub_HL.txt

###############################################################
# Normal hearing

for s in ${sub_NH_orig[@]}; do
	if ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed/${s} 1> /dev/null 2>&1; then
        echo "sub_NH_orig exists for ${s}"
    else 
        echo "sub_NH_orig does NOT exist for ${s}"
    fi
done

# Available participant
sub_NH=(IGNTCJ_00018 IGNTQI_00033 IGNTGS_00049 IGNTIV_00045 IGNTNF_00054 IGNTMN_00051 IGNTOH_00059 IGNTFM_00060 IGNTFA_00065 IGNTCK_00066 IGNTLX_00069 IGNTBR_00075 IGNTPO_00071)

echo "${sub_NH[@]}" >> ${subList_path}/sub_NH.txt