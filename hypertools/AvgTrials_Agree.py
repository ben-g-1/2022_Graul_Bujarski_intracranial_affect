# Get averaged power of trials within time (index)
# Arguments are split dataframes of conditions (e.g., agree vs. disagree trial conditions)
# dfs = {Dataframe} dfs that have be split into conditions and yet to be averaged
    # Number of arguments = 2
# axis = {Int} Determines if dataframe should be averaged column or row-wise
#   ex: 1 or 0
import pandas as pd

def avgtrials(*dfs, axis):
    df1 = pd.DataFrame()
    df2 = pd.DataFrame()
    avg_dfs = [df1, df2]
    count = 0
    for trial in dfs:
        # Make the average as new DataFrame
        average = trial.mean(axis)
        # Add the average as a new column to the DataFrame
        avg_dfs[count] = average
        count = count + 1
    return [df1, df2]
