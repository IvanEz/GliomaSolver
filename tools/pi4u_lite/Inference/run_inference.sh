#!/bin/sh
echo "Use mpicc:"
which mpicc

#Number of MPI ranks
M="$1"

mpirun -np $M ./engine_tmcmc

./extractInferenceOutput.sh
