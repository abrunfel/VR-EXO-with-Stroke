# Initialize Script------------
library(tidyverse)
library(cowplot)
library(afex)
library(emmeans)
library(effsize)
library(readxl)
if(.Platform$OS.type == "unix"){
  source("~/Dropbox/Catholic U/VR_EXO_Stroke/Scripts/ts_reduce.R", echo=TRUE)
  setwd('/Users/alexbrunfeldt/Library/CloudStorage/Dropbox/Catholic U/VR_EXO_Stroke/Routput/')
  load("/Users/alexbrunfeldt/Library/CloudStorage/Dropbox/Catholic U/VR_EXO_Stroke/Routput/230406-VREXO-Stroke-WS-NOremoval.RData")
} else if (.Platform$OS.type == "windows") {
  source("C:\\Users\\brunfa01\\Dropbox\\Catholic U\\VR_EXO_Stroke\\Scripts\\ts_reduce.R", echo=TRUE)
  setwd('C:/Users/brunfa01/Dropbox/Catholic U/VR_EXO_Stroke/Routput/')
  load("C:/Users/brunfa01/Dropbox/Catholic U/VR_EXO_Stroke/Routput/230406-VREXO-Stroke-WS-NOremoval.RData")
}
#

# RC ------------------
vr.data.mbbin %>%
  mutate(Condition = recode_factor(Condition, 'Bil-BL Pre' = 'Pre', 'Bil-BL Post' = 'Post')) %>%
  mutate(Condition = fct_relevel(Condition, "Pre", "Loading", "Post")) %>%
  ggplot(aes(x = Bin, y = rel.cont, color = Condition))+
  stat_summary(fun.data = 'mean_se', position = position_dodge(width = 0.5))+
  stat_summary(fun.data = 'mean_se', geom = 'line', position = position_dodge(width = 0.5))+
  theme_cowplot(26)+
  ylab('Relative Contribution (%)')
#aov_ez(data = subset(vr.data.mbbin, Bin == c(1,9)), id = "Subject", dv = "rel.cont", within = "Bin")

vr.data.mbb %>%
  mutate(Condition = recode_factor(Condition, 'Bil-BL Pre' = 'Pre', 'Bil-BL Post' = 'Post')) %>%
  mutate(Condition = fct_relevel(Condition, "Pre", "Loading", "Post")) %>%
  ggplot(aes(x = Condition, y = rel.cont, color = Condition))+
  geom_boxplot(outlier.shape = NA, lwd = 1.5)+
  geom_point(position = position_jitterdodge(), size = 3)+
  geom_hline(yintercept = 50, linetype = 'dashed')+
  theme_cowplot(26)+
  theme(legend.position = "none")+
  ylab('Relative Contribution (%)')
#ggsave("rc.boxplot.tiff", plot = last_plot(), width = 11.45, height = 8.5, units = "in")

dat = subset(vr.data.mbb)
t.test(subset(dat, Block == 2)$rel.cont, mu = 50)
cohen.d(subset(dat, Block == 2)$rel.cont, f = NA, mu = 50)
aov.rc = aov_ez(data = dat, id = "Subject", dv = "rel.cont", within = "Block")
#knitr::kable(nice(aov.rc))
aov.rc
means.rc = emmeans(aov.rc, ~ Block)
means.rc
pairs(means.rc)
eff_size(means.rc, sigma = sd(dat$rel.cont), edf = df.residual(aov.rc$lm))
rm(dat)
# Check for fatigue (look at main effect of Trial and interaction. If both are non-sig, that means RC does not change over time)
aov_ez(data = subset(vr.data, !Trial == "NA" & Trial == c(1,54)), id = "Subject", dv = "rel.cont", within = c("Trial", "Block"))

# MC ----------------------------------------------------------------------
emg.data.ratio.mbbin = ts_reduce_emg(emg.data.ratio,6)
emg.data.ratio.mbbin %>%
  filter(Muscle == "Deltoid") %>%
  mutate(Condition = fct_relevel(Condition, "Pre", "Loading", "Post")) %>%
  ggplot(aes(x = Bin, y = rmse.norm.bc.oc, color = Condition))+
  geom_hline(yintercept = 0, linetype = 'dashed')+
  stat_summary(fun.data = 'mean_se', position = position_dodge(width = 0.5))+
  stat_summary(fun.data = 'mean_se', geom = 'line', position = position_dodge(width = 0.5))+
  theme_cowplot()+
  ylab('Muscle Contribution (bc, norm, oc) (% change)')
  
