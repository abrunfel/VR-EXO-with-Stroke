# Script to read in both the VR+EXO+Tradeoff and Imaging datasets
# Load data --------
library(readxl)
library(cowplot)
library(tidyverse)
"%ni%" <- Negate("%in%") # Define the 'not-in' function
if(.Platform$OS.type == "unix"){
  load("~/Dropbox/Catholic U/VR_EXO_Stroke/Routput/230406-VREXO-Stroke-WS-NOremoval.RData")
  overlap_PyT <- read_excel("~/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_compile/overlap_PyT.xlsx")
} else if (.Platform$OS.type == "windows") {
  # load("C:/Users/abrun/Dropbox/Catholic U/VR_EXO_Stroke/Routput/230406-VREXO-Stroke-WS-NOremoval.RData")
  # overlap_PyT <- read_excel("C:/Users/abrun/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_compile/overlap_PyT.xlsx")
  
  load("C:/Users/brunfa01/Dropbox/Catholic U/VR_EXO_Stroke/Routput/230406-VREXO-Stroke-WS-NOremoval.RData")
  overlap_PyT <- read_excel("C:/Users/brunfa01/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_compile/overlap_PyT.xlsx")
}
overlap_PyT$Subject = as.factor(overlap_PyT$Subject) # Convert subject var to factor

# VR (Loading) + Imaging -------
img.vr.loading = cbind(subset(vr.data.mbb, Subject %in% overlap_PyT$Subject & Condition == "Loading"),
                       subset(overlap_PyT, select = -c(Subject)))

temp1 = img.vr.loading%>%
  filter(Subject %in% lefties$Subject.ID)%>%
  select(Subject, disp.lh.diff, wCSTLL)%>%
  rename(disp.diff = disp.lh.diff)
temp2 = img.vr.loading%>%
  filter(Subject %ni% lefties$Subject.ID)%>%
  select(Subject, disp.rh.diff, wCSTLL)%>%
  rename(disp.diff = disp.rh.diff)
img.disp.loading = rbind(temp1, temp2)
rm(temp1, temp2)

## Disp vs. wCSTLL
img.disp.loading %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = wCSTLL, y = disp.diff))+
  geom_point()+
  geom_smooth(method = lm)+
  theme_cowplot()

lm.disp.wcstll.overlap = lm(disp.diff ~ wCSTLL, data = img.disp.loading)
summary(lm.disp.wcstll.overlap)
#

# RMS (Loading, Impaired Bicep) + Imaging -------
img.rms.loading = cbind(subset(emg.data.mbb, Subject %in% overlap_PyT$Subject & Condition == "Loading" & Muscle == "Impaired Bicep"),
                        subset(overlap_PyT, select = -c(Subject)))
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


# Trade-off (Loading, Bicep) + Imaging -------
img.to = cbind(subset(to.bi.df, subs %in% overlap_PyT$Subject),
               subset(overlap_PyT, select = -c(Subject)))

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

# Trade-off magnitude (Loading, Bicep) + Imaging -------
img.tom = img.to %>% mutate(magnitude = sqrt(drc^2 + dmc^2)) %>% relocate(magnitude, .after = magnitude)

## wCSTLL overlap ---------
img.tom %>%
  #filter(!Subject == 73872901)%>% 
  ggplot(aes(x = wCSTLL, y = magnitude))+
  geom_point(size = 3)+
  geom_smooth(method = lm)+
  theme_cowplot(18)+
  xlab("wCSTLL") + ylab("Magnitude (a.u.)")

lm.tom.wcstll.overlap = lm(magnitude ~ wCSTLL, data = img.tom)
#lm.tom.wcstll.overlap = lm(magnitude ~ wCSTLL, data = subset(img.tom, !Subject == 73872901))
summary(lm.tom.wcstll.overlap)
#
