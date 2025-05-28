## ---------------------------
##
## Script name: b12_getIlhasTroughs_countMuts.R
##
## Purpose of script: idetify islands of diversity 
## and count the deleterious mutations within.
## ---------------------------
# Read command line arguments
args = commandArgs(trailingOnly = TRUE)
mainCase = as.character(args[1])      # e.g., 'h010LoRec'
selCoef = as.character(args[2])       # selection coefficient, e.g., '0015'
recovery = as.character(args[3])      # 'no' or 'yes'
chrL = as.character(args[4])          # chromosome length, e.g., '20'
oq = as.character(args[5])            # "trough" or "ilha"
from_rep = as.numeric(args[6])        # starting replicate
to_rep = as.numeric(args[7])          # ending replicate
from_gen = as.numeric(args[8])        # starting generation
to_gen = as.numeric(args[9])          # ending generation

# Create a replicate range string
repSTRING = sprintf("%s-%s", from_rep, to_rep)
variante = mainCase

# Load libraries
library(data.table)
library(rlist)
library(plyr)
writeFiles = T  # Set to TRUE to save output

# Set identifiers for filenames and lookup
idfier = sprintf("ancBGS_%s_sc%s_%sRecovery_p2_%sMb", mainCase,  selCoef, recovery, chrL)
tailPAR = sprintf("%s_selCoef_%s_%sMb", mainCase, selCoef, chrL) # h010LoRec_selCoef_0015_20Mb
simPAR =  sprintf("%s_%sMb", selCoef, chrL) # 0015_20Mb

# Load initial diversity data
iniDiv = fread("BGS_iniDiv_avg.txt")
iniBGS = iniDiv$eBGS_1[iniDiv$tailSIM == tailPAR & iniDiv$simType == simPAR]  # BGS diversity baseline
iniNT = iniDiv$neut_1[iniDiv$tailSIM == tailPAR & iniDiv$simType == simPAR]  # neutral baseline
print(iniBGS)
print(iniNT)

# Load genomic window map and data for all mutations
gmap = fread("10k_win_coord_20Mb.csv")
df_all = fread(sprintf("mutCountsALL_wID_alleleC_gScan_ancBGS_%s_sc%s_noRecovery_p2_%sMb.txt", variante, selCoef, chrL))
print(head(df_all))

# Set up output column names and file headers based on target type
if (oq == "trough") {
  name_col = c('w_id', 'gen', 'rep', 'mean_pi_raw', 'ini', 'end', 'mid_win', 'mutCount', 'tr_id')
  tr_fname = sprintf("%s/trougOfDiv_%s_gScan_p%s_r%s.txt", ".", idfier, 2, repSTRING)
  
  
  if (writeFiles == T) {
    write.table(t(name_col), tr_fname, append = F, row.names = F, col.names = F, sep = "\t")
  }
  
  ## SUMMARY TRPUGHS ------ ####
  name_col = c('tr_id', 'rep', 'gen', 'n_windows', 'mp_raw', 'ini', 'end', 'mid_tr', 'mutCount', 'size', 'totTr')
  sm_tr_fname = sprintf("%s/summaTrougOfDiv_%s_gScan_p%s_r%s.txt", ".", idfier, 2, repSTRING)
  if (writeFiles == T) write.table(t(name_col), sm_tr_fname, append = F, row.names = F, col.names = F, sep = "\t")
  
} else {
  # ILHAS ------ ####
  ## RAW data file ------ ####
  name_col = c('w_id', 'gen', 'rep', 'mean_pi_raw', 'ini', 'end', 'mid_win', 'mutCount', 'il_id')
  il_fname = sprintf("%s/ilhasOfDiv_%s_gScan_p%s_r%s.txt", ".", idfier, 2, repSTRING)
  if (writeFiles == T) write.table(t(name_col), il_fname, append = F, row.names = F, col.names = F, sep = "\t")
  
  ## SUMMARY ILHAS ------ ####
  name_col = c('il_id', 'rep', 'gen', 'n_windows', 'mp_raw', 'ini', 'end', 'mid_il', 'mutCount', 'size', 'totIl')
  sm_il_fname = sprintf("%s/summaIlhasOfDiv_%s_gScan_p%s_r%s.txt", ".", idfier, 2, repSTRING)
  if (writeFiles == T) write.table(t(name_col), sm_il_fname, append = F, row.names = F, col.names = F, sep = "\t")
  }
  
# Loop through generations and replicates
for (g in seq(from_gen, to_gen, 5)) {
  for (r in from_rep:to_rep) {
    cat("\r", sprintf("rep %s, gen %s", r, g))
    
    # Subset data by region (trough or ilha) and current replicate/gen
    if (oq == "trough") {
      dat = df_all[df_all$mean_pi_raw <= iniBGS/10 & 
                     df_all$gen == g & 
                     df_all$rep == r, ]
    } else {
      dat = df_all[df_all$mean_pi_raw > iniBGS/10 & 
                     df_all$gen == g & 
                     df_all$rep == r, ]
    }
    
    dat
    if (nrow(dat) != 0) {
      i = 1
      j = 1
      
      # Label contiguous windows with the same trough or ilha ID
      while (i <= nrow(dat)) {
        a = i
        while (
          (
            (i + 1 <= nrow(dat)) &
            (
              ((dat$w_id[i + 1] - dat$w_id[i]) == 1) | 
              ((dat$w_id[i + 1] - dat$w_id[i]) == 0)
            )
          )
        ) {
          i = i + 1
        }
        b = i
        for (k in a:b) {
          dat$tr_id[k] = j
        }
        j = j + 1
        i = i + 1
      }
      
      dat
      # dat
      # w_id    gen rep  mean_pi_raw      ini      end  mid_win mutCount      POS alleleC tr_id
      # 1: 1334 100005   1 0.0004908437  9993751 10003751  9998751        0       NA      NA     1
      # 2: 1335 100005   1 0.0005382500 10001251 10011251 10006251        0       NA      NA     1
      # 3: 1336 100005   1 0.0008582500 10008751 10018751 10013751        0       NA      NA     1
      
      # Keep only relevant columns and unique rows
      uq_dat = unique(
        dat[, c("w_id", "gen" ,"rep" , "mean_pi_raw",  
                "ini",  "end", "mid_win" ,"mutCount", "tr_id")]
      )    
      
      uq_dat
      if (writeFiles == T) {
        if (oq == "trough") {
          write.table(uq_dat, tr_fname, append = T, row.names = F, col.names = F, sep = "\t")
        } else {
          write.table(uq_dat, il_fname, append = T, row.names = F, col.names = F, sep = "\t")
        }
      }
      
      # Summarize each island/trough: size, count, midpoints, etc.
      meh = ddply(uq_dat, .(tr_id, rep, gen), summarise,
                  n_windows = length(tr_id),
                  mp_raw = mean(mean_pi_raw),
                  ini = min(ini),
                  end = max(end),
                  mid_gap = mean(mid_win),
                  mCount = sum(mutCount))
      
      meh$size = meh$end - meh$ini
      meh$totTr = nrow(meh)
      meh
      
      if (writeFiles == T) {
        if (oq == "trough") {
          write.table(meh, sm_tr_fname, append = T, row.names = F, col.names = F, sep = "\t")
        } else {
          write.table(meh, sm_il_fname, append = T, row.names = F, col.names = F, sep = "\t")
        }
      }
    }
  }
}
