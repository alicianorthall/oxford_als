

"""Source reconstruction.

This includes beamforming, parcellation and orthogonalisation.
"""

# Authors: Chetan Gohil <chetan.gohil@psych.ox.ac.uk>

import os
from dask.distributed import Client
import pandas as pd

from osl import source_recon, utils

# Directories
preproc_dir = "/home/mtrubshaw/Documents/ALS_dyn/data/preproc_ssp"
coreg_dir = "/home/mtrubshaw/Documents/ALS_dyn/data/coreg"
src_dir = "/home/mtrubshaw/Documents/ALS_dyn/data/src"
fsl_dir = "/opt/ohba/fsl/6.0.5"  # this is where FSL is installed on hbaws

# Files
preproc_file = preproc_dir + "/{subject}_rest_tsss/{subject}_rest_tsss_preproc_raw.fif"  # {subject} will be replaced by the subject name



# Settings
config = """
    source_recon:
    - beamform_and_parcellate:
        freq_range: [1, 80]
        chantypes: [mag, grad]
        rank: {meg: 60}
        parcellation_file: Glasser52_binary_space-MNI152NLin6_res-8x8x8.nii.gz
        method: spatial_basis
        orthogonalisation: symmetric
"""
#fmri_d100_parcellation_with_PCC_reduced_2mm_ss5mm_ds8mm.nii.gz

if __name__ == "__main__":
    utils.logger.set_up(level="INFO")
    source_recon.setup_fsl(fsl_dir)

    # Copy directory containing the coregistration
    if not os.path.exists(src_dir):
        cmd = f"cp -r -u {coreg_dir} {src_dir}"
        print(cmd)
        os.system(cmd)

    # Get paths to files
    participants = pd.read_csv(f"../../demographics/old/complete_demo_dyn_als.csv")

    subjects = participants["Subject"].values
    preproc_files = []
    for subject in subjects:
        preproc_files.append(f"{preproc_dir}/{subject}/{subject}_preproc_raw.fif")

    # Setup parallel processing
    #
    # n_workers is the number of CPUs to use,
    # we recommend less than half the total number of CPUs you have
    client = Client(n_workers=6, threads_per_worker=1)

    # Source reconstruction
    source_recon.run_src_batch(
        config,
        src_dir=src_dir,
        subjects=subjects,
        preproc_files=preproc_files,
        #dask_client=True,
        )
