source('ts_reduce.R')
library(cowplot)
# Relative Contribution------------------
p.rc.ts = vr.data.plot %>%
  mutate(Condition = recode_factor(Condition, 'Bil-BL Pre' = 'Pre', 'Bil-BL Post' = 'Post')) %>%
  ggplot(aes(x = Trial, y = rel.cont, color = Condition))+
  stat_summary(fun.data = 'mean_se', position = position_dodge(width = 0.5))+
  stat_summary(fun.data = 'mean_se', geom = 'line', position = position_dodge(width = 0.5))+
  theme_cowplot(26)+
  ylab('Relative Contribution (%)')
p.rc.ts
ggsave('rc.ts.pdf', plot = p.rc.ts, width = 9, height = 5)

# Relative Contribution (binned)------------------
p.rc.ts.bin = vr.data.mbbin %>%
  mutate(Condition = recode_factor(Condition, 'Bil-BL Pre' = 'Pre', 'Bil-BL Post' = 'Post')) %>%
  ggplot(aes(x = Bin, y = rel.cont, color = Condition))+
  stat_summary(fun.data = 'mean_se', position = position_dodge(width = 0.5))+
  stat_summary(fun.data = 'mean_se', geom = 'line', position = position_dodge(width = 0.5))+
  theme_cowplot(26)+
  ylab('Relative Contribution (%)')
p.rc.ts.bin
ggsave('rc.ts.pdf', plot = p.rc.ts, width = 9, height = 5)

# Relative Contribution (boxplot)--------
p.rc.bp = vr.data.plot %>%
  mutate(Condition = recode_factor(Condition, 'Bil-BL Pre' = 'Pre', 'Bil-BL Post' = 'Post')) %>%
  mutate(Condition = fct_relevel(Condition, "Pre", "Loading", "Post")) %>%
  ggplot(aes(x = Condition, y = rel.cont, color = Condition))+
  geom_boxplot()+
  theme_cowplot(26)+
  theme(legend.position = "none")+
  ylab('Relative Contribution (%)')
p.rc.bp
ggsave('rc.boxplot.pdf', plot = p.rc.bp, width = 9, height = 5)

# Muscle Activity Timeseries (Deltoid)-----------------
p.rms.ts = emg.data %>% filter(Muscle == c('Non-Impaired Deltoid', 'Impaired Deltoid') & !Block %in% c(2)) %>%
  mutate(Muscle = recode_factor(Muscle, 'Non-Impaired Deltoid' = 'Non-impaired', 'Impaired Deltoid' = 'Impaired')) %>%
  mutate(Block = recode_factor(Block, '3' = 'Loading', '4' = 'Post')) %>%
ggplot(aes(x = Trial, y = rmse.norm.bc, color = Muscle))+
  geom_hline(yintercept = 0, linetype = 'dashed')+
  stat_summary(fun.data = 'mean_se')+
  stat_summary(fun.data = 'mean_se', geom = 'line')+
  facet_grid(~Block)+
  theme_cowplot(26)+
  labs(y = "RMS Muscle Activity (% Change)")+
  ggtitle('Deltoid')
p.rms.ts
ggsave('rms.ts.pdf', plot = p.rms.ts, width = 11, height = 6)

# Muscle Activity Boxplot (Deltoid)-----------------
p.rms.boxplot = emg.data %>% filter(Muscle == c('Non-Impaired Deltoid', 'Impaired Deltoid') & !Block %in% c(2)) %>%
  mutate(Muscle = recode_factor(Muscle, 'Non-Impaired Deltoid' = 'Non-impaired', 'Impaired Deltoid' = 'Impaired')) %>%
  mutate(Block = recode_factor(Block, '3' = 'Loading', '4' = 'Post')) %>%
  ggplot(aes(x = Muscle, y = rmse.norm.bc, color = Muscle))+
  geom_hline(yintercept = 0, linetype = 'dashed')+
  geom_boxplot()+
  facet_grid(~Block)+
  theme_cowplot(26)+
  labs(y = "RMS Muscle Activity (% Change)")+
  ggtitle('Deltoid')
p.rms.boxplot
ggsave('rms.boxplot.pdf', plot = p.rms.boxplot, width = 11, height = 6)

