library(tidyverse)
library(cowplot)
# Takes the interlimb coherence integral data and calculates change scores and mean by group

# Calculate baseline correction
ci.data = ci.data %>%
  group_by(Subject, Muscle, Band) %>%
  mutate(CI.bc = (CI - mean(CI[Block == 2]))/mean(CI[Block == 2]))

ci.data %>%
  select(-c(Trial, Target, Level, Location)) %>% # Remove unnecessary factors
  group_by(Subject, Block, Condition, Muscle, Band) %>% # Group
  summarise(across(everything(), ~ mean(., na.rm = TRUE))) %>% # mean by group
  mutate(Condition = forcats::fct_relevel(Condition, "Pre", "Loading", "Post")) %>% # Reorder Condition Pre-Loading-Post
  ggplot(aes(x = Muscle, y = CI, fill = Condition)) +
  geom_boxplot() +
  geom_boxplot(outlier.shape = NA, lwd = 1.5) +
  geom_point(position = position_jitterdodge(jitter.width = 0.2), size = 1) + # Jitter by Condition
  facet_grid(~Band)+
  theme_cowplot(20)



ci.data %>%
  select(-c(Trial, Target, Level, Location)) %>% # Remove unnecessary factors
  group_by(Subject, Block, Condition, Muscle, Band) %>% # Group
  summarise(across(everything(), ~ mean(., na.rm = TRUE))) %>% # mean by group
  mutate(Condition = forcats::fct_relevel(Condition, "Pre", "Loading", "Post")) %>% # Reorder Condition Pre-Loading-Post
  filter(Condition == "Loading")%>%
  ggplot(aes(x = Muscle, y = CI.bc, fill = Condition)) +
  geom_boxplot() +
  geom_boxplot(outlier.shape = NA, lwd = 1.5) +
  geom_point(position = position_jitterdodge(jitter.width = 0.2), size = 3) + # Jitter by Condition
  facet_grid(~Band)+
  theme_cowplot(20)
