#!/bin/bash
### Make probabilistic activation map and cortical patch ###

pth=/Volumes/gdrive/mri/ProcData/SimHL; opt=$1
export SUBJECTS_DIR="$pth/recon"

subjs=($(ls -d 2>/dev/null $pth/raw/*/))
for i in ${!subjs[@]}; do
    subjs[$i]=${subjs[$i]%/}
    subjs[$i]=${subjs[$i]##*/}
done

hemis=("lh" "rh")

## Make probabilistic activation map;
if [ ! -f $pth/$opt/surf/actprob.lh.fssym.mgz ]; then
    # merge zfstat maps across hemispheres;
    files=($(ls 2>/dev/null $pth/$opt/surf/*/all_smth_8/?h.zfstat*.mgz)); K=${#files[@]};
    cmd=$(printf "fsmerge(%s'%s','%s','t')" $(printf "'%s'," ${files[@]:0:$((K-1))}) ${files[$((K-1))]} "$pth/$opt/surf/actprob.lh.fssym.mgz")
    matlab -batch $cmd -nojvm
    # Calculate activation probabilities for pval;
    pval="0.05"; zval=$(ptoz $pval)
    matlab -batch "fsmaths('$pth/$opt/surf/actprob.lh.fssym.mgz','thr',$zval,'$pth/$opt/surf/actprob.lh.fssym.mgz')" -nojvm
    matlab -batch "fsmaths('$pth/$opt/surf/actprob.lh.fssym.mgz','bin','$pth/$opt/surf/actprob.lh.fssym.mgz')" -nojvm
    matlab -batch "fsmaths('$pth/$opt/surf/actprob.lh.fssym.mgz','Tmean','$pth/$opt/surf/actprob.lh.fssym.mgz')" -nojvm
    matlab -batch "fsmaths('$pth/$opt/surf/actprob.lh.fssym.mgz','mul',100,'$pth/$opt/surf/actprob.lh.fssym.mgz')" -nojvm
    # smooth with fwhm = 5 mm;
    fwhm=5; mri_surf2surf --sval $pth/$opt/surf/actprob.lh.fssym.mgz --tval $pth/$opt/surf/actprob.lh.fssym.mgz --s fsaverage_sym \
    --hemi lh --fwhm $fwhm --cortex
fi

## Make patch;
mkdir -p $pth/$opt/patch
if [ ! -f $pth/$opt/patch/surf.mat ] || [ ! -f $pth/$opt/patch/patch.mat ]; then
    matlab -batch "make_patch('$pth','$opt',50,35,false,true)" -nojvm
fi
## check patch orientation in matlab using check_patch(AZ,FLIPX,FLIPY);
## start by setting all arguments to zero;
## after determining AZ, FLIPX and FLIPY, run make_patch again using these values;
## if the roi needs editing, apply "edit_roi.m" in matlab;

exit 0
