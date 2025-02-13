#!/bin/sh
#SBATCH --account=djacobs
#SBATCH --job-name=test-city-x
#SBATCH --time=1-00:00:00
#SBATCH --partition=dpart
#SBATCH --qos=medium
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=8G
#SBATCH --gres=gpu:gtx1080ti:1
#SBATCH --output=s-%j-%x.out
#--SBATCH --mail-type=end          
#--SBATCH --mail-type=fail         
#--SBATCH --mail-user=psando@umd.edu
#--SBATCH --dependency=afterok:

# Usage:
#   sbatch scripts/test_city_psp.sh config/paper/cityscapes/cityscapes_pspnet50.yaml train_psp

# Setup environment
export SCRIPT_DIR="/cfarhomes/psando/Documents/Robust-Semantic-Segmentation"
export WORK_DIR="/scratch0/slurm_${SLURM_JOBID}"

# Parse experiment name from config filename
NOW=$(date +"%Y%m%d_%H%M%S")
EXPERIMENT_NAME=${2} #$(basename $1 .yaml)
echo "Date stamp: ${NOW}"
echo "Training according to the config: ${1}"
echo "Experiment name: ${EXPERIMENT_NAME}"


# Copy training and config files to experiment directory
EXPERIMENT_DIR=/vulcanscratch/psando/semseg_experiments/${EXPERIMENT_NAME}
mkdir -p ${EXPERIMENT_DIR}
cp scripts/test_city_psp.sh tool_test/cityscapes/test_city_psp.py $1 ${EXPERIMENT_DIR}

module add cuda/10.2.89 gcc/7.5.0

# Setup environment
source /cfarhomes/psando/.bashrc
conda activate seg
# cd /cfarhomes/psando/apex
# pip install -v --disable-pip-version-check --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./
# cd $SCRIPT_DIR

# Train and validate
# Common overrides: skip_clean True  has_prediction True index_start 165 test_attack_steps [2,4,6]
export PYTHONPATH=${PYTHONPATH}:${SCRIPT_DIR}
python ${EXPERIMENT_DIR}/test_city_psp.py --config=${EXPERIMENT_DIR}/$(basename $1) experiment_name ${EXPERIMENT_NAME} workers 2
