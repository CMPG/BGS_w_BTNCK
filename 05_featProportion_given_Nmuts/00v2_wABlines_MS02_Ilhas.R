# Thu Nov 14 17:34:53 2024 ------------------------------
## ---------------------------
##
## Script name: 00v2_wABlines_MS02_Ilhas.R
## Date Created: 2024-11-14
## ---------------------------


library(data.table)

list.files("E:/OneDrive - Universitaet Bern/b13_btnck_recovery/plot_proj/00_BGS_data/r_btnck_ancBGS_sc0015_bt380_rt380_n1_50_n2_0_gt_0_mig_0_20Mb_10K/ilhaDT/")


smmIl = fread("E:/OneDrive - Universitaet Bern/b13_btnck_recovery/plot_proj/00_BGS_data/r_btnck_ancBGS_sc0015_bt380_rt380_n1_50_n2_0_gt_0_mig_0_20Mb_10K/ilhaDT/boot10000x_ILHAS_size_sc0015_20Mb_10K.txt")
#             E:\OneDrive - Universitaet Bern\b13_btnck_recovery\plot_proj\00_BGS_data\r_btnck_ancBGS_sc0015_bt380_rt380_n1_50_n2_0_gt_0_mig_0_20Mb_10K\ilhaDT

source("E:/OneDrive - Universitaet Bern/c27_Fitness_wRecovery/FUN_summarySE.R")


ref_Ilha = summarySE(data = smmIl,
                     # na.omit(aff), 
                     measurevar = "size", groupvars = "gen", na.rm = T)

dpath = "E:/OneDrive - Universitaet Bern/b13_btnck_recovery/plot_proj/00_BGS_data/r_btnck_ancBGS_CoDomLoRec_sc0015_bt380_rt380_n1_50_n2_0_gt_0_mig_0_20Mb_10K/ilhaDT"

list.files(dpath)


smmIl_CoDo = fread(sprintf("%s/boot10000x_ILHAS_size_sc0015_20Mb_10K.txt", dpath))
# names(smmIl_CoDo) = c("iter", "gen",  "mean_size")

coDo_Ilha = summarySE(data = smmIl_CoDo,
                      # na.omit(aff), 
                      measurevar = "size", groupvars = "gen", na.rm = T)




smmIl_sc01 = fread("E:/OneDrive - Universitaet Bern/b13_btnck_recovery/plot_proj/00_BGS_data/r_btnck_ancBGS_h010LoRec_sc0100_bt380_rt380_n1_50_n2_0_gt_0_mig_0_20Mb_10K/ilhaDT/boot10000x_ILHAS_size_sc0100_20Mb_10K.txt")


sc01_Ilha = summarySE(data = smmIl_sc01,
                      # na.omit(aff), 
                      measurevar = "size", groupvars = "gen", na.rm = T)






list.files("E:/OneDrive - Universitaet Bern/b13_btnck_recovery/plot_proj/00_BGS_data/r_btnck_ancBGS_h010LoRec_sc0001_bt380_rt380_n1_50_n2_0_gt_0_mig_0_20Mb_10K/ilhaDT")



smmIl_sc0001 = fread("E:/OneDrive - Universitaet Bern/b13_btnck_recovery/plot_proj/00_BGS_data/r_btnck_ancBGS_h010LoRec_sc0001_bt380_rt380_n1_50_n2_0_gt_0_mig_0_20Mb_10K/ilhaDT/boot10000x_ILHAS_size_sc0001_20Mb_10K.txt")

sc0001_Ilha = summarySE(data = smmIl_sc0001,
                        # na.omit(aff), 
                        measurevar = "size", groupvars = "gen", na.rm = T)

warnings()
sc0001_Ilha


list.files("E:/OneDrive - Universitaet Bern/b13_btnck_recovery/plot_proj/00_BGS_data/r_btnck_ancBGS_h010LoRec_sc0015_bt380_rt380_n1_50_n2_0_gt_0_mig_0_20Mb_10K/ilhaDT")


