## Script name: rest_fmri_extract_ts
# Script purpose: This script extracts the time series from each ROI (Glasser52) from preprocessed and cleaned rs-fMRI data. This can be used to create functional connectomes.

# Written by Alicia Northall, University of Oxford, 12.2023

# Set up
subjects=(001 002 003 004 005 006 008 009 010 011 013 015 016 017 018 019 020 022 023 025 027 028 029 030 031 032 033 034 036 037 038 042 043 044 045 046 047 049 050 051 052 054 055 056 057 058 059 060 061 062 063 064 065 066 068 069 070 071 072 073)
# subjects=(073)
# DATA_DIR=/vols/Data/als/users/alicia/data

# # Finalise atlas masks (resample, threshold, binarise)
# i=1000 # left hemisphere
#            while [ $i -ne 1035 ] # loop from 1000 to 1035
#                 do
#                         i=$(($i+1)) # add 1 to count
#                         echo "$i"
#                         # resample freesurfer mask (1mm) to rs-fMRI resolution (2mm)
#                         flirt -in /vols/Data/als/users/alicia/data/standard_recon/mri/desikan_killiany_atlas/aparc+aseg_$i\.nii.gz -ref /vols/Data/als/users/alicia/data/CON_001/rest.ica/filtered_func_data_clean_standard.nii.gz -out /vols/Data/als/users/alicia/data/standard_recon/mri/desikan_killiany_atlas/aparc+aseg_$i\_2mm.nii.gz -applyxfm -usesqform
#                         # binarise the resampled mask
#                         fslmaths /vols/Data/als/users/alicia/data/standard_recon/mri/desikan_killiany_atlas/aparc+aseg_$i\_2mm.nii.gz -thr 0.3 -bin /vols/Data/als/users/alicia/data/standard_recon/mri/desikan_killiany_atlas/aparc+aseg_$i\_2mm_thr_0.3.nii.gz
#                 done 
# i=2000 # left hemisphere
#            while [ $i -ne 2035 ] # loop from 2000 to 2035
#                 do
#                         i=$(($i+1)) # add 1 to count
#                         echo "$i"
#                         # resample freesurfer mask (1mm) to rs-fMRI resolution (2mm)
#                         flirt -in /vols/Data/als/users/alicia/data/standard_recon/mri/desikan_killiany_atlas/aparc+aseg_$i\.nii.gz -ref /vols/Data/als/users/alicia/data/CON_001/rest.ica/filtered_func_data_clean_standard.nii.gz -out /vols/Data/als/users/alicia/data/standard_recon/mri/desikan_killiany_atlas/aparc+aseg_$i\_2mm.nii.gz -applyxfm -usesqform
#                         # binarise the resampled mask
#                         fslmaths /vols/Data/als/users/alicia/data/standard_recon/mri/desikan_killiany_atlas/aparc+aseg_$i\_2mm.nii.gz -thr 0.3 -bin /vols/Data/als/users/alicia/data/standard_recon/mri/desikan_killiany_atlas/aparc+aseg_$i\_2mm_thr_0.3.nii.gz
#                 done 

# Extract time series from each ROI
for sub in "${subjects[@]}"; do
cd /vols/Data/als/users/alicia/data/*$sub*/rest.ica
echo $sub
mkdir -p fconnectome # create dir for outputs, if does not exist
i=1000 # left hemisphere
        while [ $i -ne 1035 ] # loop from 1000 to 1035
                do
                        i=$(($i+1)) # add 1 to count
                        echo "$i"
                        # extract average (across voxels) time series from each ROI
                        fslmeants -i filtered_func_data_clean_standard.nii.gz -o fconnectome/fconnectome_$i\.txt -m /vols/Data/als/users/alicia/data/standard_recon/mri/desikan_killiany_atlas/final/aparc+aseg_$i\_2mm_thr_0.3.nii.gz
                done
i=2000 # right hemisphere
        while [ $i -ne 2035 ] # loop from 2000 to 2035
                do
                i=$(($i+1)) # add 1 to count
                echo "$i"
                # extract average (across voxels) time series from each ROI
                fslmeants -i filtered_func_data_clean_standard.nii.gz -o fconnectome/fconnectome_$i\.txt -m /vols/Data/als/users/alicia/data/standard_recon/mri/desikan_killiany_atlas/final/aparc+aseg_$i\_2mm_thr_0.3.nii.gz
                done
done