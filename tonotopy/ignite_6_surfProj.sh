#!/bin/bash
### Project to surface ###

# Here we will use the 'recon-all' data from the resting-state, as it was only to reconstruct T1 to fs space

# So here is step TWO of surface processing, to create the lta fields which will enable the projection of the individual functional time series to the cortical surface

data_path="/Volumes/gdrive4tb/IGNITE";s=$1
tono_path="/Volumes/gdrive4tb/IGNITE/tonotopy"
preproc_path="/Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed"
glm_path="/Volumes/gdrive4tb/IGNITE/tonotopy/glm"
vol_path="/Volumes/gdrive4tb/IGNITE/tonotopy/volumetric"

# Use the path of already projected data from resting-state
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"
export SUBJECTS_DIR="${fs_path}/recon"

if [ ! -d  /Volumes/gdrive4tb/IGNITE/tonotopy/surface ]; then
        mkdir -p /Volumes/gdrive4tb/IGNITE/tonotopy/surface
fi

# This is the path to safe the registration and projected slab fmri to surface space
fs_path_sparse="/Volumes/gdrive4tb/IGNITE/tonotopy/surface"

subj=($(ls /Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed))
# subj=(IGNTBR_00075 IGNTCK_00066 IGNTNF_00054 IGNTMN_00051)

for s in ${subj[@]}; do
    mkdir -p ${fs_path_sparse}/registration/${s}

#     # ##############################################################
#     # This part below were done already in resting-state but keep it
#     # here for future reference
#     # ##############################################################

#     # # Obtain registration from T1 (fsl) to orig (fs), and concatenate with meanfunc2struct
#     # # Output is mean2fs.lta which is needed to project the mean functional image to the cortical surface

#     # tkregister2 --mov ${fs_path}/struct/$s/${s}_t1.nii.gz \
#     # --targ $SUBJECTS_DIR/${s}/mri/orig.mgz \
#     # --s ${s} \
#     # --reg ${fs_path}/registration/${s}/${s}_fsl2fs.dat \
#     # --ltaout ${fs_path}/registration/${s}/${s}_fsl2fs.lta \
#     # --noedit \
#     # --regheader

#     # # Checkpoint for tkregister2
#     # echo "${s} tkregister2 step has been performed" >> ${log_path}/5_surfProcessing_2_LOG.txt

#     # lta_convert --inlta ${fs_path}/registration/${s}/${s}_fsl2fs.lta \
#     # --outfsl ${fs_path}/registration/${s}/${s}_fsl2fs.mat

#     # # Checkpoint for lta_convert
#     # echo "${s} lta_convert step has been performed" >> ${log_path}/5_surfProcessing_2_LOG.txt

#     # ##############################################################
#     # This part above were done already in resting-state but keep it
#     # here for future reference
#     # ##############################################################

    convert_xfm -omat ${fs_path_sparse}/registration/${s}/${s}_mean2fs.mat \
    -concat ${fs_path}/registration/${s}/${s}_fsl2fs.mat ${vol_path}/registration/$s/meanfunc2struct/${s}_meanfunc2struct.mat

    # Checkpoint for convert_xfm
    echo "${s} convert_xfm step has been performed"

    lta_convert --infsl ${fs_path_sparse}/registration/${s}/${s}_mean2fs.mat \
    --outreg ${fs_path_sparse}/registration/${s}/${s}_mean2fs.dat \
    --outlta ${fs_path_sparse}/registration/${s}/${s}_mean2fs.lta \
    --subject ${s} \
    --src ${preproc_path}/$s/meanFunc/${s}_mean_func.nii.gz \
    --trg $SUBJECTS_DIR/$subj/mri/orig.mgz

    # Checkpoint for lta_convert
    echo "${s} lta_convert step has been performed"
done



