## This code is to make plot of ReHo and GCOR for different kernels

library(dplyr)
library(ggplot2)
library(scales)  # for logarithmic scales
library(ggpubr)  # for drawing lines between points

## Clear variables from workspace
rm(list = setdiff(ls(), lsf.str()))

# Define the directory paths for ReHo and GCOR files
alff_directory <- "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF"
gcor_directory <- "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR"

# Define the list of subjects
subjects <- list.files(path = "/Volumes/gdrive4tb/IGNITE/resting-state/preprocessed", full.names = FALSE, recursive = FALSE)


# Create empty data frames for each area
dat_wholeBrain_NT <- data.frame()
dat_wholeBrain_TT <- data.frame()
dat_HG_NT <- data.frame()
dat_HG_TT <- data.frame()

# Loop through the subject folders
for (subject in subjects) {
  # Loop through the main folders
  for (main_folder in c(alff_directory, gcor_directory)) {
    # Set the path to the meanValues subfolder for the current subject and main folder
    meanValues_path <- paste0(main_folder, "/meanValues/", subject)
    
    # Get the list of files in the meanValues subfolder
    file_list <- list.files(meanValues_path)
    file_list <- file_list[grepl("smooth5", file_list)]
    
    # Loop through the files
    for (file_name in file_list) {
      
      # Check if the file name contains "wholeBrain"
      if (grepl("wholeBrain", file_name)) {
        # Read the file using readLines()
        file_path <- paste0(meanValues_path, "/", file_name)
        lines <- readLines(file_path)

        # Extract decimal value from the text
        decimal_value <- as.numeric(lines[grep("\\d+\\.\\d+", lines)])

        # Extract relevant information from the file name
        file_name <- gsub("sub-\\d+_(\\w+)_wholeBrain_(\\w+)\\.txt", "\\1_\\2", file_name)

        if (grepl("NT", file_name)) {
          column_name_NT <- gsub("IGNT(\\w+)_\\d+_(\\w+).*", "NT_\\2", file_name)
          
          # Add the data to the dataframe
          dat_wholeBrain_NT[subject,column_name_NT] = decimal_value
          
        } else if (grepl("TT", file_name)) {
          column_name_TT <- gsub("IGTT(\\w+)_\\d+_(\\w+).*", "TT_\\2", file_name)
          
          # Add the data to the dataframe
          dat_wholeBrain_TT[subject,column_name_TT] = decimal_value
          
        }

        
      }
      # Check if the file name contains "HG"
      else if (grepl("HG", file_name)) {
        # Read the file using readLines()
        file_path <- paste0(meanValues_path, "/", file_name)
        lines <- readLines(file_path)

        # Extract decimal value from the text
        decimal_value <- as.numeric(lines[grep("\\d+\\.\\d+", lines)])

        # Extract relevant information from the file name
        file_name <- gsub("sub-\\d+_(\\w+)_HG_(\\w+)\\.txt", "\\1_\\2", file_name)

        if (grepl("NT", file_name)) {
          column_name_NT <- gsub("IGNT(\\w+)_\\d+_(\\w+).*", "NT_\\2", file_name)
          
          # Add the data to the dataframe
          dat_HG_NT[subject,column_name_NT] = decimal_value
          
        } else if (grepl("TT", file_name)) {
          column_name_TT <- gsub("IGTT(\\w+)_\\d+_(\\w+).*", "TT_\\2", file_name)
          
          # Add the data to the dataframe
          dat_HG_TT[subject,column_name_TT] = decimal_value
          
        }
        
      }
    }
  }
}

## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of ALFF wholeBrain lh
## ---------------------------------------------------------------------------------------------
# calculate mean and SEM
NT_mean <- mean(dat_wholeBrain_NT$NT_ALFF_wholeBrain_lh_smooth5, na.rm = TRUE)
NT_sem <- sd(dat_wholeBrain_NT$NT_ALFF_wholeBrain_lh_smooth5, na.rm = TRUE) / sqrt(nrow(dat_wholeBrain_NT))

