"""Train DyNeMo.

"""

from sys import argv

if len(argv) != 2:
    print("Please pass the run id, e.g. python train_dynemo.py 1")
    exit()
id = int(argv[1])

from osl_dynamics import run_pipeline

n_modes = 7

config = f"""
    load_data:
        inputs: ../data/src_npy
        kwargs:
            use_tfrecord: True
            n_jobs: 8
        prepare:
            tde_pca: {{n_embeddings: 15, n_pca_components: 100}}
            standardize: {{}}
    train_dynemo:
        config_kwargs:
            n_modes: {n_modes}
            learn_means: False
            learn_covariances: True
            n_kl_annealing_epochs: 10
            n_epochs: 20
            learning_rate: 0.001
        init_kwargs:
            n_init: 10
            n_epochs: 2
        save_inf_params: False
"""

run_pipeline(config, output_dir=f"{n_modes}_modes/run{id:02d}")
