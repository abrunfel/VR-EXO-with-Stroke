# Initialize Script------------
library(tidyverse)
library(cowplot)
#


# VR Data -------
if(.Platform$OS.type == "unix"){
  load("~/Library/CloudStorage/Dropbox/Catholic U/VR_EXO_Stroke/Routput/230116-VREXO-Stroke-WS-NOremoval.RData")
} else if (.Platform$OS.type == "windows") {
  load("C:\\Users\\abrun\\Dropbox\\Catholic U\\VR_EXO_Stroke\\Routput\\230116-VREXO-Stroke-WS-NOremoval.RData")
}

vr.data %>% filter(!Subject %in% lefties) %>%
  ggplot(aes(x = disp.rh, y = disp.lh, color = Condition))+
  #ggplot(aes(x = rh.normS, y = lh.normS, color = Condition))+
  #ggplot(aes(x = disp.rh/disp.cursor, y = disp.lh/disp.cursor, color = Condition))+
  geom_point()+
  geom_abline(intercept = 0, slope = 1)+
  stat_ellipse(level = 0.95)
  #coord_cartesian(xlim = c(0, 2), ylim = c(0, 2))



  facet_wrap(~Target, nrow = 2)+
  coord_cartesian(xlim = c(0, 2), ylim = c(0, 2))
#

# EMG Data-----
plot(subset(emg.data, Muscle == "Impaired Deltoid" & !Subject %in% lefties)$rmse.norm,
     subset(emg.data, Muscle == "Non-Impaired Deltoid" & !Subject %in% lefties)$rmse.norm,
     col = factor(emg.data$Condition),
     xlim = c(0,1000),
     ylim = c(0,1000))
legend("topright",
       legend = levels(factor(emg.data$Condition)),
       pch = 19,
       col = factor(levels(factor(emg.data$Condition))))
  
#

# VR Data (HEALTHIES) -------
if(.Platform$OS.type == "unix"){
  load("~/Library/CloudStorage/Dropbox/Catholic U/VR_EXO/Routput/210616_exovr_workspace.RData")
} else if (.Platform$OS.type == "windows") {
  load("C:\\Users\\abrun\\Dropbox\\Catholic U\\VR_EXO\\Routput\\210616_exovr_workspace.RData")
}

vr.data %>% filter(Target == c(7,8)) %>%
  ggplot(aes(x = disp.rh, y = disp.lh, color = Condition))+
  #ggplot(aes(x = rh.normS, y = lh.normS, color = Condition))+
  #ggplot(aes(x = disp.rh/disp.cursor, y = disp.lh/disp.cursor, color = Condition))+
  geom_point()+
  geom_abline(intercept = 0, slope = 1)
  

  stat_ellipse(level = 0.95)
  facet_wrap(~Target, nrow = 2)+
  coord_cartesian(xlim = c(0, 2), ylim = c(0, 2))
#

# EMG Data-----
plot(subset(emg.data, Muscle == "L Deltoid")$rmse,
     subset(emg.data, Muscle == "R Deltoid")$rmse,
     col = factor(emg.data$Condition))
legend("topright",
       legend = levels(factor(emg.data$Condition)),
       pch = 19,
       col = factor(levels(factor(emg.data$Condition))))

#
  
# 3D plots-------
library(plotly)
plot_ly(subset(vr.data, Target %in% c(7,8)),
        x = ~disp.rh, y = ~disp.lh, z = ~disp.cursor)
    
#