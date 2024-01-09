## Script name: Run full mrtrix pipeline for all subjects. To create structural connectomes.
# UNFINISHED CODE - RESOLVE FILENAMES SO THEY FIT WITH CODE HERE OR CHANGE CODE

# Written by Alicia Northall, University of Oxford, 03.01.2023

subjects=(001 002 003 004 005 006 007 008 009 010 011 013 014 015 016 017 018 019 020 022 023 024 025 026 027 028 029 030 031 032 033 034 035 036 037 038 039 040 041 042 043 044 045 046 047 048 049 050 051 052 053 054 055 056 057 058 059 060 061 062 063 064 065 066 068 069 070 071 072)
# subjects=(002) # single subject
DATA_DIR=/vols/Data/als/Alicia/data
RAW_DIR=/vols/Data/als/MRI_Katie_2022
SCRIPT_DIR=/home/fs0/hpc655/scratch/mrtrix

# ## Section 1A: Prepare data
# for sub in "${subjects[@]}"; do
#     cd $DATA_DIR/*${sub}*/dwi;
#     echo $sub
#     rm -r mrtrix
#     mkdir mrtrix
#     cd mrtrix
#     # copy all dwi data
#     cp $RAW_DIR/*${sub}*/dwi/* $DATA_DIR/*${sub}*/dwi/mrtrix
#     rm *.json
#     # rename images (AP)
#     mv *AP*.bvec bvec.bvec
#     mv *AP*.bval bval.bval
#     # rename images (PA)
#     mv *PA*.bvec bvec_PA.bvec
#     mv *PA*.bval bval_PA.bval
#     # copy structural data
#     cp $DATA_DIR/*${sub}*/anat/structural.nii $DATA_DIR/*${sub}*/dwi/mrtrix
#     # copy scripts to subject dir
#     cp $SCRIPT_DIR/*.sh $DATA_DIR/*${sub}*/dwi/mrtrix
# done

# manually rename diffusion images (dwi, dwi_PA) - because some sujects have differently labelled images

# Section 1B: Preprocessing
for sub in "${subjects[@]}"; do
    cd $DATA_DIR/*${sub}*/dwi/mrtrix;
    echo $sub
    fsl_sub -q cuda.q bash 01_MRtrix_Preproc_AP_Direction.sh dwi.nii dwi_PA.nii bvec.bvec bval.bval bvec_PA.bvec bval_PA.bval structural.nii
done

# ## Section 2: Quality checks
# for sub in "${subjects[@]}"; do
#     cd $DATA_DIR/*${sub}*/dwi/mrtrix
#     bash 02_QC_mrview.sh
# done

# ## Section 3: Segmentation (recon-all)
# for sub in "${subjects[@]}"; do
#     cd $DATA_DIR/*${sub}*/dwi/mrtrix
#     SUBJECTS_DIR=`pwd`;
#     fsl_sub recon-all -i structural.nii -s ${sub}_recon -all
# done

# ## Section 4: Connectome (tck2connectome)
# for sub in "${subjects[@]}"; do
#     cd $DATA_DIR/*${sub}*/dwi/mrtrix
#     bash 03_MRtrix_CreateConnectome.sh
# done