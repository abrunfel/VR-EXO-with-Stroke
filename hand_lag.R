# Messing around with time-lag between hands (calculated as the lag in seconds between Xcorrelation of hand velocity profiles (see Kantak 2019)) lag.out and lag.lap

tmp.data = vr.data %>%
  group_by(Subject, Condition, Block) %>%
  filter(!is.na(rel.cont.diff))%>%
  mutate(rel.cont.diff.oc = replace(rel.cont.diff, (abs(rel.cont.diff - median(rel.cont.diff)) > 1.5*IQR(rel.cont.diff)), NA),
         lag.lap.oc = replace(lag.lap, (abs(lag.lap - median(lag.lap)) > 1.5*IQR(lag.lap)), NA),
         lag.out.oc = replace(lag.out, (abs(lag.out - median(lag.out)) > 1.5*IQR(lag.out)), NA))

# Then get the dataframe snippet with only NAs and set rel.cont.diff.oc = NA
na.data = vr.data %>% filter(is.na(rel.cont.diff)) %>% mutate(rel.cont.diff.oc = NA)
na.data = vr.data %>% filter(is.na(lag.lap)) %>% mutate(lag.lap.oc = NA)
na.data = vr.data %>% filter(is.na(lag.out)) %>% mutate(lag.out.oc = NA)
# Rebind tmp.data and na.data, then arrange
vr.data = rbind(tmp.data, na.data)
vr.data = arrange(vr.data, Subject, Condition, Block, Trial)
rm(tmp.data, na.data)

vr.data %>%
  ggplot(aes(x = lag.out))+
  geom_histogram()
vr.data %>%
  ggplot(aes(x = lag.out.oc))+
  geom_histogram()
  
# Mean by block
vr.data.mbb = vr.data %>% select(-c(Trial, Target)) %>% group_by(Subject, Block, Condition) %>% summarise_all(funs(mean(., na.rm = T)))

vr.data.mbb %>%
  mutate(Condition = fct_relevel(Condition, "Bil-BL Pre", "Loading", "Bil-BL Post")) %>%
  ggplot(aes(x = Condition, y = lag.out.oc))+
  geom_boxplot(outlier.colour = NA)+
  geom_point(position = position_jitter(width = 0.1))+
  theme_cowplot()

vr.data.mbb %>%
  mutate(Condition = fct_relevel(Condition, "Bil-BL Pre", "Loading", "Bil-BL Post")) %>%
  ggplot(aes(x = Condition, y = lag.lap.oc))+
  geom_boxplot(outlier.colour = NA)+
  geom_point(position = position_jitter(width = 0.1))+
  theme_cowplot()

aov_ez(data = subset(vr.data.mbb, !Block %in% c(1,5)), id = "Subject", dv = "lag.lap.oc", within = "Condition")
# Followup t-tests
t.test(lag.lap ~ Block, subset(vr.data.mbb, Block %in% c(2,3)), paired = T)
t.test(lag.lap ~ Block, subset(vr.data.mbb, Block %in% c(2,4)), paired = T)
t.test(lag.lap ~ Block, subset(vr.data.mbb, Block %in% c(3,4)), paired = T)
