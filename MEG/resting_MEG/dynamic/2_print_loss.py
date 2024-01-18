"""Prints the free energy of each run.

"""

import pickle
import numpy as np

n_modes = 7

print(f"Looking at {n_modes}_modes")

def get_best_run(min_, max_):
    best_fe = np.Inf
    for run in range(min_, max_ + 1):
        history = pickle.load(open(f"{n_modes}_modes/run{run:02d}/model/history.pkl", "rb"))
        fe = history["free_energy"]
        if fe < best_fe:
            best_run = run
            best_fe = fe
    return best_run

print("Best run from 1-10:", get_best_run(1, 10))
print("Best run from 11-20:", get_best_run(11, 20))
print("Best run from 21-30:", get_best_run(21, 30))
print("Best run from all:", get_best_run(1, 30))
