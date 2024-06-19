# Check bc calculation VR ----------------------------------------------------
temp.vr = vr.data %>% group_by(Subject) %>%
  mutate(rel.cont.diff = rel.cont - mean(rel.cont[Block == 2]))

temp.vr%>%
ggplot(aes(x = Trial, y = rel.cont, color = Condition))+
  geom_point()+
  geom_hline(yintercept = 50, linetype = 'dashed')+
  facet_grid(rows = vars(Block), cols = vars(Subject))+
  theme_cowplot()+
  panel_border()+
  ylab('Relative Contribution (%)')

# Check bc calculation EMG ----------------------------------------------------
# Overall bc calculation works like a dream
summary(subset(emg.data, Block == 2 & Muscle == 'Impaired Deltoid')$rmse.bc)
emg.data %>%
  filter(Muscle == c('Non-Impaired Deltoid', 'Impaired Deltoid')) %>%
  ggplot(aes(x = Trial, y = rmse.bc, color = Muscle))+
  geom_point()+
  geom_hline(yintercept = 0, linetype = 'dashed')+
  facet_grid(rows = vars(Block), cols = vars(Subject))+
  theme_cowplot()+
  panel_border()+
  coord_cartesian(ylim = c(-200, 200))


# Try to baseline correct AFTER outlier cleaning.
#NOTE: THIS DOES NOT WORK AS OF 1/17/23
temp.emg = emg.data %>%
  group_by(Subject, Block,  Muscle) %>%
  mutate(rmse.oc = replace(rmse, (abs(rmse - median(rmse, na.rm = T)) > 1.5*IQR(rmse, na.rm = T)), NA),
         rmse.norm.oc = replace(rmse.norm, (abs(rmse.norm - median(rmse.norm, na.rm = T)) > 1.5*IQR(rmse.norm, na.rm = T)), NA))%>%
  ungroup()%>%
  group_by(Subject, Muscle) %>%
  mutate(rmse.oc.bc = 100*(rmse.oc - mean(rmse.oc[Block == 2]))/mean(rmse.oc[Block == 2]),
         rmse.norm.oc.bc = 100*(rmse.norm.oc - mean(rmse.norm.oc[Block == 2]))/mean(rmse.norm.oc[Block == 2]))

summary(subset(temp.emg, Block == 2 & Muscle == 'Impaired Deltoid')$rmse.oc.bc, na.rm = T)
temp.emg %>%
  filter(Muscle == c('Non-Impaired Deltoid', 'Impaired Deltoid')) %>%
  ggplot(aes(x = Trial, y = rmse.oc.bc, color = Muscle))+
  geom_point()+
  geom_hline(yintercept = 0, linetype = 'dashed')+
  facet_grid(rows = vars(Block), cols = vars(Subject))+
  theme_cowplot()+
  panel_border()+
  coord_cartesian(ylim = c(-200, 200))
