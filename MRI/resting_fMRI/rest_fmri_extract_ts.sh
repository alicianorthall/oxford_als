## Script name: rest_fmri_extract_ts
# Script purpose: This script extracts the time series from each ROI (Glasser52) from preprocessed and cleaned rs-fMRI data. This can be used to create functional connectomes.

# Written by Alicia Northall, University of Oxford, 12.2023

## Set up
subjects=(001 002 003 004 005 006 008 009 010 011 013 015 016 017 018 019 020 022 023 025 027 028 029 030 031 032 033 034 036 037 038 042 043 044 045 046 047 049 050 051 052 054 055 056 057 058 059 060 061 062 063 064 065 066 068 069 070 071 072)
# subjects=(001)
DATA_DIR=/vols/Data/als/Alicia/data

## Extract time series from each ROI
cd /vols/Data/als/Alicia/data
for sub in "${subjects[@]}"; do
        cd /vols/Data/als/Alicia/data/*$sub*/rest.ica
        mkdir -p fconnectome # create dir for outputs, if does not exist
        i=0
            while [ $i -ne 52 ] # loop from 1 to 52
                do
                        i=$(($i+1)) # add 1 to count
                        echo "$i"
                        # extract average (across voxels) time series from each ROI
                        fslmeants -i filtered_func_data_clean_standard.nii.gz -o fconnectome/fconnectome_$i.txt -m /home/fs0/hpc655/Downloads/hcp_atlas_masks/ohba_52/hcp_$i
                done
done