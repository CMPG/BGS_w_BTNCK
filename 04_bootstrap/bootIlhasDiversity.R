## ---------------------------
##
## Script name: bootIlhasDiversity.R
##
## Purpose of script:
##
##
## Date Created: 2024-06-14
## ---------------------------


args = commandArgs(trailingOnly = TRUE)
nBOOT = as.numeric(args[1])
cur_metric = as.character(args[2])
dpath = as.character(args[3])
selCoef = as.character(args[4])
chrL = as.numeric(args[5])
selType = as.character(args[6])
simType = as.character(args[7])
meiota = as.character(args[8])


# for RSTUDIO ------ ####
# nBOOT = 12
# dpath = "../b13_btnck_recovery/plot_proj/00_BGS_data"
# selCoef = "0001"
# chrL = 20
# selType = "10K"
# simType = "h010LoRec"
# meiota = "bt380_rt380_n1_50_n2_0_gt_0_mig_0"
# cur_metric = "size"


# Load necessary libraries
library(plyr); library(dplyr)
library(boot)
library(data.table)


if (!exists("meiota")) {
  meiota = "bt380_rt380_n1_50_n2_0_gt_0_mig_0"
}



conditions = sprintf("sc%s_%s_%sMb_%s", selCoef, meiota, chrL, selType)
print(conditions)


if (is.na(simType) | simType == "NA") {
  file_path <- sprintf("%s/r_btnck_ancBGS_%s/ilhaDT", dpath, conditions)
} else {
  file_path <- sprintf("%s/r_btnck_ancBGS_%s_%s/ilhaDT", dpath, simType, conditions)
}

print(file_path)

list.files(file_path)

if (!exists("dataType")) {
  dataType = NA
}

# dataType != "relDivLoss" |
# if (!is.na(dataType)) {
# if (dataType != c("relDivLoss"))
# if (is.na(dataType)) {

# if (cur_metric != "mean_pi_samp") {
  fname = list.files(path = file_path, pattern = glob2rx("summaIlhas*1-100.txt"))[1]
  print(fname)
  # Read the file
  data <- read.table(file = file.path(file_path, fname), header = T)
  # Rename columns
  # colnames(data) <- c("cpop", "rep", "gen", "tot_win", "mean_size", "tot_tr", "chr_tr", "prop_tr")
  
# } else {
#   # diversity_data_raw_btnck_anc2_bt380_rt0_n1_50_n2_0_gt_0_mig_0_low_rec_wsize_10k_40inds_all_reps_p2.txt
#   fname = list.files(path = file_path, pattern = glob2rx("diversity_data*samp*"))[1]
#   print(fname)
#   # Read the file
#   data <- read.table(file = file.path(file_path, fname), header = T)
#   # Rename columns
#   # colnames(data) <- c("gen",  "rep",  "cpop", "N", "mean_pi_samp", "sd", "median", "qt2", "qt3",  "qt4",  "qt1", "qt5", "se", "ci")
#   # c("cpop", "rep", "gen", "tot_win", "mean_size", "tot_tr", "chr_tr", "prop_tr")
#   
# }


print(head(data))


# Function to perform bootstrap resampling
bootstrap_summary <- function(data, column_name, n_bootstrap) {
  boot_fn <- function(data, indices) {
    d <- data[indices, ]
    return(mean(d[[column_name]]))
  }
  boot_res <- boot(data, boot_fn, R = n_bootstrap)
  return(boot_res$t) # Extract the bootstrap samples
}

# Initialize an empty list to store results
bootstrap_results <- list()

# Perform bootstrap for each generation
gens <- unique(data$gen)

for (gen in gens) {
  gen_data <- data %>% filter(gen == !!gen)
  print(sprintf("g: %s; wh; %s;", gen, cur_metric))
  cur_metric_bootstrap <- bootstrap_summary(gen_data, cur_metric, nBOOT)
  
  bootstrap_results[[as.character(gen)]] <- list(
    cur_metric_bootstrap = cur_metric_bootstrap
  )
}

# Create a data.table to store bootstrap iterations
bootstrap_dt <- data.table()

# Populate the data.table with bootstrap results
for (gen in names(bootstrap_results)) {
  cur_metric_bootstrap <- bootstrap_results[[gen]]$cur_metric_bootstrap
  cur_metric_dt <- data.table(iteration = 1:nBOOT, gen = as.integer(gen), val = cur_metric_bootstrap)
  bootstrap_dt <- rbindlist(list(bootstrap_dt, cur_metric_dt))
}

# Print or save the final data.table
names(bootstrap_dt) = c("iter",    "gen", cur_metric)
print(bootstrap_dt)

if (nBOOT * length(names(bootstrap_results)) == nrow(bootstrap_dt)) {
  ftoSAVE = sprintf("%s/boot%sx_ILHAS_%s_sc%s_%sMb_%s.txt", file_path, nBOOT, cur_metric,  selCoef, chrL, selType)
  print(ftoSAVE)
  write.table(bootstrap_dt, file = ftoSAVE, sep = "\t", row.names = FALSE, col.names = TRUE)
} else {
  print("ALGUMA COISA DEU ERRADO!")
}