smmIl_sc0015LoRec = fread("E:/OneDrive - Universitaet Bern/b13_btnck_recovery/plot_proj/00_BGS_data/r_btnck_ancBGS_h010LoRec_sc0015_bt380_rt380_n1_50_n2_0_gt_0_mig_0_20Mb_10K/ilhaDT/boot10000x_ILHAS_size_sc0015_20Mb_10K.txt")

sc0015LoRec_Ilha = summarySE(data = smmIl_sc0015LoRec,
                             # na.omit(aff), 
                             measurevar = "size", groupvars = "gen", na.rm = T)


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

makeSVG = T
makePDF = F
fWIDTH = 6.5
fHEIGHT = 4.5




file_name = sprintf("./pdf_files/%s/xx_f00v2_MS02_BOOTS_Grids_IslandSize_%s_%s",  subDir, 
                    "h010xCoDo"
                    , format(Sys.time(), "%d_%b_%Hh_%Mm_%Ss"))



print(file_name)

# pdf(file = paste0(file_name, ".pdf"),
#     width = 9.5, height = 6.5
#     # paper = "a4r",
#     # width = 0, height = 0
# )


if (makePDF == T) {
  pdf(
    file = paste0(file_name, ".pdf"),
    width = fWIDTH, height = fHEIGHT
  )
} else if (makeSVG == T) {
  
  library(svglite)
  svglite(
    file = paste0(file_name, ".svg"),
    width = fWIDTH, height = fHEIGHT,
    standalone = T
  )
  
}

# 
# layout(
#   matrix(c(1,2), nrow = 1))
par(oma = c(0,   0,   2,   0.5))
par(mar = c(2.5, 5.5, 0.5, 0.5) + 0.1)



layout(
  matrix(c(
    1,1,1,1,2,2,2,2,2,2,
    1,1,1,1,2,2,2,2,2,2,
    1,1,1,1,2,2,2,2,2,2,
    1,1,1,1,2,2,2,2,2,2,
    1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1
  ), nrow = 7, byrow = T
  )
)
# 4e6 == 4.000.000

# plot(ref_Ilha$gen, ref_Ilha$size, bty = "n",
#      type = "l", lty = 3, lwd = 3, col = "pink4",
#      # ylim = c(min(ref_Ilha$qt10), max(ref_Ilha$qt90))
#      # ylim = c(min(sc0001_Ilha$qt10), max(sc0001_Ilha$qt90)),
#      ylim = c(min(sc0015LoRec_Ilha$qt10), max(sc0015LoRec_Ilha$qt90)),
#      # ylim = c(10000, 4e6),
#      xlim = c(100005, 100050),
#      xaxt = "n", yaxt = "n",
#      ylab = "size (Mb)",
#      xlab = "time", xaxs = "i", yaxs = "i"
#      
# )


plot(sc0015LoRec_Ilha$gen, sc0015LoRec_Ilha$size, bty = "n",
     type = "l", lty = 3, lwd = 3, col = "violet",
     # ylim = c(min(ref_Ilha$qt10), max(ref_Ilha$qt90))
     # ylim = c(min(sc0001_Ilha$qt10), max(sc0001_Ilha$qt90)),
     # ylim = c(min(sc0015LoRec_Ilha$qt1), max(sc0015LoRec_Ilha$qt5)),
     ylim = c(10000, 4.5e6),
     # ylim = c(10000, 10e6),
     xlim = c(100005, 100050),
     xaxt = "n", yaxt = "n",
     ylab = "size (Mb)",
     xlab = "time", xaxs = "i", yaxs = "i",
     cex.lab = 1.5, mgp = c(4, 1, 0)
     
     
)

title(main = "size of diversity islands through time",
      outer = F, line = 3
)
abline(h = seq(10000, 4.5e6, 200000), col = scales::alpha("gray22", 0.15))
abline(v = seq(100000, 100050, 5), col = scales::alpha("gray22", 0.15))

