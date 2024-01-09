Title: mrtrix processing guide
Note: that these scripts were written for use on the WIN jalapeno server at the University of Oxford.

Author: Alicia Northall, University of Oxford (Dec2023)

Data: (2mm isotropic resolution) DWI data.
Acqusition: Katie Yoganathan (2022-ongoing)

CORE SCRIPTS:
- 01_rest_fmri_preprocessing.sh (manual section)
    - You need to identify the main rs-fMRI data (4D) and the reference image (3D). You also need to identify the         magnitude (take either) and phase images for creating the field map
    - Note that the single-subject ICA step requires manual Melodic GUI operation - the command line version of does     not implement all steps as in the GUI
- 02_rest_fmri_processing.sh
- 03_rest_fmri_gICA.sh
    - After performing the group ICA, you must again inspect the components and identify the noise components. Then       manually edit the script to clean these components out of the group ICA data
- 04_rest_fmri_dualregression.sh
    - You must not run dual regression using fsl_sub. It will automatically batch and run faster without this.
    - After dual regression has identified the components with significant group differences, you should remove           significant voxels that are situated in white matter or those that are within a cluster that is fewer than 20         voxels in size. This thresholding is standard practice in the field but the latter can be chosen (20-100).

OTHER SCRIPTS:

FIX training script:
- rest_fmri_fix_train.sh
    - You can try to use FIX with one of the existing training datasets (e.g., biobank) but this will perform poorly.     You should train FIX on your own dataset by manually classifying noise/signal components in a subset of patients      (I did this for 10 from each group = 20 total). The manual classification is complex and subjective - I followed      the guidelines published in Griffanti et al,, 2016 (Neuroimage)
    - You should quality-check your trained FIX by manual classifying a further two subjects (one from each group),       and comparing the results. I used the quality check criterion that FIX should not remove any more noise than the      manual classification, but FIX can detect signal components that were not identified with manual classification.

Functional connectome scripts
- rest_fmri_extract_ts.sh
- rest_fmri_fconnectome.py
    - THIS IS A CURRENTLY A WORKING SCRIPT

FSLNets scripts
- rest_fmri_fslnets_prep.sh
    - Run this before manually copying code from the following script
    - You need to use slices_summary to create images of the networks for FSLNets to use for visualisations
    - NOTE: I encountered an error in the statistics step in FSLNets when using the version currently installed on        jalapeno. I was advised by Paul McCarthy to clone the latest git version of the program to my local directory. In     the future, this bug may be fixed and you can set this to the jalapeno installation (skip git and export               commands)
    - NOTE: fslipython creates a Python environment needed for running FSLNets
- rest_fmri_fslnets.sh (manual)
