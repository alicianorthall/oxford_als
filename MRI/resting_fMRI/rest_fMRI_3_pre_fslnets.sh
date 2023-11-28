## Script name: rest_fMRI_3_pre_fslnets
# Script purpose: This script prepares the data for FSLNets (see script rest_fMRI_4_fslnets).
# Written by Alicia Northall (Nov2023)

## Section 1: Prepare data for FSLNets.
# create images of nodes
slices_summary groupICA15/melodic_IC_clean 4 $FSLDIR/data/standard/MNI152_T1_2mm groupICA15.sum -1

## Section 2: Run FSLNets.
cd /vols/Data/als/Alicia/data # navigate to nets directory
git clone https://git.fmrib.ox.ac.uk/fsl/fslnets.git -b mnt/tempdir # clone current git version of fslnets to local dir
export PYTHONPATH=$(pwd)/fslnets # add path to cloned git fslnets to pythonpath
fslipython # start python environment

# End of script