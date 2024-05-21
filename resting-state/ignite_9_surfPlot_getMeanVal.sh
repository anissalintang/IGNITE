#!/bin/bash

# Script to get the mean Value from ALFF, GCOR and ReHo for plotting

fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon"

mask_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/colin27_fsavg"
export SUBJECTS_DIR="${mask_path}"

alff_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF"
# reho_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReHo"
gcor_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR"

hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# subj=(IGTTFJ_00074)

# ======================================================================= #
# Get mean values for wholeBrain
for s in ${subj[@]}; do
	mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF/meanValues/${s}"
	# mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReHo/meanValues/${s}"
	mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/meanValues/${s}"

		for h in ${hemi[@]}; do
			# Then calculate the mean ALFF for all subjects in wholeBrain
			matlab -batch "fsstats('${alff_path}/${s}/${s}_${h}_fsavg_ALFF.mgz','-l 500 -m')" -nojvm > ${alff_path}/meanValues/${s}/${s}_ALFF_wholeBrain_${h}_smooth5.txt

			# # Then calculate the mean ALFF sqr for all subjects in wholeBrain
			# matlab -batch "fsstats('${alff_path}/${s}/${s}_${h}_fsavg_ALFF_sqr.mgz','-m')" -nojvm > ${alff_path}/meanValues/${s}/${s}_ALFF_sqr_wholeBrain_${h}.txt

			# # Then calculate the mean REHO 2.5 for all subjects in wholeBrain
			# matlab -batch "fsstats('${reho_path}/${s}/${s}_ReHo_${h}_2_5.mgz','-m')" -nojvm > ${reho_path}/meanValues/${s}/${s}_ReHo_wholeBrain_${h}_2_5.txt

			# # Then calculate the mean REHO 5 for all subjects in wholeBrain
			# matlab -batch "fsstats('${reho_path}/${s}/${s}_ReHo_${h}_5.mgz','-m')" -nojvm > ${reho_path}/meanValues/${s}/${s}_ReHo_wholeBrain_${h}_5.txt

			# # Then calculate the mean REHO 10 for all subjects in wholeBrain
			# matlab -batch "fsstats('${reho_path}/${s}/${s}_ReHo_${h}_10.mgz','-m')" -nojvm > ${reho_path}/meanValues/${s}/${s}_ReHo_wholeBrain_${h}_10.txt

			# # Then calculate the mean REHO 20 for all subjects in wholeBrain
			# matlab -batch "fsstats('${reho_path}/${s}/${s}_ReHo_${h}_20.mgz','-m')" -nojvm > ${reho_path}/meanValues/${s}/${s}_ReHo_wholeBrain_${h}_20.txt

			# # Then calculate the mean REHO 40 for all subjects in wholeBrain
			# matlab -batch "fsstats('${reho_path}/${s}/${s}_ReHo_${h}_40.mgz','-m')" -nojvm > ${reho_path}/meanValues/${s}/${s}_ReHo_wholeBrain_${h}_40.txt

			# Then calculate the mean GCOR for all subjects in wholeBrain
			matlab -batch "fsstats('${gcor_path}/${s}/${s}_GCOR_wholeBrain_${h}.mgz','-m')" -nojvm > ${gcor_path}/meanValues/${s}/${s}_GCOR_wholeBrain_${h}_smooth5.txt

	done
done


# ======================================================================= #
# Get mean values for AUD region with HO_HG mask
for s in ${subj[@]}; do
	for h in ${hemi[@]}; do
		# Then calculate the mean ALFF for all subjects in HG
		matlab -batch "fsstats('${alff_path}/${s}/${s}_${h}_fsavg_ALFF.mgz','-l 500 -m','$SUBJECTS_DIR/HO_HG_${h}_mask_fsavg.mgz')" -nojvm > ${alff_path}/meanValues/${s}/${s}_ALFF_HG_${h}_smooth5.txt

		# # Then calculate the mean ALFF sqr for all subjects in HG
		# matlab -batch "fsstats('${alff_path}/${s}/${s}_${h}_fsavg_ALFF_sqr.mgz','-m','$SUBJECTS_DIR/HO_HG_${h}_mask_fsavg.mgz')" -nojvm > ${alff_path}/meanValues/${s}/${s}_ALFF_sqr_HG_${h}.txt

		# # Then calculate the mean REHO 2.5 for all subjects in HG
		# matlab -batch "fsstats('${reho_path}/${s}/${s}_ReHo_${h}_2_5.mgz','-m','$SUBJECTS_DIR/HO_HG_${h}_mask_fsavg.mgz')" -nojvm > ${reho_path}/meanValues/${s}/${s}_ReHo_HG_${h}_2_5.txt

		# # Then calculate the mean REHO 5 for all subjects in HG
		# matlab -batch "fsstats('${reho_path}/${s}/${s}_ReHo_${h}_5.mgz','-m','$SUBJECTS_DIR/HO_HG_${h}_mask_fsavg.mgz')" -nojvm > ${reho_path}/meanValues/${s}/${s}_ReHo_HG_${h}_5.txt

		# # Then calculate the mean REHO 10 for all subjects in HG
		# matlab -batch "fsstats('${reho_path}/${s}/${s}_ReHo_${h}_10.mgz','-m','$SUBJECTS_DIR/HO_HG_${h}_mask_fsavg.mgz')" -nojvm > ${reho_path}/meanValues/${s}/${s}_ReHo_HG_${h}_10.txt

		# # Then calculate the mean REHO 20 for all subjects in HG
		# matlab -batch "fsstats('${reho_path}/${s}/${s}_ReHo_${h}_20.mgz','-m','$SUBJECTS_DIR/HO_HG_${h}_mask_fsavg.mgz')" -nojvm > ${reho_path}/meanValues/${s}/${s}_ReHo_HG_${h}_20.txt

		# # Then calculate the mean REHO 40 for all subjects in HG
		# matlab -batch "fsstats('${reho_path}/${s}/${s}_ReHo_${h}_40.mgz','-m','$SUBJECTS_DIR/HO_HG_${h}_mask_fsavg.mgz')" -nojvm > ${reho_path}/meanValues/${s}/${s}_ReHo_HG_${h}_40.txt

		# Then calculate the mean GCOR for all subjects in HG
		matlab -batch "fsstats('${gcor_path}/${s}/${s}_GCOR_wholeBrain_${h}.mgz','-m','$SUBJECTS_DIR/HO_HG_${h}_mask_fsavg.mgz')" -nojvm > ${gcor_path}/meanValues/${s}/${s}_GCOR_HG_${h}_smooth5.txt

	done
done

