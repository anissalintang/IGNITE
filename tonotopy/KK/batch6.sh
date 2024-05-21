#!/bin/bash
### Extract signal changes and make probabilistic tonotopic maps ###

pth=/Volumes/gdrive/mri/ProcData/SimHL
export SUBJECTS_DIR="$pth/recon"

subjs=($(ls -d 2>/dev/null $pth/raw/*/))
for i in ${!subjs[@]}; do
    subjs[$i]=${subjs[$i]%/}
    subjs[$i]=${subjs[$i]##*/}
done

pth=$pth/$1;

hemis=("lh" "rh")

# Extract signal changes for patch vertices;
if [ ! -f $pth/patch/schavg.mat ] || [ ! -f $pth/patch/schlay.mat ]; then
    matlab -batch "xtrct_sigch('$pth')" -nojvm
fi

# Make individual pfi (preferred-frequency-index) maps;
for subj in ${subjs[@]}; do
    if [ -z "$(ls 2>/dev/null $pth/surf/$subj/*.pfi*.mgz)" ]; then
        for hemi in ${hemis[@]}; do
            matlab -batch "fsmaths('$pth/surf/$subj/nh_cmb_8/$hemi.sigch.avg.lh.fssym.mgz','Tmaxn','$pth/surf/$subj/$hemi.pfi.lh.fssym.mgz')" -nojvm
        done
    fi
done

# Make smoothed max-prob pfi and pf maps for calculation of field borders;
if [ ! -f $pth/surf/pfimax.lh.fssym.mgz ] || [ ! -f $pth/surf/pfmax.lh.fssym.mgz ]; then
    files=($(ls 2>/dev/null $pth/surf/*/?h.pfi*.mgz)); K=${#files[@]};
    cmd=$(printf "fsmerge(%s'%s','%s','t')" $(printf "'%s'," ${files[@]:0:$((K-1))}) ${files[$((K-1))]} "$pth/surf/pfimax.lh.fssym.mgz")
    matlab -batch $cmd -nojvm
    matlab -batch "make_pfimax('$pth/surf/pfimax.lh.fssym.mgz','$pth/surf/pfimax.lh.fssym.mgz')" -nojvm
    matlab -batch "cnvrt_pfi2pf('$pth/surf/pfimax.lh.fssym.mgz','$pth/surf/pfmax.lh.fssym.mgz')" -nojvm
    fwhm=2.5; strg=${fwhm/./_}; strg=${strg%_0}
    mri_surf2surf --sval $pth/surf/pfmax.lh.fssym.mgz --tval $pth/surf/pfmax_sm$strg.lh.fssym.mgz --s fsaverage_sym \
    --hemi lh --fwhm $fwhm --cortex
    fwhm=7.5; strg=${fwhm/./_}; strg=${strg%_0}
    mri_surf2surf --sval $pth/surf/pfmax.lh.fssym.mgz --tval $pth/surf/pfmax_sm$strg.lh.fssym.mgz --s fsaverage_sym \
    --hemi lh --fwhm $fwhm --cortex
fi

# Make jack-knife max-prob pfi maps for individual hemispheres;
for subj in ${subjs[@]}; do
    if [ ! -f $pth/surf/$subj/pfimax.lh.fssym.mgz ]; then
        files=($(ls 2>/dev/null $pth/surf/*/?h.pfi*.mgz))
        i=0; for file in ${files[@]}; do
            if [[ $file != *$subj* ]]; then
                i=$((i+1))
                if [ $i -eq 1 ]; then
                    cp $file $pth/surf/$subj/pfimax.lh.fssym.mgz
                else
                    matlab -batch "fsmerge('$pth/surf/$subj/pfimax.lh.fssym.mgz','$file','$pth/surf/$subj/pfimax.lh.fssym.mgz','t')" -nojvm
                fi
            fi
        done
        matlab -batch "make_pfimax('$pth/surf/$subj/pfimax.lh.fssym.mgz','$pth/surf/$subj/pfimax.lh.fssym.mgz')" -nojvm
    fi
done

if [ ! -f $pth/patch/fields.mat ]; then
    matlab -batch "make_fields('$pth')" -nojvm
fi

exit 0