# Muscle Contribution (Deltoid) -----------------
p.mc.ts = emg.data.ratio %>% filter(Muscle == c('Deltoid') & !Block %in% c(2)) %>%
  mutate(Block = recode_factor(Block, '3' = 'Loading', '4' = 'Post')) %>%
  ggplot(aes(x = Trial, y = rmse.norm.bc.oc, color = Block))+
  geom_hline(yintercept = 0, linetype = 'dashed')+
  stat_summary(fun.data = 'mean_se')+
  stat_summary(fun.data = 'mean_se', geom = 'line')+
  theme_cowplot(26)+
  labs(y = "Muscle Contribution (% Change)")+
  guides(color=guide_legend(title="Condition"))+
  ggtitle('Deltoid')
p.mc.ts
ggsave('mc.ts.pdf', plot = p.mc.ts, width = 11, height = 6)

# Muscle Contribution Deltoid (binned)-----------------
emg.data.ratio.mbbin = ts_reduce_emg(emg.data.ratio, 6)
p.mc.ts.bin = emg.data.ratio.mbbin %>% filter(Muscle == c('Deltoid') & !Block %in% c(2)) %>%
  mutate(Block = recode_factor(Block, '3' = 'Loading', '4' = 'Post')) %>%
  ggplot(aes(x = Bin, y = rmse.norm.bc.oc, color = Block))+
  geom_hline(yintercept = 0, linetype = 'dashed')+
  stat_summary(fun.data = 'mean_se', position = position_dodge(width = 0.5))+
  stat_summary(fun.data = 'mean_se', geom = 'line', position = position_dodge(width = 0.5))+
  theme_cowplot(26)+
  labs(y = "Muscle Contribution (% Change)")+
  guides(color=guide_legend(title="Condition"))+
  ggtitle('Deltoid')
p.mc.ts.bin
ggsave('mc.ts.bin.pdf', plot = p.mc.ts.bin, width = 11, height = 6)

# Muscle Contribution Deltoid (boxplot)-----------
p.mc.bp = emg.data.ratio %>% filter(Muscle == c('Deltoid')) %>%
  mutate(Condition = recode_factor(Block, '2' = 'Pre', '3' = 'Loading', '4' = 'Post')) %>%
  mutate(Condition = fct_relevel(Condition, "Pre", "Loading", "Post")) %>%
  ggplot(aes(x = Block, y = rmse.norm.bc.oc, color = Condition))+
  geom_boxplot()+
  geom_hline(yintercept = 0, linetype = 'dashed')+
  theme_cowplot()+
  panel_border()+
  ggtitle('Deltoid')+
  ylab('Muscle Contribution (bc, norm, oc) (% change)')
p.mc.bp
ggsave('mc.bp.pdf', plot = p.mc.bp, width = 11, height = 6)

# Tradeoff (Deltoid) ------------
p.to = df.corr.deltoid %>% filter( !Condition %in% c("Bil-BL Post"))%>%
  mutate(Condition = recode_factor(Condition, 'Bil-BL Pre' = 'Pre', 'Bil-BL Post' = 'Post')) %>%
ggplot(aes(x = emg.diff, y = rel.cont.diff))+
  geom_point(aes(color = Condition, size = 2))+
  geom_text(aes(label = Subject))+
  geom_line(aes(group = Subject))+
  #coord_cartesian(xlim = c(-33,33), ylim = c(-5,5))+
  geom_hline(yintercept = 0, size = 1, alpha = 0.1)+
  geom_vline(xintercept = 0, size = 1, alpha = 0.1)+
  theme_cowplot(26)+
  labs(x = "\u0394 Muscle Contribution (%)", y = "\u0394 Relative Contribution (%)",
       title = "Deltoid")+
  guides(size = 'none', shape = 'none')
p.to
ggsave('tradeoff.pdf', plot = p.to, width = 9, height = 6)

# Muscle Activity (Bicep)-----------------
p.rms.ts.bicep = emg.data %>% filter(Muscle == c('Non-Impaired Bicep', 'Impaired Bicep') & !Block %in% c(2)) %>%
  mutate(Muscle = recode_factor(Muscle, 'Non-Impaired Bicep' = 'Non-impaired', 'Impaired Bicep' = 'Impaired')) %>%
  mutate(Block = recode_factor(Block, '3' = 'Loading', '4' = 'Post')) %>%
  ggplot(aes(x = Trial, y = rmse.norm.bc, color = Muscle))+
  geom_hline(yintercept = 0, linetype = 'dashed')+
  stat_summary(fun.data = 'mean_se')+
  stat_summary(fun.data = 'mean_se', geom = 'line')+
  facet_grid(~Block)+
  theme_cowplot(26)+
  labs(y = "RMS Muscle Activity (% Change)")+
  ggtitle('Bicep')
