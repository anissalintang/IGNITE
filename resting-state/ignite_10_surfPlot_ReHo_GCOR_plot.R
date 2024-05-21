## This code is to make plot of ReHo and GCOR for different kernels

library(dplyr)
library(ggplot2)
library(scales)  # for logarithmic scales
library(ggpubr)  # for drawing lines between points

## Clear variables from workspace
rm(list = setdiff(ls(), lsf.str()))

# Define the directory paths for ReHo and GCOR files
reho_directory <- "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReHo"
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
  for (main_folder in c(reho_directory, gcor_directory)) {
    # Set the path to the meanValues subfolder for the current subject and main folder
    meanValues_path <- paste0(main_folder, "/meanValues/", subject)
    
    # Get the list of files in the meanValues subfolder
    file_list <- list.files(meanValues_path)
    
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
          column_name_NT <- gsub("IGNT[A-Z]+_[0-9]+_", "NT_", file_name)
          
          # Add the data to the dataframe
          dat_wholeBrain_NT[subject,column_name_NT] = decimal_value
          
        } else if (grepl("TT", file_name)) {
          column_name_TT <- gsub("IGTT[A-Z]+_[0-9]+_", "TT_", file_name)
          
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
           column_name_NT <- gsub("IGNT[A-Z]+_[0-9]+_", "NT_", file_name)
           
           # Add the data to the dataframe
           dat_HG_NT[subject,column_name_NT] = decimal_value
           
         } else if (grepl("TT", file_name)) {
           column_name_TT <- gsub("IGTT[A-Z]+_[0-9]+_", "TT_", file_name)
           
           # Add the data to the dataframe
           dat_HG_TT[subject,column_name_TT] = decimal_value
          
        }
        
      }
    }
  }
}


## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of wholeBrain lh
## ---------------------------------------------------------------------------------------------
wb_lh_NT <- grep("lh", colnames(dat_wholeBrain_NT), value = TRUE)
wb_lh_TT <- grep("lh", colnames(dat_wholeBrain_TT), value = TRUE)

dat_wholeBrain_lh_NT <- dat_wholeBrain_NT[,wb_lh_NT]
dat_wholeBrain_lh_TT <- dat_wholeBrain_TT[,wb_lh_TT]

# Subset the columns for ReHo and GCOR with the desired pattern
reho_columns_NT <- grep("ReHo", names(dat_wholeBrain_lh_NT), value = TRUE)
gcor_columns_NT <- grep("GCOR", names(dat_wholeBrain_lh_NT), value = TRUE)

reho_columns_TT <- grep("ReHo", names(dat_wholeBrain_lh_TT), value = TRUE)
gcor_columns_TT <- grep("GCOR", names(dat_wholeBrain_lh_TT), value = TRUE)


# Set the kernel values
kernels <- c(2.5, 5, 10, 20, 40)

# Create a data frame with the kernel values and corresponding means and standard errors
mean_reho_NT = colMeans(dat_wholeBrain_lh_NT[, reho_columns_NT], na.rm = TRUE)
mean_gcor_NT = colMeans(dat_wholeBrain_lh_NT[, gcor_columns_NT], na.rm = TRUE)
se_reho_NT = apply(dat_wholeBrain_lh_NT[, reho_columns_NT], 2, function(x) sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x))))
se_gcor_NT = sd(dat_wholeBrain_lh_NT[, gcor_columns_NT]) / sqrt(length(dat_wholeBrain_lh_NT[, gcor_columns_NT]))

mean_reho_TT = colMeans(dat_wholeBrain_lh_TT[, reho_columns_TT], na.rm = TRUE)
mean_gcor_TT = colMeans(dat_wholeBrain_lh_TT[, gcor_columns_TT], na.rm = TRUE)
se_reho_TT = apply(dat_wholeBrain_lh_TT[, reho_columns_TT], 2, function(x) sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x))))
se_gcor_TT = sd(dat_wholeBrain_lh_TT[, gcor_columns_TT]) / sqrt(length(dat_wholeBrain_lh_TT[, gcor_columns_TT]))


