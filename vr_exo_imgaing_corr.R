# Script to read in both the VR+EXO+Tradeoff and Imaging datasets
# Load data --------
library(readxl)
library(cowplot)
library(tidyverse)
if(.Platform$OS.type == "unix"){
  load("~/Dropbox/Catholic U/VR_EXO_Stroke/Routput/230116-VREXO-Stroke-WS-NOremoval.RData")
  overlap_SMATT <- read_excel("~/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_compile/overlap_SMATT.xlsx")
} else if (.Platform$OS.type == "windows") {
  load("C:/Users/abrun/Dropbox/Catholic U/VR_EXO_Stroke/Routput/230116-VREXO-Stroke-WS-NOremoval.RData")
  overlap_SMATT <- read_excel("C:/Users/abrun/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_compile/overlap_SMATT.xlsx")
}
overlap_SMATT$Subject = as.factor(overlap_SMATT$Subject) # Convert subject var to factor

# VR (Loading) + Imaging -------
img.vr.loading = cbind(subset(vr.data.mbb, Subject %in% overlap_SMATT$Subject & Condition == "Loading"),
                       subset(overlap_SMATT, select = -c(Subject)))

## Lesion Volume --------
img.vr.loading %>%
  #filter(!Subject == 73872901)%>% 
ggplot(aes(x = lesion_vol, y = rel.cont.diff))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.rc.vol = lm(rel.cont.diff ~ lesion_vol, data = img.vr.loading)
#lm.rc.vol = lm(rel.cont.diff ~ lesion_vol, data = subset(img.vr.loading, !Subject == 73872901))
summary(lm.rc.vol)
#

## Slice-wise overlap ---------
img.vr.loading %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = maxSliceWise_overlap, y = rel.cont.diff))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.rc.slice = lm(rel.cont.diff ~ maxSliceWise_overlap, data = img.vr.loading)
#lm.rc.slice = lm(rel.cont.diff ~ maxSliceWise_overlap, data = subset(img.vr.loading, !Subject == 73872901))
summary(lm.rc.slice)
#

## Volumetric overlap ---------
img.vr.loading %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = max_vol_overlap, y = rel.cont.diff))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.rc.vol.overlap = lm(rel.cont.diff ~ max_vol_overlap, data = img.vr.loading)
#lm.rc.vol.overlap = lm(rel.cont.diff ~ max_vol_overlap, data = subset(img.vr.loading, !Subject == 73872901))
summary(lm.rc.vol.overlap)
#

## wCSTLL overlap ---------
img.vr.loading %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = wCSTLL, y = rel.cont.diff))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.rc.wcstll.overlap = lm(rel.cont.diff ~ wCSTLL, data = img.vr.loading)
#lm.rc.wcstll.overlap = lm(rel.cont.diff ~ max_vol_overlap, data = subset(img.vr.loading, !Subject == 73872901))
summary(lm.rc.wcstll.overlap)
#

# RMS (Loading, Impaired Deltoid) + Imaging -------
img.rms.loading = cbind(subset(emg.data.mbb, Subject %in% overlap_SMATT$Subject & Condition == "Loading" & Muscle == "Impaired Deltoid"),
                        subset(overlap_SMATT, select = -c(Subject)))
#

## Lesion Volume --------
img.rms.loading %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = lesion_vol, y = rmse.norm.bc))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.rms.vol = lm(rmse.norm.bc ~ lesion_vol, data = img.rms.loading)
#lm.rms.vol = lm(rmse.norm.bc ~ lesion_vol, data = subset(img.rms.loading, !Subject == 73872901))
summary(lm.rms.vol)
#

## Slice-wise overlap --------
img.rms.loading %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = maxSliceWise_overlap, y = rmse.norm.bc))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.rms.slice = lm(rmse.norm.bc ~ maxSliceWise_overlap, data = img.rms.loading)
#lm.rms.slice = lm(rmse.norm.bc ~ maxSliceWise_overlap, data = subset(img.rms.loading, !Subject == 73872901))
summary(lm.rms.slice)
#

