# Load Packages -----------------------------------------------------------
library(tidyverse)
library(gridExtra)
library(gtable)
library(grid)
library(cowplot)
# Load data-----------
# FOR NOW: just run "vr_exo_stroke_vr.Rmd" and "vr_exo_stroke_emg.Rmd" first
#PC
# Stroke
#load("C://Users//Alex//Dropbox//Catholic U//VR_EXO_Stroke//Routput//exovr_stroke_pilot_WS_211227.RData")

## Create df.corr variables ----
bicep = subset(emg.data.ratio.mbb, Muscle == "Bicep")$rmse.norm.bc
deltoid = subset(emg.data.ratio.mbb, Muscle == "Deltoid")$rmse.norm.bc

df.corr.bicep = cbind(vr.data.mbb, bicep)
df.corr.bicep = df.corr.bicep %>% rename(emg.diff = ...27) # Watch this closely. Going from pilot to real experiment, one variable was removed (not sure which), so this changed from 26 to 25.
df.corr.deltoid = cbind(vr.data.mbb, deltoid)
df.corr.deltoid = df.corr.deltoid %>% rename(emg.diff = ...27)
#


## Plot only the 60% load for the RC vs MC plot----
ggplot(data = subset(df.corr.bicep, !Condition %in% c("Bil-BL Post")), aes(x = emg.diff, y = rel.cont.diff))+
  geom_point(aes(color = Condition, size = 2))+
  geom_text(aes(label = Subject))+
  geom_line(aes(group = Subject))+
  #coord_cartesian(xlim = c(-33,33), ylim = c(-5,5))+
  geom_hline(yintercept = 0, size = 1, alpha = 0.1)+
  geom_vline(xintercept = 0, size = 1, alpha = 0.1)+
  theme_cowplot(24)+
  labs(x = "\u0394 Muscle Contribution (%)", y = "\u0394 Relative Contribution (%)",
       title = "Bicep")+
  guides(size = FALSE, shape = FALSE)

ggplot(data = subset(df.corr.deltoid, !Condition %in% c("Bil-BL Post")), aes(x = emg.diff, y = rel.cont.diff))+
  geom_point(aes(color = Condition, size = 2))+
  geom_text(aes(label = Subject))+
  geom_line(aes(group = Subject))+
  #coord_cartesian(xlim = c(-33,33), ylim = c(-5,5))+
  geom_hline(yintercept = 0, size = 1, alpha = 0.1)+
  geom_vline(xintercept = 0, size = 1, alpha = 0.1)+
  theme_cowplot(24)+
  labs(x = "\u0394 Muscle Contribution (%)", y = "\u0394 Relative Contribution (%)",
       title = "Deltoid")+
  guides(size = FALSE, shape = FALSE)


## Create new tradeoff dataframe----
# Attempt at creating a new df that contains the a difference measure (representing the TRADEOFF) between Baseline and Loading* Conditions.
# That is, take the rel.cont.diff of baseline condition minus rel.cont.diff of Loading* condition (same for MC),
# then use those an independent values in determining the tradeoff.

temp.load = df.corr.bicep %>% filter(Condition == "Loading") %>%
  select(c(Subject, rel.cont.diff, emg.diff))

temp.bl = df.corr.bicep %>% filter(Condition == "Bil-BL Pre") %>%
  select(c(Subject, rel.cont.diff, emg.diff))

subs = temp.load$Subject
rcl = temp.load$rel.cont.diff
rcb = temp.bl$rel.cont.diff
mcl = temp.load$emg.diff
mcb = temp.bl$emg.diff

drc = rcl-rcb
dmc = mcl-mcb

to.bi.df = data.frame(subs, drc, dmc)
to.bi.df = to.bi.df %>% mutate(slope = drc/dmc)

# RC-MC mean cluster location (Bicep)
# Loading
c(mean(mcl), mean(rcl))
# Baseline (should be almost zero)
c(mean(mcb), mean(rcb))

#clean up
rm(subs, rcl, rcb, mcl, mcb, drc, dmc, temp.load, temp.bl)

# Test for normality
# ggplot(data = to.bi.df, aes(sample = slope))+
#   geom_qq()+
#   geom_qq_line()
# shapiro.test(to.bi.df$slope)

# CI for slopes
quantile(to.bi.df$slope, 0.025)
quantile(to.bi.df$slope, 0.975)
#

## Deltoid Tradeoff Analysis----
temp.load = df.corr.deltoid %>% filter(Condition == "Loading") %>%
  select(c(Subject, rel.cont.diff, emg.diff))

temp.bl = df.corr.deltoid %>% filter(Condition == "Bil-BL Pre") %>%
  select(c(Subject, rel.cont.diff, emg.diff))

subs = temp.load$Subject
rcl = temp.load$rel.cont.diff
rcb = temp.bl$rel.cont.diff
mcl = temp.load$emg.diff
mcb = temp.bl$emg.diff
drc = rcl-rcb
dmc = mcl-mcb

to.delt.df = data.frame(subs, drc, dmc)
to.delt.df = to.delt.df %>% mutate(slope = drc/dmc)

# RC-MC mean cluster location (Deltoid)
# Loading
c(mean(mcl), mean(rcl))
# Baseline (should be almost zero)
c(mean(mcb), mean(rcb))

#clean up
rm(subs, rcl, rcb, mcl, mcb, drc, dmc, temp.load, temp.bl)

# Test for normality
# ggplot(data = to.delt.df, aes(sample = slope))+
#   geom_qq()+
#   geom_qq_line()
# shapiro.test(to.delt.df$slope)

# CI for slopes
quantile(to.delt.df$slope, 0.025)
quantile(to.delt.df$slope, 0.975)