# Create a dataframe with the data for plotting
plot_data <- data.frame(
  kernel = c("2.5", "5", "10", "20", "40", "GCOR"),
  mean_reho_NT = c(mean_reho_NT["NT_ReHo_wholeBrain_lh_2_5.txt"], mean_reho_NT["NT_ReHo_wholeBrain_lh_5.txt"], 
                   mean_reho_NT["NT_ReHo_wholeBrain_lh_10.txt"],mean_reho_NT["NT_ReHo_wholeBrain_lh_20.txt"],
                   mean_reho_NT["NT_ReHo_wholeBrain_lh_40.txt"], mean_gcor_NT),
  mean_reho_TT = c(mean_reho_TT["TT_ReHo_wholeBrain_lh_2_5.txt"], mean_reho_TT["TT_ReHo_wholeBrain_lh_5.txt"],
                   mean_reho_TT["TT_ReHo_wholeBrain_lh_10.txt"],mean_reho_TT["TT_ReHo_wholeBrain_lh_20.txt"], 
                   mean_reho_TT["TT_ReHo_wholeBrain_lh_40.txt"], mean_gcor_TT),
  se_reho_NT = c(se_reho_NT["NT_ReHo_wholeBrain_lh_2_5.txt"], se_reho_NT["NT_ReHo_wholeBrain_lh_5.txt"], 
                 se_reho_NT["NT_ReHo_wholeBrain_lh_10.txt"], se_reho_NT["NT_ReHo_wholeBrain_lh_20.txt"], 
                 se_reho_NT["NT_ReHo_wholeBrain_lh_40.txt"], se_gcor_NT),
  se_reho_TT = c(se_reho_TT["TT_ReHo_wholeBrain_lh_2_5.txt"], se_reho_TT["TT_ReHo_wholeBrain_lh_5.txt"], 
                 se_reho_TT["TT_ReHo_wholeBrain_lh_10.txt"],se_reho_TT["TT_ReHo_wholeBrain_lh_20.txt"], 
                 se_reho_TT["TT_ReHo_wholeBrain_lh_40.txt"], se_gcor_TT)
)

plot_data$kernel <- factor(plot_data$kernel, levels = c("2.5", "5", "10", "20", "40", "GCOR"))

# Create the plot
ggplot(plot_data, aes(x = kernel, group = 1)) +
  geom_point(aes(y = mean_reho_NT), color = "blue", size = 2, shape = 23, fill = "blue") +
  geom_errorbar(aes(ymin = mean_reho_NT - se_reho_NT, ymax = mean_reho_NT + se_reho_NT), width = 0.2, color = "blue") +
  geom_line(aes(y = mean_reho_NT, color = "blue", linetype="No tinnitus"), color = "blue", size = 0.5) +
  
  geom_point(aes(y = mean_reho_TT), color = "red", size = 2, shape = 19) +
  geom_errorbar(aes(ymin = mean_reho_TT - se_reho_TT, ymax = mean_reho_TT + se_reho_TT), width = 0.2, color = "red") +
  geom_line(aes(y = mean_reho_TT, color = "red", linetype="Tinnitus"), color = "red", size = 0.5) +
  ylim(0, 0.75) +
  xlab("Kernel") +
  ylab("Signal Correlation") +
  theme_bw() +
  theme(panel.grid = element_blank()) +
  labs(linetype = "Group")+
  scale_linetype_manual(values = c("No tinnitus" = "solid", "Tinnitus" = "dashed"),
                        guide = guide_legend(override.aes = list(color = c("blue", "red")))) +
  
  ggtitle("Whole-Brain left hemisphere")

## ---------------------------------------------------------------------------------------------
## Calculate slope of wholeBrain lh
## ---------------------------------------------------------------------------------------------
# create a new data frame only for numeric kernels and convert the kernel to numeric
plot_data_numeric <- plot_data[plot_data$kernel != "GCOR", ]
plot_data_numeric$kernel <- as.numeric(as.character(plot_data_numeric$kernel))

# calculate the slope for each consecutive pair of kernels for no tinnitus and tinnitus
slopes_noTin <- c()
slopes_tin <- c()

for (i in 1:(nrow(plot_data_numeric) - 1)) {
  # noTin
  y1_rs <- plot_data_numeric$mean_reho_NT[i]
  y2_rs <- plot_data_numeric$mean_reho_NT[i + 1]
  x1 <- log2(plot_data_numeric$kernel[i])
  x2 <- log2(plot_data_numeric$kernel[i + 1])
  # the slope is computed directly using the formula for the slope of a line connecting two points
  slopes_noTin_calc <- (y2_rs - y1_rs) / (x2 - x1)
  slopes_noTin <- c(slopes_noTin, slopes_noTin_calc)
  
  # Tin
  y1_vs <- plot_data_numeric$mean_reho_TT[i]
  y2_vs <- plot_data_numeric$mean_reho_TT[i + 1]
  slopes_tin_calc <- (y2_vs - y1_vs) / (x2 - x1)
  slopes_tin <- c(slopes_tin, slopes_tin_calc)
}

# calculate the average slopes
average_slopes_noTin <- mean(slopes_noTin)
average_slopes_tin <- mean(slopes_tin)

print(paste("Average slope for no tinnitus: ", average_slopes_noTin))
print(paste("Average slope for tinnitus: ", average_slopes_tin))

