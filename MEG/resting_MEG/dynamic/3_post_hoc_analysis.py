"""Post-hoc analysis of a DyNeMo run.

"""

from sys import argv

if len(argv) != 2:
    print("Please pass the run id, e.g. python post_hoc_analysis.py 1")
    exit()
id = int(argv[1])

from osl_dynamics import run_pipeline

n_modes = 7

config = """
    load_data:
        inputs: ../data/src_npy
        kwargs:
            sampling_frequency: 250
            mask_file: MNI152_T1_8mm_brain.nii.gz
            parcellation_file: Glasser52_binary_space-MNI152NLin6_res-8x8x8.nii.gz
            n_jobs: 16
        prepare:
            tde_pca: {n_embeddings: 15, n_pca_components: 100}
            standardize: {}
    get_inf_params: {}
    regression_spectra:
        kwargs:
            frequency_range: [1, 80]
            n_jobs: 16
    plot_group_tde_dynemo_networks:
        power_save_kwargs:
            plot_kwargs: {views: [lateral]}
"""

run_pipeline(config, output_dir=f"{n_modes}_modes/run{id:02d}")
