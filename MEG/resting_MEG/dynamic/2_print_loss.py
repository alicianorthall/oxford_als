"""Prints the free energy of each run.

"""

import pickle
import numpy as np
from sys import argv

if len(argv) != 2:
    print("Please pass the number of modes, e.g. python print_loss.py 8")
    exit()
n_modes = int(argv[1])

def get_best_run(min_, max_):
    best_fe = np.Inf
    for run in range(min_, max_ + 1):
        history = pickle.load(open(f"results/{n_modes}_modes/run{run:02d}/model/history.pkl", "rb"))
        fe = history["free_energy"]
        if fe < best_fe:
            best_run = run
            best_fe = fe
    return best_run

print("Best run from 1-10:", get_best_run(1, 10))
print("Best run from 11-20:", get_best_run(11, 20))
print("Best run from 21-30:", get_best_run(21, 30))