## ---------------------------------------------------------------------------------------------
## Add slopes information to the plot
# Create the plot
p <- ggplot(plot_data, aes(x = kernel, group = 1)) +
  geom_point(aes(y = mean_reho_NT), color = "blue", size = 2, shape = 23, fill = "blue") +
  geom_errorbar(aes(ymin = mean_reho_NT - se_reho_NT, ymax = mean_reho_NT + se_reho_NT), width = 0.2, color = "blue") +
  geom_line(aes(y = mean_reho_NT, color = "blue", linetype="No tinnitus"), color = "blue", size = 0.5) +
  
  geom_point(aes(y = mean_reho_TT), color = "red", size = 2, shape = 19) +
  geom_errorbar(aes(ymin = mean_reho_TT - se_reho_TT, ymax = mean_reho_TT + se_reho_TT), width = 0.2, color = "red") +
  geom_line(aes(y = mean_reho_TT, color = "red", linetype="Tinnitus"), color = "red", size = 0.5) +
  ylim(0, 0.75) +
  xlab("Kernel") +
  ylab("Signal Correlation") +
  theme_bw() +
  theme(panel.grid = element_blank()) +
  labs(linetype = "Group")+
  scale_linetype_manual(values = c("No tinnitus" = "solid", "Tinnitus" = "dashed"),
                        guide = guide_legend(override.aes = list(color = c("blue", "red")))) +
  
  ggtitle("Whole-Brain left hemisphere")

# Add the slopes to the plot
p <- p + annotate("text", x = 6, y = 0.75, 
                  label = paste("Avg. slope no tinnitus: ", round(average_slopes_noTin, 3), sep=""),
                  size = 3, hjust = 1, color = "blue")
p <- p + annotate("text", x = 6, y = 0.7, 
                  label = paste("Avg. slope tinnitus: ", round(average_slopes_tin, 3), sep=""),
                  size = 3, hjust = 1, color = "red")

print(p)

ggsave("/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/sigCorr_kernels_wholeBrain_lh.png",width = 8, height = 4)



## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of wholeBrain rh
## ---------------------------------------------------------------------------------------------
wb_rh_NT <- grep("rh", colnames(dat_wholeBrain_NT), value = TRUE)
wb_rh_TT <- grep("rh", colnames(dat_wholeBrain_TT), value = TRUE)

dat_wholeBrain_rh_NT <- dat_wholeBrain_NT[,wb_rh_NT]
dat_wholeBrain_rh_TT <- dat_wholeBrain_TT[,wb_rh_TT]

# Subset the columns for ReHo and GCOR with the desired pattern
reho_columns_NT <- grep("ReHo", names(dat_wholeBrain_rh_NT), value = TRUE)
gcor_columns_NT <- grep("GCOR", names(dat_wholeBrain_rh_NT), value = TRUE)

reho_columns_TT <- grep("ReHo", names(dat_wholeBrain_rh_TT), value = TRUE)
gcor_columns_TT <- grep("GCOR", names(dat_wholeBrain_rh_TT), value = TRUE)


# Set the kernel values
kernels <- c(2.5, 5, 10, 20, 40)

# Create a data frame with the kernel values and corresponding means and standard errors
mean_reho_NT = colMeans(dat_wholeBrain_rh_NT[, reho_columns_NT], na.rm = TRUE)
mean_gcor_NT = mean(dat_wholeBrain_rh_NT[, gcor_columns_NT], na.rm = TRUE)
se_reho_NT = apply(dat_wholeBrain_rh_NT[, reho_columns_NT], 2, function(x) sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x))))
se_gcor_NT = sd(dat_wholeBrain_rh_NT[, gcor_columns_NT]) / sqrt(length(dat_wholeBrain_rh_NT[, gcor_columns_NT]))

mean_reho_TT = colMeans(dat_wholeBrain_rh_TT[, reho_columns_TT], na.rm = TRUE)
mean_gcor_TT = mean(dat_wholeBrain_rh_TT[, gcor_columns_TT], na.rm = TRUE)
se_reho_TT = apply(dat_wholeBrain_rh_TT[, reho_columns_TT], 2, function(x) sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x))))
se_gcor_TT = sd(dat_wholeBrain_rh_TT[, gcor_columns_TT]) / sqrt(length(dat_wholeBrain_rh_TT[, gcor_columns_TT]))


# Create a dataframe with the data for plotting
plot_data <- data.frame(
  kernel = c("2.5", "5", "10", "20", "40", "GCOR"),
  mean_reho_NT = c(mean_reho_NT["NT_ReHo_wholeBrain_rh_2_5.txt"], mean_reho_NT["NT_ReHo_wholeBrain_rh_5.txt"], 
                   mean_reho_NT["NT_ReHo_wholeBrain_rh_10.txt"],mean_reho_NT["NT_ReHo_wholeBrain_rh_20.txt"],
                   mean_reho_NT["NT_ReHo_wholeBrain_rh_40.txt"], mean_gcor_NT),
  mean_reho_TT = c(mean_reho_TT["TT_ReHo_wholeBrain_rh_2_5.txt"], mean_reho_TT["TT_ReHo_wholeBrain_rh_5.txt"],
                   mean_reho_TT["TT_ReHo_wholeBrain_rh_10.txt"],mean_reho_TT["TT_ReHo_wholeBrain_rh_20.txt"], 
                   mean_reho_TT["TT_ReHo_wholeBrain_rh_40.txt"], mean_gcor_TT),
  se_reho_NT = c(se_reho_NT["NT_ReHo_wholeBrain_rh_2_5.txt"], se_reho_NT["NT_ReHo_wholeBrain_rh_5.txt"], 
                 se_reho_NT["NT_ReHo_wholeBrain_rh_10.txt"], se_reho_NT["NT_ReHo_wholeBrain_rh_20.txt"], 
                 se_reho_NT["NT_ReHo_wholeBrain_rh_40.txt"], se_gcor_NT),
  se_reho_TT = c(se_reho_TT["TT_ReHo_wholeBrain_rh_2_5.txt"], se_reho_TT["TT_ReHo_wholeBrain_rh_5.txt"], 
                 se_reho_TT["TT_ReHo_wholeBrain_rh_10.txt"],se_reho_TT["TT_ReHo_wholeBrain_rh_20.txt"], 
                 se_reho_TT["TT_ReHo_wholeBrain_rh_40.txt"], se_gcor_TT)
)

