import os
import shutil
from tkinter import *
from tkinter import filedialog

root = Tk()
root.withdraw()

# Change these variables

filePath = 'C:\\Users\\bgrau\\OneDrive\\Documents\\GitHub\\git_ieeg_affect\\scripts\\oasis\\1-27_filter_list.csv'
folderPath = 'C:\\Users\\bgrau\\OneDrive\\Documents\\GitHub\\git_ieeg_affect\\oasis\\images\\'
destination = 'C:\\Users\\bgrau\\OneDrive\\Documents\\GitHub\\git_ieeg_affect\\oasis\\filter_1-27\\'

# First, create a list and populate it with the files

# you want to find (1 file per row in myfiles.txt)

filesToFind = []
with open(filePath, "r") as fh:
    for row in fh:
        filesToFind.append(row.strip() + ".jpg")

# Had an issue here but needed to define and then reference the filename variable itself
for filename in os.listdir(folderPath):
    if filename in filesToFind:
        filename = os.path.join(folderPath, filename)
        shutil.copy(filename, destination)
    #else:
    #    print(filename, "is not copied")