TT_mean <- mean(dat_wholeBrain_TT$TT_ALFF_wholeBrain_lh_smooth5, na.rm = TRUE)
TT_sem <- sd(dat_wholeBrain_TT$TT_ALFF_wholeBrain_lh_smooth5, na.rm = TRUE) / sqrt(nrow(dat_wholeBrain_TT))

# create a dataframe for plotting
plot_df <- data.frame(Group = c("No tinnitus", "Tinnitus"),
                      Mean = c(NT_mean, TT_mean),
                      SEM = c(NT_sem, TT_sem))

# create a bar plot
ggplot(plot_df, aes(x=Group, y=Mean, fill=Group)) +
  geom_bar(stat="identity", width=0.5) +
  geom_errorbar(aes(ymin=Mean-SEM, ymax=Mean+SEM), width=.1, position=position_dodge(.9)) +
  scale_fill_manual(values=c("No tinnitus" = "blue", "Tinnitus" = "red")) +
  ylab("Mean ALFF") +
  ggtitle("ALFF whole brain lh") +
  theme_bw() +
  theme(panel.grid = element_blank())

ggsave("/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/barP_ALFF_Tin_noTin_wholeBrain_lh.png",width = 6, height = 4)

## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of ALFF wholeBrain rh
## ---------------------------------------------------------------------------------------------
# calculate mean and SEM
NT_mean <- mean(dat_wholeBrain_NT$NT_ALFF_wholeBrain_rh_smooth5, na.rm = TRUE)
NT_sem <- sd(dat_wholeBrain_NT$NT_ALFF_wholeBrain_rh_smooth5, na.rm = TRUE) / sqrt(nrow(dat_wholeBrain_NT))

TT_mean <- mean(dat_wholeBrain_TT$TT_ALFF_wholeBrain_rh_smooth5, na.rm = TRUE)
TT_sem <- sd(dat_wholeBrain_TT$TT_ALFF_wholeBrain_rh_smooth5, na.rm = TRUE) / sqrt(nrow(dat_wholeBrain_TT))

# create a dataframe for plotting
plot_df <- data.frame(Group = c("No tinnitus", "Tinnitus"),
                      Mean = c(NT_mean, TT_mean),
                      SEM = c(NT_sem, TT_sem))

# create a bar plot
ggplot(plot_df, aes(x=Group, y=Mean, fill=Group)) +
  geom_bar(stat="identity", width=0.5) +
  geom_errorbar(aes(ymin=Mean-SEM, ymax=Mean+SEM), width=.1, position=position_dodge(.9)) +
  scale_fill_manual(values=c("No tinnitus" = "blue", "Tinnitus" = "red")) +
  ylab("Mean ALFF") +
  ylim(0, 4) +
  ggtitle("ALFF whole brain rh") +
  theme_bw() +
  theme(panel.grid = element_blank())

ggsave("/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/barP_ALFF_Tin_noTin_wholeBrain_rh.png",width = 6, height = 4)


## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of ALFF HG lh
## ---------------------------------------------------------------------------------------------
# calculate mean and SEM
NT_mean <- mean(dat_HG_NT$NT_ALFF_HG_lh_smooth5, na.rm = TRUE)
NT_sem <- sd(dat_HG_NT$NT_ALFF_HG_lh_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_NT))

TT_mean <- mean(dat_HG_TT$TT_ALFF_HG_lh_smooth5, na.rm = TRUE)
TT_sem <- sd(dat_HG_TT$TT_ALFF_HG_lh_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_TT))


# create a dataframe for plotting
plot_df <- data.frame(Group = c("No tinnitus", "Tinnitus"),
                      Mean = c(NT_mean, TT_mean),
                      SEM = c(NT_sem, TT_sem))

# create a bar plot
ggplot(plot_df, aes(x=Group, y=Mean, fill=Group)) +
  geom_bar(stat="identity", width=0.5) +
  geom_errorbar(aes(ymin=Mean-SEM, ymax=Mean+SEM), width=.1, position=position_dodge(.9)) +
  scale_fill_manual(values=c("No tinnitus" = "blue", "Tinnitus" = "red")) +
  ylab("Mean ALFF") +
  ylim(0, 1.5) +
  ggtitle("ALFF Heschl's gyrus lh") +
  theme_bw() +
  theme(panel.grid = element_blank())

