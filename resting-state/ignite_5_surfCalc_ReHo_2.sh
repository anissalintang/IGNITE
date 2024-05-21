#!/bin/bash

proj_path="/Users/msxar17/brainStates/surfProj"
data_path="/Users/msxar17/brainStates/AnissaSurfaceAnalysis"
fs_path="/Users/msxar17/brainStates/Surface/Freesurfer"

reho_path="/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo"

hemi=(lh rh)
cond=(ns vs as)

mkdir -p "/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo/merge_mean"

opt=(2_5 5 10 20 40)

for h in ${hemi[@]}; do
	for c in ${cond[@]}; do
		for o in ${opt[@]}; do
			# Merge all subjects <<- automate this fsmerge!
			matlab -batch "fsmerge('${reho_path}/sub-01/sub-01_${c}_ReHo_${h}_${o}.mgz','${reho_path}/sub-02/sub-02_${c}_ReHo_${h}_${o}.mgz','${reho_path}/sub-03/sub-03_${c}_ReHo_${h}_${o}.mgz','${reho_path}/sub-04/sub-04_${c}_ReHo_${h}_${o}.mgz','${reho_path}/sub-05/sub-05_${c}_ReHo_${h}_${o}.mgz','${reho_path}/sub-06/sub-06_${c}_ReHo_${h}_${o}.mgz','${reho_path}/sub-07/sub-07_${c}_ReHo_${h}_${o}.mgz','${reho_path}/sub-08/sub-08_${c}_ReHo_${h}_${o}.mgz','${reho_path}/sub-09/sub-09_${c}_ReHo_${h}_${o}.mgz','${reho_path}/sub-10/sub-10_${c}_ReHo_${h}_${o}.mgz','${reho_path}/sub-11/sub-11_${c}_ReHo_${h}_${o}.mgz','${reho_path}/merge_mean/allSubj_ReHo_${c}_${h}_${o}_merged.mgz','t')" -nojvm

			# Then calculate the mean out of the merged image
			matlab -batch "fsmaths('${reho_path}/merge_mean/allSubj_ReHo_${c}_${h}_${o}_merged.mgz','Tmean','${reho_path}/merge_mean/allSubj_ReHo_${c}_${h}_${o}_merged_mean.mgz')" -nojvm

			# Remove the merged image
			rm ${reho_path}/merge_mean/allSubj_ReHo_${c}_${h}_${o}_merged.mgz
		done
	done
done