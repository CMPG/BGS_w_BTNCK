#!/bin/bash
#SBATCH --output=./log_files/sb12_output_%j_%a.txt
#SBATCH --error=./log_files/sb12_error_%j_%a.txt

# b12_slurm_getIlhasTroughs_countMuts.sh

if [ $USER == "schlichta" ]
then
    printf "running on CMPG Matrix"
elif [ $USER == "flavia" ]
then
	printf "running on inspiron f5566"

elif [ $USER == "fs19b061" ]
then
	module load GCC
	module load R
else
	module load Development/gcc/9.2.1
	module load R


fi


variante=${1}
selCoef=${2}
recover=${3}
chrMB=${4}

oq=${5}
from_rep=${6}
to_rep=${7}
from_gen=${8}
to_gen=${9}


script=b12_getIlhasTroughs_countMuts.R

echo $PWD

full_model=btnck_ancBGS_${variante}_sc${selCoef}_bt380_rt380_n1_50_n2_0_gt_0_mig_0_${chrMB}Mb
cd $HOME/fwd_bottleneck/${full_model}

echo $PWD

printf "\n Rscript ${script} ${variante} ${selCoef} ${recover} ${chrMB} ${oq} ${from_rep} ${to_rep} ${from_gen} ${to_gen} \n"

Rscript ${script} ${variante} ${selCoef} ${recover} ${chrMB} ${oq} ${from_rep} ${to_rep} ${from_gen} ${to_gen}


wait

printf "\n end of TASK ID ${SLURM_ARRAY_TASK_ID} \n"