## Volumetric overlap ---------
img.rms.loading %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = max_vol_overlap, y = rmse.norm.bc))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.rms.vol.overlap = lm(rmse.norm.bc ~ max_vol_overlap, data = img.rms.loading)
#lm.rms.vol.overlap = lm(rmse.norm.bc ~ max_vol_overlap, data = subset(img.rms.loading, !Subject == 73872901))
summary(lm.rms.vol.overlap)
#

## wCSTLL overlap ---------
img.rms.loading %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = wCSTLL, y = rmse.norm.bc))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.rms.wcstll.overlap = lm(rmse.norm.bc ~ wCSTLL, data = img.rms.loading)
#lm.rms.wcstll.overlap = lm(rel.cont.diff ~ max_vol_overlap, data = subset(img.vr.loading, !Subject == 73872901))
summary(lm.rms.wcstll.overlap)
#

# MC (Loading, Deltoid) + Imaging -------
img.mc.loading = cbind(subset(emg.data.ratio.mbb, Subject %in% overlap_SMATT$Subject & Condition == "Loading" & Muscle == "Deltoid"),
                        subset(overlap_SMATT, select = -c(Subject)))
#

## Lesion Volume --------
img.mc.loading %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = lesion_vol, y = rmse.norm.bc.oc))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.mc.vol = lm(rmse.norm.bc.oc ~ lesion_vol, data = img.mc.loading)
#lm.mc.vol = lm(rmse.norm.bc.oc ~ lesion_vol, data = subset(img.mc.loading, !Subject == 73872901))
summary(lm.mc.vol)
#

## Slice-wise overlap --------
img.mc.loading %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = maxSliceWise_overlap*100, y = rmse.norm.bc.oc))+
  geom_point(size = 3)+
  geom_smooth(method = lm)+
  theme_cowplot(18)+
  xlab("Slice-wise overlap (%)") + ylab("\u0394 Muscle Contribution (%)")

lm.mc.slice = lm(rmse.norm.bc.oc ~ maxSliceWise_overlap, data = img.mc.loading)
#lm.mc.slice = lm(rmse.norm.bc.oc ~ maxSliceWise_overlap, data = subset(img.mc.loading, !Subject == 73872901))
summary(lm.mc.slice)
#

## Volumetric overlap ---------
img.mc.loading %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = max_vol_overlap, y = rmse.norm.bc.oc))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.mc.vol.overlap = lm(rmse.norm.bc.oc ~ max_vol_overlap, data = img.mc.loading)
#lm.mc.vol.overlap = lm(rmse.norm.bc.oc ~ max_vol_overlap, data = subset(img.mc.loading, !Subject == 73872901))
summary(lm.mc.vol.overlap)
#

## wCSTLL overlap ---------
img.mc.loading %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = wCSTLL, y = rmse.norm.bc.oc))+
  geom_point(size = 3)+
  geom_smooth(method = lm)+
  theme_cowplot(18)+
  xlab("wCSTLL (cc)") + ylab("\u0394 Muscle Contribution (%)")

lm.mc.wcstll.overlap = lm(rmse.norm.bc.oc ~ wCSTLL, data = img.mc.loading)
#lm.mc.wcstll.overlap = lm(rel.cont.diff ~ max_vol_overlap, data = subset(img.vr.loading, !Subject == 73872901))
summary(lm.mc.wcstll.overlap)
#

# Trade-off (Loading, Deltoid) + Imaging -------
img.to = cbind(subset(to.delt.df, subs %in% overlap_SMATT$Subject),
                       subset(overlap_SMATT, select = -c(Subject)))
#

## Lesion Volume --------
img.to %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = lesion_vol, y = slope))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.to.vol = lm(slope ~ lesion_vol, data = img.to)
#lm.to.vol = lm(slope ~ lesion_vol, data = subset(img.to, !Subject == 73872901))
summary(lm.to.vol)
#

