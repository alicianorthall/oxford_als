"""Coregistration.

"""

import numpy as np
import pandas as pd
from glob import glob
from dask.distributed import Client

from osl import source_recon, utils

fsl_dir = "/opt/ohba/fsl/6.0.5"

## if using standard brain (missing structural) remember to add allow_smri_scaling: True to config under coregister

def fix_headshape_points(src_dir, subject, preproc_file, smri_file, epoch_file):
    filenames = source_recon.rhino.get_coreg_filenames(src_dir, subject)

    # Load saved headshape and nasion files
    hs = np.loadtxt(filenames["polhemus_headshape_file"])
    nas = np.loadtxt(filenames["polhemus_nasion_file"])
    lpa = np.loadtxt(filenames["polhemus_lpa_file"])
    rpa = np.loadtxt(filenames["polhemus_rpa_file"])

    # Remove headshape points on the nose
    remove = np.logical_and(hs[1] > max(lpa[1], rpa[1]), hs[2] < nas[2])
    hs = hs[:, ~remove]

    # Remove headshape points on the neck
    remove = hs[2] < min(lpa[2], rpa[2]) - 4
    hs = hs[:, ~remove]

    # Remove headshape points far from the head in any direction
    remove = np.logical_or(
        hs[0] < lpa[0] - 5,
        np.logical_or(
            hs[0] > rpa[0] + 5,
            hs[1] > nas[1] + 5,
        ),
    )
    hs = hs[:, ~remove]

    # Overwrite headshape file
    utils.logger.log_or_print(f"overwritting {filenames['polhemus_headshape_file']}")
    np.savetxt(filenames["polhemus_headshape_file"], hs)


if __name__ == "__main__":
    utils.logger.set_up(level="INFO")
    source_recon.setup_fsl(fsl_dir)
    client = Client(n_workers=6, threads_per_worker=1)

    config = """
        source_recon:
        - extract_fiducials_from_fif: {}
        - fix_headshape_points: {}
        - compute_surfaces:
            include_nose: False
        - coregister:
            use_nose: False
            use_headshape: True
        - forward_model:
            model: Single Layer
    """

    preproc_dir = "/home/mtrubshaw/Documents/ALS_dyn/data/preproc_ssp"
    smri_dir = "/home/mtrubshaw/Documents/ALS_dyn/data/smri"
    coreg_dir = "/home/mtrubshaw/Documents/ALS_dyn/data/coreg"
    

    participants = pd.read_csv("/home/mtrubshaw/Documents/ALS_dyn/data/demographics/complete_demo_dyn_als.csv")
    subjects = participants["Subject"].values
    datasets = participants["Dataset"].values
    structurals = participants["Structural"].values

    preproc_files = []
    smri_files = []
    for subject, structural in zip(subjects, structurals):
        preproc_files.append(f"{preproc_dir}/{subject}/{subject}_preproc_raw.fif")
        smri_files.append(f"{smri_dir}/{structural}")

    source_recon.run_src_batch(
        config,
        src_dir=coreg_dir,
        subjects=subjects,
        preproc_files=preproc_files,
        smri_files=smri_files,
        extra_funcs=[fix_headshape_points],
        dask_client=True,
    )
