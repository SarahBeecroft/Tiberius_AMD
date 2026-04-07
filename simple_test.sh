#!/bin/bash -l
#SBATCH --job-name=tiber-test
#SBATCH --account=pawsey0000-gpu
#SBATCH --partition=gpu
#SBATCH --nodes=1 
#SBATCH --gres=gpu:1
#SBATCH --time=01:00:00


git clone https://github.com/SarahBeecroft/Tiberius_AMD.git
CONTAINER=${MYSCRATCH}/Tiberius_AMD/tiberius_latest.sif
GENOME=${MYSCRATCH}/Tiberius_AMD/Tiberius/test_data/Panthera_pardus/inp/genome.fa
OUTDIR=${MYSCRATCH}/tiberius_test
mkdir -p ${OUTDIR}

module load singularity/4.1.0-nompi

srun -N 1 -n 1 -c 8 --gres=gpu:1 --gpus-per-task=1 \
    singularity exec \
    ${CONTAINER} \
    tiberius  \
    --genome ${GENOME} \
    --model_cfg mammalia_softmasking_v2 \
    --out ${OUTFILE} \
    --batch_size 32 \
    --seq_len 259992