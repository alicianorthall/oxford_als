## Script name: rest_fmri_gICA
# Script purpose: This script performs the preprocessing steps (e.g., subject and group level cleaning) on resting-state fMRI data.

# Written by Alicia Northall, University of Oxford, 10.2023

## Group ICA.
    cd /vols/Data/als/Alicia/data
    ls -1 */*rest.ica/filtered_func_data_clean_standard.nii.gz >> input_files.txt # get txt list of cleaned data for all subjects
    melodic -i input_files.txt -o groupICA20 --tr=0.72 --nobet -a concat -m $FSLDIR/data/standard/MNI152_T1_2mm_brain_mask.nii.gz --report --Oall -d 20
    # note that you need to investigate different component thresholds (here -d 20 means that the data are decomposed into 20 components) - if you change this then reaname the output folder (-o)
    # note that you need to set the tr for the study

## Clean group ICA data.
    # note that you need to inspect the group melodic components (here for thr = 20) and identify the noise components
    cd /vols/Data/als/Alicia/data/groupICA20
    # fsleyes -std groupICA20/melodic_IC -un -cm -red-yellow -nc blue-lightblue -dr 4 15 # view group melodic components - identify noise components and list below
    fslsplit melodic_IC.nii.gz # split 4D image into 3D volumes
    mkdir noise_group_IC_components # create dir for noise components
    mv vol0011.nii.gz vol0013.nii.gz vol0015.nii.gz vol0016.nii.gz vol0017.nii.gz noise_group_IC_components/ # move noise components to respective directory - edit this list accordingly
    mkdir signal_group_IC_components # create dir for signal components
    mv vol* signal_group_IC_components/ # move signal components to respective directory (to reduce clutter)
    fslmerge -t melodic_IC_clean.nii.gz signal_group_IC_components/vol* # merge signal components to create cleaned group melodic 4D image