ggsave("/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/barP_ALFF_Tin_noTin_HG_lh.png",width = 6, height = 4)

## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of ALFF HG rh
## ---------------------------------------------------------------------------------------------
# calculate mean and SEM
NT_mean <- mean(dat_HG_NT$NT_ALFF_HG_rh_smooth5, na.rm = TRUE)
NT_sem <- sd(dat_HG_NT$NT_ALFF_HG_rh_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_NT))

TT_mean <- mean(dat_HG_TT$TT_ALFF_HG_rh_smooth5, na.rm = TRUE)
TT_sem <- sd(dat_HG_TT$TT_ALFF_HG_rh_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_TT))

# create a dataframe for plotting
plot_df <- data.frame(Group = c("No tinnitus", "Tinnitus"),
                      Mean = c(NT_mean, TT_mean),
                      SEM = c(NT_sem, TT_sem))

# create a bar plot
ggplot(plot_df, aes(x=Group, y=Mean, fill=Group)) +
  geom_bar(stat="identity", width=0.5) +
  geom_errorbar(aes(ymin=Mean-SEM, ymax=Mean+SEM), width=.1, position=position_dodge(.9)) +
  scale_fill_manual(values=c("No tinnitus" = "blue", "Tinnitus" = "red")) +
  ylab("Mean ALFF") +
  ylim(0,1.5) +
  ggtitle("ALFF Heschl's gyrus rh") +
  theme_bw() +
  theme(panel.grid = element_blank())

ggsave("/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/barP_ALFF_Tin_noTin_HG_rh.png",width = 6, height = 4)
## ---------------------------------------------------------------------------------------------

# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 

## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of GCOR wholeBrain lh
## ---------------------------------------------------------------------------------------------
# calculate mean and SEM
NT_mean <- mean(dat_wholeBrain_NT$NT_GCOR_wholeBrain_lh_smooth5, na.rm = TRUE)
NT_sem <- sd(dat_wholeBrain_NT$NT_GCOR_wholeBrain_lh_smooth5, na.rm = TRUE) / sqrt(nrow(dat_wholeBrain_NT))

TT_mean <- mean(dat_wholeBrain_TT$TT_GCOR_wholeBrain_lh_smooth5, na.rm = TRUE)
TT_sem <- sd(dat_wholeBrain_TT$TT_GCOR_wholeBrain_lh_smooth5, na.rm = TRUE) / sqrt(nrow(dat_wholeBrain_TT))

# create a dataframe for plotting
plot_df <- data.frame(Group = c("No tinnitus", "Tinnitus"),
                      Mean = c(NT_mean, TT_mean),
                      SEM = c(NT_sem, TT_sem))

# create a bar plot
ggplot(plot_df, aes(x=Group, y=Mean, fill=Group)) +
  geom_bar(stat="identity", width=0.5) +
  geom_errorbar(aes(ymin=Mean-SEM, ymax=Mean+SEM), width=.1, position=position_dodge(.9)) +
  scale_fill_manual(values=c("No tinnitus" = "blue", "Tinnitus" = "red")) +
  ylab("Mean GCOR") +
  ylim(0, 0.03) +
  ggtitle("GCOR whole brain lh") +
  theme_bw() +
  theme(panel.grid = element_blank())

ggsave("/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/barP_GCOR_Tin_noTin_wholeBrain_lh.png",width = 6, height = 4)

## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of GCOR wholeBrain rh
## ---------------------------------------------------------------------------------------------
# calculate mean and SEM
NT_mean <- mean(dat_wholeBrain_NT$NT_GCOR_wholeBrain_rh_smooth5, na.rm = TRUE)
NT_sem <- sd(dat_wholeBrain_NT$NT_GCOR_wholeBrain_rh_smooth5, na.rm = TRUE) / sqrt(nrow(dat_wholeBrain_NT))

