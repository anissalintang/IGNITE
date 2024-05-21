#!/bin/bash

### Smooth all sigchange ###

data_path="/Volumes/gdrive4tb/IGNITE/tonotopy/surface/projected"

designs=(e_8.fsf e_16.fsf)
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed))

for s in ${subj[@]}; do
	for d in ${designs[@]}; do
		for h in ${hemi[@]}; do
			# smooth with fwhm = 5 mm;
		    # fwhm=5; 
		    # mri_surf2surf \
		    # --sval $data_path/${s}/${d}/${h}.sigch.avg.fsavg.mgz \
		    # --tval $data_path/${s}/${d}/${h}.sigch.avg.fsavg.smooth5.mgz \
		    # --s fsaverage \
		    # --hemi ${h} \
		    # --fwhm $fwhm \
		    # --cortex

		    # smooth with fwhm = 2.5 mm;
		    fwhm=2.5; 
		    mri_surf2surf \
		    --sval $data_path/${s}/${d}/${h}.sigch.avg.fsavg.mgz \
		    --tval $data_path/${s}/${d}/${h}.sigch.avg.fsavg.smooth2.5.mgz \
		    --s fsaverage \
		    --hemi ${h} \
		    --fwhm $fwhm \
		    --cortex
		done
	done
done