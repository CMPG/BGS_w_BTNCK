#!/bin/bash
#SBATCH --mail-user=fs190b61@campus.unibe.ch
#SBATCH --mail-type=END,FAIL
#SBATCH --mem-per-cpu=5G
#SBATCH --output=./log_files/sb11_output_%j_%a.txt
#SBATCH --error=./log_files/sb11_error_%j_%a.txt
#SBATCH --time=24:00:00
# b11_slurm_getMasterTableAlleleC.sh

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


sim_type=${1}
selCoef=${2}
recover=${3}
chr_size=${4}
cpop=${5}
from=${6}
to=${7}

echo $PWD

echo $PWD
script="b11_getMasterTable_alleleC_mutsC.R"

# mainCase = as.character(args[1]) # h010LoRec
# selCoef = as.character(args[2]) # 0015
# recovery = as.character(args[3]) # no
# chrL = as.character(args[4]) # 20

printf "\n Rscript ${script} ${sim_type} ${selCoef} ${recover} ${chr_size} ${cpop} ${from} ${to} & \n"


Rscript ${script} ${sim_type} ${selCoef} ${recover} ${chr_size} ${cpop} ${from} ${to} &
	
wait

printf "\n end of TASK ID ${SLURM_ARRAY_TASK_ID} \n"
