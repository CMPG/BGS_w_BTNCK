#!/bin/bash
#SBATCH --mail-user=$USER@campus.unibe.ch
#SBATCH --mail-type=FAIL
#SBATCH --output=./log_sim01/burnin_output_%j_%a.txt
#SBATCH --error=./log_sim01/burnin_error_%j_%a.txt

model=${1}
num_samples=${2}
script_base_name=${3} 
suffix=${4}

printf "\n node_id: ${SLURM_NODEID} \n"
printf "job_node_list: ${SLURM_JOB_NODELIST} \n"
printf "job_numb_nodes: ${SLURM_JOB_NUM_NODES} \n"
printf "job_partition: ${SLURM_JOB_PARTITION} \n"

model_parent_folder="fwd_bottleneck"

#where the script runs from, current $PWD
if [ $USER == "fschlichta" ]
then
    fwd_path="/data/projects/p671_RangeExpansion/${model_parent_folder}"
    module purge

else
    fwd_path="/storage/homefs/$USER/${model_parent_folder}"
	module load GCC
	module load R

fi

# models=($mod2 $mod3)
models=($model)

if [ ${SLURM_ARRAY_TASK_ID} == 1 ]
then
    for m in "${models[@]}"; do
        mkdir -p ./$m

        files=("01_run_${script_base_name}.sh" "01_sim_AncNe_${script_base_name}_noRecovery.slim")

        for f in "${files[@]}"; do
            printf "cp $f $fwd_path/$m/$f \n"
            cp $f $fwd_path/$m/$f
        done

        cp "./param_files/params_${m}.sh" $fwd_path/$m/"params_${m}.sh"

    done
fi    

chmod 777 $fwd_path/*.sh
chmod 777 $fwd_path/*/*.sh

srun --ntasks=1 $fwd_path/$model/01_run_${script_base_name}.sh ${model} ${num_samples} ${suffix} &

wait


printf "\n end of sim TASK ID ${SLURM_ARRAY_TASK_ID} \n"