plot_data$kernel <- factor(plot_data$kernel, levels = c("2.5", "5", "10", "20", "40", "GCOR"))

# Create the plot
ggplot(plot_data, aes(x = kernel, group = 1)) +
  geom_point(aes(y = mean_reho_NT), color = "blue", size = 2, shape = 23, fill = "blue") +
  geom_errorbar(aes(ymin = mean_reho_NT - se_reho_NT, ymax = mean_reho_NT + se_reho_NT), width = 0.2, color = "blue") +
  geom_line(aes(y = mean_reho_NT, color = "blue", linetype="No tinnitus"), color = "blue", size = 0.5) +
  
  geom_point(aes(y = mean_reho_TT), color = "red", size = 2, shape = 19) +
  geom_errorbar(aes(ymin = mean_reho_TT - se_reho_TT, ymax = mean_reho_TT + se_reho_TT), width = 0.2, color = "red") +
  geom_line(aes(y = mean_reho_TT, color = "red", linetype="Tinnitus"), color = "red", size = 0.5) +
  ylim(0, 0.75) +
  xlab("Kernel") +
  ylab("Signal Correlation") +
  theme_bw() +
  theme(panel.grid = element_blank()) +
  labs(linetype = "Group")+
  scale_linetype_manual(values = c("No tinnitus" = "solid", "Tinnitus" = "dashed"),
                        guide = guide_legend(override.aes = list(color = c("blue", "red")))) +
  
  ggtitle("Whole-Brain right hemisphere")


## ---------------------------------------------------------------------------------------------
## Calculate slope of wholeBrain rh
## ---------------------------------------------------------------------------------------------
# create a new data frame only for numeric kernels and convert the kernel to numeric
plot_data_numeric <- plot_data[plot_data$kernel != "GCOR", ]
plot_data_numeric$kernel <- as.numeric(as.character(plot_data_numeric$kernel))

# calculate the slope for each consecutive pair of kernels for no tinnitus and tinnitus
slopes_noTin <- c()
slopes_tin <- c()

for (i in 1:(nrow(plot_data_numeric) - 1)) {
  # noTin
  y1_rs <- plot_data_numeric$mean_reho_NT[i]
  y2_rs <- plot_data_numeric$mean_reho_NT[i + 1]
  x1 <- log2(plot_data_numeric$kernel[i])
  x2 <- log2(plot_data_numeric$kernel[i + 1])
  # the slope is computed directly using the formula for the slope of a line connecting two points
  slopes_noTin_calc <- (y2_rs - y1_rs) / (x2 - x1)
  slopes_noTin <- c(slopes_noTin, slopes_noTin_calc)
  
  # Tin
  y1_vs <- plot_data_numeric$mean_reho_TT[i]
  y2_vs <- plot_data_numeric$mean_reho_TT[i + 1]
  slopes_tin_calc <- (y2_vs - y1_vs) / (x2 - x1)
  slopes_tin <- c(slopes_tin, slopes_tin_calc)
}

# calculate the average slopes
average_slopes_noTin <- mean(slopes_noTin)
average_slopes_tin <- mean(slopes_tin)

print(paste("Average slope for no tinnitus: ", average_slopes_noTin))
print(paste("Average slope for tinnitus: ", average_slopes_tin))

## ---------------------------------------------------------------------------------------------
## Add slopes information to the plot
# Create the plot
p <- ggplot(plot_data, aes(x = kernel, group = 1)) +
  geom_point(aes(y = mean_reho_NT), color = "blue", size = 2, shape = 23, fill = "blue") +
  geom_errorbar(aes(ymin = mean_reho_NT - se_reho_NT, ymax = mean_reho_NT + se_reho_NT), width = 0.2, color = "blue") +
  geom_line(aes(y = mean_reho_NT, color = "blue", linetype="No tinnitus"), color = "blue", size = 0.5) +
  
  geom_point(aes(y = mean_reho_TT), color = "red", size = 2, shape = 19) +
  geom_errorbar(aes(ymin = mean_reho_TT - se_reho_TT, ymax = mean_reho_TT + se_reho_TT), width = 0.2, color = "red") +
  geom_line(aes(y = mean_reho_TT, color = "red", linetype="Tinnitus"), color = "red", size = 0.5) +
  ylim(0, 0.75) +
  xlab("Kernel") +
  ylab("Signal Correlation") +
  theme_bw() +
  theme(panel.grid = element_blank()) +
  labs(linetype = "Group")+
  scale_linetype_manual(values = c("No tinnitus" = "solid", "Tinnitus" = "dashed"),
                        guide = guide_legend(override.aes = list(color = c("blue", "red")))) +
  
  ggtitle("Whole-Brain right hemisphere")

