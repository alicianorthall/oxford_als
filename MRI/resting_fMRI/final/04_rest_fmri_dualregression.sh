## Script name: rest_fmri_process
# Script purpose: This script performs dual regression on preprocessed (cleaned) group ICA resting-state fMRI data.
# Written by Alicia Northall (Nov2023)

## Section 1: Perform dual regression to investigate group differences - do NOT submit using fsl_sub.
  cd /vols/Data/als/users/users/alicia/data
  dual_regression groupICA20/melodic_IC_clean 1 design.mat design.con 5000 groupICA20.dr $(cat input_files.txt)
  dual_regression groupICA30/melodic_IC_clean 1 design.mat design.con 5000 groupICA30.dr $(cat input_files.txt)

## Section 2: Perform component thresholding.
# Create white matter mask of standard structural image - already done
  # cp ${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz /vols/Data/als/users/users/alicia/data # copy standard 2mm image to working directory
  # bet MNI152_T1_2mm.nii.gz MNI152_T1_2mm_brain.nii.gz -m -f 0.2 # perform brain extraction on standard image
  # fast MNI152_T1_2mm_brain.nii.gz # segment standard image
  # fslmaths MNI152_T1_2mm_brain_pve_2.nii.gz -thr 0.5 -bin MNI152_T1_2mm_brain_pve_2_thr0.5.nii.gz # threshold WM probability image and binarise to create WM mask
  # fslmaths MNI152_T1_2mm_brain_pve_2_thr0.5.nii.gz -mul -1 -add 1 MNI152_T1_2mm_brain_pve_2_thr0.5_inv.nii.gz # create inverse of WM mask

# # Get list of components with p-values. If the maximum value in any given image is not above 0.95, you know that nothing survived thresholding.
  cd groupICA20.dr
  for i in dr_stage3_ic00??_tfce_corrp_tstat?.nii.gz ; do
      echo $i $(fslstats $i -R)
      # echo $i $(fslstats $i -R) --> components_pvals.txt
  done

  cd groupICA30.dr
  for i in dr_stage3_ic00??_tfce_corrp_tstat?.nii.gz ; do
      echo $i $(fslstats $i -R)
  done

## Apply white matter mask to components with significant group differences
# GICA20
fslmaths dr_stage3_ic0007_tfce_corrp_tstat2.nii.gz -mul /vols/Data/als/users/alicia/data/MNI152_T1_2mm_brain_pve_2_thr0.5_inv.nii.gz dr_stage3_ic0007_tfce_corrp_tstat2_gm.nii.gz
fslmaths dr_stage3_ic0009_tfce_corrp_tstat2.nii.gz -mul /vols/Data/als/users/alicia/data/MNI152_T1_2mm_brain_pve_2_thr0.5_inv.nii.gz dr_stage3_ic0009_tfce_corrp_tstat2_gm.nii.gz
fslmaths dr_stage3_ic0010_tfce_corrp_tstat2.nii.gz -mul /vols/Data/als/users/alicia/data/MNI152_T1_2mm_brain_pve_2_thr0.5_inv.nii.gz dr_stage3_ic0010_tfce_corrp_tstat2_gm.nii.gz
fslmaths dr_stage3_ic0012_tfce_corrp_tstat2.nii.gz -mul /vols/Data/als/users/alicia/data/MNI152_T1_2mm_brain_pve_2_thr0.5_inv.nii.gz dr_stage3_ic0012_tfce_corrp_tstat2_gm.nii.gz
fslmaths dr_stage3_ic0014_tfce_corrp_tstat2.nii.gz -mul /vols/Data/als/users/alicia/data/MNI152_T1_2mm_brain_pve_2_thr0.5_inv.nii.gz dr_stage3_ic0014_tfce_corrp_tstat2_gm.nii.gz