emg.data.ratio.mbb %>% filter(Muscle == c('Deltoid'),
                              Condition %in% c("Pre", "Loading", "Post")) %>%
  mutate(Condition = fct_relevel(Condition, "Pre", "Loading", "Post")) %>%
  ggplot(aes(x = Condition, y = rmse.norm.bc.oc, color = Condition))+
  geom_boxplot(outlier.shape = NA, lwd = 1.5)+
  geom_point(position = position_jitterdodge(), size = 3)+
  geom_hline(yintercept = 0, linetype = 'dashed')+
  theme_cowplot(26)+
  #panel_border()+
  theme(legend.position = "none")+
  ylab('\u0394 Muscle Contribution (% change)')
#ggsave("mc.boxplot.asnr23.tiff", plot = last_plot(), width = 11.45, height = 8.5, units = "in")

#mc.outlier = c('73881501')
mc.outlier = c()
dat = subset(emg.data.ratio.mbb, Muscle == "Deltoid" & !Subject %in% mc.outlier)
t.test(subset(dat, Block == 2)$rmse.norm, mu = 50)
aov.mc.delt = aov_ez(data = dat, id = "Subject", dv = "rmse.norm.bc.oc", within = "Block") #knitr::kable(nice(aov.mc.delt))
aov.mc.delt
means.mc.delt = emmeans(aov.mc.delt, ~ Block)
means.mc.delt
pairs(means.mc.delt)
eff_size(means.mc.delt, sigma = sd(dat$rmse.norm), edf = df.residual(aov.mc.delt$lm))
rm(dat)
#

# RMS --------
emg.data.mbbin = ts_reduce_emg(emg.data,6)
emg.data.mbbin %>%
  filter(Muscle %in% c("Impaired Deltoid", "Non-Impaired Deltoid")) %>%
  mutate(Condition = fct_relevel(Condition, "Pre", "Loading", "Post")) %>%
  ggplot(aes(x = Bin, y = rmse.norm.bc, color = Condition))+
  geom_hline(yintercept = 0, linetype = 'dashed')+
  stat_summary(fun.data = 'mean_se', position = position_dodge(width = 0.5))+
  stat_summary(fun.data = 'mean_se', geom = 'line', position = position_dodge(width = 0.5))+
  theme_cowplot()+
  facet_wrap(~Muscle)+
  ylab("Baseline corrected, normalized RMS (% Change)")
  

emg.data.mbb %>%
  filter(Muscle %in% c("Impaired Deltoid", "Non-Impaired Deltoid"),
         Condition %in% c("Loading", "Post")) %>%
  mutate(Condition = fct_relevel(Condition, "Pre", "Loading", "Post")) %>%
  ggplot(aes(x = Condition, y = rmse.norm.bc, color = Muscle))+
  geom_boxplot(outlier.shape = NA)+
  geom_point(position = position_jitterdodge())+
  geom_hline(yintercept = 0, linetype = 'dashed')+
  theme_cowplot()+
  panel_border()+
  ylab("Baseline corrected, normalized RMS (% Change)")

aov_ez(data = subset(emg.data.mbb, !Block %in% c(1,5) & Muscle %in% c("Impaired Deltoid", "Non-Impaired Deltoid")), id = "Subject", dv = "rmse.norm.bc", within = c("Condition", "Muscle"))
t.test(rmse.norm.bc ~ Muscle, subset(emg.data.mbb, Condition == "Loading" & Muscle %in% c("Impaired Deltoid", "Non-Impaired Deltoid"), paired = T))
t.test(subset(emg.data.mbb, Condition == "Loading" & Muscle %in% c("Impaired Deltoid"))$rmse.norm.bc, mu = 0)
t.test(subset(emg.data.mbb, Condition == "Loading" & Muscle %in% c("Non-Impaired Deltoid"))$rmse.norm.bc, mu = 0)
#

# Tradeoff --------
bicep = subset(emg.data.ratio.mbb, Muscle == "Bicep")$rmse.norm.bc
deltoid = subset(emg.data.ratio.mbb, Muscle == "Deltoid")$rmse.norm.bc