axis(side = 1, at = seq(100000, 100100, 10), labels = seq(0, 100, 10),
     cex.axis = 1.25,  mgp = c(3, 0.75, 0)
)
# axis(side = 2, at = seq(10000, 4.5e6, 200000), labels = seq(10000, 4.5e6, 200000)/1e6, las = 1,

axis(side = 2, at = seq(10000, 4.5e6, 400000), labels = seq(10000, 4.5e6, 400000)/1e6, las = 1,
     cex.axis = 1.25,  mgp = c(3, 0.75, 0)
)

# lines(ref_Ilha$gen, ref_Ilha$median, col = "pink3", lty = 2)
# polygon(c(ref_Ilha$gen, rev(ref_Ilha$gen)), 
#         y = c(ref_Ilha$qt10, rev(ref_Ilha$qt90))
#         , col = scales::alpha("pink3", 0.30),
#         border = scales::alpha("pink3", 0.15)
#         
# )

lines(sc0015LoRec_Ilha$gen, sc0015LoRec_Ilha$size, col = "violet", lty = 3, lwd = 3)
polygon(c(sc0015LoRec_Ilha$gen, rev(sc0015LoRec_Ilha$gen)),
        y = c(sc0015LoRec_Ilha$qt1, rev(sc0015LoRec_Ilha$qt5))
        , col = scales::alpha( "violet", 0.30),
        border = scales::alpha("violet", 0.15)
        
)



lines(coDo_Ilha$gen, coDo_Ilha$size, col = "green4", lty = 3, lwd = 3)
# lines(coDo_Ilha$gen, coDo_Ilha$median, col = "green4", lty = 2)
polygon(c(coDo_Ilha$gen, rev(coDo_Ilha$gen)), 
        y = c(coDo_Ilha$qt10, rev(coDo_Ilha$qt90))
        , col = scales::alpha( "green4", 0.30),
        border = scales::alpha("green4", 0.15)
        
)

# lines(sc0001_Ilha$gen, sc0001_Ilha$size, col = "cornflowerblue", lty = 3, lwd = 3)
# # lines(sc01_Ilha$gen, sc01_Ilha$median, col = "cornflowerblue", lty = 2)
# polygon(c(sc0001_Ilha$gen, rev(sc0001_Ilha$gen)),
#         y = c(sc0001_Ilha$qt10, rev(sc0001_Ilha$qt90))
#         , col = scales::alpha( "cornflowerblue", 0.30),
#         border = scales::alpha("cornflowerblue", 0.15)
#         
# )


# lines(sc01_Ilha$gen, sc01_Ilha$size, col = "darkorange", lty = 3, lwd = 3)
# # lines(sc01_Ilha$gen, sc01_Ilha$median, col = "darkorange", lty = 2)
# polygon(c(sc01_Ilha$gen, rev(sc01_Ilha$gen)),
#         y = c(sc01_Ilha$qt10, rev(sc01_Ilha$qt90))
#         , col = scales::alpha( "darkorange", 0.30),
#         border = scales::alpha("darkorange", 0.15)
# 
# )




# lines(sc0015LoRec_Ilha$gen, sc0015LoRec_Ilha$size, col = "violet", lty = 3, lwd = 3)
# # lines(sc01_Ilha$gen, sc01_Ilha$median, col = "violet", lty = 2)
# polygon(c(sc0015LoRec_Ilha$gen, rev(sc0015LoRec_Ilha$gen)),
#         y = c(sc0015LoRec_Ilha$qt10, rev(sc0015LoRec_Ilha$qt90))
#         , col = scales::alpha( "violet", 0.30),
#         border = scales::alpha("violet", 0.15)
#         
# )


# par("bg")
# [1] "white"

par(bg = "white")

