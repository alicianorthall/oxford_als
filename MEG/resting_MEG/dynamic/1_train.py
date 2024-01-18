"""Train DyNeMo.

"""

from sys import argv

if len(argv) != 3:
    print("Please pass the number of modes and run id, e.g. python train.py 8 1")
    exit()
n_modes = int(argv[1])
id = int(argv[2])

from osl_dynamics import run_pipeline

config = f"""
    load_data:
        inputs: ../data/npy
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

run_pipeline(config, output_dir=f"results/{n_modes}_modes/run{id:02d}")
