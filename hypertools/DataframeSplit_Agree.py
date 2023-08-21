# Make two dfs: with agree column trials, and other with disagree column trials
# df = {DataFrame} Datafrmae to split into conditions
# condition_labels = {Dataframe, Series, List} Group of class labels used to split into two conditions
# label_names = {List of strings} Names of labels to differentiate the conditions
# label_number = {List of int} Numbers of the label to differentiate the conditions

import pandas as pd

def group_agree(df, condition_labels, label_names, label_number):
    count = 0
    column = df.iloc[:, count]
    column_name = df.columns[count]
    print("Column name:", column_name)
    print("Column:")
    print(column)

    df1 = pd.DataFrame()
    df2 = pd.DataFrame()
    for label in condition_labels:
        if label == label_number[0]:
            df1[column_name] = column
            print(label_names[0] + ":")
            print(df1[column_name])
        elif label == label_number[1]:
            df2[column_name] = column
            print(label_names[1] + ":")
            print(df2[column_name])
        count = count + 1
        print(count)
        print(len(df.columns))
        if count == len(df.columns):
            break
        column = df.iloc[:, count]
        column_name = df.columns[count]
    return [df1, df2]
