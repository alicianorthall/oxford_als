#!/bin/bash

# Edited by Alicia Northall, University of Oxford, 03.01.2023
# Written by Andrew Jahn, University of Michigan, 02.25.2019
# Updated 07.10.2020 to incorporate changes from MRtrix version 3.0.1
# Based on Marlene Tahedl's BATMAN tutorial (http://www.miccai.org/edu/finalists/BATMAN_trimmed_tutorial.pdf)
# The main difference between this script and the other one in this repository, is that this script assumes that your diffusion images were acquired with AP phase encoding
# Thanks to John Plass and Bennet Fauber for useful comments

# Set up environment for FMRIB use
module load ANTs
module load freesurfer
module load mrtrix3
# add path to mrtrix scripts (needed for dwifslpreproc)
export PATH="/opt/fmrib/conda/python3/envs/mrtrix3/bin:$PATH"
# dwifslpreproc --help # test if path works

SUBJ=$1

#Convert the labels of the FreeSurfer parcellation to a format that MRtrix understands. This requires recon-all to have been run on the subject
labelconvert ${SUBJ}_recon/mri/aparc+aseg.mgz $FREESURFER_HOME/FreeSurferColorLUT.txt /usr/local/mrtrix3/share/mrtrix3/labelconvert/fs_default.txt ${SUBJ}_parcels.mif

#Unclear if the line below is needed; it seems to make the coregistration worse. Maybe it is only needed for atlases aside from the default FreeSurfer atlases
#mrtransform ${SUBJ}_parcels.mif -interp nearest -linear diff2struct_mrtrix.txt -inverse -datatype uint32 ${SUBJ}_parcels_coreg.mif

#Create a whole-brain connectome, representing the streamlines between each parcellation pair in the atlas (in this case, 84x84). The "symmetric" option will make the lower diagonal the same as the upper diagonal, and the "scale_invnodevol" option will scale the connectome by the inverse of the size of the node 
#tck2connectome -symmetric -zero_diagonal -scale_invnodevol -tck_weights_in sift_1M.txt sub-01_parcels.mif sub-01_parcels.csv -out_assignment assignments_sub-01_parcels.csv
tck2connectome -symmetric -zero_diagonal -scale_invnodevol -tck_weights_in sift_1M.txt tracks_10M.tck ${SUBJ}_parcels.mif ${SUBJ}_parcels.csv -out_assignment assignments_${SUBJ}_parcels.csv

#Creates a tract file between the specified nodes that can then be visualized in mrview. Replace the "8,10" pair after the "nodes" option with the labels in ~/mrtrix3/share/mrtrix3/labelconvert/fs_default.txt that you are interested in
#connectome2tck -nodes 8,10 -exclusive sift_1mio.tck assignments_sub-01_parcels.csv test