# Add the slopes to the plot
p <- p + annotate("text", x = 6, y = 0.75, 
                  label = paste("Avg. slope no tinnitus: ", round(average_slopes_noTin, 3), sep=""),
                  size = 3, hjust = 1, color = "blue")
p <- p + annotate("text", x = 6, y = 0.7, 
                  label = paste("Avg. slope tinnitus: ", round(average_slopes_tin, 3), sep=""),
                  size = 3, hjust = 1, color = "red")

print(p)

ggsave("/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/sigCorr_kernels_wholeBrain_rh.png",width = 8, height = 4)

## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of HG lh
## ---------------------------------------------------------------------------------------------
wb_lh_NT <- grep("lh", colnames(dat_HG_NT), value = TRUE)
wb_lh_TT <- grep("lh", colnames(dat_HG_TT), value = TRUE)

dat_HG_lh_NT <- dat_HG_NT[,wb_lh_NT]
dat_HG_lh_TT <- dat_HG_TT[,wb_lh_TT]

# Subset the columns for ReHo and GCOR with the desired pattern
reho_columns_NT <- grep("ReHo", names(dat_HG_lh_NT), value = TRUE)
gcor_columns_NT <- grep("GCOR", names(dat_HG_lh_NT), value = TRUE)

reho_columns_TT <- grep("ReHo", names(dat_HG_lh_TT), value = TRUE)
gcor_columns_TT <- grep("GCOR", names(dat_HG_lh_TT), value = TRUE)


# Set the kernel values
kernels <- c(2.5, 5, 10, 20, 40)

# Create a data frame with the kernel values and corresponding means and standard errors
mean_reho_NT = colMeans(dat_HG_lh_NT[, reho_columns_NT], na.rm = TRUE)
mean_gcor_NT = mean(dat_HG_lh_NT[, gcor_columns_NT], na.rm = TRUE)
se_reho_NT = apply(dat_HG_lh_NT[, reho_columns_NT], 2, function(x) sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x))))
se_gcor_NT = sd(dat_HG_lh_NT[, gcor_columns_NT]) / sqrt(length(dat_HG_lh_NT[, gcor_columns_NT]))

mean_reho_TT = colMeans(dat_HG_lh_TT[, reho_columns_TT], na.rm = TRUE)
mean_gcor_TT = mean(dat_HG_lh_TT[, gcor_columns_TT], na.rm = TRUE)
se_reho_TT = apply(dat_HG_lh_TT[, reho_columns_TT], 2, function(x) sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x))))
se_gcor_TT = sd(dat_HG_lh_TT[, gcor_columns_TT]) / sqrt(length(dat_HG_lh_TT[, gcor_columns_TT]))


# Create a dataframe with the data for plotting
plot_data <- data.frame(
  kernel = c("2.5", "5", "10", "20", "40", "GCOR"),
  mean_reho_NT = c(mean_reho_NT["NT_ReHo_HG_lh_2_5.txt"], mean_reho_NT["NT_ReHo_HG_lh_5.txt"], 
                   mean_reho_NT["NT_ReHo_HG_lh_10.txt"],mean_reho_NT["NT_ReHo_HG_lh_20.txt"],
                   mean_reho_NT["NT_ReHo_HG_lh_40.txt"], mean_gcor_NT),
  mean_reho_TT = c(mean_reho_TT["TT_ReHo_HG_lh_2_5.txt"], mean_reho_TT["TT_ReHo_HG_lh_5.txt"],
                   mean_reho_TT["TT_ReHo_HG_lh_10.txt"],mean_reho_TT["TT_ReHo_HG_lh_20.txt"], 
                   mean_reho_TT["TT_ReHo_HG_lh_40.txt"], mean_gcor_TT),
  se_reho_NT = c(se_reho_NT["NT_ReHo_HG_lh_2_5.txt"], se_reho_NT["NT_ReHo_HG_lh_5.txt"], 
                 se_reho_NT["NT_ReHo_HG_lh_10.txt"], se_reho_NT["NT_ReHo_HG_lh_20.txt"], 
                 se_reho_NT["NT_ReHo_HG_lh_40.txt"], se_gcor_NT),
  se_reho_TT = c(se_reho_TT["TT_ReHo_HG_lh_2_5.txt"], se_reho_TT["TT_ReHo_HG_lh_5.txt"], 
                 se_reho_TT["TT_ReHo_HG_lh_10.txt"],se_reho_TT["TT_ReHo_HG_lh_20.txt"], 
                 se_reho_TT["TT_ReHo_HG_lh_40.txt"], se_gcor_TT)
)

