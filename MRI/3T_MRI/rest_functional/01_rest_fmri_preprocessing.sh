## Script name: rest_fmri_preprocess_new
# Script purpose: This script performs the preprocessing steps (e.g., subject and group level cleaning) on resting-state fMRI data.

# Written by Alicia Northall, University of Oxford, 10.2023

# subjects=(001 002 003 004 005 006 007 008 009 010 011 013 014 015 016 017 018 019 020 022 023 024 025 026 027 028 029 030 031 032 033 034 035 036 037 038 039 040 041 042 043 044 045 046 047 048 049 050 051 052 053 054 055 056 057 058 059 060 061 062 063 064 065 066 068 069 070 071 072)
subjects=(074) # single subject
DATA_DIR=/vols/Data/als/users/alicia/data
# RAW_DIR=/vols/Data/als/MRI_Katie_2022
SCRIPT_DIR=/home/fs0/hpc655/scratch/mrtrix

## Section 1: Prepare data.
cd /vols/Data/als/Alicia/data
for sub in "${subjects[@]}"; do
        # Prepare functional images
        cd $DATA_DIR/*$sub*/rest
        echo $sub
        mv images_05_MB8_FMRI_fov210_2.4mm_resting.nii rest_functional.nii # rename resting 4D (multi-band) image
        mv images_04_MB8_FMRI_fov210_2.4mm_resting.nii rest_reference.nii # rename resting 3D (single-band) image
        # Prepare structural image
        cd $DATA_DIR/*$sub*/anat
        # mv images_03_t1_mpr_ax_1mm_iso_withNose_32ch_v2.nii structural.nii # rename structural image
        bet structural.nii structural_brain.nii -m -f 0.2 # brain extract structural image
        # Prepare field map image
        cd $DATA_DIR/*$sub*/fmap
        mv *e1.nii mag.nii # rename magnitude imae
        mv *e2_ph.nii phase.nii # rename phase image
        bet mag.nii mag_brain.nii -m -f 0.2 # brain extract magnitude image
        fsl_prepare_fieldmap SIEMENS phase.nii mag_brain.nii fmap_rads 2.46 # create field map
done 

## Section 2: Single-subject ICA.
# Note that this is done MANUALLY using the Melodic GUI (follow instructions):
    # Navigate to subject directory and load GUI by typing Melodic. 
    # Data tab: load 4D file (rest_functional.nii) 
    # Pre-stats tab: select B0 warping, load field map (fmap.nii.gz), load brain-extracted magnitude image (mag_brain.nii.gz), set effective echo spacing (0.64 ms) and EPI TE (39 ms)
    # Pre-stats tab: select alternative reference image, load the high-contrast 3D reference image (rest_reference.nii)
    # Registration tab: select main structural image, load the brain-extracted structural image (structural_brain.nii.gz)