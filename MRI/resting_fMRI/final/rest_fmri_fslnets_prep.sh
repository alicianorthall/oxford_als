## Script name: rest_fmri_prep_fslnets
# Script purpose: This script prepares the data and the environment for running fslnets.

# Written by Alicia Northall, University of Oxford, 11.2023

# Create images of nodes from group ICA
# slices_summary groupICA20/melodic_IC_clean 4 $FSLDIR/data/standard/MNI152_T1_2mm groupICA20.sum -1
# slices_summary groupICA30/melodic_IC_clean 4 $FSLDIR/data/standard/MNI152_T1_2mm groupICA30.sum -1

# Set up environment
cd /vols/Data/als/users/alicia/data # navigate to nets directory
git clone https://git.fmrib.ox.ac.uk/fsl/fslnets.git -b mnt/tempdir
export PYTHONPATH=$(pwd)/fslnets
fslipython # start python environment