plot_data$kernel <- factor(plot_data$kernel, levels = c("2.5", "5", "10", "20", "40", "GCOR"))

# Create the plot
ggplot(plot_data, aes(x = kernel, group = 1)) +
  geom_point(aes(y = mean_reho_NT), color = "blue", size = 2, shape = 23, fill = "blue") +
  geom_errorbar(aes(ymin = mean_reho_NT - se_reho_NT, ymax = mean_reho_NT + se_reho_NT), width = 0.2, color = "blue") +
  geom_line(aes(y = mean_reho_NT, color = "blue", linetype="No tinnitus"), color = "blue", size = 0.5) +
  
  geom_point(aes(y = mean_reho_TT), color = "red", size = 2, shape = 19) +
  geom_errorbar(aes(ymin = mean_reho_TT - se_reho_TT, ymax = mean_reho_TT + se_reho_TT), width = 0.2, color = "red") +
  geom_line(aes(y = mean_reho_TT, color = "red", linetype="Tinnitus"), color = "red", size = 0.5) +
  ylim(0, 0.75) +
  xlab("Kernel") +
  ylab("Signal Correlation") +
  theme_bw() +
  theme(panel.grid = element_blank()) +
  labs(linetype = "Group")+
  scale_linetype_manual(values = c("No tinnitus" = "solid", "Tinnitus" = "dashed"),
                        guide = guide_legend(override.aes = list(color = c("blue", "red")))) +
  
  ggtitle("Heschl's gyrus left hemisphere")

## ---------------------------------------------------------------------------------------------
## Calculate slope of HG lh
## ---------------------------------------------------------------------------------------------
# create a new data frame only for numeric kernels and convert the kernel to numeric
plot_data_numeric <- plot_data[plot_data$kernel != "GCOR", ]
plot_data_numeric$kernel <- as.numeric(as.character(plot_data_numeric$kernel))

# calculate the slope for each consecutive pair of kernels for no tinnitus and tinnitus
slopes_noTin <- c()
slopes_tin <- c()

for (i in 1:(nrow(plot_data_numeric) - 1)) {
  # noTin
  y1_rs <- plot_data_numeric$mean_reho_NT[i]
  y2_rs <- plot_data_numeric$mean_reho_NT[i + 1]
  x1 <- log2(plot_data_numeric$kernel[i])
  x2 <- log2(plot_data_numeric$kernel[i + 1])
  # the slope is computed directly using the formula for the slope of a line connecting two points
  slopes_noTin_calc <- (y2_rs - y1_rs) / (x2 - x1)
  slopes_noTin <- c(slopes_noTin, slopes_noTin_calc)
  
  # Tin
  y1_vs <- plot_data_numeric$mean_reho_TT[i]
  y2_vs <- plot_data_numeric$mean_reho_TT[i + 1]
  slopes_tin_calc <- (y2_vs - y1_vs) / (x2 - x1)
  slopes_tin <- c(slopes_tin, slopes_tin_calc)
}

# calculate the average slopes
average_slopes_noTin <- mean(slopes_noTin)
average_slopes_tin <- mean(slopes_tin)

print(paste("Average slope for no tinnitus: ", average_slopes_noTin))
print(paste("Average slope for tinnitus: ", average_slopes_tin))

## ---------------------------------------------------------------------------------------------
## Add slopes information to the plot
# Create the plot
p <- ggplot(plot_data, aes(x = kernel, group = 1)) +
  geom_point(aes(y = mean_reho_NT), color = "blue", size = 2, shape = 23, fill = "blue") +
  geom_errorbar(aes(ymin = mean_reho_NT - se_reho_NT, ymax = mean_reho_NT + se_reho_NT), width = 0.2, color = "blue") +
  geom_line(aes(y = mean_reho_NT, color = "blue", linetype="No tinnitus"), color = "blue", size = 0.5) +
  
  geom_point(aes(y = mean_reho_TT), color = "red", size = 2, shape = 19) +
  geom_errorbar(aes(ymin = mean_reho_TT - se_reho_TT, ymax = mean_reho_TT + se_reho_TT), width = 0.2, color = "red") +
  geom_line(aes(y = mean_reho_TT, color = "red", linetype="Tinnitus"), color = "red", size = 0.5) +
  ylim(0, 0.75) +
  xlab("Kernel") +
  ylab("Signal Correlation") +
  theme_bw() +
  theme(panel.grid = element_blank()) +
  labs(linetype = "Group")+
  scale_linetype_manual(values = c("No tinnitus" = "solid", "Tinnitus" = "dashed"),
                        guide = guide_legend(override.aes = list(color = c("blue", "red")))) +
  
  ggtitle("Heschls' gyrus left hemisphere")

