## This code is to make plot of ALFF and ReHo of sparse rest, comparing rest and vis
## from tinnitus and no tinnitus group

library(dplyr)
library(ggplot2)
library(scales)  # for logarithmic scales
library(ggpubr)  # for drawing lines between points

## Clear variables from workspace
rm(list = setdiff(ls(), lsf.str()))

# Define the directory paths for ALFF and ReHo files
alff_directory <- "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF"
reho_directory <- "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo"

# Define the list of subjects
subjects <- list.files(path = "/Volumes/gdrive4tb/IGNITE/sparse_rest/preprocessed", full.names = FALSE, recursive = FALSE)


# Create empty data frames for each area
dat_HG_rest_NT <- data.frame()
dat_HG_rest_TT <- data.frame()
dat_HG_vis_NT <- data.frame()
dat_HG_vis_TT <- data.frame()

# Loop through the subject folders
for (subject in subjects) {
  # Loop through the main folders
  for (main_folder in c(alff_directory, reho_directory)) {
    # Set the path to the meanValues subfolder for the current subject and main folder
    meanValues_path <- paste0(main_folder, "/meanValues/", subject)
    
    # Get the list of files in the meanValues subfolder
    file_list <- list.files(meanValues_path)
    file_list <- file_list[grepl("smooth5", file_list)]
    
    # Loop through the files
    for (file_name in file_list) {
      
        # Read the file using readLines()
        file_path <- paste0(meanValues_path, "/", file_name)
        lines <- readLines(file_path)

        # Extract decimal value from the text
        decimal_value <- as.numeric(lines[grep("\\d+\\.\\d+", lines)])

        # Extract relevant information from the file name
        file_name <- gsub("sub-\\d+_(\\w+)_HG_(\\w+)\\.txt", "\\1_\\2", file_name)

        if (grepl("NT.*rest", file_name)) {
          column_name_NT <- gsub("IGNT(\\w+)_\\d+_(\\w+).*", "NT_\\2", file_name)
          
          # Add the data to the dataframe
          dat_HG_rest_NT[subject,column_name_NT] = decimal_value
          
        } else if (grepl("TT.*rest", file_name)) {
          column_name_TT <- gsub("IGTT(\\w+)_\\d+_(\\w+).*", "TT_\\2", file_name)
          
          # Add the data to the dataframe
          dat_HG_rest_TT[subject,column_name_TT] = decimal_value
          
        } else if (grepl("NT.*vis", file_name)) {
          column_name_NT <- gsub("IGNT(\\w+)_\\d+_(\\w+).*", "NT_\\2", file_name)
          
          # Add the data to the dataframe
          dat_HG_vis_NT[subject,column_name_NT] = decimal_value
          
        } else if (grepl("TT.*vis", file_name)) {
          column_name_TT <- gsub("IGTT(\\w+)_\\d+_(\\w+).*", "TT_\\2", file_name)
          
          # Add the data to the dataframe
          dat_HG_vis_TT[subject,column_name_TT] = decimal_value
          
        }
        
    }
  }
}

## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of ALFF HG lh
## ---------------------------------------------------------------------------------------------
# calculate mean and SEM for each dataframe
NT_rest_mean <- mean(dat_HG_rest_NT$NT_lh_ALFF_rest_smooth5, na.rm = TRUE)
NT_rest_sem <- sd(dat_HG_rest_NT$NT_lh_ALFF_rest_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_rest_NT))

TT_rest_mean <- mean(dat_HG_rest_TT$TT_lh_ALFF_rest_smooth5, na.rm = TRUE)
TT_rest_sem <- sd(dat_HG_rest_TT$TT_lh_ALFF_rest_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_rest_TT))

NT_vis_mean <- mean(dat_HG_vis_NT$NT_lh_ALFF_vis_smooth5, na.rm = TRUE)
NT_vis_sem <- sd(dat_HG_vis_NT$NT_lh_ALFF_vis_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_vis_NT))

TT_vis_mean <- mean(dat_HG_vis_TT$TT_lh_ALFF_vis_smooth5, na.rm = TRUE)
TT_vis_sem <- sd(dat_HG_vis_TT$TT_lh_ALFF_vis_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_vis_TT))