# GICA30
fslmaths dr_stage3_ic0000_tfce_corrp_tstat2.nii.gz -mul /vols/Data/als/users/alicia/data/MNI152_T1_2mm_brain_pve_2_thr0.5_inv.nii.gz dr_stage3_ic0000_tfce_corrp_tstat2_gm.nii.gz
fslmaths dr_stage3_ic0003_tfce_corrp_tstat2.nii.gz -mul /vols/Data/als/users/alicia/data/MNI152_T1_2mm_brain_pve_2_thr0.5_inv.nii.gz dr_stage3_ic0003_tfce_corrp_tstat2_gm.nii.gz
fslmaths dr_stage3_ic0008_tfce_corrp_tstat2.nii.gz -mul /vols/Data/als/users/alicia/data/MNI152_T1_2mm_brain_pve_2_thr0.5_inv.nii.gz dr_stage3_ic0008_tfce_corrp_tstat2_gm.nii.gz
fslmaths dr_stage3_ic0014_tfce_corrp_tstat2.nii.gz -mul /vols/Data/als/users/alicia/data/MNI152_T1_2mm_brain_pve_2_thr0.5_inv.nii.gz dr_stage3_ic0014_tfce_corrp_tstat2_gm.nii.gz
fslmaths dr_stage3_ic0015_tfce_corrp_tstat2.nii.gz -mul /vols/Data/als/users/alicia/data/MNI152_T1_2mm_brain_pve_2_thr0.5_inv.nii.gz dr_stage3_ic0015_tfce_corrp_tstat2_gm.nii.gz
fslmaths dr_stage3_ic0017_tfce_corrp_tstat1.nii.gz -mul /vols/Data/als/users/alicia/data/MNI152_T1_2mm_brain_pve_2_thr0.5_inv.nii.gz dr_stage3_ic0017_tfce_corrp_tstat1_gm.nii.gz

## Get cluster info from significant components
# GICA20
cluster -i dr_stage3_ic0007_tfce_corrp_tstat2_gm.nii.gz -t 0.95 > cluster_info_ic0007_tstat2.txt
cluster -i dr_stage3_ic0009_tfce_corrp_tstat2_gm.nii.gz -t 0.95 > cluster_info_ic0009_tstat2.txt
cluster -i dr_stage3_ic0010_tfce_corrp_tstat2_gm.nii.gz -t 0.95 > cluster_info_ic0010_tstat2.txt
cluster -i dr_stage3_ic0012_tfce_corrp_tstat2_gm.nii.gz -t 0.95 > cluster_info_ic0012_tstat2.txt
cluster -i dr_stage3_ic0014_tfce_corrp_tstat2_gm.nii.gz -t 0.95 > cluster_info_ic0014_tstat2.txt

# GICA30
cluster -i dr_stage3_ic0000_tfce_corrp_tstat2_gm.nii.gz -t 0.95 > cluster_info_ic0000_tstat2.txt
cluster -i dr_stage3_ic0003_tfce_corrp_tstat2_gm.nii.gz -t 0.95 > cluster_info_ic0003_tstat2.txt
cluster -i dr_stage3_ic0008_tfce_corrp_tstat2_gm.nii.gz -t 0.95 > cluster_info_ic0008_tstat2.txt
cluster -i dr_stage3_ic0014_tfce_corrp_tstat2_gm.nii.gz -t 0.95 > cluster_info_ic0014_tstat2.txt
cluster -i dr_stage3_ic0015_tfce_corrp_tstat2_gm.nii.gz -t 0.95 > cluster_info_ic0015_tstat2.txt
cluster -i dr_stage3_ic0017_tfce_corrp_tstat1_gm.nii.gz -t 0.95 > cluster_info_ic0017_tstat1.txt

# # only consider components containing clusters with number of voxels > 50: - how to filter?

# ## Section 3: Visualise the significant effects
# # Set the melodic_IC volume to match the component statistical image shown (example below)
# fsleyes -std groupICA15/melodic_IC -un -cm red-yellow -nc blue-lightblue -dr 4 15 groupICA15.dr/dr_stage3_ic0001_tfce_corrp_tstat4_gm.nii.gz -cm green -dr 0.95 1 &