# Add the slopes to the plot
p <- p + annotate("text", x = 6, y = 0.75, 
                  label = paste("Avg. slope no tinnitus: ", round(average_slopes_noTin, 3), sep=""),
                  size = 3, hjust = 1, color = "blue")
p <- p + annotate("text", x = 6, y = 0.7, 
                  label = paste("Avg. slope tinnitus: ", round(average_slopes_tin, 3), sep=""),
                  size = 3, hjust = 1, color = "red")

print(p)

ggsave("/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/sigCorr_kernels_HG_lh.png",width = 8, height = 4)



## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of HG rh
## ---------------------------------------------------------------------------------------------
wb_rh_NT <- grep("rh", colnames(dat_HG_NT), value = TRUE)
wb_rh_TT <- grep("rh", colnames(dat_HG_TT), value = TRUE)

dat_HG_rh_NT <- dat_HG_NT[,wb_rh_NT]
dat_HG_rh_TT <- dat_HG_TT[,wb_rh_TT]

# Subset the columns for ReHo and GCOR with the desired pattern
reho_columns_NT <- grep("ReHo", names(dat_HG_rh_NT), value = TRUE)
gcor_columns_NT <- grep("GCOR", names(dat_HG_rh_NT), value = TRUE)

reho_columns_TT <- grep("ReHo", names(dat_HG_rh_TT), value = TRUE)
gcor_columns_TT <- grep("GCOR", names(dat_HG_rh_TT), value = TRUE)


# Set the kernel values
kernels <- c(2.5, 5, 10, 20, 40)

# Create a data frame with the kernel values and corresponding means and standard errors
mean_reho_NT = colMeans(dat_HG_rh_NT[, reho_columns_NT], na.rm = TRUE)
mean_gcor_NT = mean(dat_HG_rh_NT[, gcor_columns_NT], na.rm = TRUE)
se_reho_NT = apply(dat_HG_rh_NT[, reho_columns_NT], 2, function(x) sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x))))
se_gcor_NT = sd(dat_HG_rh_NT[, gcor_columns_NT]) / sqrt(length(dat_HG_rh_NT[, gcor_columns_NT]))

mean_reho_TT = colMeans(dat_HG_rh_TT[, reho_columns_TT], na.rm = TRUE)
mean_gcor_TT = mean(dat_HG_rh_TT[, gcor_columns_TT], na.rm = TRUE)
se_reho_TT = apply(dat_HG_rh_TT[, reho_columns_TT], 2, function(x) sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x))))
se_gcor_TT = sd(dat_HG_rh_TT[, gcor_columns_TT]) / sqrt(length(dat_HG_rh_TT[, gcor_columns_TT]))


# Create a dataframe with the data for plotting
plot_data <- data.frame(
  kernel = c("2.5", "5", "10", "20", "40", "GCOR"),
  mean_reho_NT = c(mean_reho_NT["NT_ReHo_HG_rh_2_5.txt"], mean_reho_NT["NT_ReHo_HG_rh_5.txt"], 
                   mean_reho_NT["NT_ReHo_HG_rh_10.txt"],mean_reho_NT["NT_ReHo_HG_rh_20.txt"],
                   mean_reho_NT["NT_ReHo_HG_rh_40.txt"], mean_gcor_NT),
  mean_reho_TT = c(mean_reho_TT["TT_ReHo_HG_rh_2_5.txt"], mean_reho_TT["TT_ReHo_HG_rh_5.txt"],
                   mean_reho_TT["TT_ReHo_HG_rh_10.txt"],mean_reho_TT["TT_ReHo_HG_rh_20.txt"], 
                   mean_reho_TT["TT_ReHo_HG_rh_40.txt"], mean_gcor_TT),
  se_reho_NT = c(se_reho_NT["NT_ReHo_HG_rh_2_5.txt"], se_reho_NT["NT_ReHo_HG_rh_5.txt"], 
                 se_reho_NT["NT_ReHo_HG_rh_10.txt"], se_reho_NT["NT_ReHo_HG_rh_20.txt"], 
                 se_reho_NT["NT_ReHo_HG_rh_40.txt"], se_gcor_NT),
  se_reho_TT = c(se_reho_TT["TT_ReHo_HG_rh_2_5.txt"], se_reho_TT["TT_ReHo_HG_rh_5.txt"], 
                 se_reho_TT["TT_ReHo_HG_rh_10.txt"],se_reho_TT["TT_ReHo_HG_rh_20.txt"], 
                 se_reho_TT["TT_ReHo_HG_rh_40.txt"], se_gcor_TT)
)

plot_data$kernel <- factor(plot_data$kernel, levels = c("2.5", "5", "10", "20", "40", "GCOR"))

