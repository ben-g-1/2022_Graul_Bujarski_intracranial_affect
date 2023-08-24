# Get the class labels:
# trialinfo = {String} filepath of trial info csv file
# class_labels_name {String} string of class label to pop from dataframe
import pandas as pd

def getclasslabels(trialinfo, class_labels_name):
    pd.set_option("display.max_column", None)
    # data = np.loadtxt(trialinfo, delimiter=',')
    data = pd.read_csv(trialinfo)
    # data.index = np.arange(1, len(data) + 1)
    class_labels = data.pop(class_labels_name)
    # pair_labels.index = np.arange(1, len(pair_labels ) + 1)
    print(class_labels)
    return class_labels