p.rms.ts.bicep
ggsave('rms.ts.bicep.pdf', plot = p.rms.ts.bicep, width = 11, height = 6)

# Muscle Contribution (Bicep) -----------------
p.mc.ts.bicep = emg.data.ratio %>% filter(Muscle == c('Bicep') & !Block %in% c(2)) %>%
  mutate(Block = recode_factor(Block, '3' = 'Loading', '4' = 'Post')) %>%
  ggplot(aes(x = Trial, y = rmse.norm.bc.oc, color = Block))+
  geom_hline(yintercept = 0, linetype = 'dashed')+
  stat_summary(fun.data = 'mean_se')+
  stat_summary(fun.data = 'mean_se', geom = 'line')+
  theme_cowplot(26)+
  labs(y = "Muscle Contribution (% Change)")+
  guides(color=guide_legend(title="Condition"))+
  ggtitle('Bicep')
p.mc.ts.bicep
ggsave('mc.ts.bicep.pdf', plot = p.mc.ts.bicep, width = 11, height = 6)

# Muscle Contribution Bicep (binned)-----------------
emg.data.ratio.mbbin = ts_reduce_emg(emg.data.ratio, 6)
p.mc.ts.bin.bicep = emg.data.ratio.mbbin %>% filter(Muscle == c('Bicep') & !Block %in% c(2)) %>%
  mutate(Block = recode_factor(Block, '3' = 'Loading', '4' = 'Post')) %>%
  ggplot(aes(x = Bin, y = rmse.norm.bc.oc, color = Block))+
  geom_hline(yintercept = 0, linetype = 'dashed')+
  stat_summary(fun.data = 'mean_se', position = position_dodge(width = 0.5))+
  stat_summary(fun.data = 'mean_se', geom = 'line', position = position_dodge(width = 0.5))+
  theme_cowplot(26)+
  labs(y = "Muscle Contribution (% Change)")+
  guides(color=guide_legend(title="Condition"))+
  ggtitle('Bicep')
p.mc.ts.bin.bicep
ggsave('mc.ts.bin.bicep.pdf', plot = p.mc.ts.bin.bicep, width = 11, height = 6)

# Muscle Contribution Bicep (boxplot)-----------
p.mc.bp.bicep = emg.data.ratio %>% filter(Muscle == c('Bicep')) %>%
  mutate(Condition = recode_factor(Block, '2' = 'Pre', '3' = 'Loading', '4' = 'Post')) %>%
  mutate(Condition = fct_relevel(Condition, "Pre", "Loading", "Post")) %>%
  ggplot(aes(x = Block, y = rmse.norm.bc.oc, color = Condition))+
  geom_boxplot()+
  geom_hline(yintercept = 0, linetype = 'dashed')+
  theme_cowplot()+
  panel_border()+
  ggtitle('Bicep')+
  ylab('Muscle Contribution (bc, norm, oc) (% change)')
p.mc.bp.bicep
ggsave('mc.bp.bicep.pdf', plot = p.mc.bp.bicep, width = 11, height = 6)

# Tradeoff (Bicep) ------------
p.to.bicep = df.corr.bicep %>% filter( !Condition %in% c("Bil-BL Post"))%>%
  mutate(Condition = recode_factor(Condition, 'Bil-BL Pre' = 'Pre', 'Bil-BL Post' = 'Post')) %>%
  ggplot(aes(x = emg.diff, y = rel.cont.diff))+
  geom_point(aes(color = Condition, size = 2))+
  geom_text(aes(label = Subject))+
  geom_line(aes(group = Subject))+
  #coord_cartesian(xlim = c(-33,33), ylim = c(-5,5))+
  geom_hline(yintercept = 0, size = 1, alpha = 0.1)+
  geom_vline(xintercept = 0, size = 1, alpha = 0.1)+
  theme_cowplot(26)+
  labs(x = "\u0394 Muscle Contribution (%)", y = "\u0394 Relative Contribution (%)",
       title = "Bicep")+
  guides(size = 'none', shape = 'none')
p.to.bicep
ggsave('tradeoff.bicep.pdf', plot = p.to.bicep, width = 9, height = 6)
