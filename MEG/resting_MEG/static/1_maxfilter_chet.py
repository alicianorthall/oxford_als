"""Example script for maxfiltering raw data recorded at Oxford.
Note: this script needs to be run on a computer with a MaxFilter license.
"""

# Authors: Chetan Gohil <chetan.gohil@psych.ox.ac.uk>

from osl.maxfilter import run_maxfilter_batch

# Setup paths to raw (pre-maxfiltered) fif files

input_files = [
"/home/mtrubshaw/Documents/ALS_TMS/raw/s106_rest.fif",

]

# Directory to save the maxfiltered data to
output_directory = "/home/mtrubshaw/Documents/ALS_TMS/maxfiltered"

# Run MaxFiltering
run_maxfilter_batch(
    input_files,
    output_directory,

#Must specify --scanner below:
    "--maxpath /neuro/bin/util/maxfilter --scanner VectorView2 --tsss --mode multistage --headpos --movecomp",


)

