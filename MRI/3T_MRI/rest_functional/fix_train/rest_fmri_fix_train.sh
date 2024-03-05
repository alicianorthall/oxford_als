## Script name: rest_fmri_fix_train
# Script purpose: This script performs the preprocessing steps (e.g., subject and group level cleaning) on resting-state fMRI data.

# Written by Alicia Northall, University of Oxford, 10.2023

# subjects=(001 002 003 004 005 006 007 008 009 010 011 013 014 015 016 017 018 019 020 022 023 024 025 026 027 028 029 030 031 032 033 034 035 036 037 038 039 040 041 042 043 044 045 046 047 048 049 050 051 052 053 054 055 056 057 058 059 060 061 062 063 064 065 066 068 069 070 071 072)
subjects=(072) # single subject
DATA_DIR=/vols/Data/als/users/alicia/data
# RAW_DIR=/vols/Data/als/MRI_Katie_2022
SCRIPT_DIR=/home/fs0/hpc655/scratch/mrtrix

# # Section 3: Train and apply FIX to clean the single-subject data (TRAINING COMPLETED - instructions for future here)

# # Section 1: Manually classify ICA components 
# Use the fsleyes Melodic GUI to classify components for 20 subjects (10 PAT, 10 CON).
# fsleyes --scene melodic -ad filtered_func_data.ica & # open fsleyes in melodic mode, manually label components (signal or unclassified noise) and save as labels.txt

# # Section 2: Train FIX on the study-specific manually classified data
# cd /vols/Data/als/users/alicia/data
# for sub in "${subjects[@]}"; do
# cd /vols/Data/als/users/alicia/data/*$sub*
# cd rest.ica/filtered_func_data.ica
# tail -n 1 labels.txt > /vols/Data/als/users/alicia/data/$sub/rest.ica/hand_labels_noise.txt # create list of noise components from the labels text file
# done 

# If you want to clean a single dataset after manual classification - edit noise components list
# fsl_regfilt -i filtered_func_data.nii.gz -d filtered_func_data.ica/melodic_mix -o filtered_func_data_clean.nii.gz -f "1, 2, 3, 4, 5, 9, 11, 12, 13, 14, 17, 18, 23, 24, 26, 27, 28, 31, 32, 34, 37, 38, 39, 40, 42, 43, 46, 47, 48, 49, 51, 53, 54, 56, 57, 58, 59, 61, 62, 63, 65, 66, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89"

# Example training code for context: /usr/local/fix/fix -t <Training> [-l]  <Melodic1.ica> <Melodic2.ica> ...
# /home/fs0/steve/NETWORKS/fix/fix -t ALS_HC_3T_106 -l /vols/Data/als/users/alicia/data/001/rest.ica /vols/Data/als/users/alicia/data/002/rest.ica /vols/Data/als/users/alicia/data/003/rest.ica /vols/Data/als/users/alicia/data/004/rest.ica /vols/Data/als/users/alicia/data/005/rest.ica /vols/Data/als/users/alicia/data/008/rest.ica /vols/Data/als/users/alicia/data/011/rest.ica /vols/Data/als/users/alicia/data/016/rest.ica /vols/Data/als/users/alicia/data/018/rest.ica /vols/Data/als/users/alicia/data/019/rest.ica /vols/Data/als/users/alicia/data/006/rest.ica /home/fs0/hpc655/scratch/W3T_2022_106/009/rest.ica /vols/Data/als/users/alicia/data/010/rest.ica /vols/Data/als/users/alicia/data/020/rest.ica /vols/Data/als/users/alicia/data/022/rest.ica /vols/Data/als/users/alicia/data/025/rest.ica /vols/Data/als/users/alicia/data/028/rest.ica /vols/Data/als/users/alicia/data/032/rest.ica /vols/Data/als/users/alicia/data/034/rest.ica /vols/Data/als/users/alicia/data/036/rest.ica
# note that you must use the full paths to the melodic dirs

# # Section 3: Quality check of trained FIX compared to manual classifications in two new datasets (1 PAT, 1 CON)

# Manual classification of new subject - for comparison with FIX
# fsleyes --scene melodic -ad /vols/Data/als/users/alicia/data/037/rest.ica/filtered_func_data.ica & # open fsleyes in melodic mode, manually label components and save as labels.txt
    
# # Run trained FIX (combined stages)
# fsl_sub /home/fs0/steve/NETWORKS/fix/fix /vols/Data/als/users/alicia/data/037/rest.ica /vols/Data/als/users/alicia/data/ALS_HC_3T_106.RData 20 -m  # FULL SCRIPT: to identify, classify and clean
    
# # Run trained FIX (separate stages, if combined does not work)
# fsl_sub /home/fs0/steve/NETWORKS/fix/fix -f rest.ica # SUB-SCRIPT: this step identifies the components
# fsl_sub /home/fs0/steve/NETWORKS/fix/fix -c /vols/Data/als/users/alicia/data/037/rest.ica /vols/Data/als/users/alicia/data/ALS_HC_3T_106.RData 20 # SUB-SCRIPT: this step classifies components
# fsl_sub /home/fs0/steve/NETWORKS/fix/fix -a /vols/Data/als/users/alicia/data/037/rest.ica/fix4melview_ALS_HC_3T_106_thr20.txt -m # SUB-SCRIPT: this step cleans the data
