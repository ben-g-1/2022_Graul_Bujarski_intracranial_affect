#!/bin/bash

for file_name in `cat C:\Users\bgrau\OneDrive\Documents\GitHub\git_ieeg_affect\scripts\oasis\1-25_filter_list.csv`; do
    ln /mnt/c/Users/bgrau/Matlab/projects/ieeg_affect/oasis/Images/$file_name /mnt/c/Users/bgrau/Matlab/projects/ieeg_affect/oasis/oasis_filter_11.1.22/$file_name
done

for file in `cat c:/Users/bgrau/OneDrive/Documents/GitHub/git_ieeg_affect/scripts/oasis/1-25_filter_list.csv`; 
do cp c:/Users/bgrau/OneDrive/Documents/GitHub/git_ieeg_affect/oasis/Images/$file c:/Users/bgrau/OneDrive/Documents/GitHub/git_ieeg_affect/oasis/filter_1-25; 
done