# plot(ref_Ilha$gen, ref_Ilha$size, bty = "n",
#      type = "l", lty = 3, lwd = 3, col = "pink3",
plot(sc0015LoRec_Ilha$gen, sc0015LoRec_Ilha$size, bty = "n",
     type = "l", lty = 3, lwd = 3, col = "violet",
     # ylim = c(min(ref_Ilha$qt10), max(ref_Ilha$qt90))
     ylim = c(10000, 310000),
     xlim = c(100050, 100100), las = 1,
     xaxt = "n", yaxt = "n",
     ylab = "size (Mb)", xaxs = "i", yaxs = "i",
     xlab = "time",
     cex.lab = 1.5, mgp = c(4, 1, 0),
     
     
)

rect(par("usr")[1], par("usr")[3],
     par("usr")[2], par("usr")[4],
     col = "white",
     lwd = 1
     # border = NA 
) # Color

abline(h = seq(10000, 350000, 50000), col = scales::alpha("gray22", 0.15))
abline(v = seq(100050, 100100, 5), col = scales::alpha("gray22", 0.15))

axis(side = 1, at = seq(100000, 100100, 10), labels = seq(0, 100, 10),
     cex.axis = 1.25,  mgp = c(3, 0.75, 0)
)
axis(side = 2, at = seq(10000, 1e6, 100000), labels = seq(10000, 1e6, 100000)/1e6, las = 1,
     cex.axis = 1.25,  mgp = c(3, 0.75, 0)
)

# # lines(ref_Ilha$gen, ref_Ilha$median, col = "pink3", lty = 2)
# polygon(c(ref_Ilha$gen, rev(ref_Ilha$gen)), 
#         y = c(ref_Ilha$qt10, rev(ref_Ilha$qt90))
#         , col = scales::alpha("pink2", 0.1),
#         border = scales::alpha("pink2", 0.15)
#         
# )


lines(coDo_Ilha$gen, coDo_Ilha$size, col = "green4", lty = 3, lwd = 3)
# lines(coDo_Ilha$gen, coDo_Ilha$median, col = "green4", lty = 2)
polygon(c(coDo_Ilha$gen, rev(coDo_Ilha$gen)), 
        y = c(coDo_Ilha$qt10, rev(coDo_Ilha$qt90))
        , col = scales::alpha( "green4", 0.1),
        border = scales::alpha("green4", 0.15)
        
)


lines(sc0015LoRec_Ilha$gen, sc0015LoRec_Ilha$size, col = "violet", lty = 3, lwd = 3)
# lines(sc01_Ilha$gen, sc01_Ilha$median, col = "violet", lty = 2)
polygon(c(sc0015LoRec_Ilha$gen, rev(sc0015LoRec_Ilha$gen)),
        y = c(sc0015LoRec_Ilha$qt10, rev(sc0015LoRec_Ilha$qt90))
        , col = scales::alpha( "violet", 0.30),
        border = scales::alpha("violet", 0.15)
        
)


# lines(sc0001_Ilha$gen, sc0001_Ilha$size, col = "cornflowerblue", lty = 3, lwd = 3)
# # lines(sc01_Ilha$gen, sc01_Ilha$median, col = "cornflowerblue", lty = 2)
# polygon(c(sc0001_Ilha$gen, rev(sc0001_Ilha$gen)),
#         y = c(sc0001_Ilha$qt10, rev(sc0001_Ilha$qt90))
#         , col = scales::alpha( "cornflowerblue", 0.1),
#         border = scales::alpha("cornflowerblue", 0.15)
#         
# )

# polygon(c(sc0015LoRec_Ilha$gen, rev(sc0015LoRec_Ilha$gen)),
#         y = c(sc0015LoRec_Ilha$qt10, rev(sc0015LoRec_Ilha$qt90))
#         , col = scales::alpha( "violet", 0.30),
#         border = scales::alpha("violet", 0.15)
#         
# )





