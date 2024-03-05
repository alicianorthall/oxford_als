## Script name: fconnectome_mri_dk
# Purpose: calculate and visualise functional connectomes from preprocessed resting-state time series data using the Desikan-Killiany atlas (68 regions)

# load packages
import os
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import glob

# define the list of subject IDs
subject_list = ["001"]
# subject_list = [
#     "001", "002", "003", "004", "005", "006", "007", "008", "009", "010",
#     "011", "013", "014", "015", "016", "017", "018", "019", "020", "022",
#     "023", "024", "025", "026", "027", "028", "029", "030", "031", "032",
#     "033", "034", "035", "036", "037", "038", "039", "040", "041", "042",
#     "043", "044", "045", "046", "047", "048", "049", "050", "051", "052",
#     "053", "054", "055", "056", "057", "058", "059", "060", "061", "062",
#     "063", "064", "065", "066", "068", "069", "070", "071", "072", "073"
# ]

# loop over subject IDs
for subject_id in subject_list:
    # os.chdir('/vols/Data/als/Alicia/data/*{subject_id}*/rest.ica/fconnectome')

    # Construct the subject folder path with a wildcard to match any folder containing the subject ID
    subject_folder_pattern = '/vols/Data/als/Alicia/data/*' + str(subject_id) + '*/rest.ica/fconnectome'

    # Find the matching folder paths
    matching_folders = glob.glob(subject_folder_pattern)

    if len(matching_folders) == 0:
        print("No matching folder found for subject " + str(subject_id))
        continue

    # Take the first matching folder path
    subject_folder = matching_folders[0]

    # Change current directory to the subject folder
    os.chdir(subject_folder)
    print("Processing subject:", subject_id)

    time_series_all = {}  # dictionary to store data

    # loop over the specified ranges
    for x in range(1001, 1036):
        if x != 1004:  # Exclude 1004 (corpus callosum)
            # file_name = f"fconnectome_{x}.txt"
            file_name = "fconnectome_" + str(x) + ".txt"
            data = np.loadtxt(file_name, dtype=int)
            # time_series_all[f"region_{x}"] = data
            time_series_all["region_" + str(x)] = data


    for x in range(2001, 2036):
        if x != 2004:  # Exclude 2004 (corpus callosum)
            # file_name = f"fconnectome_{x}.txt"
            file_name = "fconnectome_" + str(x) + ".txt"
            data = np.loadtxt(file_name, dtype=int)
            # time_series_all[f"region_{x}"] = data
            time_series_all["region_" + str(x)] = data

    # create a DataFrame from the dictionary
    time_series_all = pd.DataFrame(time_series_all)

    # create the correlation matrix
    correlation_matrix = time_series_all.corr()
    num_regions = correlation_matrix.shape[0]

    # visualise the correlation matrix
    plt.figure(figsize=(10, 8))
    sns.heatmap(correlation_matrix, annot=False)
    plt.title('Functional Connectivity Matrix (fMRI)')
    plt.xlabel('Parcels')
    plt.ylabel('Parcels')
    plt.xticks(np.arange(0, num_regions, 5), np.arange(1, num_regions + 1, 5))
    plt.yticks(np.arange(0, num_regions, 5), np.arange(1, num_regions + 1, 5))

    # save the results (csv, png)
    correlation_matrix.to_csv('correlation_matrix.csv')
    plt.savefig('fconnectome_mri_' + str(subject_id) + '.png')
    plt.close()

    # end of script