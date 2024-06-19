# Timing and Kinematics (Bimanual Analysis)
# Run "vr_exo_stroke_vr.Rmd" before this

# Movement Time --------
biman.data.mbb %>%
  mutate(Condition = fct_relevel(Condition, "Bil-BL Pre", "Loading", "Bil-BL Post")) %>%
  ggplot(aes(x = Condition, y = mt))+
  geom_boxplot(outlier.shape = NA)+
  geom_jitter(width = 0.1)+
  facet_wrap(~Hand)+
  theme_cowplot()
t.test(mt ~ Condition, subset(biman.data.mbb, Hand == "Impaired" & Condition %in% c("Bil-BL Pre","Bil-BL Post")), paired = T)
t.test(mt ~ Condition, subset(biman.data.mbb, Hand == "Non-Impaired" & Condition %in% c("Bil-BL Pre","Bil-BL Post")), paired = T)
#

# Peak Velocity --------
biman.data.mbb %>%
  mutate(Condition = fct_relevel(Condition, "Bil-BL Pre", "Loading", "Bil-BL Post")) %>%
  ggplot(aes(x = Condition, y = velPeak))+
  geom_boxplot(outlier.shape = NA)+
  geom_jitter(width = 0.1)+
  facet_wrap(~Hand)+
  theme_cowplot()
t.test(velPeak ~ Condition, subset(biman.data.mbb, Hand == "Impaired" & Condition %in% c("Bil-BL Pre","Bil-BL Post")), paired = T)
t.test(velPeak ~ Condition, subset(biman.data.mbb, Hand == "Non-Impaired" & Condition %in% c("Bil-BL Pre","Bil-BL Post")), paired = T)
#

# Time to Peak Velocity --------
biman.data.mbb %>%
  mutate(Condition = fct_relevel(Condition, "Bil-BL Pre", "Loading", "Bil-BL Post")) %>%
  ggplot(aes(x = Condition, y = time2pv))+
  geom_boxplot(outlier.shape = NA)+
  geom_jitter(width = 0.1)+
  facet_wrap(~Hand)+
  theme_cowplot()
t.test(time2pv ~ Condition, subset(biman.data.mbb, Hand == "Impaired" & Condition %in% c("Bil-BL Pre","Bil-BL Post")), paired = T)
t.test(time2pv ~ Condition, subset(biman.data.mbb, Hand == "Non-Impaired" & Condition %in% c("Bil-BL Pre","Bil-BL Post")), paired = T)
#

# Reaction Time --------
biman.data.mbb %>%
  mutate(Condition = fct_relevel(Condition, "Bil-BL Pre", "Loading", "Bil-BL Post")) %>%
  ggplot(aes(x = Condition, y = rt))+
  geom_boxplot(outlier.shape = NA)+
  geom_jitter(width = 0.1)+
  facet_wrap(~Hand)+
  theme_cowplot()
t.test(rt ~ Condition, subset(biman.data.mbb, Hand == "Impaired" & Condition %in% c("Bil-BL Pre","Bil-BL Post")), paired = T)
t.test(rt ~ Condition, subset(biman.data.mbb, Hand == "Non-Impaired" & Condition %in% c("Bil-BL Pre","Bil-BL Post")), paired = T)
#

# Average Velocity --------
biman.data.mbb %>%
  mutate(Condition = fct_relevel(Condition, "Bil-BL Pre", "Loading", "Bil-BL Post")) %>%
  ggplot(aes(x = Condition, y = disp/mt))+
  geom_boxplot(outlier.shape = NA)+
  geom_jitter(width = 0.1)+
  facet_wrap(~Hand)+
  theme_cowplot()
t.test(disp/mt ~ Condition, subset(biman.data.mbb, Hand == "Impaired" & Condition %in% c("Bil-BL Pre","Bil-BL Post")), paired = T)
t.test(disp/mt ~ Condition, subset(biman.data.mbb, Hand == "Non-Impaired" & Condition %in% c("Bil-BL Pre","Bil-BL Post")), paired = T)
#