TT_mean <- mean(dat_wholeBrain_TT$TT_GCOR_wholeBrain_rh_smooth5, na.rm = TRUE)
TT_sem <- sd(dat_wholeBrain_TT$TT_GCOR_wholeBrain_rh_smooth5, na.rm = TRUE) / sqrt(nrow(dat_wholeBrain_TT))

# create a dataframe for plotting
plot_df <- data.frame(Group = c("No tinnitus", "Tinnitus"),
                      Mean = c(NT_mean, TT_mean),
                      SEM = c(NT_sem, TT_sem))

# create a bar plot
ggplot(plot_df, aes(x=Group, y=Mean, fill=Group)) +
  geom_bar(stat="identity", width=0.5) +
  geom_errorbar(aes(ymin=Mean-SEM, ymax=Mean+SEM), width=.1, position=position_dodge(.9)) +
  scale_fill_manual(values=c("No tinnitus" = "blue", "Tinnitus" = "red")) +
  ylab("Mean GCOR") +
  ylim(0, 0.03) +
  ggtitle("GCOR whole brain rh") +
  theme_bw() +
  theme(panel.grid = element_blank())

ggsave("/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/barP_GCOR_Tin_noTin_wholeBrain_rh.png",width = 6, height = 4)


## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of GCOR HG lh
## ---------------------------------------------------------------------------------------------
# calculate mean and SEM
NT_mean <- mean(dat_HG_NT$NT_GCOR_HG_lh_smooth5, na.rm = TRUE)
NT_sem <- sd(dat_HG_NT$NT_GCOR_HG_lh_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_NT))

TT_mean <- mean(dat_HG_TT$TT_GCOR_HG_lh_smooth5, na.rm = TRUE)
TT_sem <- sd(dat_HG_TT$TT_GCOR_HG_lh_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_TT))

# create a dataframe for plotting
plot_df <- data.frame(Group = c("No tinnitus", "Tinnitus"),
                      Mean = c(NT_mean, TT_mean),
                      SEM = c(NT_sem, TT_sem))

# create a bar plot
ggplot(plot_df, aes(x=Group, y=Mean, fill=Group)) +
  geom_bar(stat="identity", width=0.5) +
  geom_errorbar(aes(ymin=Mean-SEM, ymax=Mean+SEM), width=.1, position=position_dodge(.9)) +
  scale_fill_manual(values=c("No tinnitus" = "blue", "Tinnitus" = "red")) +
  ylab("Mean GCOR") +
  ylim(0, 0.04) +
  ggtitle("GCOR Heschl's gyrus lh") +
  theme_bw() +
  theme(panel.grid = element_blank())

ggsave("/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/barP_GCOR_Tin_noTin_HG_lh.png",width = 6, height = 4)

## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of GCOR HG rh
## ---------------------------------------------------------------------------------------------
# calculate mean and SEM
NT_mean <- mean(dat_HG_NT$NT_GCOR_HG_rh_smooth5, na.rm = TRUE)
NT_sem <- sd(dat_HG_NT$NT_GCOR_HG_rh_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_NT))

TT_mean <- mean(dat_HG_TT$TT_GCOR_HG_rh_smooth5, na.rm = TRUE)
TT_sem <- sd(dat_HG_TT$TT_GCOR_HG_rh_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_TT))

# create a dataframe for plotting
plot_df <- data.frame(Group = c("No tinnitus", "Tinnitus"),
                      Mean = c(NT_mean, TT_mean),
                      SEM = c(NT_sem, TT_sem))

# create a bar plot
ggplot(plot_df, aes(x=Group, y=Mean, fill=Group)) +
  geom_bar(stat="identity", width=0.5) +
  geom_errorbar(aes(ymin=Mean-SEM, ymax=Mean+SEM), width=.1, position=position_dodge(.9)) +
  scale_fill_manual(values=c("No tinnitus" = "blue", "Tinnitus" = "red")) +
  ylab("Mean GCOR") +
  ylim(0, 0.04) +
  ggtitle("GCOR Heschl's gyrus rh") +
  theme_bw() +
  theme(panel.grid = element_blank())

ggsave("/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/barP_GCOR_Tin_noTin_HG_rh.png",width = 6, height = 4)