legend("topright", legend = c("h = 0.1, s = 0.0015, r = 1e-9", 
                              "h = 0.5, s = 0.0015, r = 1e-9"
),
fill = c(
  scales::alpha("violet",0.75), 
  scales::alpha("green4",0.75)
),
border = NA, cex = 1.5,
bg = scales::alpha("white", 0.5), box.col = NA
)

# legend("topright", legend = c("h = 0.1, s = 0.0015, r = 5e-9", 
#                               "h = 0.5, s = 0.0015, r = 1e-9"
#                               , "h = 0.1, s = 0.0100, r = 1e-9"
#                               , "h = 0.1, s = 0.0001, r = 1e-9"
#                               
#                               
#                               ),
#        fill = c(
#          scales::alpha("pink3",0.75), 
#          scales::alpha("green4",0.75),
#          scales::alpha("darkorange",0.75),
#          scales::alpha("cornflowerblue",0.75)
#          
#          
#          
#          ),
#        border = NA,
#        bty = "n"
# )


if (makePDF == T | makeSVG == T) {
dev.off()
}




# ref_Ilha[ref_Ilha$gen %in% c(100080, 100085, 100090, 100095, 100100),]
#       gen    N      size       sd median   qt2   qt3    qt4   qt1    qt5  qt10  qt15  qt20  qt30   qt70
# 16 100080 7692 108506.24 162122.3  47500 17500 47500 130000 10000 565000 10000 10000 17500 17500 107500
# 17 100085 7861 104035.91 155986.8  47500 17500 47500 122500 10000 542500 10000 10000 17500 17500 100000
# 18 100090 8113  99208.68 147351.2  40000 17500 40000 122500 10000 520000 10000 10000 17500 17500  92500
# 19 100095 8191  96429.16 143540.6  40000 17500 40000 115000 10000 505000 10000 10000 17500 17500  92500
# 20 100100 8167  93976.22 136327.0  40000 17500 40000 115000 10000 497500 10000 10000 17500 17500  92500
# qt80   qt90       se       ci
# 16 160000 272500 1848.515 3623.594
# 17 152500 257500 1759.337 3448.768
# 18 145000 250000 1635.923 3206.828
# 19 145000 250000 1586.011 3108.985
# 20 137500 242500 1508.519 2957.080



# coDo_Ilha[coDo_Ilha$gen %in% c(100080, 100085, 100090, 100095, 100100),]
#       gen     N     size       sd median   qt2   qt3   qt4   qt1    qt5  qt10  qt15  qt20  qt30  qt70
# 16 100080 15408 44072.80 65633.16  25000 10000 25000 47500 10000 220000 10000 10000 10000 17500 40000
# 17 100085 14981 43702.19 64919.72  25000 10000 25000 47500 10000 220000 10000 10000 10000 17500 40000
# 18 100090 14857 42830.65 63756.46  25000 10000 25000 46250 10000 212500 10000 10000 10000 17500 40000
# 19 100095 14757 42156.86 62528.33  25000 10000 25000 40000 10000 205000 10000 10000 10000 17500 40000
# 20 100100 14861 40749.53 59076.28  17500 10000 17500 40000 10000 205000 10000 10000 10000 17500 32500
# qt80   qt90       se        ci
# 16 55000 100000 528.7497 1036.4119
# 17 55000  92500 530.4034 1039.6555
# 18 55000  92500 523.0686 1025.2792
# 19 55000  92500 514.7280 1008.9311
# 20 47500  85000 484.6064  949.8885

# lines(sc01_Ilha$gen, sc01_Ilha$size, col = "cornflowerblue", lty = 3, lwd = 3)
# # lines(sc01_Ilha$gen, sc01_Ilha$median, col = "cornflowerblue", lty = 2)
# polygon(c(sc01_Ilha$gen, rev(sc01_Ilha$gen)), 
#         y = c(sc01_Ilha$qt10, rev(sc01_Ilha$qt90))
#         , col = scales::alpha( "cornflowerblue", 0.1),
#         border = scales::alpha("cornflowerblue", 0.15)
#         
# )