df.corr.bicep = cbind(vr.data.mbb, bicep)
df.corr.bicep = df.corr.bicep %>% rename(emg.diff = ...27) # Watch this closely. Going from pilot to real experiment, one variable was removed (not sure which), so this changed from 26 to 25.
df.corr.deltoid = cbind(vr.data.mbb, deltoid)
df.corr.deltoid = df.corr.deltoid %>% rename(emg.diff = ...27)

# Deltoid
subs.all = df.corr.deltoid$Subject
df.corr.deltoid %>%
  filter(Condition != "Bil-BL Post" & Subject %in% subs.all)%>%
  mutate(Condition = recode_factor(Condition, 'Bil-BL Pre' = 'Pre', 'Bil-BL Post' = 'Post')) %>%
ggplot(aes(x = emg.diff, y = rel.cont.diff))+
  geom_point(aes(color = Condition, size = 2))+
  #geom_text(aes(label = Subject))+
  geom_line(aes(group = Subject))+
  #coord_cartesian(xlim = c(-33,33), ylim = c(-5,5))+
  geom_hline(yintercept = 0, size = 1, alpha = 0.1)+
  geom_vline(xintercept = 0, size = 1, alpha = 0.1)+
  theme_cowplot(26)+
  labs(x = "\u0394 Muscle Contribution (%)", y = "\u0394 Relative Contribution (%)",
       title = "A. Deltoid - Stroke (Individuals)")+
  theme(legend.position = "none")+
  guides(size = "none", shape = "none")
#ggsave("tradeoff.delt.asnr23.tiff", plot = last_plot(), width = 11.45, height = 8.5, units = "in")

# Bicep
subs.all = df.corr.bicep$Subject
df.corr.bicep %>%
  filter(Condition != "Bil-BL Post" & Subject %in% subs.all)%>%
  mutate(Condition = recode_factor(Condition, 'Bil-BL Pre' = 'Pre', 'Bil-BL Post' = 'Post')) %>%
  ggplot(aes(x = emg.diff, y = rel.cont.diff))+
  geom_point(aes(color = Condition, size = 2))+
  #geom_text(aes(label = Subject))+
  geom_line(aes(group = Subject))+
  #coord_cartesian(xlim = c(-33,33), ylim = c(-5,5))+
  geom_hline(yintercept = 0, size = 1, alpha = 0.1)+
  geom_vline(xintercept = 0, size = 1, alpha = 0.1)+
  theme_cowplot(26)+
  labs(x = "\u0394 Muscle Contribution (%)", y = "\u0394 Relative Contribution (%)",
       title = "Biceps Brachii - Stroke (Individuals)")+
  theme(legend.position = "none")+
  guides(size = "none", shape = "none")
#ggsave("tradeoff.bicep.asnr23.tiff", plot = last_plot(), width = 11.45, height = 8.5, units = "in")


# Imaging correlations (Loading, Deltoid) + Imaging -------
if(.Platform$OS.type == "unix"){
  overlap_SMATT <- read_excel("/Users/alexbrunfeldt/Library/CloudStorage/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_compile/overlap_SMATT.xlsx")
  overlap_PyT <- read_excel("/Users/alexbrunfeldt/Library/CloudStorage/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_compile/overlap_PyT.xlsx")
} else if (.Platform$OS.type == "windows") {
  overlap_SMATT <- read_excel("C://Users//brunfa01//Dropbox//Catholic U//VR_EXO_Stroke//Data//post_compile//overlap_SMATT.xlsx")
  overlap_PyT <- read_excel("C://Users//brunfa01//Dropbox//Catholic U//VR_EXO_Stroke//Data//post_compile//overlap_PyT.xlsx")
}
# Concat emg data and imaging data
# First sort subjects to match. If you don't these relationships are totally WRONG!
emg.data.ratio.mbb = emg.data.ratio.mbb %>%
  arrange(Subject, Block, Muscle)
overlap_SMATT = overlap_SMATT %>%
  arrange(Subject)
overlap_PyT = overlap_PyT %>%
  arrange(Subject)
# cbind dataframes together
img.mc.loading.smatt = cbind(subset(emg.data.ratio.mbb, Subject %in% overlap_SMATT$Subject & Condition == "Loading" & Muscle == "Deltoid"),
                       subset(overlap_SMATT, select = -c(Subject)))
img.mc.loading.pyt = cbind(subset(emg.data.ratio.mbb, Subject %in% overlap_PyT$Subject & Condition == "Loading" & Muscle == "Deltoid"),
                             subset(overlap_PyT, select = -c(Subject)))