# create a dataframe for plotting
plot_df <- data.frame(
  Group = c(rep("No tinnitus", 2), rep("Tinnitus", 2)),
  Condition = rep(c("Rest", "Vis"), 2),
  Mean = c(NT_rest_mean, NT_vis_mean, TT_rest_mean, TT_vis_mean),
  SEM = c(NT_rest_sem, NT_vis_sem, TT_rest_sem, TT_vis_sem)
)

# create a bar plot
ggplot(plot_df, aes(x=Group, y=Mean, fill=Condition)) +
  geom_bar(stat="identity", position="dodge", width=0.5) +
  geom_errorbar(aes(ymin=Mean-SEM, ymax=Mean+SEM), width=.1, position=position_dodge(.5)) +
  scale_fill_manual(values=c("Rest" = "blue", "Vis" = "red")) +
  ylab("Mean ALFF") +
  ylim(0, 1.5) +
  ggtitle("ALFF Heschl's gyrus lh During Rest and Vis") +
  theme_bw() +
  theme(panel.grid = element_blank())


ggsave("/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/keyFigures/barP_ALFF_Tin_noTin_HG_lh.png",width = 6, height = 4)

## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of ALFF HG rh
## ---------------------------------------------------------------------------------------------
# calculate mean and SEM for each dataframe
NT_rest_mean <- mean(dat_HG_rest_NT$NT_rh_ALFF_rest_smooth5, na.rm = TRUE)
NT_rest_sem <- sd(dat_HG_rest_NT$NT_rh_ALFF_rest_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_rest_NT))

TT_rest_mean <- mean(dat_HG_rest_TT$TT_rh_ALFF_rest_smooth5, na.rm = TRUE)
TT_rest_sem <- sd(dat_HG_rest_TT$TT_rh_ALFF_rest_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_rest_TT))

NT_vis_mean <- mean(dat_HG_vis_NT$NT_rh_ALFF_vis_smooth5, na.rm = TRUE)
NT_vis_sem <- sd(dat_HG_vis_NT$NT_rh_ALFF_vis_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_vis_NT))

TT_vis_mean <- mean(dat_HG_vis_TT$TT_rh_ALFF_vis_smooth5, na.rm = TRUE)
TT_vis_sem <- sd(dat_HG_vis_TT$TT_rh_ALFF_vis_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_vis_TT))

# create a dataframe for plotting
plot_df <- data.frame(
  Group = c(rep("No tinnitus", 2), rep("Tinnitus", 2)),
  Condition = rep(c("Rest", "Vis"), 2),
  Mean = c(NT_rest_mean, NT_vis_mean, TT_rest_mean, TT_vis_mean),
  SEM = c(NT_rest_sem, NT_vis_sem, TT_rest_sem, TT_vis_sem)
)

# create a bar plot
ggplot(plot_df, aes(x=Group, y=Mean, fill=Condition)) +
  geom_bar(stat="identity", position="dodge", width=0.5) +
  geom_errorbar(aes(ymin=Mean-SEM, ymax=Mean+SEM), width=.1, position=position_dodge(.5)) +
  scale_fill_manual(values=c("Rest" = "blue", "Vis" = "red")) +
  ylab("Mean ALFF") +
  ylim(0, 1.5) +
  ggtitle("ALFF Heschl's gyrus rh During Rest and Vis") +
  theme_bw() +
  theme(panel.grid = element_blank())

ggsave("/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/keyFigures/barP_ALFF_Tin_noTin_HG_rh.png",width = 6, height = 4)
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
## New dataframe for plotting of ReHo HG lh
## ---------------------------------------------------------------------------------------------
# calculate mean and SEM for each dataframe
NT_rest_mean <- mean(dat_HG_rest_NT$NT_lh_ReHo_rest_smooth5, na.rm = TRUE)
NT_rest_sem <- sd(dat_HG_rest_NT$NT_lh_ReHo_rest_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_rest_NT))

TT_rest_mean <- mean(dat_HG_rest_TT$TT_lh_ReHo_rest_smooth5, na.rm = TRUE)
TT_rest_sem <- sd(dat_HG_rest_TT$TT_lh_ReHo_rest_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_rest_TT))

