#!/bin/bash

for file_name in `cat /mnt/c/Users/bgrau/OneDrive/Documents/GitHub/2022_Graul_Bujarski_intracranial_affect/oasis_filter_file_names.csv`; do
    ln /mnt/c/Users/bgrau/Matlab/projects/ieeg_affect/oasis/Images/$file_name /mnt/c/Users/bgrau/Matlab/projects/ieeg_affect/oasis/oasis_filter_11.1.22/$file_name
done