# Create the plot
ggplot(plot_data, aes(x = kernel, group = 1)) +
  geom_point(aes(y = mean_reho_NT), color = "blue", size = 2, shape = 23, fill = "blue") +
  geom_errorbar(aes(ymin = mean_reho_NT - se_reho_NT, ymax = mean_reho_NT + se_reho_NT), width = 0.2, color = "blue") +
  geom_line(aes(y = mean_reho_NT, color = "blue", linetype="No tinnitus"), color = "blue", size = 0.5) +
  
  geom_point(aes(y = mean_reho_TT), color = "red", size = 2, shape = 19) +
  geom_errorbar(aes(ymin = mean_reho_TT - se_reho_TT, ymax = mean_reho_TT + se_reho_TT), width = 0.2, color = "red") +
  geom_line(aes(y = mean_reho_TT, color = "red", linetype="Tinnitus"), color = "red", size = 0.5) +
  ylim(0, 0.75) +
  xlab("Kernel") +
  ylab("Signal Correlation") +
  theme_bw() +
  theme(panel.grid = element_blank()) +
  labs(linetype = "Group")+
  scale_linetype_manual(values = c("No tinnitus" = "solid", "Tinnitus" = "dashed"),
                        guide = guide_legend(override.aes = list(color = c("blue", "red")))) +
  
  ggtitle("Heschl's gyrus right hemisphere")


## ---------------------------------------------------------------------------------------------
## Calculate slope of HG rh
## ---------------------------------------------------------------------------------------------
# create a new data frame only for numeric kernels and convert the kernel to numeric
plot_data_numeric <- plot_data[plot_data$kernel != "GCOR", ]
plot_data_numeric$kernel <- as.numeric(as.character(plot_data_numeric$kernel))

# calculate the slope for each consecutive pair of kernels for no tinnitus and tinnitus
slopes_noTin <- c()
slopes_tin <- c()

for (i in 1:(nrow(plot_data_numeric) - 1)) {
  # noTin
  y1_rs <- plot_data_numeric$mean_reho_NT[i]
  y2_rs <- plot_data_numeric$mean_reho_NT[i + 1]
  x1 <- log2(plot_data_numeric$kernel[i])
  x2 <- log2(plot_data_numeric$kernel[i + 1])
  # the slope is computed directly using the formula for the slope of a line connecting two points
  slopes_noTin_calc <- (y2_rs - y1_rs) / (x2 - x1)
  slopes_noTin <- c(slopes_noTin, slopes_noTin_calc)
  
  # Tin
  y1_vs <- plot_data_numeric$mean_reho_TT[i]
  y2_vs <- plot_data_numeric$mean_reho_TT[i + 1]
  slopes_tin_calc <- (y2_vs - y1_vs) / (x2 - x1)
  slopes_tin <- c(slopes_tin, slopes_tin_calc)
}

# calculate the average slopes
average_slopes_noTin <- mean(slopes_noTin)
average_slopes_tin <- mean(slopes_tin)

print(paste("Average slope for no tinnitus: ", average_slopes_noTin))
print(paste("Average slope for tinnitus: ", average_slopes_tin))

## ---------------------------------------------------------------------------------------------
## Add slopes information to the plot
# Create the plot
p <- ggplot(plot_data, aes(x = kernel, group = 1)) +
  geom_point(aes(y = mean_reho_NT), color = "blue", size = 2, shape = 23, fill = "blue") +
  geom_errorbar(aes(ymin = mean_reho_NT - se_reho_NT, ymax = mean_reho_NT + se_reho_NT), width = 0.2, color = "blue") +
  geom_line(aes(y = mean_reho_NT, color = "blue", linetype="No tinnitus"), color = "blue", size = 0.5) +
  
  geom_point(aes(y = mean_reho_TT), color = "red", size = 2, shape = 19) +
  geom_errorbar(aes(ymin = mean_reho_TT - se_reho_TT, ymax = mean_reho_TT + se_reho_TT), width = 0.2, color = "red") +
  geom_line(aes(y = mean_reho_TT, color = "red", linetype="Tinnitus"), color = "red", size = 0.5) +
  ylim(0, 0.75) +
  xlab("Kernel") +
  ylab("Signal Correlation") +
  theme_bw() +
  theme(panel.grid = element_blank()) +
  labs(linetype = "Group")+
  scale_linetype_manual(values = c("No tinnitus" = "solid", "Tinnitus" = "dashed"),
                        guide = guide_legend(override.aes = list(color = c("blue", "red")))) +
  
  ggtitle("Heschls' gyrus right hemisphere")

# Add the slopes to the plot
p <- p + annotate("text", x = 6, y = 0.75, 
                  label = paste("Avg. slope no tinnitus: ", round(average_slopes_noTin, 3), sep=""),
                  size = 3, hjust = 1, color = "blue")
p <- p + annotate("text", x = 6, y = 0.7, 
                  label = paste("Avg. slope tinnitus: ", round(average_slopes_tin, 3), sep=""),
                  size = 3, hjust = 1, color = "red")

print(p)

ggsave("/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/sigCorr_kernels_HG_rh.png",width = 8, height = 4)








