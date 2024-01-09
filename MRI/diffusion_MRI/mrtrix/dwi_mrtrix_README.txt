Title: mrtrix processing guide
Note: that these scripts were written for use on the WIN jalapeno server at the University of Oxford.

Author: Alicia Northall, University of Oxford (Dec2023)

Data: (2mm isotropic resolution) DWI data.
Acqusition: Katie Yoganathan (2022-ongoing)

CORE SCRIPTS:
- dwi_mrtrix_full.sh
    - This is the master script that calls the following sub-scripts:
    - 01 for preprocessing, segmentation, streamlines
    - 02 for quality checks
    - The master script also runs recon-all for segmentation
    - 03 for creating the structural connectome

- 01_MRtrix_Preproc_AP_Direction.sh
    - Performs preprocessing steps, then creates the streamlines
    - dwifslpreproc must be run using GPU (fmrib cuda.q), so you should submit this script to this queue

- 02_QC_mrview.sh
    - Performs quality checks (visual inspection) after preprocessing

- 03_MRtrix_CreateConnectome.sh
    - Generates the structural connectome between all defined ROIs
    - WORKING: need to modify to use custom atlas (Glasser52) over the standard (Glasser82)
