# load packages
import os
import numpy as np
import pandas as pd
import seaborn as sn
import matplotlib.pyplot as plt

# change current directory - CON 001
os.chdir('/Users/alicianorthall/Downloads/fconnectome_final/001')

# print current directory
current_working_directory = os.getcwd()
print(current_working_directory)

data_dict = {}  # dictionary to store data

for x in range(1, 53):  # note: range(1, 53) includes 1 but excludes 53
    file_name = f"fconnectome_{x}.txt"
    data = np.loadtxt(file_name, dtype=int)
    data_dict[f"region_{x}"] = data

# create a DataFrame from the dictionary and transpose it
df = pd.DataFrame(data_dict)

# now, df is a DataFrame where each column is a file, and columns are named "region_1", "region_2", etc.
print(df)

# create a correlation matrix between columns of df, then display as heatmap
corr_matrix_001 = df.corr()
# sn.heatmap(corr_matrix_001, annot=False)
sn.heatmap(corr_matrix_001, annot=False, cmap='rocket_r')
plt.show()

# change current directory - PAT 006
os.chdir('/Users/alicianorthall/Downloads/fconnectome_final/006')

# print current directory
current_working_directory = os.getcwd()
print(current_working_directory)

data_dict = {}  # dictionary to store data

for x in range(1, 53):  # note: range(1, 53) includes 1 but excludes 53
    file_name = f"fconnectome_{x}.txt"
    data = np.loadtxt(file_name, dtype=int)
    data_dict[f"region_{x}"] = data

# create a DataFrame from the dictionary and transpose it
df = pd.DataFrame(data_dict)

# now, df is a DataFrame where each column is a file, and columns are named "region_1", "region_2", etc.
print(df)

# create a correlation matrix between columns of df, then display as heatmap
corr_matrix_006 = df.corr()
# sn.heatmap(corr_matrix_006, annot=False)
sn.heatmap(corr_matrix_006, annot=False, cmap='rocket_r')
plt.show()

import numpy as geek
diff = geek.subtract(corr_matrix_001,corr_matrix_006) 
sn.heatmap(diff, annot=False, cmap='rocket_r')
plt.show()