# Wed Jun  5 18:26:07 2024 ------------------------------
## ---------------------------
##
## Script name: 0v2.5_write2File_PropPlot_MultiModel.R
##
## Purpose of script:
##
##
## Date Created: 2024-06-05
## ---------------------------


# -- -- -- -- -- -- -- -- -- --
# START  ####
# -- -- -- -- --


idfier_grp = paste(paste(list_variantes, list_selCoef, sep = "_"), collapse = "--")

idfier_grp



for (i in 1:length(list_variantes)) {
  
  mainCase = list_variantes[i]
  selCoef = list_selCoef[i]
  letterID = LETTERS[i]
  
  idfier_TITULO = sprintf("type:%s sel:0.%s chrL:%sMb", mainCase,  selCoef, chrL)
  idfier_TITULO
  
  gah = get(paste0("bigD_", i))
  
  write.table(x = t(prop.table((gah))),
              file = sprintf("propTable_%s_s0.%s_%sMb.txt", mainCase, selCoef, chrL),
              row.names = T,
              col.names = T)
  
  write.table(x = t(((gah))),
              file = sprintf("wCountsTable_%s_s0.%s_%sMb.txt", mainCase, selCoef, chrL),
              row.names = T,
              col.names = T)
  
  
  
}