## Slice-wise overlap --------
img.to %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = maxSliceWise_overlap, y = slope))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.to.slice = lm(slope ~ maxSliceWise_overlap, data = img.to)
#lm.to.slice = lm(slope ~ maxSliceWise_overlap, data = subset(img.to, !Subject == 73872901))
summary(lm.to.slice)
#

## Volumetric overlap ---------
img.to %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = max_vol_overlap, y = slope))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.to.vol.overlap = lm(slope ~ max_vol_overlap, data = img.to)
#lm.to.vol.overlap = lm(slope ~ max_vol_overlap, data = subset(img.to, !Subject == 73872901))
summary(lm.to.vol.overlap)
#

## wCSTLL overlap ---------
img.to %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = wCSTLL, y = slope))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.to.wcstll.overlap = lm(slope ~ wCSTLL, data = img.to)
#lm.to.wcstll.overlap = lm(slope ~ wCSTLL, data = subset(img.to, !Subject == 73872901))
summary(lm.to.wcstll.overlap)
#

# Trade-off magnitude (Loading, Deltoid) + Imaging -------
img.tom = img.to %>% mutate(magnitude = sqrt(drc^2 + dmc^2)) %>% relocate(magnitude, .after = magnitude)

## Lesion Volume --------
img.tom %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = lesion_vol, y = magnitude))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.tom.vol = lm(magnitude ~ lesion_vol, data = img.tom)
#lm.tom.vol = lm(magnitude ~ lesion_vol, data = subset(img.tom, !Subject == 73872901))
summary(lm.tom.vol)
#

## Slice-wise overlap --------
img.tom %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = maxSliceWise_overlap, y = magnitude))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.tom.slice = lm(magnitude ~ maxSliceWise_overlap, data = img.tom)
#lm.tom.slice = lm(magnitude ~ maxSliceWise_overlap, data = subset(img.tom, !Subject == 73872901))
summary(lm.tom.slice)
#

## Volumetric overlap ---------
img.tom %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = max_vol_overlap, y = magnitude))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.tom.vol.overlap = lm(magnitude ~ max_vol_overlap, data = img.tom)
#lm.tom.vol.overlap = lm(magnitude ~ max_vol_overlap, data = subset(img.tom, !Subject == 73872901))
summary(lm.tom.vol.overlap)
#

## wCSTLL overlap ---------
img.tom %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = wCSTLL, y = magnitude))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.tom.wcstll.overlap = lm(magnitude ~ wCSTLL, data = img.tom)
#lm.tom.wcstll.overlap = lm(magnitude ~ wCSTLL, data = subset(img.tom, !Subject == 73872901))
summary(lm.tom.wcstll.overlap)
#

# FM vs. Lesion Load---------------
overlap_SMATT = cbind(overlap_SMATT,p.table %>% filter(p.table$Subject.ID %in% overlap_SMATT$Subject) %>% select('FM'))

## Slice-wise overlap --------
overlap_SMATT %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = maxSliceWise_overlap*100, y = FM))+
  geom_point(size = 3)+
  geom_smooth(method = lm)+
  theme_cowplot(18)+
  xlab("Slice-wise overlap (%)") + ylab("UE-FM Score")

lm.fm.slice = lm(FM ~ maxSliceWise_overlap, data = overlap_SMATT)
summary(lm.fm.slice)
#

## wCSTLL overlap --------
overlap_SMATT %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = wCSTLL, y = FM))+
  geom_point(size = 3)+
  geom_smooth(method = lm)+
  theme_cowplot(18)+
  xlab("wCSTLL (cc)") + ylab("UE-FM Score")

lm.fm.wcstll = lm(FM ~ wCSTLL, data = overlap_SMATT)
summary(lm.fm.wcstll)
#

