import os
import csv
import pandas as pd
import shutil
from pathlib import Path
list = os.listdir('C:\\Users\\bgrau\\GitHub\\git_ieeg_affect\\oasis\\filter_1-31')

f=open('C:\\Users\\bgrau\\GitHub\\git_ieeg_affect\\oasis\\filter_1-31.csv','w')
w=csv.writer(f)
for path, dirs, files in os.walk("C:\\Users\\bgrau\\GitHub\\git_ieeg_affect\\oasis\\filter_1-31"):
    for filename in files:
        w.writerow([filename])