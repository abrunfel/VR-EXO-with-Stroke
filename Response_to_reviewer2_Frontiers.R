# Change 73874401 symbol/linestyle

## Movement Time-------
uni.data.mbb %>%
  mutate(Condition = recode_factor(Condition, 'Pre' = 'Pre-Uni', 'Post' = 'Post-Uni')) %>%
  mutate(Condition = fct_relevel(Condition, "Pre-Uni", "Post-Uni")) %>%
  ggplot(aes(x = Condition, y = mt, group = Subject)) +
  geom_line(aes(linetype = factor(Subject)), size = 1) +
  geom_point(aes(shape = factor(Subject), fill = factor(Subject)), size = 4) +
  scale_linetype_manual(values = ifelse(unique(uni.data.mbb$Subject) == 73874401, "dashed", "solid")) +
  scale_shape_manual(values = ifelse(unique(uni.data.mbb$Subject) == 73874401, 2, 16)) + # 16 for filled circle
  theme_cowplot(26) +
  labs(
    x = "Block",
    y = "Movement Time (s)") +
  theme(legend.position = "none")  # Remove the legend

ggsave("uni.mt.tiff", plot = last_plot(), width = 11.45, height = 8.5, units = "in")
t.test(mt ~ Condition, uni.data.mbb, paired = T)
cohen.d(mt ~ Condition, uni.data.mbb)
#
## Reaction Time-------
uni.data.mbb %>%
  mutate(Condition = recode_factor(Condition, 'Pre' = 'Pre-Uni', 'Post' = 'Post-Uni')) %>%
  mutate(Condition = fct_relevel(Condition, "Pre-Uni", "Post-Uni")) %>%
  ggplot(aes(x = Condition, y = rt, group = Subject)) +
  geom_line(aes(linetype = factor(Subject)), size = 1) +
  geom_point(aes(shape = factor(Subject), fill = factor(Subject)), size = 4) +
  scale_linetype_manual(values = ifelse(unique(uni.data.mbb$Subject) == 73874401, "dashed", "solid")) +
  scale_shape_manual(values = ifelse(unique(uni.data.mbb$Subject) == 73874401, 2, 16)) + # 16 for filled circle
  theme_cowplot(26) +
  labs(
    x = "Block",
    y = "Reaction Time (s)") +
  theme(legend.position = "none")  # Remove the legend
ggsave("uni.rt.tiff", plot = last_plot(), width = 11.45, height = 8.5, units = "in")
t.test(rt ~ Condition, uni.data.mbb, paired = T)
cohen.d(rt ~ Condition, uni.data.mbb)
#

## Average Velocity-------
uni.data.mbb %>%
  mutate(Condition = recode_factor(Condition, 'Pre' = 'Pre-Uni', 'Post' = 'Post-Uni')) %>%
  mutate(Condition = fct_relevel(Condition, "Pre-Uni", "Post-Uni")) %>%
  ggplot(aes(x = Condition, y = avg.vel, group = Subject)) +
  geom_line(aes(linetype = factor(Subject)), size = 1) +
  geom_point(aes(shape = factor(Subject), fill = factor(Subject)), size = 4) +
  scale_linetype_manual(values = ifelse(unique(uni.data.mbb$Subject) == 73874401, "dashed", "solid")) +
  scale_shape_manual(values = ifelse(unique(uni.data.mbb$Subject) == 73874401, 2, 16)) + # 16 for filled circle
  theme_cowplot(26) +
  labs(
    x = "Block",
    y = "Average Velocity (m/s)") +
  theme(legend.position = "none")  # Remove the legend
ggsave("uni.av.tiff", plot = last_plot(), width = 11.45, height = 8.5, units = "in")
t.test(avg.vel ~ Condition, uni.data.mbb, paired = T)
cohen.d(avg.vel ~ Condition, uni.data.mbb)
#

## Peak Velocity-------
uni.data.mbb %>%
  mutate(Condition = recode_factor(Condition, 'Pre' = 'Pre-Uni', 'Post' = 'Post-Uni')) %>%
  mutate(Condition = fct_relevel(Condition, "Pre-Uni", "Post-Uni")) %>%
  ggplot(aes(x = Condition, y = peak.vel, group = Subject)) +
  geom_line(aes(linetype = factor(Subject)), size = 1) +
  geom_point(aes(shape = factor(Subject), fill = factor(Subject)), size = 4) +
  scale_linetype_manual(values = ifelse(unique(uni.data.mbb$Subject) == 73874401, "dashed", "solid")) +
  scale_shape_manual(values = ifelse(unique(uni.data.mbb$Subject) == 73874401, 2, 16)) + # 16 for filled circle
  theme_cowplot(26) +
  labs(
    x = "Block",
    y = "Peak Velocity (m/s)") +
  theme(legend.position = "none")  # Remove the legend
ggsave("uni.pv.tiff", plot = last_plot(), width = 11.45, height = 8.5, units = "in")
t.test(peak.vel ~ Condition, uni.data.mbb, paired = T)
cohen.d(peak.vel ~ Condition, uni.data.mbb)
#

# Fix Fig 4 ("more/less-impaired")---------
# Only use this to generate the legend
biman.data.mbb %>%
  mutate(Condition = recode_factor(Condition, 'Bil-BL Pre' = 'Pre', 'Bil-BL Post' = 'Post')) %>%
  mutate(Condition = fct_relevel(Condition, "Pre", "Loading", "Post")) %>%
  ggplot(aes(x = Condition, y = disp, color = Hand))+
  geom_boxplot(outlier.shape = NA, lwd = 1.5)+
  geom_point(position = position_jitterdodge(), size = 3)+
  theme_cowplot(26)+
  guides(color = guide_legend(title="Arm"))+
  scale_color_manual(labels = c("More-impaired", "Less-impaired"), values = c("#F8766D", "#00BFC4")) +
  labs(title = "B",
       x = "Block",
       y = 'Displacement (m)')
