"""Example script for checking the data and which scanner data was recorded with.
This script has to be run on a computer with a MaxFilter license.
"""

from subprocess import PIPE, run
import numpy as np


raw_dir =  "/home/mtrubshaw/Documents/ALS_dyn/data/raw/"

files = ["s097_resting.fif",
"s098_resting.fif",
"s099_rest.fif",
"s037_rest.fif",
"s106_rest.fif",
"s139_resting.fif",
"s140_resting.fif",
"s147_resting.fif",
"s152_resting.fif",
"143_restingstate.fif",
"c9_200_rest.fif",
"c9_198_resting.fif",
"c9_197_resting.fif",
"c9_195_resting.fif",
"c9_194_resting.fif",
"c9_196_resting.fif",
"C9_187_resting.fif",
"C9_186_resting_anon.fif",
"C9_188_resting.fif",
"c9_185_resting.fif",
"c9_179_resting.fif",
"C9_168_resting_state.fif",
"C9_167_resting_state.fif",
"C9_166_resting_state.fif",
"C9_165_resting_state.fif",
"C9_201_resting_state.fif",
"C9_204_resting_state.fif",
"C9_158_resting_state.fif",
"C9_211_resting_state.fif",
"C9_210_resting_state.fif",
"C9_212_resting.fif",
"biomox_T3_rs.fif",
"mnd_p01_restopen.fif",
"biomox_s39_rest.fif",
"s43_rest.fif",
"s107_rest.fif",
"s109_rest.fif",
"s157_resting.fif",
"c9_199_resting.fif",
"C9_190_resting.fif",
    ]

ids = []
dates = []
scanners = []

print()
for file in files:
    path = raw_dir + file
    cmd = f"/neuro/bin/util/show_fiff -v -t 100:206 {path}"
    result = run(cmd.split(), stdin=PIPE, stdout=PIPE, stderr=PIPE)
    stdout = result.stdout.splitlines()
    date = str(stdout[0]).split("    ")[-1][2:-1]
    scanner = str(stdout[1]).split("    ")[-1][2:-1]

    print(file)
    print(f"date:    {date}")
    print(f"scanner: {scanner}")
    print()
    ids.append(file)
    dates.append(date)
    scanners.append(scanner)
    
    output = [ids,dates,scanners]
    
    


print("See: https://github.com/OHBA-analysis/osl/tree/examples/examples/oxford/maxfilter for what to use for the --scanner argument.")