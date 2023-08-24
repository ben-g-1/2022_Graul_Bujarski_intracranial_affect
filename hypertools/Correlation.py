import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd

# cond_list = {List} list of the condition to compare
# cond_names = {List, Series} group of condition names that corresponds to the condition list

def cor(cond_list, cond_names):
    data = []

    for condition in cond_list:
        cond_array = np.array(condition)
        cond_array = cond_array.flatten()
        data.append(cond_array)

    df = pd.DataFrame(data, columns=cond_names)
    correlation_matrix = df.corr()
    plt.figure(figsize=(10, 8))  # Adjust the figure size as needed
    sns.heatmap(correlation_matrix, annot=True, cmap='coolwarm', fmt='.2f')
    plt.title('Correlation Matrix')
    png_file = input("Name of correlation matrix heatmap csv file")
    plt.savefig(png_file)
    plt.show()
