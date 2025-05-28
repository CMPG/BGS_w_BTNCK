## ---------------------------
##
## Script name: 0v2.2_onlyOpenData_MultiModel.R
## Purpose: open big mutation count data and
## 
## ---------------------------


rm(list = ls())  # Clear all variables from the R environment

library(data.table)  # Efficient data handling

# Define the combinations of simulation parameters to be tested
list_variantes = c("CoDomLoRec", "h010", "h010LoRec", "h010LoRec")
list_selCoef = c("0015", "0015", "0015", "0001")

recovery = "no"  # Indicates if recovery phase is included
chrL = 20        # Chromosome length in Mb

# Loop over each combination of variant and selection coefficient
for (i in 1:length(list_variantes)) {
  
  mainCase = list_variantes[i]  # Current genetic architecture
  selCoef = list_selCoef[i]     # Current selection coefficient
  
  # Generate consistent identifiers for file names and plots
  idfier = sprintf("ancBGS_%s_sc%s_%sRecovery_p2_%sMb", mainCase,  selCoef, recovery, chrL)
  idfier_TITULO = sprintf("type:%s sel:0.%s chrL:%sMb", mainCase,  selCoef, chrL)
  tailPAR = sprintf("%s_selCoef_%s_%sMb", mainCase, selCoef, chrL)
  simPAR =  sprintf("%s_%sMb", selCoef, chrL)
  
  # Load initial diversity estimates for calculating BGS threshold
  iniDiv = fread("BGS_iniDiv_avg.txt")
  iniBGS = iniDiv$eBGS_1[iniDiv$tailSIM == tailPAR & iniDiv$simType == simPAR]
  print(iniBGS)
  
  # Load mutation counts and raw π values
  pmcAll = fread(sprintf("mutCountsALL_wID_alleleC_gScan_%s.txt", idfier))
  
  # Keep unique entries with relevant fields
  mcAll = unique(pmcAll[,c("w_id", "gen", "rep", "mean_pi_raw", "mutCount")])
  
  # Check structure of dataset
  nwin = length(unique(mcAll$w_id))   # Number of genomic windows
  nrep = length(unique(mcAll$rep))    # Number of replicates
  ngen = length(unique(mcAll$gen))    # Number of generations
  
  # Assert data dimensions match expected full grid
  nrow(mcAll) == nwin*ngen*nrep
  
  # Classify rows based on mutation count
  just1 = mcAll[mcAll$mutCount == 1,]
  plus1 = mcAll[mcAll$mutCount > 1,]
  mc0 = mcAll[mcAll$mutCount == 0, ]
  
  # Confirm sum of subsets equals original data
  nrow(just1) + nrow(plus1) + nrow(mc0) == nrow(mcAll)
  nrow(just1) + nrow(plus1) + nrow(mc0) == 1334*76*100
  length(unique(mcAll$w_id)) == 1334  # Validate window count
  
  # Define island and trough classes by π threshold (10% of initial BGS level)
  ilhaPlus = plus1[plus1$mean_pi_raw > iniBGS/10, c("w_id", "gen", "rep", "mutCount", "mean_pi_raw")]
  
  # islands and only 1 del Mut
  ilhaMins =  just1[just1$mean_pi_raw > iniBGS/10  , c("w_id", "gen", "rep", "mutCount", "mean_pi_raw")]
  
  # trough and 2 or+ del muts
  trouPlus = plus1[plus1$mean_pi_raw <= iniBGS/10  , c("w_id", "gen", "rep", "mutCount", "mean_pi_raw")]
  
  # trough just 1 delMut 
  trouMins = just1[just1$mean_pi_raw <= iniBGS/10  , c("w_id", "gen", "rep", "mutCount", "mean_pi_raw")]
  
  # island without del muts
  mc0Ilha = mc0[mc0$mean_pi_raw > iniBGS/10, c("w_id", "gen", "rep", "mutCount", "mean_pi_raw")]
  
  # trough without del mut
  mc0Trou = mc0[mc0$mean_pi_raw <= iniBGS/10, c("w_id", "gen", "rep", "mutCount", "mean_pi_raw")]
  
  # Confirm all categories add up
  nrow(ilhaPlus) + nrow(ilhaMins) + nrow(trouPlus) + nrow(trouMins) + nrow(mc0Ilha) + nrow(mc0Trou) == 1334*76*100
  
  # Generate artificial rows for missing generations (ensures complete time series)
  possG = seq(100005, 100380, 5)
  
  fTrPlus = rbind(trouPlus, 
                  data.frame(
                    w_id = rep(NA, length(possG)),
                    gen = possG,
                    rep = rep(unique(trouPlus$rep), length(possG)),
                    mutCount = rep(NA, length(possG)),
                    mean_pi_raw = rep(NA, length(possG)))
  )
  
  fTrMins = rbind(trouMins, 
                  data.frame(
                    w_id = rep(NA, length(possG)),
                    gen = possG,
                    rep = rep(unique(trouPlus$rep), length(possG)),
                    mutCount = rep(NA, length(possG)),
                    mean_pi_raw = rep(NA, length(possG)))
  )
  
  
  
  fTrmc0 = rbind(mc0Trou, 
                 data.frame(
                   w_id = rep(NA, length(possG)),
                   gen = possG,
                   rep = rep(unique(mc0Trou$rep), length(possG)),
                   mutCount = rep(NA, length(possG)),
                   mean_pi_raw = rep(NA, length(possG))
                 )
  )
  
  
  
  
  
  fIlMins = rbind(ilhaMins, 
                  data.frame(
                    w_id = rep(NA, length(possG)),
                    gen = possG,
                    rep = rep(unique(ilhaMins$rep), length(possG)),
                    mutCount = rep(NA, length(possG)),
                    mean_pi_raw = rep(NA, length(possG)))
  )
  
  
  
  fIlPlus = rbind(ilhaPlus, 
                  data.frame(
                    w_id = rep(NA, length(possG)),
                    gen = possG,
                    rep = rep(unique(ilhaPlus$rep), length(possG)),
                    mutCount = rep(NA, length(possG)),
                    mean_pi_raw = rep(NA, length(possG)))
  )
  
  fIlmc0 = rbind(mc0Ilha, 
                 data.frame(
                   w_id = rep(NA, length(possG)),
                   gen = possG,
                   rep = rep(unique(mc0Ilha$rep), length(possG)),
                   mutCount = rep(NA, length(possG)),
                   mean_pi_raw = rep(NA, length(possG))
                 )
  )
  
  
  # Choose filled or original tables depending on whether all generations are present
  if ( dim(table(mc0Ilha$gen)) == 76 ) {
    CHOSEN_mc0Ilha = mc0Ilha
  } else {
    CHOSEN_mc0Ilha = fIlmc0
  }
  
  if ( dim(table(ilhaMins$gen)) == 76 ) {
    CHOSEN_ilhaMins = ilhaMins
  } else {
    CHOSEN_ilhaMins = fIlMins
  }
  
  if ( dim(table(ilhaPlus$gen)) == 76 ) {
    CHOSEN_ilhaPlus = ilhaPlus
  } else {
    CHOSEN_ilhaPlus = fIlPlus
  }
  
  if ( dim(table(trouMins$gen)) == 76 ) {
    CHOSEN_trouMins = trouMins
  } else {
    CHOSEN_trouMins = fTrMins
  }
  if ( dim(table(trouPlus$gen)) == 76 ) {
    CHOSEN_trouPlus = trouPlus
  } else {
    CHOSEN_trouPlus = fTrPlus
  }
  
  if ( dim(table(mc0Trou$gen)) == 76 ) {
    CHOSEN_mc0Trou = mc0Trou
  } else {
    CHOSEN_mc0Trou = fTrmc0
  }
  
  # Combine generation tables into a matrix format
  gah = rbind(
    t(table(CHOSEN_mc0Ilha$gen)),
    t(table(CHOSEN_ilhaMins$gen)),
    t(table(CHOSEN_ilhaPlus$gen)), 
    t(table(CHOSEN_mc0Trou$gen)),
    t(table(CHOSEN_trouMins$gen)),
    t(table(CHOSEN_trouPlus$gen))
  )
  
  gah
  # Adjust row/column names for clarity in plot/export
  dimnames(gah)[[2]] = as.numeric(dimnames(gah)[[2]]) - 100000
  dimnames(gah)[[1]] = c("ilha0", "ilha1", "ilha2Mais", "trou0", "trou1", "trou2Mais")
  
  gah
  
  
  colSums(gah)
  
  # Store result as variable tied to parameter set index
  assign(paste0("bigD_", i), gah)
  
}