NT_vis_mean <- mean(dat_HG_vis_NT$NT_lh_ReHo_vis_smooth5, na.rm = TRUE)
NT_vis_sem <- sd(dat_HG_vis_NT$NT_lh_ReHo_vis_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_vis_NT))

TT_vis_mean <- mean(dat_HG_vis_TT$TT_lh_ReHo_vis_smooth5, na.rm = TRUE)
TT_vis_sem <- sd(dat_HG_vis_TT$TT_lh_ReHo_vis_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_vis_TT))

# create a dataframe for plotting
plot_df <- data.frame(
  Group = c(rep("No tinnitus", 2), rep("Tinnitus", 2)),
  Condition = rep(c("Rest", "Vis"), 2),
  Mean = c(NT_rest_mean, NT_vis_mean, TT_rest_mean, TT_vis_mean),
  SEM = c(NT_rest_sem, NT_vis_sem, TT_rest_sem, TT_vis_sem)
)

# create a bar plot
ggplot(plot_df, aes(x=Group, y=Mean, fill=Condition)) +
  geom_bar(stat="identity", position="dodge", width=0.5) +
  geom_errorbar(aes(ymin=Mean-SEM, ymax=Mean+SEM), width=.1, position=position_dodge(.5)) +
  scale_fill_manual(values=c("Rest" = "blue", "Vis" = "red")) +
  ylab("Mean ReHo") +
  ylim(0, 0.1) +
  ggtitle("ReHo Heschl's gyrus lh During Rest and Vis") +
  theme_bw() +
  theme(panel.grid = element_blank())

ggsave("/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/keyFigures/barP_ReHo_Tin_noTin_HG_lh.png",width = 6, height = 4)

## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of ReHo HG rh
## ---------------------------------------------------------------------------------------------
# calculate mean and SEM for each dataframe
NT_rest_mean <- mean(dat_HG_rest_NT$NT_rh_ReHo_rest_smooth5, na.rm = TRUE)
NT_rest_sem <- sd(dat_HG_rest_NT$NT_rh_ReHo_rest_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_rest_NT))

TT_rest_mean <- mean(dat_HG_rest_TT$TT_rh_ReHo_rest_smooth5, na.rm = TRUE)
TT_rest_sem <- sd(dat_HG_rest_TT$TT_rh_ReHo_rest_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_rest_TT))

NT_vis_mean <- mean(dat_HG_vis_NT$NT_rh_ReHo_vis_smooth5, na.rm = TRUE)
NT_vis_sem <- sd(dat_HG_vis_NT$NT_rh_ReHo_vis_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_vis_NT))

TT_vis_mean <- mean(dat_HG_vis_TT$TT_rh_ReHo_vis_smooth5, na.rm = TRUE)
TT_vis_sem <- sd(dat_HG_vis_TT$TT_rh_ReHo_vis_smooth5, na.rm = TRUE) / sqrt(nrow(dat_HG_vis_TT))

# create a dataframe for plotting
plot_df <- data.frame(
  Group = c(rep("No tinnitus", 2), rep("Tinnitus", 2)),
  Condition = rep(c("Rest", "Vis"), 2),
  Mean = c(NT_rest_mean, NT_vis_mean, TT_rest_mean, TT_vis_mean),
  SEM = c(NT_rest_sem, NT_vis_sem, TT_rest_sem, TT_vis_sem)
)

# create a bar plot
ggplot(plot_df, aes(x=Group, y=Mean, fill=Condition)) +
  geom_bar(stat="identity", position="dodge", width=0.5) +
  geom_errorbar(aes(ymin=Mean-SEM, ymax=Mean+SEM), width=.1, position=position_dodge(.5)) +
  scale_fill_manual(values=c("Rest" = "blue", "Vis" = "red")) +
  ylab("Mean ReHo") +
  ylim(0, 0.1) +
  ggtitle("ReHo Heschl's gyrus rh During Rest and Vis") +
  theme_bw() +
  theme(panel.grid = element_blank())

ggsave("/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/keyFigures/barP_ReHo_Tin_noTin_HG_rh.png",width = 6, height = 4)
