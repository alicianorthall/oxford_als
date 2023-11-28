Title: Resting-state fMRI processing guide
Note that these scripts were written for use on the WIN jalapeno server at the University of Oxford.

Author: Alicia Northall (Nov2023)

Data: Mutliband 8 (2.4mm isotropic resolution) rs-fMRI data.

Important notes:

rest_fMRI_1_preprocess.sh
- You need to identify the main rs-fMRI data (4D) and the reference image (3D). You also need to identify the magnitude (take either) and phase images for creating the field map.
- Note that many of the steps require manual work. You must run single-subject ICA in the GUI for each subject because the command line version does not implement all steps as in the GUI.
- You can try to use FIX with one of the existing training datasets (e.g., biobank) but this will perform poorly. You should train FIX on your own dataset by manually classifying noise/signal components in a subset of patients (I did this for 10 from each group = 20 total). The manual classification is complex and subjective - I followed the guidelines published in Griffanti et al,, 2016 (Neuroimage).
- You should quality-check your trained FIX by manual classifying a further two subjects (one from each group), and comparing the results. I used the quality check criterion that FIX should not remove any more noise than the manual classification, but FIX can detect signal components that were not identified with manual classification.
- After performing the group ICA, you must again inspect the components and identify the noise components. Then edit the script to clean these components out of the group ICA data.

rest_fMRI_2_dualregression.sh
- You must not run dual regression using fsl_sub. It will automatically batch and run faster without this.
- After dual regression has identified the components with significant group differences, you should remove significant voxels that are situated in white matter or those that are within a cluster that is fewer than 20 voxels in size. This thresholding is standard practice in the field but the latter can be chosen (20-100).

rest_fMRI_3_pre_fslnets.sh
- Note that this is not really a script but just a note on what you should do before running the python script rest_fMRI_4_fslnets.py. 
- You need to use slices_summary to create images of the networks for FSLNets to use for visualisations.
- NOTE: I encountered an error in the statistics step in FSLNets when using the version currently installed on jalapeno. I was advised by Paul McCarthy to clone the latest git version of the program to my local directory. In the future, this bug may be fixed and you can set this to the jalapeno installation (skip git and export commands).
- NOTE: you need to start a python environment using fslipython before moving onto the next script.

rest_fMRI_4_fslnets.py
- This is a python script that should be run in a python environment within FSL.
