"""Post-hoc analysis of a DyNeMo run.

"""

from sys import argv

if len(argv) != 3:
    print("Please pass the number of modes and run id, e.g. python calc_post_hoc.py 8 1")
    exit()
n_modes = int(argv[1])
id = int(argv[2])

from osl_dynamics import run_pipeline

config = """
    load_data:
        inputs: npy
        kwargs:
            sampling_frequency: 250
            mask_file: MNI152_T1_8mm_brain.nii.gz
            parcellation_file: Glasser52_binary_space-MNI152NLin6_res-8x8x8.nii.gz
            n_jobs: 8
        prepare:
            tde_pca: {n_embeddings: 15, n_pca_components: 100}
            standardize: {}
#    get_inf_params: {}
    regression_spectra:
        kwargs:
            frequency_range: [1, 80]
            window_length: 500
            n_sub_windows: 1
            n_jobs: 8
#    plot_group_tde_dynemo_networks:
#        power_save_kwargs:
#            plot_kwargs: {views: [lateral]}
"""

run_pipeline(config, output_dir=f"results/{n_modes}_modes/run{id:02d}")
