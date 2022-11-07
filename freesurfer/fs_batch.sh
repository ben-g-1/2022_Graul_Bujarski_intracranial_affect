#!/bin/bash

for subj in `cat <subjid_file>.txt`; do
   sbatch \
   -o ~/logfiles/${1}/output_${subj}.txt \
   -e ~/logfiles/${1}/error_${subj}.txt \
   ~/scripts/class/freesurfer_job.sh \
   ${subj}
   sleep 1
done