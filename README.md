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
Very briefly, it uses VCF files sampled during simulation to window the genome and calculate diversity; Then separates the information on troughs (based on levels of ancestral diversity) and summarizes them over time.

Used to obtain:
- [Figure 1](./MainFigures/Fig1@Vector.svg)
- [Figure 2](./MainFigures/Fig2@Vector.svg)
- [Figure 3](./MainFigures/Fig3@Vector.svg)
- [Figure 4](./MainFigures/Fig4@Vector.svg)

[back to top &uarr;](#bgs_w_btnck)


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

[back to top &uarr;](#bgs_w_btnck)

## 3. s(b12) narrow down counts to either feature

Isolates data from either feature (based on ancestral levels of diversity) and combines it with mutaion count data (item 2)
Scripts: b12_slurm_getIlhasTroughs_countMuts.sh ⏭ b12_getIlhasTroughs_countMuts.R
Also summarises data per replicate and generation
Data output sample: 
- RAW: [ilhasOfDiv](./Intermediate%20Files_CLEAN.md/#1a-islands-of-diversity)
- SUMMARIZED: [summaIlhasOfDiv](./Intermediate%20Files_CLEAN.md/#1a2-summarise-raw-data-1a1-per-generation-and-replicate)


### 3.1 Islands of Diversity

Command:
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

Command:
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

[back to top &uarr;](#bgs_w_btnck)

## 4. Bootstrap feature mutation count
Bootstrap results to produce [Supplementary Figure S8](./MainFigures/SuppFig_S8_xx_from00MS02_v2_BOOTS_IslandSize_h010xCoDo_17_Nov_20h_37m_52s.svg)

Data output sample: [boot%sx_ILHAS_%s_sc%s_%sMb_%s.txt](./Intermediate%20Files_CLEAN.md/#1a3-bootstrap-summarised-data-1a2)

Command:
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

[back to top &uarr;](#bgs_w_btnck)

## 5. Proportion data relative to the number of deleterious mutations within feature (produces Figure 5)

Scripts:
- calculation: 0v2.2_onlyOpenData_MultiModel.R
- plotting: 0v2.6_onlyPDF_PropPlot_MultiModel_withTroughWhite.R
- save data: 0v2.5_write2File_PropPlot_MultiModel.R

Data sample: [propTable_%s_%s_%sMb.txt](./Intermediate%20Files_CLEAN.md/#1b1-proportion-table-used-to-produce-figure-5)


[back to top &uarr;](#bgs_w_btnck)

# Main figures

![Figure 1](https://raw.githubusercontent.com/CMPG/BGS_w_BTNCK/main/MainFigures/Fig1@Vector.svg)

**Figure 1**: Genome scans of nucleotide diversity (π) during a bottleneck, for a neutral region of 3 Mb, highlighting the changes in the genomic landscape over time at the expansion edge. Four time points are shown: -1, 5, 100 and 200 generations from the start of the bottleneck. Thus, generation -1 shows the ancestral population immediately before the bottleneck. Y-axis shows nucleotide diversity (π), and X-axis shows position in the genome. The horizontal dotted line indicates the threshold used to define troughs (10% of average ancestral diversity). The horizontal solid green line shows the average π value of the chromosome segment at each of the four-time points, and the exact value is shown in green on the top of each pane. Troughs are highlighted in red, with their total numbers (for the 10Mb chromosome) shown in red on the top right of each pane (thus trough density is determined by dividing the total number of troughs by the chromosome length). Details on the parameters used in the neutral forward simulations can be found in the Material and Methods section.


![Figure 2](https://raw.githubusercontent.com/CMPG/BGS_w_BTNCK/main/MainFigures/Fig2@Vector.svg)

**Figure 2**: Statistics of trough dynamics during a bottleneck for neutral simulations in populations having different ancestral sizes (N_anc) or different recombination rates (ρ_ ). (A) Trough density (number of troughs per Mb), (B) diversity loss relative to the ancestral population, (C) average trough size and (D) proportion of the genome within troughs. Populations with smaller ancestral diversity (blue and orange lines) show higher trough density and smaller troughs compared to the population with larger ancestral sizes (magenta) before the onset of the bottleneck. Lower recombination (orange) only has a small effect in trough size and trough density. Importantly, despite different trough statistics and starting levels of diversity, all populations lose diversity at the same rate and a similar pattern is observed for the proportion of the genome within troughs, albeit with slightly different proportions between populations of different ancestral sizes. Shaded areas show 95% CI obtained from the bootstrap distribution of 10,000 bootstrap samples corresponding to resampling 100 genomic simulations with replacement.


![Figure 3](https://raw.githubusercontent.com/CMPG/BGS_w_BTNCK/main/MainFigures/Fig3@Vector.svg)

**Figure 3**: Effect of recombination rate (ρ) and dominance levels (h) on trough density (A) and diversity loss (B) during a bottleneck. The selection coefficient of deleterious mutation was set to s = 0.0015 for both recessive (h = 0.1, dashed lines) and codominant (h = 0.5, solid lines) variants. Results for chromosomes with low recombination (ρ =1×10^(-9) per bp per generation) are shown in purple, whereas those for regions of intermediate recombination (ρ =   per bp per generation) are shown in orange. Note that the recombination rate for the neutral case is ρ = 10-8 per bp per generation. Shaded areas show 95% CI obtained from 10,000 bootstrap iterations. Note that the neutral model (s = 0) is represented in a black dash-dotted line and was carried out in larger chromosomes (100 Mb instead of 20Mb for selected chromosomes), leading to smaller confidence intervals, but with similar average statistics (see supplementary fig. S4).


![Figure 4](https://raw.githubusercontent.com/CMPG/BGS_w_BTNCK/main/MainFigures/Fig4@Vector.svg)

**Figure 4**: Effect of selection intensity (s) on trough density (A), diversity loss (B) and trough size (C) during a bottleneck. All cases shown are for simulations with partially recessive deleterious mutations (h = 0.1). Results for chromosomes with a low recombination rate (ρ = 10-9 per bp per generation) are shown with a solid line, whereas those with an intermediate recombination rate (ρ = 5 ×10-9 per bp per generation) are shown with a dashed line. Note that the recombination rate for the neutral case is ρ = 10-8 per bp per generation. Orange lines represent results obtained for chromosomes including deleterious mutation of very small effect (s=-0.0001), whereas those in purple are for chromosomes with mutations 10x stronger (s=-0.001), and those in pink with mutations 100x stronger (s = -0.0100). Shaded areas show 95% CI obtained from 10,000 bootstrap iterations. Note that the neutral model (s = 0) is represented in a black dash-dotted line and was carried out in larger chromosomes (100 Mb instead of 20Mb for selected chromosomes), leading to smaller confidence intervals, but with similar average statistics (see supplementary fig. S4).


![Figure 5](https://raw.githubusercontent.com/CMPG/BGS_w_BTNCK/main/MainFigures/Fig5@Vector.svg)

**Figure 5**: Evolution of the proportion of the genome in islands of diversity (blue colours) including 0, 1, or ≥2 recessive mutations per 10 Kb window. (A) chromosomes of low recombination rate including codominant mutations with selective disadvantage s = -0.0015. (B-D) chromosomes with highly recessive mutations (h = 0.1). (B) s = -0.0015 and intermediate recombination (ρ = 5×10-9 per bp per generation); (C) same s and h as B but in regions of low recombination (ρ = 10-9 per bp per generation); (D) same h and recombination as C but with s = -0.0001.


[back to top &uarr;](#bgs_w_btnck)
