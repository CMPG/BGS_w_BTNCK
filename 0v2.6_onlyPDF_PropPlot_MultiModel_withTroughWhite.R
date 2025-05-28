# Wed Jun  5 18:26:07 2024 ------------------------------
## ---------------------------
##
## Script name: 0v2.6_onlyPDF_PropPlot_MultiModel_withTroughWhite.R
##
## Purpose of script:
##
##
## Date Created: 2024-06-05
## ---------------------------


# -- -- -- -- -- -- -- -- -- --
# START PDF big pane in middle ####
# -- -- -- -- --

mainDir <- "./pdf_files"
subDir <- format(Sys.time(), "%b_%d")

if (file.exists(file.path(mainDir))) {
} else {
  dir.create(file.path(mainDir))
}



if (file.exists(file.path(mainDir, subDir))) {
} else {
  dir.create(file.path(mainDir, subDir))
}

idfier_grp = paste(paste(list_variantes, list_selCoef, sep = "_"), collapse = "--")

idfier_grp

file_name = sprintf("pdf_files/%s/xx_4Pans_DiffSelCoefs_gWindowScan_relative_density_DelMuts_overtime_TrOneColor_%s_%s", subDir, idfier_grp, format(Sys.time(), "%d_%b_%Hh_%Mm_%Ss"))

file_name

pdf(file = paste0(file_name, ".pdf"),
    # paper = "a4r",
    # paper = "a4",
    # width = 0, height = 0
    # width = 8.3, height = 5.8
    width = 5.8, height = 8.3
)

# layout(
  # matrix(c(rep(1, 10),
  #          rep(2, 10),
  #          rep(3, 10),
  #          rep(4, 10)
  # 
  # 
  # )
  # , ncol = 5
  # , byrow = T)
# )


layout(
  matrix(c(rep(1, 5),
           rep(2, 10),
           rep(3, 10),
           rep(4, 10),
           rep(5, 10)


  )
  , ncol = 5
  , byrow = T)
)



colorList = c(
  "cornflowerblue", 
  "cyan", 
  "dodgerblue4",
  scales::alpha("white", 0.05),
  scales::alpha("white", 0.05),
  scales::alpha("white", 0.05)
  # scales::alpha("grey42", 0.75),
  # scales::alpha("gray62", 0.75),   
)

# par(oma = c(2.5, 0.5, 1, 0) + 0.1)
# par(mar = c(4.5, 3.5, 1.5, .5) + 0.1)
# par(mgp = c(3, 0.85, 0))
# par(oma = c(0.5, 0.5, 0, 0.75) + 0.1)
# par(mar = c(2.5, 3.5, 0, .75) + 0.1)
par(oma = c( 2,  1.5, 0.25, 1.5) + 0.1)
par(mar = c(.5, 1.5, 0.25, .5) + 0.1)
par(mgp = c(3, 0.85, 0))
par(xpd = F)

cFACT = 2


plot.new()

legend("center",
       legend = c(0, 1, "2 or +"),
       fill = colorList, col = colorList,
       bty = "n", horiz = T, title = "number of deleterious mutations\nin each genomic window", adj = c(0.25, .5)
)


for (i in 1:length(list_variantes)) {
  
  mainCase = list_variantes[i]
  selCoef = list_selCoef[i]
  letterID = LETTERS[i]
  
  idfier_TITULO = sprintf("type:%s sel:0.%s chrL:%sMb", mainCase,  selCoef, chrL)
  idfier_TITULO
  
  gah = get(paste0("bigD_", i))
  
  
  barplot(prop.table((gah), margin = 2), 
          beside = F,
          horiz = F,
          col = colorList, las = 2,
          
          space = 0,
          border = NA,  
          main = "",
          cex.main = 0.75*cFACT, 
          # xlab = "", 
          # ylab = "proportion",
          ylab = "",
          # xlab = "proportion",
          cex.axis = 0.45*cFACT,
          cex.names = 0.5*cFACT,
          mgp = c(1.25*cFACT, 0.65, 0),
          y = c(0, 1), 
          # ylim = c(0, 1), 
          # xlim = c(0.05, 31.50),
          cex.lab = 0.5*cFACT, xpd = F,
          axes = T,
          axis.lty = 1,
          las = 2,
          xaxs = "i",
          xaxt = ifelse(i == length(list_variantes), "s", "n"),
          # xaxt = ifelse(i == 4, "s", "n")
          # xaxt = "s"
  )
  
  if (i != 4) {
  coordBars = barplot(prop.table((gah[c("ilha0", "ilha1", "ilha2Mais"),]), margin = 2),
                      horiz = T, plot = F, 
                      space = 0
                      )
  labs = colnames(prop.table((gah[c("ilha0", "ilha1", "ilha2Mais"),]), margin = 2))
  
  axis(side = 1, at = coordBars, labels = F, tick = T)
  
  }
  
  
  mtext(sprintf("%s", idfier_TITULO), side = 4, line = 0, cex = 0.5)
  mtext(sprintf("%s", letterID), side = 2, adj = 1, padj = -7.5, line = 1.75, cex = 1, las = 2, font = 2)
  # abline(h = (seq(0, 1, 0.025)), 
  #        # col = "gray32", 
  #        col = "white", 
  #        lty = 1, lwd = 0.25)
  # mtext(sprintf("%s", idfier_TITULO), side = 4, line = 0.5, cex = 0.5
  
  
  
}

dev.off()
