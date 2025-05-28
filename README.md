# BGS_w_BTNCK

- [BGS\_w\_BTNCK](#bgs_w_btnck)
  - [1. Trough Statistics](#1-trough-statistics)
  - [2. s(b11): Obtain table with Number of mutations per genomic window](#2-sb11-obtain-table-with-number-of-mutations-per-genomic-window)
  - [3. s(b12) narrow down counts to either feature](#3-sb12-narrow-down-counts-to-either-feature)
    - [3.1 Islands of Diversity](#31-islands-of-diversity)
    - [3.2 Troughs of Diversity](#32-troughs-of-diversity)
  - [4. Bootstrap feature mutation count](#4-bootstrap-feature-mutation-count)
  - [5. Proportion data relative to the number of deleterious mutations within feature (produces Figure 5)](#5-proportion-data-relative-to-the-number-of-deleterious-mutations-within-feature-produces-figure-5)
- [Main figures](#main-figures)



## 1. Trough Statistics
Data Analisys obtaining trough statitics and relative diversity loss were previously detailed here: https://github.com/CMPG/genomicSurfing (items 2.1 through 2.5).
Very briefly, it uses VCF files sampled during simulation to window and calculate diversity; Then separates the information on troughs (based on levels of ancestral diversity) and characterises them in a summary over time.

Used to obtain:
- [Figure 1](./MainFigures/Fig1@Vector.svg)
- [Figure 2](./MainFigures/Fig2@Vector.svg)
- [Figure 3](./MainFigures/Fig3@Vector.svg)
- [Figure 4](./MainFigures/Fig4@Vector.svg)


## 2. s(b11): Obtain table with Number of mutations per genomic window

Uses genomic profiles and VCF files to count mutations within genomic windows
scripts: b11_slurm_getMasterTableAlleleC.sh ⏭ b11_getMasterTable_alleleC_mutsC.R

Command:
```sh

chrMB="20"
variante="h010LoRec"
list_sc=("0010")
recover="no"
cpop="p2"
from=1
to=100


for selCoef in "${list_sc[@]}"; do
    full_model=BGS_burnin_${variante}_c20_e0_l100_g0_d0_sel_${selCoef}_${chrMB}Mb
    cd $HOME/fwd_bottleneck/${full_model}

    TCU=$(sbatch --cpus-per-task=2 --array=1 -p bdw-invest --parsable --mem-per-cpu=2G --time=03:59:59 b11_slurm_getMasterTableAlleleC.sh ${variante} ${selCoef} ${recover} ${chrMB} ${cpop} ${from} ${to})

    printf "$TCU $selCoef\t"

done

```

Data output sample: [mutCountsALL_wID_alleleC_gScan_%%](./Intermediate%20Files_CLEAN.md/#1-obtain-number-of-deleterious-mutations-per-genomic-window)

## 3. s(b12) narrow down counts to either feature

Isolates data from either feature (based on ancestral levels of diversity) and combines it with mutaion count data (item 2)
Scripts: b12_slurm_getIlhasTroughs_countMuts.sh ⏭ b12_getIlhasTroughs_countMuts.R
Also summarises data per replicate and generation
Data output sample: 
- RAW: [ilhasOfDiv](./Intermediate%20Files_CLEAN.md/#1a-islands-of-diversity)
- SUMMARIZED: [summaIlhasOfDiv](./Intermediate%20Files_CLEAN.md/#1a2-summarise-raw-data-1a1-per-generation-and-replicate)


### 3.1 Islands of Diversity

```sh

variante="h010"
selCoef="0015"
recover="no"
chrMB="20"

oq="ilhas"
from_rep=1
to_rep=100
from_gen=100005
to_gen=100380


script=b12_slurm_getIlhasTroughs_countMuts.sh


full_model=btnck_ancBGS_${variante}_sc${selCoef}_bt380_rt380_n1_50_n2_0_gt_0_mig_0_${chrMB}Mb
cd $HOME/fwd_bottleneck/${full_model}

TCU=$(sbatch --cpus-per-task=2 --array=1 -p bdw-invest --parsable --mem-per-cpu=5G --time=23:59:59 ${script} ${variante} ${selCoef} ${recover} ${chrMB} ${oq} ${from_rep} ${to_rep} ${from_gen} ${to_gen})


printf "$TCU\t$selCoef\n"

```


### 3.2 Troughs of Diversity

```sh

variante="h010"
selCoef="0015"
recover="no"
chrMB="20"

oq="trough"
from_rep=1
to_rep=100
from_gen=100005
to_gen=100380


script=b12_slurm_getIlhasTroughs_countMuts.sh


full_model=btnck_ancBGS_${variante}_sc${selCoef}_bt380_rt380_n1_50_n2_0_gt_0_mig_0_${chrMB}Mb
cd $HOME/fwd_bottleneck/${full_model}

TCU=$(sbatch --cpus-per-task=2 --array=1 -p bdw-invest --parsable --mem-per-cpu=5G --time=23:59:59 ${script} ${variante} ${selCoef} ${recover} ${chrMB} ${oq} ${from_rep} ${to_rep} ${from_gen} ${to_gen})

printf "$TCU\t$selCoef\n"

```



## 4. Bootstrap feature mutation count
Bootstrap results to produce [Supplementary Figure S8](./MainFigures/SuppFig_S8_xx_from00MS02_v2_BOOTS_IslandSize_h010xCoDo_17_Nov_20h_37m_52s.svg)

Data output sample: [boot%sx_ILHAS_%s_sc%s_%sMb_%s.txt](./Intermediate%20Files_CLEAN.md/#1a3-bootstrap-summarised-data-1a2)

```sh

selType="10K"
nBOOT=10000
dpath="../b13_btnck_recovery/plot_proj/00_BGS_data"
chrL=20
meiota="bt380_rt380_n1_50_n2_0_gt_0_mig_0"
cur_metric="size"


simType_list=("CoDomLoRec" "h010LoRec")
selCoef_list=("0015" "0015")

for i in "${!selCoef_list[@]}"; do
    selCoef="${selCoef_list[$i]}"
    simType="${simType_list[$i]}"
    printf "$cur_metric $simType\n"
    printf "$nBOOT $cur_metric $dpath $selCoef $chrL $selType $simType $meiota\n" >> out_${cur_metric}_v1.txt
    Rscript bootIlhasDiversity.R $nBOOT $cur_metric $dpath $selCoef $chrL $selType $simType $meiota &>> out_$cur_metric.txt
done

```


## 5. Proportion data relative to the number of deleterious mutations within feature (produces Figure 5)

Scripts:
- calculation: 0v2.2_onlyOpenData_MultiModel.R
- plotting: 0v2.6_onlyPDF_PropPlot_MultiModel_withTroughWhite.R
- save data: 0v2.5_write2File_PropPlot_MultiModel.R

Data sample: [propTable_h010_s0.0015_20Mb.txt](./Intermediate%20Files_CLEAN.md/#1b1-proportion-table-used-to-produce-figure-5)



# Main figures

![Figure 1](https://raw.githubusercontent.com/CMPG/BGS_w_BTNCK/main/MainFigures/Fig1@Vector.svg)
