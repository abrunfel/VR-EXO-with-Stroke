# Deltoid---------
to.img.delt %>%
  mutate(wCSTLL = wCSTLL) %>%
  ggplot(aes(x = emg.diff, y = rel.cont.diff)) +
  geom_point(aes(color = Condition, size = wCSTLL)) +
  geom_line(aes(group = Subject)) +
  coord_cartesian(xlim = c(-40, 40), ylim = c(-10, 10)) +
  geom_hline(yintercept = 0, size = 1, alpha = 0.1) +
  geom_vline(xintercept = 0, size = 1, alpha = 0.1) +
  geom_text(data = filter(to.img.delt, Condition != "Pre"),
            aes(x = emg.diff, y = rel.cont.diff + 0.6,label = scales::number(wCSTLL, accuracy = 0.01), fontface = "bold"),
            size = 5) +
  theme_cowplot(26) +
  labs(
    x = "\u0394 Muscle Contribution (%)",
    y = "\u0394 Relative Contribution (%)",
    title = "A Deltoid - Subset w/ Imaging"
  ) +
  theme(
    legend.position = "none",  # Remove the legend
    legend.text = element_text(size = 20),
    legend.title = element_text(size = 20)
  )
ggsave("to.img.delt.tiff", plot = last_plot(), width = 11.45, height = 8.5, units = "in")

# Biceps-------
to.img.bicep %>%
  mutate(wCSTLL = wCSTLL) %>%
  ggplot(aes(x = emg.diff, y = rel.cont.diff)) +
  geom_point(aes(color = Condition, size = wCSTLL)) +
  geom_line(aes(group = Subject)) +
  coord_cartesian(xlim = c(-40, 40), ylim = c(-10, 10)) +
  geom_hline(yintercept = 0, size = 1, alpha = 0.1) +
  geom_vline(xintercept = 0, size = 1, alpha = 0.1) +
  geom_text(data = filter(to.img.bicep, Condition != "Pre"),
            aes(x = emg.diff, y = rel.cont.diff + 0.6,label = scales::number(wCSTLL, accuracy = 0.01), fontface = "bold"),
            size = 5) +
  theme_cowplot(26) +
  labs(
    x = "\u0394 Muscle Contribution (%)",
    y = "\u0394 Relative Contribution (%)",
    title = "B Biceps - Subset w/ Imaging"
  ) +
  theme(
    legend.position = "none",  # Remove the legend
    legend.text = element_text(size = 20),
    legend.title = element_text(size = 20)
  )
ggsave("to.img.bicep.tiff", plot = last_plot(), width = 11.45, height = 8.5, units = "in")
