#!/bin/bash

# Name of the job (* specify job name)
#SBATCH --job-name=eeg_perms

# Number of compute nodes
#SBATCH --nodes=1

# Number of CPUs per task
#SBATCH --cpus-per-task=8

# Request memory
#SBATCH --mem-per-cpu=4gb

# save logs (change YOUR-DIRECTORY to where you want to save logs)
#SBATCH --output=/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/EEE_projects_imgview/logs/perm_output_%j.txt
#SBATCH --output=/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/EEE_projects_imgview/logs/perm_error_%j.txt

# Walltime (job duration)
#SBATCH --time=24:00:00

# Array jobs (* change the range according to # of subject; % = number of active job array tasks)
#SBATCH --array=1-5%5

# Email notifications (*comma-separated options: BEGIN,END,FAIL)
#SBATCH --mail-type=BEGIN,END,FAIL

# Account to use (*change to any other account you are affiliated with)
#SBATCH --account=dbic

# Parameters

chans=${SLURM_ARRAY_TASK_ID}
outpath=/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/EEE_projects_imgview/perms

module purge
module load matlab/r2022a

matlab -batch 'permtest_test'

echo "Submitted batch " ${SLURM_ARRAY_TASK_ID}