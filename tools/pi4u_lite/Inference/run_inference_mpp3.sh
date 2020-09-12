#!/bin/bash

#General Options
#SBATCH -D .                        #Start job in specified directory
#SBATCH --mail-user=     #E-mail Adress (obligatory)
#SBATCH --mail-type=NONE       # change to get email notifications
#SBATCH -J PI                #Name of batch request (not more than 8 characters or so)
#SBATCH -o jobLog.%j.%N.out      #write standard output to specified file
#SBATCH --export=NONE               #export designated envorinment variables into job script

#Job control
#SBATCH --time=03:00:00             #Maximum runtime
#SBATCH --nodes=8                   #number of nodes to be used
#SBATCH --ntasks-per-node=64         #tasks runnable on each node
#SBATCH --tasks=512                #expected amount of tasks
##SBATCH --overcommit               #allow more than one task per CPU
##SBATCH --ntasks-per-core          #tasks per core
#SBATCH --cpus-per-task=1           #specify ampunt of CPUs for every single task
#SBATCH --clusters=mpp3              #cluster to be used (testing: inter)
#SBATCH --partition=mpp3_batch      #node on this cluster to be used   (testig: mpp3_inter)
#SBATCH --get-user-env

module load slurm_setup
# Modules
source /etc/profile.d/modules.sh
module purge
#module load admin/1.0 lrz/default gsl/2.3 tempdir  #gsl/2.3 causes: "libgsl.so.23 cannot open shared object file no such file or directory"
module load admin lrz tempdir
#WARNING(gsl/2.3): This module is scheduled for retirement.
#WARNING(gcc/4.9): This module is scheduled for retirement.
module load gcc #requirement: tempdir
module load spack
module load intel       #requirement: spack
module load mpi.intel   #requirement: intel
#on inter nodes: "intel-mpi/2018-gcc" as newer mpi version causes errors (State: April 2020)
module load mkl
#on inter nodes: "intel-mkl/2018"
module load gsl     #requires intel/19.1.0
module load matlab   #extracting the Inference output needs this!
module list

# Libraries
export LIB_BASE=$HOME/IBBM/GliomaSolver/lib
export LD_LIBRARY_PATH=$LIB_BASE/tbb40_20120613oss/build/linux_intel64_gcc_cc4.6.1_libc2.5_kernel2.6.18_release/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LIB_BASE/myVTK/lib/vtk-5.4/:$LD_LIBRARY_PATH
export PATH=$HOME/usr/torc/bin:$PATH
export LD_LIBRARY_PATH=$HOME/usr/torc/bin:$LD_LIBRARY_PATH
export PATH=$PATH:$LIB_BASE/mpich-install/bin/
export LD_LIBRARY_PATH=$LIB_BASE/mpich-install/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/lrz/sys/tools/intel-mpi-wrappers/bin/mpicc:$LD_LIBRARY_PATH

echo "Using this mpicc:"
which mpicc

export LANG=C
export LC_ALL=C
export OMP_NUM_THREADS=$SLURM_NTASKS_PER_NODE
#export I_MPI_DEBUG=5   #for extra debugging output

echo "In the directory: $PWD"
echo "Running program on $SLURM_NNODES nodes with $SLURM_CPUS_PER_TASK tasks, each with $SLURM_CPUS_PER_TASK cores."
echo "OMP_NUM_THREADS: $OMP_NUM_THREADS"


mpirun -env TORC_WORKERS 1 ./engine_tmcmc
#mpirun -np 64 -env TORC_WORKERS 1 ./engine_tmcmc


./extractInferenceOutput_LRZ.sh
