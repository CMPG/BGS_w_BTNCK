## ---------------------------
##
## Script name: getMasterTable_alleleC_mutsC.R
##
## Purpose of script: count the number of deleterious sites
## per genomic window
## ---------------------------

# Load arguments from the command line
args = commandArgs(trailingOnly = TRUE)
mainCase = as.character(args[1])    # Scenario name (e.g., h010LoRec)
selCoef = as.character(args[2])     # Selection coefficient identifier (e.g., 0015)
recovery = as.character(args[3])    # Recovery status (e.g., "no")
chrL = as.character(args[4])        # Chromosome length in Mb (e.g., 20)

# Load required libraries
library(data.table)
library(rlist)
library(plyr)

# Load genomic window coordinate map
gmap = fread("10k_win_coord_20Mb.csv")

# Define identifiers for file naming
idfier = sprintf("ancBGS_%s_sc%s_%sRecovery_p2_%sMb", mainCase, selCoef, recovery, chrL)

tailPAR = sprintf("%s_selCoef_%s_%sMb", mainCase, selCoef, chrL)
simPAR = sprintf("%s_%sMb", selCoef, chrL)

# Read initial diversity values (π_BGS and π_neutral) for normalization
iniDiv = fread("BGS_iniDiv_avg.txt")
iniBGS = iniDiv$eBGS_1[iniDiv$tailSIM == tailPAR & iniDiv$simType == simPAR]
iniNT  = iniDiv$neut_1[iniDiv$tailSIM == tailPAR & iniDiv$simType == simPAR]

# Output files (header only at first)
name_col = c("w_id", "gen", "rep", "mean_pi_raw", "ini", "end",  "mid_win",  "mutCount", "POS", "alleleC")
ftname = sprintf("%s/mutCounts_wID_alleleC_gScan_%s.txt", ".", idfier)
write.table(t(name_col), ftname, append = F, row.names = F, col.names = F, sep = "\t")


name_col = c("w_id", "gen", "rep", "mean_pi_raw", "ini", "end",  "mid_win",  "mutCount", "POS", "alleleC")
ftDELname = sprintf("%s/mutCounts0_wID_alleleC_gScan_%s.txt", ".", idfier)
write.table(t(name_col), ftDELname, append = F, row.names = F, col.names = F, sep = "\t")

name_col = c("w_id", "gen", "rep", "mean_pi_raw", "ini", "end",  "mid_win",  "mutCount", "POS", "alleleC")
ftALLname = sprintf("%s/mutCountsALL_wID_alleleC_gScan_%s.txt", ".", idfier)
write.table(t(name_col), ftALLname, append = F, row.names = F, col.names = F, sep = "\t")


# Iterate through replicates and generations
for (replicate in 1:100) {
  for (g in seq(100005, 100380, 5)) {
    
    print(g)    

    # Read diversity data for current generation/replicate
    raw_gs = fread(sprintf("%s/genomic_profile_10k/genomic_profile_%s_p2_r%s_ancBGS_sc%s_%sMb_40inds.txt.gz", replicate, g, replicate, selCoef, chrL))
    
    gs = merge(raw_gs, gmap, by.x = "w_id", by.y = "id")
    
    # Get mean π values (not used in same script)
    mNT = mean(gs$mean_pi_raw[gs$w_id < 1334])
    mNN = mean(gs$mean_pi_raw[gs$w_id >= 1334])
    
    # Load compressed VCF file and extract POS and INFO
    wtf = fread(sprintf("%s/vcf_files/out_gen_%s_r%s_ancBGS_sc%s_%sMb_p2.vcf.gz", replicate, g, replicate, selCoef, chrL))
    gdat = wtf[,c("POS", "INFO")]
    
    # Remove multiallelic sites
    lociMulti = grep("MULTIALLELIC", gdat$INFO)
    onlyNonMulti_ID <- setdiff(seq_len(nrow(gdat)), lociMulti)
    dt_onlyNmulti = gdat[onlyNonMulti_ID]
  
    # Find only deleterious mutations (annotated by presence of ";S=-")
    del_indexes = grep(";S=-", dt_onlyNmulti$INFO)
    del_pos = dt_onlyNmulti[del_indexes, ]
    
    # Split INFO field into structured columns
    aff = data.table(del_pos$POS, data.table(list.rbind(strsplit(del_pos$INFO, ";"))))
    names(aff) = c("POS", "mid", "sel", "dom", "p0", "g0", "mt", "alleleC", "dp")
    
    # Clean and convert numeric fields    
    aff$g0 = as.numeric(gsub(pattern = "GO=", replacement = "", x = aff$g0))
    aff$p0 = as.numeric(gsub(pattern = "PO=", replacement = "", x = aff$p0))
    aff$alleleC = as.numeric(gsub(pattern = "AC=", replacement = "", x = aff$alleleC))
    
    # Initialize mutation count column
    gs$mutCount = 0
  
    allMuts = c()
    # Loop over all deleterious mutation positions
    for (mut in aff$POS) {
      # Keep windows within 20kb of the mutation site
      tmp = gs[((gs$mid_win - 10000) < mut) & ((gs$mid_win + 10000) > mut), ]
      aCount = aff$alleleC[aff$POS == mut]
      
      # If the mutation falls inside a window, record it
      for (i in 1:nrow(tmp)) {
      # if mut is within INI X END of current window
        if (mut > tmp$ini[i] && mut < tmp$end[i]) {
        # for each window, make a new line
          new_line = data.frame(w_id = tmp$w_id[i], POS = mut, alleleC = aCount)
        # add to mega table
          allMuts = rbind(allMuts, new_line)
        }
      }
      
    }
    allMuts

    
  # Count number of mutations per window
  #    w_id      POS
  # 1  1346 10093546__\--> is found in 2 windows
  # 2  1347 10093546_/
  # 3  1350 10120770
  # 4  1352 10132088
  # 5  1357 10175703__\ --> found in 2 windows
  # 6  1358 10175703_/
  
  
    list_windows = unique(allMuts$w_id)
    affWindows = c()
    for (pos in list_windows) {
    # grab all positions contained in sigle window
    # EX: w_id      POS
    # 113 2667 19992432
      tmp = allMuts[allMuts$w_id == pos, ]
     # number of rows == number of loci
      gs$mutCount[gs$w_id == pos] <- nrow(tmp)
    }
    
  gs
  

    # Focus only on BGS-affected windows (w_id ≥ 1334)
    gsNew = gs[gs$w_id >= 1334, ]
    gsNew
    

    pos2wid = allMuts
    ancPOSwid = pos2wid

    # Merge diversity data with mutation info
    pall = merge(
      x = gsNew[,c("w_id", "gen", "rep",
                   "mean_pi_raw", "ini", "end", "mid_win", "mutCount")],
      y = ancPOSwid, by = c("w_id"), all = T)
    
    pall
    
    # Write all entries (including NAs) to global file
    write.table(pall, ftALLname, append = T, row.names = F, col.names = F, sep = "\t")
    
    # Write windows with no deleterious mutations
    noDEL = pall[is.na(pall$alleleC),]
    noDEL
    write.table(noDEL, ftDELname, append = T, row.names = F, col.names = F, sep = "\t")
    
    # Write windows with at least one deleterious mutation
    all = pall[!is.na(pall$w_id),] # remove mutations that don't exist in current generation
    all
    
    if (nrow(all) != 0) {
      
      write.table(all, ftname, append = T, row.names = F, col.names = F, sep = "\t")
    }
    
  }
  
}
