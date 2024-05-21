#!/bin/bash
### GLM ###

data_path="/Volumes/gdrive4tb/IGNITE"
tono_path="/Volumes/gdrive4tb/IGNITE/tonotopy"
preproc_path="/Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed"

subj=($(ls /Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed))
# subj=(IGNTFA_00065)

## Prestats (globint and temporal filtering);
# prestats(){
#     data_path="/Volumes/gdrive4tb/IGNITE";s=$1
#     tono_path="/Volumes/gdrive4tb/IGNITE/tonotopy"
#     preproc_path="/Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed"

#     if [ ! -d  $tono_path/glm/$s ]; then
#         mkdir -p $tono_path/glm/$s
#     fi
    
#     # # This is a default step in FEAT called the "grand mean scaling"
#     # globint=$(fslstats $preproc_path/${s}/${s}_preprocessed.nii.gz -k $preproc_path/${s}/meanFunc/bet/${s}_mean_func_bet_mask.nii.gz -p 50)
#     # fslmaths $preproc_path/${s}/${s}_preprocessed.nii.gz -mul 10000 -div $globint $preproc_path/${s}/${s}_preprocessed_globint.nii.gz

#     # line=($(fslhd $preproc_path/${s}/${s}_preprocessed_globint.nii.gz | grep pixdim4)); tr=${line[1]}; tf=$(bc -l <<< "100/($tr*2)")


#     # fslmaths $preproc_path/${s}/${s}_preprocessed_globint.nii.gz -Tmean $preproc_path/$s/${s}_preprocessed_globint_temp.nii.gz
#     # fslmaths $preproc_path/${s}/${s}_preprocessed_globint.nii.gz -bptf $tf -1 -add $preproc_path/${s}/${s}_preprocessed_globint_temp.nii.gz $preproc_path/${s}/${s}_preprocessed_globint_prestats.nii.gz

#     # imrm $preproc_path/${s}/${s}_preprocessed_globint_temp.nii.gz
# }
# export -f prestats

# s=($(ls /Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed))
# # s=(IGNTFA_00065)

# # Check the content of the subject array
# echo ${s[@]}

# parallel --jobs 6 'prestats {1}' ::: ${s[@]}

# for s in ${subj[@]}; do
#     ## cp $data_path/data/Tonotopy_log/$s/${s}_*.log $data_path/data/Tonotopy_log/$s/${s}_*.txt
#     if [ ! -d  $tono_path/glm/$s/logFiles ]; then
#         mkdir -p $tono_path/glm/$s/logFiles
#     fi

#     for txt_file in $data_path/data/Tonotopy_log/${s}/${s}_*.txt; do
#         matlab -batch "read_logfiles('$txt_file','$tono_path/glm/${s}/logFiles/')" -nojvm
#     done
# done

# for s in ${subj[@]}; do
#     if [ ! -d $tono_path/glm/$s/designs ]; then
#         mkdir -p $tono_path/glm/$s/designs
#     fi

#     matlab -batch "write_designs('$tono_path/glm/${s}/')" -nojvm
#     cp $tono_path/glm/$s/designs/e_8.fsf $tono_path/glm/$s/designs/e_8_smoothed5.fsf
# done

## Run glm;
runglm(){
    glm_path="/Volumes/gdrive4tb/IGNITE/tonotopy/glm";s=$1
    preproc_path="/Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed"

    designs=($(ls 2>/dev/null $glm_path/${s}/designs/*.fsf))

    for design in ${designs[@]}; do
        featdir=$(basename $design).feat

        if [ ! -d $glm_path/${s}/feat/$featdir ]; then
            mkdir -p $glm_path/${s}/feat/$featdir

            cp $design "$glm_path/${s}/feat/$featdir/design.fsf"
            imcp "$preproc_path/${s}/${s}_preprocessed_globint_prestats.nii.gz" "$glm_path/${s}/feat/$featdir/filtered_func_data"
            fslmaths "$glm_path/${s}/feat/$featdir/filtered_func_data" -Tmean "$glm_path/${s}/feat/$featdir/example_func"

            imcp "$preproc_path/${s}/${s}_preprocessed_smoothed5_globint_prestats.nii.gz" "$glm_path/${s}/feat/$featdir/filtered_func_data_smoothed5"
            fslmaths "$glm_path/${s}/feat/$featdir/filtered_func_data_smoothed5" -Tmean "$glm_path/${s}/feat/$featdir/example_func_smoothed5"

            feat_model "$glm_path/${s}/feat/$featdir/design"

            if [[ $design = *smoothed5* ]]; then
                film_gls \
                --in=$glm_path/${s}/feat/$featdir/filtered_func_data_smoothed5 \
                --rn=$glm_path/${s}/feat/$featdir/stats \
                --pd=$glm_path/${s}/feat/$featdir/design.mat \
                --thr=1000.0 \
                --noest \
                --con=$glm_path/${s}/feat/$featdir/design.con \
                --fcon=$glm_path/${s}/feat/$featdir/design.fts
                # Process the design.con file
                while read -r line; do
                    line=($line)
                    if [[ ${line[0]} = *PPheights* ]]; then
                        ppheights=(${line[@]:1})
                    fi
                done < $glm_path/${s}/feat/$featdir/design.con

            else
                film_gls \
                --in=$glm_path/${s}/feat/$featdir/filtered_func_data \
                --rn=$glm_path/${s}/feat/$featdir/stats \
                --pd=$glm_path/${s}/feat/$featdir/design.mat \
                --thr=1000.0 \
                --noest \
                --con=$glm_path/${s}/feat/$featdir/design.con

                # Process the design.con file
                while read -r line; do
                    line=($line)
                    if [[ ${line[0]} = *PPheights* ]]; then
                        ppheights=(${line[@]:1})
                    fi
                done < $glm_path/${s}/feat/$featdir/design.con

                # Convert to percentage signal change (PSC)
                for i in ${!ppheights[@]}; do
                    fslmaths $glm_path/${s}/feat/$featdir/stats/cope$(($i+1)) -div $glm_path/${s}/feat/$featdir/example_func -div ${ppheights[$i]} -mul 100 \
                    $glm_path/${s}/feat/$featdir/stats/sigch$(($i+1))
                done
            fi
        fi
    done
        
}
export -f runglm

s=($(ls /Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed))
# s=(IGNTFA_00065)

# Check the content of the subject array
echo ${s[@]}

parallel --jobs 6 'runglm {1}' ::: ${s[@]}
exit 0
