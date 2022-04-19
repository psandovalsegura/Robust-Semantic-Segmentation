#!/bin/sh
#SBATCH --account=djacobs
#SBATCH --job-name=test-all-voc
#SBATCH --time=1-12:00:00
#SBATCH --partition=dpart
#SBATCH --qos=default
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=8G
#SBATCH --gres=gpu:gtx1080ti:1
#SBATCH --output=s-%j-%x.out
#SBATCH --mail-type=end          
#SBATCH --mail-type=fail         
#SBATCH --mail-user=psando@umd.edu
#--SBATCH --dependency=afterok:

# Usage:
#   sbatch scripts/test_voc.sh config/paper/voc2012/voc2012_pspnet50.yaml

# Setup environment
export SCRIPT_DIR="/cfarhomes/psando/Documents/Robust-Semantic-Segmentation"
export WORK_DIR="/scratch0/slurm_${SLURM_JOBID}"
export EXPERIMENT_NAME="all_voc"

# Parse experiment name from config filename
NOW=$(date +"%Y%m%d_%H%M%S")
echo "Date stamp: ${NOW}"
echo "Training according to the config: ${1}"
echo "Experiment name: ${EXPERIMENT_NAME}"

module add cuda/10.2.89 gcc/7.5.0

# Setup environment
source /cfarhomes/psando/.bashrc
conda activate seg
# cd /cfarhomes/psando/apex
# pip install -v --disable-pip-version-check --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./
# cd $SCRIPT_DIR

# Train and validate
export PYTHONPATH=${PYTHONPATH}:${SCRIPT_DIR}

declare -a EXP_NAMES=('train_psp' 'train_sat_psp' 'train_advprop_psp')
for EXP_NAME in ${EXP_NAMES[@]}; do

# Copy training and config files to experiment directory
EXPERIMENT_DIR=/vulcanscratch/psando/semseg_experiments/${EXP_NAME}
mkdir -p ${EXPERIMENT_DIR}
cp tool_test/voc2012/test_voc_psp.py $1 ${EXPERIMENT_DIR}
python ${EXPERIMENT_DIR}/test_voc_psp.py --config=${EXPERIMENT_DIR}/$(basename $1) experiment_name ${EXP_NAME} workers 2 has_prediction True

done

