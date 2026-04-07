#!/bin/bash -l
#SBATCH --job-name=tiberius-bench
#SBATCH --account=pawsey0000-gpu
#SBATCH --partition=gpu
#SBATCH --nodes=1 
#SBATCH --gres=gpu:1
#SBATCH --time=01:00:00
#SBATCH --array=1-16

GENOME="${MYSCRATCH}/Tiberius/test_data/Panthera_pardus/inp/genome.fa"
OUTDIR="${MYSCRATCH}/tiberius_benchmarking"
mkdir -p ${OUTDIR}

# Clear env vars for each run
unset TF_ROCM_FUSION_ENABLE
unset TF_ENABLE_AUTO_MIXED_PRECISION

case ${SLURM_ARRAY_TASK_ID} in
    1)
        DESC="baseline_b16_s500004"
        BATCH=16; SEQLEN=500004
        ;;
    2)
        DESC="b16_s259992"
        BATCH=16; SEQLEN=259992
        ;;
    3)
        DESC="b8_s500004"
        BATCH=8; SEQLEN=500004
        ;;
    4)
        DESC="b8_s259992"
        BATCH=8; SEQLEN=259992
        ;;
    5)
        DESC="b32_s259992"
        BATCH=32; SEQLEN=259992
        ;;
    6)
        DESC="b16_s500004_fusion"
        BATCH=16; SEQLEN=500004
        export TF_ROCM_FUSION_ENABLE=1
        ;;
    7)
        DESC="b16_s259992_fusion"
        BATCH=16; SEQLEN=259992
        export TF_ROCM_FUSION_ENABLE=1
        ;;
    8)
        DESC="b16_s500004_fp16"
        BATCH=16; SEQLEN=500004
        export TF_ENABLE_AUTO_MIXED_PRECISION=1
        ;;
    9)
        DESC="b8_s259992_fp16"
        BATCH=8; SEQLEN=259992
        export TF_ENABLE_AUTO_MIXED_PRECISION=1
        ;;
    10)
        DESC="b16_s259992_fusion_fp16"
        BATCH=16; SEQLEN=259992
        export TF_ROCM_FUSION_ENABLE=1
        export TF_ENABLE_AUTO_MIXED_PRECISION=1
        ;;
    11)
        DESC="b64_s259992"
        BATCH=64; SEQLEN=259992
        ;;
    12)
        DESC="b32_s500004"
        BATCH=32; SEQLEN=500004
        ;;
    13)
        DESC="b48_s259992"
        BATCH=48; SEQLEN=259992
        ;;
    14)
        DESC="b32_s259992_fusion"
        BATCH=32; SEQLEN=259992
        export TF_ROCM_FUSION_ENABLE=1
        ;;
    15)
        DESC="b40_s259992"
        BATCH=40; SEQLEN=259992
        ;;
    16)
        DESC="b56_s259992"
        BATCH=56; SEQLEN=259992
        ;;
esac

OUTFILE="${OUTDIR}/${DESC}.gtf"

echo "=== Test ${SLURM_ARRAY_TASK_ID}: ${DESC} ==="
echo "Batch size: ${BATCH}"
echo "Seq length: ${SEQLEN}"
echo "TF_ROCM_FUSION_ENABLE: ${TF_ROCM_FUSION_ENABLE:-unset}"
echo "TF_ENABLE_AUTO_MIXED_PRECISION: ${TF_ENABLE_AUTO_MIXED_PRECISION:-unset}"
START=$(date +%s)
echo "Start: $(date)"

module load singularity/4.1.0-nompi

srun -N 1 -n 1 -c 8 --gres=gpu:1 --gpus-per-task=1 \
    singularity exec \
    new_tiber.sif \
    tiberius  \
    --genome ${GENOME} \
    --model_cfg mammalia_softmasking_v2 \
    --out ${OUTFILE} \
    --batch_size ${BATCH} \
    --seq_len ${SEQLEN} \
    2>&1

END=$(date +%s)
ELAPSED=$((END - START))
MINS=$((ELAPSED / 60))
SECS=$((ELAPSED % 60))
echo "End: $(date)"
echo "Walltime: ${MINS}m ${SECS}s (${ELAPSED}s total)"
echo "${DESC},${BATCH},${SEQLEN},${ELAPSED}" >> ${OUTDIR}/summary.csv
