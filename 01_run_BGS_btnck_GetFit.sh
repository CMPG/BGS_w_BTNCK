#!/bin/bash

# --- Print input arguments and environment setup ---
printf "\n running model $1 \n"
printf "\n changing to directory $PWD/$1 \n"
printf "\n sample size & replicate: $2 - $SLURM_ARRAY_TASK_ID \n"

# Assign input arguments to variables
model=${1}               # Model name (e.g., Ne scenario)
num_samples=${2}         # Number of samples to be taken
suffix=${3}              # Suffix specifying burn-in variant (e.g., recombination regime)

# Replicate number taken from SLURM array job ID
replicate=$SLURM_ARRAY_TASK_ID

# Define burn-in scenario type
burnin_type="ancBGS_${suffix}" # e.g., ancBGS_lowRec

# --- Define key paths and folders ---
HOME="/storage/homefs/fs*****"
FWD_FOLDER="fwd_bottleneck"     # Folder containing forward simulations
sim_path="${HOME}/${FWD_FOLDER}/${model}"  # Full simulation path

echo "burn-in type: ${burnin_type} |l24|"
echo "home: $HOME |l25|"
echo fwd folder: $FWD_FOLDER
echo sim_path: $sim_path

# Load required compiler module
module load GCC

# --- Load simulation parameters ---
echo param file: "${HOME}/${FWD_FOLDER}/param_files/params_${model}.sh"
source ${HOME}/${FWD_FOLDER}/param_files/params_"${model}".sh

# --- Set tree path based on chromosome length ---
slim_path="${HOME}/SLiM34/build"  # SLiM executable path
    if [ ${chrL} == 100000000 ]; then
        treepath="${HOME}/${FWD_FOLDER}/BGS_burn_in_tree_files_${suffix}_100Mb"
        echo $treepath
    else
        treepath="${HOME}/${FWD_FOLDER}/BGS_burn_in_tree_files_${suffix}_20Mb"
        echo $treepath
    fi

echo "TREE PATH: ${treepath}"

# --- Create working directories ---
cd ${sim_path}
echo CURR DIR: "${PWD} |l50|"
echo making folders: "${sim_path}/${replicate} |l51|"
mkdir -p ${sim_path}                     # Ensure model directory exists
mkdir -p ${sim_path}/${replicate}       # Create replicate-specific output folder

echo "final TREE PATH: ${treepath}"

# --- Setup temporary directory for simulation ---
tdir=$TMPDIR                            # Use TMPDIR for temp output

# Create temp folders
mkdir -p $tdir/${model}
mkdir -p $tdir/${model}/$replicate

# Define output directory for VCFs and trees
out_dir="${tdir}/${model}/${replicate}/vcf_files"
echo OUT PATH: "${out_dir} |+|l66"
mkdir -p $out_dir

# Burn-in files source path
burnin_path="${treepath}"
echo BI PATH: ${burnin_path}

# Update sim_path to point to replicate subfolder
sim_path=$sim_path/$replicate
echo "sim path is now: ${sim_path} |+|l75"

# --- Prepare SLiM simulation script ---
sim_file="01_sim_AncNe_BGS_btnck_GetFit_noRecovery.slim"
echo "SIM FILE: $sim_file |+|l79"

# Copy base SLiM script to simulation directory
cp ${HOME}/fwd_bottleneck/${sim_file} $sim_path/${sim_file}
cd $sim_path

# Replace placeholders in SLiM script with concrete values
sed -i "s/_burn_in_/$(($burn+100))/g" $sim_path/$sim_file
sed -i "s/_other_gens_/$(($burn+100+1))/g" $sim_path/$sim_file
sed -i "s/_next_geracoes_/$(($burn+100+2))/g" $sim_path/$sim_file
sed -i "s/_end_sim_/$(($burn+100+500))/g"  $sim_path/$sim_file

# --- Print SLiM execution command ---
printf "\n $slim_path/slim -d L=${chrL} \
-d burn=$burn \n
-d out_path=${out_dir} \n
-d rep=$replicate \n
-d selCoefID=${selCoefID} \n
-d burnin_path=${burnin_path} \n
-d btnck_size=${btnck_size} \n
-d samp_interval=${samp_interval} \n
-d num_samples=${num_samples} \n
-d gen_end_bottleneck=${gen_end_bottleneck} \n
-d mig=${mig} \n
-d gen_end_recovery=${gen_end_recovery} \n
-d dom_diff=${dom_diff} \n
-d dom=${dom} \n
-d isDFE=${isDFE}
-d shapePAR=${shapePAR}
-t -l $sim_path/$sim_file &> $sim_path/end_slim_BGS_btnck_${selCoefID}_${replicate}.output l102\n"

# --- Run SLiM simulation with provided parameters ---
$slim_path/slim -d L=${chrL} \
-d burn=$burn \
-d "out_path='${out_dir}'" \
-d rep=$replicate \
-d "selCoefID='${selCoefID}'" \
-d "burnin_path='${burnin_path}'" \
-d btnck_size=${btnck_size} \
-d samp_interval=${samp_interval} \
-d num_samples=${num_samples} \
-d gen_end_bottleneck=${gen_end_bottleneck} \
-d mig=${mig} \
-d gen_end_recovery=${gen_end_recovery} \
-d dom_diff=${dom_diff} \
-d dom=${dom} \
-d isDFE=${isDFE} \
-d shapePAR=${shapePAR} \
-t -l $sim_path/$sim_file &> $sim_path/end_slim_BGS_btnck_${selCoefID}_${replicate}.output

# --- Compress simulation outputs ---
gzip -f $out_path/*.vcf
gzip -f $out_path/*.trees

# --- Copy results from temp to final location ---
rsync -arv --progress --remove-source-files ${tdir}/${model}/${replicate}/* $sim_path
