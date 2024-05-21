#!/bin/bash
### GLM ###

pth=/Volumes/gdrive/mri/ProcData/SimHL; opt=$1

subjs=($(ls -d 2>/dev/null $pth/raw/*/))
for i in ${!subjs[@]}; do
    subjs[$i]=${subjs[$i]%/}
    subjs[$i]=${subjs[$i]##*/}
done

## Prestats (baseline correction, spatial smoothing, temporal filtering);
prestats(){
    pth=$1; opt=$2; subj=$3
    conds=('nh' 'hl')
    fwhm=5; sigma=$(bc -l <<< "$fwhm/(2*sqrt(2*l(2)))");

    if [ ! -d  $pth/$opt/glm/$subj ]; then
        mkdir -p $pth/$opt/glm/$subj
        
        fslmaths $pth/$opt/preproc/$subj/func -Tmean $pth/$opt/glm/$subj/mean

        if [ $opt = nordic ]; then prefix="nordic_"; else prefix=""; fi
        N=0; for cond in ${conds[@]}; do
            files=($(ls 2>/dev/null $pth/raw/$subj/$cond/${prefix}fmri*.nii.gz));
            
            n=(); for file in ${files[@]}; do
                line=($(fslhd $file | grep dim4));
                n+=(${line[1]});
            done
                
            # baseline correction;
            for i in ${!files[@]}; do
                fslroi $pth/$opt/preproc/$subj/func $pth/$opt/glm/$subj/func_${cond}_r$(($i+1)) $N ${n[$i]}
                fslmaths $pth/$opt/glm/$subj/func_${cond}_r$(($i+1)) -Tmean $pth/$opt/glm/$subj/TEMP
                fslmaths $pth/$opt/glm/$subj/func_${cond}_r$(($i+1)) -sub $pth/$opt/glm/$subj/TEMP -div $pth/$opt/glm/$subj/TEMP \
                -mul $pth/$opt/glm/$subj/mean -add $pth/$opt/glm/$subj/mean $pth/$opt/glm/$subj/func_${cond}_r$(($i+1))
                N=$(($N+${n[$i]}))
            done

            files=(); for i in ${!n[@]}; do files+=($pth/$opt/glm/$subj/func_${cond}_r$(($i+1))); done
            fslmerge -t $pth/$opt/glm/$subj/func_${cond}_cmb ${files[@]}
            susan $pth/$opt/glm/$subj/func_${cond}_cmb -1 $sigma 3 1 1 $pth/$opt/glm/$subj/mean -1 $pth/$opt/glm/$subj/func_${cond}_smth
            fslmaths $pth/$opt/glm/$subj/func_${cond}_smth -Tmin -bin $pth/$opt/glm/$subj/mask0 -odt char
            fslmaths $pth/$opt/glm/$subj/func_${cond}_smth -mas $pth/$opt/glm/$subj/mask0 $pth/$opt/glm/$subj/func_${cond}_smth
        done
        imrm $pth/$opt/glm/$subj/TEMP

        files=(); for i in ${!conds[@]}; do files+=($pth/$opt/glm/$subj/func_${conds[$i]}_cmb); done
        fslmerge -t $pth/$opt/glm/$subj/func_all_smth ${files[@]}
        susan $pth/$opt/glm/$subj/func_all_smth -1 $sigma 3 1 1 $pth/$opt/glm/$subj/mean -1 $pth/$opt/glm/$subj/func_all_smth
        fslmaths $pth/$opt/glm/$subj/func_all_smth -Tmin -bin $pth/$opt/glm/$subj/mask0 -odt char
        fslmaths $pth/$opt/glm/$subj/func_all_smth -mas $pth/$opt/glm/$subj/mask0 $pth/$opt/glm/$subj/func_all_smth
        imrm $pth/$opt/glm/$subj/mask0

        files=($(ls 2>/dev/null $pth/$opt/glm/$subj/func*.nii.gz))
        for file in ${files[@]}; do
            globint=$(fslstats $file -k $pth/$opt/preproc/$subj/mask -p 50)
            fslmaths $file -mul 10000 -div $globint $file

            line=($(fslhd $file | grep pixdim4)); tr=${line[1]}; tf=$(bc -l <<< "100/($tr*2)")
            fslmaths $file -Tmean $pth/$opt/glm/$subj/temp
            fslmaths $file -bptf $tf -1 -add $pth/$opt/glm/$subj/temp $file
        done
        imrm $pth/$opt/glm/$subj/mean $pth/$opt/glm/$subj/*usan_size $pth/$opt/glm/$subj/mask0 $pth/$opt/glm/$subj/temp
    fi
}
export -f prestats
parallel --jobs 0 'prestats {1} {2} {3}' ::: $pth ::: $opt ::: ${subjs[@]}

for subj in ${subjs[@]}; do
    if [ ! -d  $pth/$opt/glm/$subj/logFiles ]; then
        matlab -batch "read_logfiles('$pth','$opt','$subj')" -nojvm
    fi
done

for subj in ${subjs[@]}; do
    if [ ! -d $pth/$opt/glm/$subj/designs ]; then
        matlab -batch "write_designs('$pth/$opt/glm','$subj')" -nojvm
    fi
done

## Run glm;
runglm(){
    pth=$1/$2/glm/$3

    designs=($(ls 2>/dev/null $pth/designs/*.fsf))
    for i in ${!designs[@]}; do
        tmp=${designs[$i]##*/}
        designs[$i]=${tmp%.fsf}
    done
        
    for design in ${designs[@]}; do
        featdir=$design.feat
        if [ ! -d $pth/feat/$featdir ]; then
            mkdir -p $pth/feat/$featdir

            cp $pth/designs/$design.fsf $pth/feat/$featdir/design.fsf
            imcp $pth/func_${design%_*} $pth/feat/$featdir/filtered_func_data
            fslmaths $pth/feat/$featdir/filtered_func_data -Tmean $pth/feat/$featdir/example_func

            feat_model $pth/feat/$featdir/design

            if [[ $design = *smth* ]]; then
                film_gls --in=$pth/feat/$featdir/filtered_func_data --rn=$pth/feat/$featdir/stats \
                --pd=$pth/feat/$featdir/design.mat --thr=1000.0 --noest \
                --con=$pth/feat/$featdir/design.con --fcon=$pth/feat/$featdir/design.fts
             else
                film_gls --in=$pth/feat/$featdir/filtered_func_data --rn=$pth/feat/$featdir/stats \
                --pd=$pth/feat/$featdir/design.mat --thr=1000.0 --noest \
                --con=$pth/feat/$featdir/design.con

                while read -r line; do
                    line=($line)
                    if [[ ${line[0]} = *PPheights* ]]; then
                        ppheights=(${line[@]:1})
                    fi
                done < $pth/feat/$featdir/design.con
                for i in ${!ppheights[@]}; do
                    fslmaths $pth/feat/$featdir/stats/cope$(($i+1)) -div $pth/feat/$featdir/example_func -div ${ppheights[$i]} -mul 100 \
                    $pth/feat/$featdir/stats/sigch$(($i+1))
                done
            fi
        fi
    done
}
export -f runglm
parallel --jobs 0 'runglm {1} {2} {3}' ::: $pth ::: $opt ::: ${subjs[@]}

exit 0
