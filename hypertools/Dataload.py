# Upload data and removing missing data
# datadir = {String} string of the csv file name
# index_label = {Dataframe, Series, List} Group of trial labels used to set the dataframe index
import pandas as pd
import numpy as np

def dataload(datadir, index_label):
    pd.set_option("display.max_column", None)
    data = np.loadtxt(datadir, delimiter=',')
    df = pd.DataFrame(data)
    # Arrange the 48 df index to trial numbers
    df.set_index(index_label, inplace=True)
    # Make time as rows and trials as columns
    df = df.T
    # Now the trial numbers should be the columns
    print("List of columns")
    print(df.columns)
    return df
