ts_reduce_vr <- function(df, binSize) { # Reduce VR-based timeseries data into 'bins' of trials
nr = nrow(df)
numTrial = max(df$Trial, na.rm = T)
numBlock = nlevels(df$Block)
numSub = nr/numTrial/numBlock
blockSize = binSize # Must be factor of 96
df$Bin = as.factor(rep(1:(numTrial/blockSize), each = blockSize, times = numSub*numBlock))
# Take mean by block
df.mbbin = df %>% relocate(Bin, .after = Trial) %>% group_by(Subject, Condition, Block, Bin) %>%
  summarise_each(funs(mean(., na.rm = TRUE))) %>% select(-c(Trial, Target))
df.mbbin$Bin = as.numeric(df.mbbin$Bin)
return(df.mbbin)
}

ts_reduce_emg <- function(df, binSize) { # Reduce EMG-based (works on both RMS and MC) timeseries data into 'bins' of trials
  nr = nrow(df)
  numTrial = max(df$Trial, na.rm = T)
  numBlock = nlevels(df$Block)
  numSub = nr/numTrial/numBlock
  blockSize = binSize # Must be factor of 96
  df$Bin = as.factor(rep(1:(numTrial/blockSize), each = blockSize, times = numSub*numBlock))
  # Take mean by block
  df.mbbin = df %>% relocate(Bin, .after = Trial) %>% group_by(Subject, Condition, Block, Muscle, Bin) %>%
    summarise_each(funs(mean(., na.rm = TRUE))) %>% select(-c(Trial, Target))
  df.mbbin$Bin = as.numeric(df.mbbin$Bin)
  return(df.mbbin)
}