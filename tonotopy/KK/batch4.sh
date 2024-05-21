#!/bin/bash
### Project to surface ###

pth=/Volumes/gdrive/mri/ProcData/SimHL; opt=$1

subjs=($(ls -d 2>/dev/null $pth/raw/*/))
for i in ${!subjs[@]}; do
    subjs[i]=${subjs[i]%/}
    subjs[i]=${subjs[i]##*/}
done

## Project functional data to surface;
func2surf(){
    pth=$1/$2; subj=$3
    export SUBJECTS_DIR="$1/recon"
    hemis=("lh" "rh")
    layers=(); for i in $(seq -1 5); do
        layers+=($(bc -l <<< "$i*0.2"))
    done

    folders=($(ls -d 2>/dev/null $pth/glm/$subj/feat/*.feat/))
    designs=()
    for folder in ${folders[@]}; do
        folder=${folder%.feat/}; designs+=(${folder##*/});
    done
        
    for design in ${designs[@]}; do
        if [ ! -d $pth/surf/$subj/$design ]; then
            mkdir -p $pth/surf/$subj/$design
            
            # project any zfstat volumes;
            files=($(ls 2>/dev/null $pth/glm/$subj/feat/$design.feat/stats/zfstat*.nii.gz))
            if [ ${#files[@]} -gt 0 ]; then
                for file in ${files[@]}; do
                    nam=${file##*/}; nam=${nam%%.*}
                    for hemi in ${hemis[@]}; do
                        mri_vol2surf --src $file --o $pth/surf/$subj/$design/$hemi.$nam.avg.lh.fssym.mgz \
                        --hemi $hemi --projfrac-avg 0 1 0.1 --reg $pth/preproc/$subj/reg/mean2fs.lta --srcsubject $subj
                        if [ $hemi = "lh" ]; then
                            mris_apply_reg --src $pth/surf/$subj/$design/$hemi.$nam.avg.lh.fssym.mgz --o $pth/surf/$subj/$design/$hemi.$nam.avg.lh.fssym.mgz \
                            --streg $SUBJECTS_DIR/$subj/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
                        else
                            mris_apply_reg --src $pth/surf/$subj/$design/$hemi.$nam.avg.lh.fssym.mgz --o $pth/surf/$subj/$design/$hemi.$nam.avg.lh.fssym.mgz \
                            --streg $SUBJECTS_DIR/$subj/xhemi/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
                        fi
                    done
                done
            fi
            
            # project any sigch volumes;
            files=($(ls 2>/dev/null $pth/glm/$subj/feat/$design.feat/stats/sigch*.nii.gz))
            if [ ${#files[@]} -gt 0 ]; then
                for hemi in ${hemis[@]}; do
                    # project to average;
                    for i in ${!files[@]}; do
                        mri_vol2surf --src $pth/glm/$subj/feat/$design.feat/stats/sigch$((i+1)).nii.gz --o $pth/surf/$subj/$design/temp.$i.mgz \
                        --hemi $hemi --projfrac-avg 0 1 0.1 --reg $pth/preproc/$subj/reg/mean2fs.lta --srcsubject $subj
                        if [ $hemi = "lh" ]; then
                            mris_apply_reg --src $pth/surf/$subj/$design/temp.$i.mgz --o $pth/surf/$subj/$design/temp.$i.mgz \
                            --streg $SUBJECTS_DIR/$subj/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
                        else
                            mris_apply_reg --src $pth/surf/$subj/$design/temp.$i.mgz --o $pth/surf/$subj/$design/temp.$i.mgz \
                            --streg $SUBJECTS_DIR/$subj/xhemi/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
                        fi
                    done
                    I=${#files[@]}; cmd=$(printf "fsmerge(%s'%s','%s','t')" $(printf "'$pth/surf/$subj/$design/temp.%s.mgz'," $(seq 0 $((I-2)))) \
                    "$pth/surf/$subj/$design/temp.$((I-1)).mgz" "$pth/surf/$subj/$design/$hemi.sigch.avg.lh.fssym.mgz")
                    matlab -batch $cmd -nojvm
                    rm $pth/surf/$subj/$design/temp*.mgz

                    # project to layers;
                    for i in ${!files[@]}; do
                        for j in ${!layers[@]}; do
                            mri_vol2surf --src $pth/glm/$subj/feat/$design.feat/stats/sigch$((i+1)).nii.gz --o $pth/surf/$subj/$design/temp.$i.$j.mgz \
                            --hemi $hemi --projfrac ${layers[j]} --reg $pth/preproc/$subj/reg/mean2fs.lta --srcsubject $subj
                            if [ $hemi = "lh" ]; then
                                mris_apply_reg --src $pth/surf/$subj/$design/temp.$i.$j.mgz --o $pth/surf/$subj/$design/temp.$i.$j.mgz \
                                --streg $SUBJECTS_DIR/$subj/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
                            else
                                mris_apply_reg --src $pth/surf/$subj/$design/temp.$i.$j.mgz --o $pth/surf/$subj/$design/temp.$i.$j.mgz \
                                --streg $SUBJECTS_DIR/$subj/xhemi/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
                            fi
                        done
                        J=${#layers[@]}; cmd=$(printf "fsmerge(%s'%s','%s','y')" $(printf "'$pth/surf/$subj/$design/temp.$i.%s.mgz'," $(seq 0 $((J-2)))) \
                        "$pth/surf/$subj/$design/temp.$i.$((J-1)).mgz" "$pth/surf/$subj/$design/temp.$i.mgz")
                        matlab -batch $cmd -nojvm
                        rm $pth/surf/$subj/$design/temp.$i.*.mgz
                    done
                    I=${#files[@]}; cmd=$(printf "fsmerge(%s'%s','%s','t')" $(printf "'$pth/surf/$subj/$design/temp.%s.mgz'," $(seq 0 $((I-2)))) \
                    "$pth/surf/$subj/$design/temp.$((I-1)).mgz" "$pth/surf/$subj/$design/$hemi.sigch.lay.lh.fssym.mgz")
                    matlab -batch $cmd -nojvm
                    rm $pth/surf/$subj/$design/temp*.mgz
                done
            fi
        fi
    done
}
export -f func2surf
parallel --jobs 0 'func2surf {1} {2} {3}' ::: $pth ::: $opt ::: ${subjs[@]}

exit 0
