## Script name: rest_fmri_preprocess_new
# Script purpose: This script performs the preprocessing steps (e.g., subject and group level cleaning) on resting-state fMRI data.

# Written by Alicia Northall, University of Oxford, 10.2023

# subjects=(001 002 003 004 005 006 007 008 009 010 011 013 014 015 016 017 018 019 020 022 023 024 025 026 027 028 029 030 031 032 033 034 035 036 037 038 039 040 041 042 043 044 045 046 047 048 049 050 051 052 053 054 055 056 057 058 059 060 061 062 063 064 065 066 068 069 070 071 072)
subjects=(073) # single subject
DATA_DIR=/vols/Data/als/users/users/alicia/data
# RAW_DIR=/vols/Data/als/3T_MRI_Katie_2022
SCRIPT_DIR=/home/fs0/hpc655/scratch/mrtrix

# ## Section 1: Run trained-FIX.
#     # run FIX using the study-specific training dataset - run on all subjects (including those you did manual classification on)
#     for sub in "${subjects[@]}"; do
#             cd /vols/Data/als/users/users/alicia/data/*$sub*
#             fsl_sub /home/fs0/steve/NETWORKS/fix/fix /vols/Data/als/users/users/alicia/data/*$sub*/rest.ica /home/fs0/hpc655/scratch/ALS_HC_3T_106.RData 20 -m  # run FIX (batch on fsl_sub)
#     done 

## Section 2: Registration to standard space.
    # data must be in the same space before running the group ICA
    cd /vols/Data/als/users/alicia/data
    for sub in "${subjects[@]}"; do
        cd /vols/Data/als/users/users/alicia/data/*$sub*
        flirt -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -in anat/structural_brain.nii.gz -omat rest.ica/reg/my_affine_transf.mat # estimate linear transform (structural to standard)
        fnirt --in=anat/structural_brain.nii.gz --aff=rest.ica/reg/my_affine_transf.mat --cout=rest.ica/reg/my_nonlinear_transf --config=T1_2_MNI152_2mm # estimate non-linear transform (structural to standard)
        fsl_sub applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=rest.ica/filtered_func_data_clean.nii.gz --warp=rest.ica/reg/my_nonlinear_transf --premat=rest.ica/reg/example_func2highres.mat --out=rest.ica/filtered_func_data_clean_standard.nii.gz
    done