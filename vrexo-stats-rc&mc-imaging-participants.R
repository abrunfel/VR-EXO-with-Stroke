# Initialize Script, load data ------------
library(tidyverse)
library(cowplot)
library(afex)
library(emmeans)
library(effsize)
library(readxl)
if(.Platform$OS.type == "unix"){
  source("~/Dropbox/Catholic U/VR_EXO_Stroke/Scripts/ts_reduce.R", echo=TRUE)
  setwd('/Users/alexbrunfeldt/Library/CloudStorage/Dropbox/Catholic U/VR_EXO_Stroke/Routput/')
  load("/Users/alexbrunfeldt/Library/CloudStorage/Dropbox/Catholic U/VR_EXO_Stroke/Routput/230411-VREXO-Stroke-WS-NOremoval.RData")
} else if (.Platform$OS.type == "windows") {
  source("C:\\Users\\abrun\\Dropbox\\Catholic U\\VR_EXO_Stroke\\Scripts\\ts_reduce.R", echo=TRUE)
  setwd('C:/Users/abrun/Dropbox/Catholic U/VR_EXO_Stroke/Routput/')
  load("C:/Users/abrun/Dropbox/Catholic U/VR_EXO_Stroke/Routput/230411-VREXO-Stroke-WS-NOremoval.RData")
  
  # source("C:\\Users\\brunfa01\\Dropbox\\Catholic U\\VR_EXO_Stroke\\Scripts\\ts_reduce.R", echo=TRUE)
  # setwd('C:/Users/brunfa01/Dropbox/Catholic U/VR_EXO_Stroke/Routput/')
  # load("C:/Users/brunfa01/Dropbox/Catholic U/VR_EXO_Stroke/Routput/230411-VREXO-Stroke-WS-NOremoval.RData")
}
if(.Platform$OS.type == "unix"){
  overlap_SMATT <- read_excel("/Users/alexbrunfeldt/Library/CloudStorage/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_compile/overlap_SMATT.xlsx")
  overlap_PyT <- read_excel("/Users/alexbrunfeldt/Library/CloudStorage/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_compile/overlap_PyT.xlsx")
} else if (.Platform$OS.type == "windows") {
  overlap_SMATT <- read_excel("C://Users//abrun//Dropbox//Catholic U//VR_EXO_Stroke//Data//post_compile//overlap_SMATT.xlsx")
  overlap_PyT <- read_excel("C://Users//abrun//Dropbox//Catholic U//VR_EXO_Stroke//Data//post_compile//overlap_PyT.xlsx")
  
  # overlap_SMATT <- read_excel("C://Users//brunfa01//Dropbox//Catholic U//VR_EXO_Stroke//Data//post_compile//overlap_SMATT.xlsx")
  # overlap_PyT <- read_excel("C://Users//brunfa01//Dropbox//Catholic U//VR_EXO_Stroke//Data//post_compile//overlap_PyT.xlsx")
}

# Get only the imaging participants (N = 10)-----------
vr.data.img.mbb = subset(vr.data.mbb, Subject %in% overlap_PyT$Subject)
emg.data.ratio.img.mbb = subset(emg.data.ratio.mbb, Subject %in% overlap_PyT$Subject)

# RC plots and stats---------
vr.data.img.mbb %>%
  mutate(Condition = recode_factor(Condition, 'Bil-BL Pre' = 'Pre', 'Bil-BL Post' = 'Post')) %>%
  mutate(Condition = fct_relevel(Condition, "Pre", "Loading", "Post")) %>%
  ggplot(aes(x = Condition, y = rel.cont))+
  geom_boxplot(outlier.shape = NA, lwd = 1.5)+
  geom_point(position = position_jitter(width = 0.1), size = 3)+
  geom_hline(yintercept = 50, linetype = 'dashed')+
  theme_cowplot(26)+
  theme(legend.position = "none")+
  labs(title = "A",
       x = "Block",
       y = 'Relative Contribution (%)')
#ggsave("rc.boxplot.tiff", plot = last_plot(), width = 11.45, height = 8.5, units = "in")

dat = subset(vr.data.img.mbb)
t.test(subset(dat, Block == 2)$rel.cont, mu = 50)
cohen.d(subset(dat, Block == 2)$rel.cont, f = NA, mu = 50)
aov.rc = aov_ez(data = dat, id = "Subject", dv = "rel.cont", within = "Block")
aov.rc

# MC plots and stats----------
emg.data.ratio.img.mbb %>% filter(Muscle == c('Deltoid'),
                              Condition %in% c("Pre", "Loading", "Post")) %>%
  mutate(Condition = fct_relevel(Condition, "Pre", "Loading", "Post")) %>%
  ggplot(aes(x = Condition, y = rmse.norm))+
  geom_boxplot(outlier.shape = NA, lwd = 1.5)+
  geom_point(position = position_jitter(width = 0.1), size = 3)+
  geom_hline(yintercept = 50, linetype = 'dashed')+
  theme_cowplot(26)+
  #panel_border()+
  theme(legend.position = "none")+
  labs(title = "C Deltoid",
       x = "Block",
       y = 'Muscle Contribution (%)')
#ggsave("mc.delt.boxplot.tiff", plot = last_plot(), width = 11.45, height = 8.5, units = "in")

#mc.outlier = c('73881501')
mc.outlier = c()
dat = subset(emg.data.ratio.img.mbb, Muscle == "Deltoid" & !Subject %in% mc.outlier)
t.test(subset(dat, Block == 2)$rmse.norm, mu = 50)
cohen.d(subset(dat, Block == 2)$rmse.norm, f = NA, mu = 50)
aov.mc.delt = aov_ez(data = dat, id = "Subject", dv = "rmse.norm", within = "Block") #knitr::kable(nice(aov.mc.delt))
aov.mc.delt
means.mc.delt = emmeans(aov.mc.delt, ~ Block)
means.mc.delt
pairs(means.mc.delt)
eff_size(means.mc.delt, sigma = sd(dat$rmse.norm), edf = df.residual(aov.mc.delt$lm))
rm(dat)