img.mc.loading.pyt %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = wCSTLL, y = rmse.norm.bc.oc))+
  geom_point(size = 3)+
  geom_smooth(method = lm)+
  theme_cowplot(26)+
  xlab("Lesion Load (cc)") + ylab("\u0394 Muscle Contribution (%)")
#ggsave("mc.wCSTLL.asnr23.tiff", plot = last_plot(), width = 11.45, height = 8.5, units = "in")

lm.mc.wcstll.overlap = lm(rmse.norm.bc.oc ~ wCSTLL, data = img.mc.loading.pyt)
#lm.mc.wcstll.overlap = lm(rel.cont.diff ~ max_vol_overlap, data = subset(img.vr.loading, !Subject == 73872901))
summary(lm.mc.wcstll.overlap)
#

# Tradeoff + Lesion Load ------------
overlap_PyT.duplicate = rbind(overlap_PyT,overlap_PyT) # Duplicate overlap to get same nrow as tradeoff dataframe
overlap_PyT.duplicate = overlap_PyT.duplicate %>% arrange(Subject) # arrange by Subject ID to match tradeoff dataframe

df.corr.deltoid.clean = df.corr.deltoid %>% # Clean up the dataframe to get rid of extra vars and recode some factors
  filter(Condition != "Bil-BL Post" & Subject %in% overlap_PyT$Subject)%>%
  select(c(Subject, Block, Condition, rel.cont.diff, emg.diff))%>%
  mutate(Condition = recode_factor(Condition, 'Bil-BL Pre' = 'Pre', 'Bil-BL Post' = 'Post'))

# Combine the overlap and trade-off dataframes
to.img = cbind(df.corr.deltoid.clean,
               subset(overlap_PyT.duplicate, select = -c(Subject)))
rm(overlap_PyT.duplicate)
  
  
to.img%>%
  mutate(wCSTLL = wCSTLL/1.526e-5)%>%
  ggplot(aes(x = emg.diff, y = rel.cont.diff))+
  geom_point(aes(color = Condition, size = wCSTLL))+
  #geom_text(aes(label = Subject))+
  geom_line(aes(group = Subject))+
  #coord_cartesian(xlim = c(-33,33), ylim = c(-5,5))+
  geom_hline(yintercept = 0, size = 1, alpha = 0.1)+
  geom_vline(xintercept = 0, size = 1, alpha = 0.1)+
  theme_cowplot(26)+
  labs(x = "\u0394 Muscle Contribution (%)", y = "\u0394 Relative Contribution (%)",
       title = "Deltoid - Subset w/ Imaging")+
  theme(legend.position = c(0.8,0.3),
        legend.text = element_text(size = 20),
        legend.title = element_text(size = 20))+
  guides(color = "none")
#ggsave("tradeoff.img.asnr23.tiff", plot = last_plot(), width = 11.45, height = 8.5, units = "in")
#

# Tradeoff, Lesion Load, and FM-------------
p.table.img = subset(p.table, Subject.ID %in% overlap_SMATT$Subject)
p.table.img.duplicate = rbind(p.table.img, p.table.img) # Duplicate overlap to get same nrow as tradeoff dataframe
p.table.img.duplicate = p.table.img.duplicate %>% arrange(Subject.ID) # arrange by Subject ID to match tradeoff data

to.img$Age = p.table.img.duplicate$Age
to.img$Time.since.stroke = p.table.img.duplicate$Time.since.stroke
to.img$FM = p.table.img.duplicate$FM
rm(p.table.img.duplicate)

to.img%>%
  mutate(wCSTLL = wCSTLL/1.526e-5)%>%
  ggplot(aes(x = emg.diff, y = rel.cont.diff))+
  geom_point(aes(color = Condition, size = wCSTLL))+
  geom_text(aes(label = FM))+
  geom_line(aes(group = Subject))+
  #coord_cartesian(xlim = c(-33,33), ylim = c(-5,5))+
  geom_hline(yintercept = 0, size = 1, alpha = 0.1)+
  geom_vline(xintercept = 0, size = 1, alpha = 0.1)+
  theme_cowplot(26)+
  labs(x = "\u0394 Muscle Contribution (%)", y = "\u0394 Relative Contribution (%)",
       title = "Deltoid - Subset w/ Imaging")+
  theme(legend.position = c(0.8,0.3),
        legend.text = element_text(size = 20),
        legend.title = element_text(size = 20))+
  guides(color = "none")
#