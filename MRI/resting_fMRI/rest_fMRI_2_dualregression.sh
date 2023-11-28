## Script name: rest_fmri_2_dualregression
# Script purpose: This script performs dual regression on preprocessed (cleaned) group ICA resting-state fMRI data (after running rest_fMRI_1_preprocess)
# Written by Alicia Northall (Nov2023)

## Section 1: Perform dual regression.
    # do NOT submit using fsl_sub (it will batch automatically and run faster)
    cd /vols/Data/als/Alicia/data
    dual_regression groupICA20/melodic_IC_clean 1 design.mat design.con 5000 groupICA20.dr $(cat input_files.txt)

## Section 2: Get list of significant components.
# if the maximum value in any given image is not above 0.95, then none of the components survived thresholding
    cd /vols/Data/als/Alicia/data/groupICA120.dr
    for i in dr_stage3_ic00??_tfce_corrp_tstat?.nii.gz ; do
        echo $i $(fslstats $i -R) --> components_pvals.txt
    done

## Section 2: Perform significant component thresholding.
    # create white matter mask of standard structural image
    cp ${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz /vols/Data/als/Alicia/data # copy standard 2mm image to working directory
    bet MNI152_T1_2mm.nii.gz MNI152_T1_2mm_brain.nii.gz -m -f 0.2 # perform brain extraction on standard image
    fast MNI152_T1_2mm_brain.nii.gz # segment standard image
    fslmaths MNI152_T1_2mm_brain_pve_2.nii.gz -thr 0.5 -bin MNI152_T1_2mm_brain_pve_2_thr0.5.nii.gz # threshold WM probability image and binarise to create WM mask
    fslmaths MNI152_T1_2mm_brain_pve_2_thr0.5.nii.gz -mul -1 -add 1 MNI152_T1_2mm_brain_pve_2_thr0.5_inv.nii.gz # create inverse of WM mask (i.e., cortex mask)
    # apply white matter mask to components with significant group differences (here 8, 9 and 11 - edit this accordingly)
    fslmaths dr_stage3_ic0008_tfce_corrp_tstat4.nii.gz -mul MNI152_T1_2mm_brain_pve_2_thr0.5_inv.nii.gz dr_stage3_ic0008_tfce_corrp_tstat4_gm.nii.gz
    fslmaths dr_stage3_ic0009_tfce_corrp_tstat4.nii.gz -mul MNI152_T1_2mm_brain_pve_2_thr0.5_inv.nii.gz dr_stage3_ic0009_tfce_corrp_tstat4_gm.nii.gz
    fslmaths dr_stage3_ic0011_tfce_corrp_tstat4.nii.gz -mul MNI152_T1_2mm_brain_pve_2_thr0.5_inv.nii.gz dr_stage3_ic0011_tfce_corrp_tstat4_gm.nii.gz
    # get cluster info from significant components - only consider components that contain clusters with a voxel size greater than 20
    cluster -i dr_stage3_ic0008_tfce_corrp_tstat4_gm.nii.gz -t 0.95 > cluster_info_ic0008_tstat4.txt
    cluster -i dr_stage3_ic0009_tfce_corrp_tstat4_gm.nii.gz -t 0.95 > cluster_info_ic0009_tstat4.txt
    cluster -i dr_stage3_ic0011_tfce_corrp_tstat4_gm.nii.gz -t 0.95 > cluster_info_ic0011_tstat4.txt

## Section 3: Visualise the significant components
    # Set the melodic_IC volume to match the component statistical image shown (example below)
    fsleyes -std groupICA20/melodic_IC -un -cm red-yellow -nc blue-lightblue -dr 4 15 groupICA20.dr/dr_stage3_ic0008_tfce_corrp_tstat4_gm.nii.gz -cm green -dr 0.95 1 &

## end of script