## Project functional data to surface;
func2surf(){
    data_path="/Volumes/gdrive4tb/IGNITE";s=$1
    tono_path="/Volumes/gdrive4tb/IGNITE/tonotopy"
    preproc_path="/Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed"
    glm_path="/Volumes/gdrive4tb/IGNITE/tonotopy/glm"
    vol_path="/Volumes/gdrive4tb/IGNITE/tonotopy/volumetric"
    # This is the path to save the registration and projected slab fmri to surface space
    fs_path_sparse="/Volumes/gdrive4tb/IGNITE/tonotopy/surface"

    # Use the path of already projected data from resting-state
    fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"
    export SUBJECTS_DIR="${fs_path}/recon"

    # echo "subject directory is.. $SUBJECTS_DIR"
    hemi=("lh" "rh")

    folders=($(ls -d 2>/dev/null $glm_path/${s}/feat/*.feat/))
    designs=()
    for folder in ${folders[@]}; do
        folder=${folder%.feat/}; designs+=(${folder##*/});
    done
 
    for design in ${designs[@]}; do
        if [ ! -d $tono_path/surface/projected/${s}/$design ]; then
            mkdir -p $tono_path/surface/projected/${s}/$design
            
            # project any zfstat volumes;
            files=($(ls 2>/dev/null $glm_path/${s}/feat/$design.feat/stats/zfstat*.nii.gz))
            if [ ${#files[@]} -gt 0 ]; then
                for file in ${files[@]}; do
                    nam=${file##*/}; nam=${nam%%.*}
                    
                    # To project to fsaverage_sym
                    for h in ${hemi[@]}; do
                        mri_vol2surf \
                        --src $file \
                        --o $tono_path/surface/projected/${s}/$design/$h.$nam.avg.lh.fssym.mgz \
                        --hemi $h \
                        --projfrac-avg 0 1 0.1 \
                        --reg ${fs_path_sparse}/registration/${s}/${s}_mean2fs.lta \
                        --srcsubject $s

                        if [ $h = "lh" ]; then
                            mris_apply_reg --src $tono_path/surface/projected/${s}/$design/$h.$nam.avg.lh.fssym.mgz \
                            --o $tono_path/surface/projected/${s}/$design/$h.$nam.avg.lh.fssym.mgz \
                            --streg $SUBJECTS_DIR/$s/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
                        else
                            mris_apply_reg --src $tono_path/surface/projected/${s}/$design/$h.$nam.avg.lh.fssym.mgz --o $tono_path/surface/projected/${s}/$design/$h.$nam.avg.lh.fssym.mgz \
                            --streg $SUBJECTS_DIR/$s/xhemi/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
                        fi
                    done

                    # # To project to fsaverage
                    # for h in ${hemi[@]}; do
                    #     mri_vol2surf \
                    #     --src $file \
                    #     --o $tono_path/surface/projected/${s}/$design/$h.$nam.avg.fsavg.mgz \
                    #     --hemi $h \
                    #     --projfrac-avg 0 1 0.1 \
                    #     --reg ${fs_path_sparse}/registration/${s}/${s}_mean2fs.lta \
                    #     --srcsubject $s
                    # done

                    # for h in ${hemi[@]}; do
                    #     mris_apply_reg --src $tono_path/surface/projected/${s}/$design/$h.$nam.avg.fsavg.mgz \
                    #     --o $tono_path/surface/projected/${s}/$design/$h.$nam.avg.fsavg.mgz \
                    #     --streg $SUBJECTS_DIR/${s}/surf/${h}.fsaverage.sphere.reg $SUBJECTS_DIR/fsaverage/surf/${h}.sphere.reg
                    # done
                done
            fi
            
            # project any sigch volumes;
            files=($(ls 2>/dev/null $glm_path/${s}/feat/$design.feat/stats/sigch*.nii.gz))
            # echo "files: " $files
            # echo "design: " $design
            if [ ${#files[@]} -gt 0 ]; then
                for h in ${hemi[@]}; do

                    # To project to fsaverage_sym
                    for i in ${!files[@]}; do
                        mri_vol2surf \
                        --src $glm_path/${s}/feat/$design.feat/stats/sigch$((i+1)).nii.gz \
                        --o $tono_path/surface/projected/${s}/$design/temp.$i.mgz \
                        --hemi $h \
                        --projfrac-avg 0 1 0.1 \
                        --reg ${fs_path_sparse}/registration/${s}/${s}_mean2fs.lta \
                        --srcsubject $s

                        if [ $h = "lh" ]; then
                            mris_apply_reg \
                            --src $tono_path/surface/projected/${s}/$design/temp.$i.mgz \
                            --o $tono_path/surface/projected/${s}/$design/temp.$i.mgz \
                            --streg $SUBJECTS_DIR/$s/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg

                        else
                            mris_apply_reg \
                            --src $tono_path/surface/projected/${s}/$design/temp.$i.mgz \
                            --o $tono_path/surface/projected/${s}/$design/temp.$i.mgz \
                            --streg $SUBJECTS_DIR/$s/xhemi/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
                        fi
                    done

                    I=${#files[@]}; cmd=$(printf "fsmerge(%s'%s','%s','t')" $(printf "'$tono_path/surface/projected/${s}/$design/temp.%s.mgz'," $(seq 0 $((I-2)))) \
                    "$tono_path/surface/projected/${s}/$design/temp.$((I-1)).mgz" "$tono_path/surface/projected/${s}/$design/$h.sigch.avg.lh.fssym.mgz")
                    matlab -batch $cmd -nojvm
                    rm $tono_path/surface/projected/${s}/$design/temp*.mgz

                    # # To project to fsaverage
                    # for i in ${!files[@]}; do
                    #     mri_vol2surf \
                    #     --src $glm_path/${s}/feat/$design.feat/stats/sigch$((i+1)).nii.gz \
                    #     --o $tono_path/surface/projected/${s}/$design/temp.$i.mgz \
                    #     --hemi $h \
                    #     --projfrac-avg 0 1 0.1 \
                    #     --reg ${fs_path_sparse}/registration/${s}/${s}_mean2fs.lta \
                    #     --srcsubject $s

                    #     mris_apply_reg \
                    #     --src $tono_path/surface/projected/${s}/$design/temp.$i.mgz \
                    #     --o $tono_path/surface/projected/${s}/$design/temp.$i.mgz \
                    #     --streg $SUBJECTS_DIR/${s}/surf/${h}.fsaverage.sphere.reg $SUBJECTS_DIR/fsaverage/surf/${h}.sphere.reg

                    # done

                    # I=${#files[@]}; cmd=$(printf "fsmerge(%s'%s','%s','t')" $(printf "'$tono_path/surface/projected/${s}/$design/temp.%s.mgz'," $(seq 0 $((I-2)))) \
                    # "$tono_path/surface/projected/${s}/$design/temp.$((I-1)).mgz" "$tono_path/surface/projected/${s}/$design/$h.sigch.avg.fsavg.mgz")
                    # matlab -batch $cmd -nojvm
                    # rm $tono_path/surface/projected/${s}/$design/temp*.mgz

                done
            fi
        fi
    done
}
export -f func2surf

s=($(ls /Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed))
# s=(IGNTGS_00049 IGNTLX_00069 IGNTMN_00051 IGNTNF_00054 IGNTFM_00060)
# s=(IGNTBR_00075 IGNTCK_00066 IGNTNF_00054 IGNTMN_00051)

# Check the content of the subject array
echo ${s[@]}

parallel --jobs 6 'func2surf {1}' ::: ${s[@]}
exit 0