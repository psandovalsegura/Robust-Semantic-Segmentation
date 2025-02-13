#!/bin/sh
#SBATCH --account=djacobs
#SBATCH --job-name=city-advprop
#SBATCH --time=1-12:00:00
#SBATCH --partition=dpart
#SBATCH --qos=high
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=8G
#SBATCH --gres=gpu:p6000:4
#SBATCH --output=s-%j-%x.out
#SBATCH --mail-type=end          
#SBATCH --mail-type=fail         
#SBATCH --mail-user=psando@umd.edu
#--SBATCH --dependency=afterany:

# Usage:
#   sbatch scripts/train.sh config/paper/voc2012/voc2012_pspnet50.yaml train_sat_psp None
#                           [                   $1                   ] [     $2    ] [$3]

# Setup environment
export SCRIPT_DIR="/cfarhomes/psando/Documents/Robust-Semantic-Segmentation"
export WORK_DIR="/scratch0/slurm_${SLURM_JOBID}"

# Parse experiment name from train script filename
NOW=$(date +"%Y%m%d_%H%M%S")
EXPERIMENT_NAME=${2} #$(basename $1 .yaml)
echo "Date stamp: ${NOW}"
echo "Training according to the config: ${1}"
echo "Experiment name: ${EXPERIMENT_NAME}"


# Copy training and config files to experiment directory
EXPERIMENT_DIR=/vulcanscratch/psando/semseg_experiments/${EXPERIMENT_NAME}
mkdir -p ${EXPERIMENT_DIR}
cp scripts/train_voc_psp.sh tool_train/${EXPERIMENT_NAME}.py tool_test/voc2012/test_voc_psp.py $1 ${EXPERIMENT_DIR}

# Setup environment
module add cuda/10.2.89 gcc/7.5.0
# cd /cfarhomes/psando/apex
# pip install -v --disable-pip-version-check --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./
cd $SCRIPT_DIR

# Train and validate
export PYTHONPATH=${PYTHONPATH}:${SCRIPT_DIR}
python ${EXPERIMENT_DIR}/${EXPERIMENT_NAME}.py --config=${EXPERIMENT_DIR}/$(basename $1) experiment_name ${EXPERIMENT_NAME} resume $3
python ${EXPERIMENT_DIR}/test_voc_psp.py --config=${EXPERIMENT_DIR}/$(basename $1) experiment_name ${EXPERIMENT_NAME}
