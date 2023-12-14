## Script name: hcp_atlas_masks
# Script purpose: This script creates masks from the HCP atlas (Glasser, 2016)
# Written by Alicia Northall (Dec2023)

# go to atlas dir
cd /home/fs0/hpc655/Downloads
mkdir hcp_atlas_masks

# extract roi masks for left hemisphere (n = 22, count = 1-22)
#!/bin/sh
i=0
while [ $i -ne 22 ]
do
        i=$(($i+1))
        echo "$i"
        fslmaths hcp-mmp1_cortices_label_all.nii.gz -thr $i -uthr $i -bin $i\_hcp-mmp1_cortices_label_bin.nii.gz
done

# extract roi masks for left hemisphere (n = 22, count = 1-22)
#!/bin/sh
i=100
while [ $i -ne 122 ]
do
        i=$(($i+1))
        echo "$i"
        fslmaths hcp-mmp1_cortices_label_all.nii.gz -thr $i -uthr $i -bin $i\_hcp-mmp1_cortices_label_bin.nii.gz
done

cp *.nii.gz hcp_atlas_masks/

## end of script