## This code is to make plot of ReCov and GCOV for different kernels from brainStates

library(dplyr)
library(ggplot2)
library(scales)  # for logarithmic scales
library(ggpubr)  # for drawing lines between points

## Clear variables from workspace
rm(list = setdiff(ls(), lsf.str()))

# Define the directory paths for ALFF, ReCov and GCOV files
alff_directory <- "/Volumes/gdrive4tb/brainStates/AnissaSurfaceAnalysis_new/ALFF"
recov_directory <- "/Volumes/gdrive4tb/brainStates/AnissaSurfaceAnalysis_new/ReCov"
gcov_directory <- "/Volumes/gdrive4tb/brainStates/AnissaSurfaceAnalysis_new/GCOV"

# Define the list of subjects
subjects <- c('sub-01', 'sub-02', 'sub-03', 'sub-04', 'sub-05', 'sub-06', 'sub-07', 'sub-08', 'sub-09', 'sub-10', 'sub-11')

# Create empty data frames for each area
dat_wholeBrain <- data.frame()

# Loop through the subject folders
for (subject in subjects) {
  # Loop through the main folders
  for (main_folder in c(alff_directory, recov_directory, gcov_directory)) {
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
        condition <- gsub("sub-\\d+_(\\w+)_wholeBrain_(\\w+)\\.txt", "\\1_\\2", file_name)
        
        column_name <- condition
        
        # Add the data to the dataframe
        dat_wholeBrain[subject,column_name] = decimal_value
        
      }
    }
  }
}

## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of wholeBrain lh
## ---------------------------------------------------------------------------------------------
wb_lh <- grep("lh", colnames(dat_wholeBrain), value = TRUE)

dat_wholeBrain_lh <- dat_wholeBrain[,wb_lh]

# Subset the columns for ReCov and GCOV with the desired pattern
alff_ns_columns <- grep("^ALFF_sqr_ns", names(dat_wholeBrain_lh), value = TRUE)
recov_ns_columns <- grep("^ReCov_ns", names(dat_wholeBrain_lh), value = TRUE)
gcov_ns_columns <- grep("^GCOV_ns", names(dat_wholeBrain_lh), value = TRUE)

# Set the kernel values
kernels <- c(2.5, 5, 10, 20, 40)

# Create a data frame with the kernel values and corresponding means and standard errors
mean_alff_ns = mean(dat_wholeBrain_lh[, alff_ns_columns], na.rm = TRUE)
mean_recov_ns = colMeans(dat_wholeBrain_lh[, recov_ns_columns], na.rm = TRUE)
mean_gcov_ns = mean(dat_wholeBrain_lh[, gcov_ns_columns], na.rm = TRUE)

se_alff_ns = sd(dat_wholeBrain_lh[, alff_ns_columns]) / sqrt(length(dat_wholeBrain_lh[, alff_ns_columns]))
se_recov_ns = apply(dat_wholeBrain_lh[, recov_ns_columns], 2, function(x) sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x))))
se_gcov_ns = sd(dat_wholeBrain_lh[, gcov_ns_columns]) / sqrt(length(dat_wholeBrain_lh[, gcov_ns_columns]))



# Create a dataframe with the data for plotting
plot_data <- data.frame(
  kernel = c("ALFF^2","2.5", "5", "10", "20", "40", "GCOV"),
  mean_recov_ns = c(mean_alff_ns, mean_recov_ns["ReCov_ns_lh_2_5"], mean_recov_ns["ReCov_ns_lh_5"], mean_recov_ns["ReCov_ns_lh_10"],
                    mean_recov_ns["ReCov_ns_lh_20"], mean_recov_ns["ReCov_ns_lh_40"], mean_gcov_ns),
  se_recov_ns = c(se_alff_ns, se_recov_ns["ReCov_ns_lh_2_5"], se_recov_ns["ReCov_ns_lh_5"], se_recov_ns["ReCov_ns_lh_10"],
                  se_recov_ns["ReCov_ns_lh_20"], se_recov_ns["ReCov_ns_lh_40"], se_gcov_ns))

plot_data$kernel <- factor(plot_data$kernel, levels = c("ALFF^2","2.5", "5", "10", "20", "40", "GCOV"))

# Modify the 'kernel' variable to be numeric
plot_data <- plot_data %>%
  mutate(kernel = as.character(kernel),  # Convert factor to character
         kernel_numeric = case_when(
           kernel == "ALFF^2" ~ 1,
           kernel == "2.5"    ~ 2.5,
           kernel == "5"      ~ 5,
           kernel == "10"     ~ 10,
           kernel == "20"     ~ 20,
           kernel == "40"     ~ 40,
           kernel == "GCOV"   ~ 200
         ))

# Create the plot
ggplot(plot_data, aes(x = kernel_numeric, group = 1)) +
  geom_point(aes(y = mean_recov_ns), color = "blue", size = 2, shape = 23, fill = "blue") +
  geom_errorbar(aes(ymin = mean_recov_ns - se_recov_ns, ymax = mean_recov_ns + se_recov_ns), width = 0.2, color = "blue") +
  geom_line(aes(y = mean_recov_ns, color = "blue", linetype="resting-state"), color = "blue", size = 0.5) +
  scale_x_continuous(breaks = c(1, 2.5, 5, 10, 20, 40, 200), 
                     labels = c("ALFF^2", "2.5", "5", "10", "20", "40", "GCOV")) +
  
  xlab("Kernel") +
  ylab("Signal Covariance") +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size = 10)) +  # Adjust angle and size here
  labs(linetype = "Condition")+
  scale_linetype_manual(values = c("resting-state" = "solid"),
                        guide = guide_legend(override.aes = list(color = "blue"))) +
  
  ggtitle("Whole-Brain left hemisphere")




################################################################################

## Adding ReCov data from IGNITE sparse rest

################################################################################
# Define the directory paths
recov_directory_ignite <- "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReCov/temporal"

# Define the list of subjects
subjects <- list.files(path = "/Volumes/gdrive4tb/IGNITE/sparse_rest/preprocessed", full.names = FALSE, recursive = FALSE)

# Create empty data frames for each area
dat_wholeBrain_ignite <- data.frame()

# Loop through the subject folders
for (subject in subjects) {
  # Loop through the main folders
  for (main_folder in recov_directory_ignite) {
    # Set the path to the meanValues subfolder for the current subject and main folder
    meanValues_path <- paste0(main_folder, "/meanValues/", subject)
    
    # Get the list of files in the meanValues subfolder
    file_list <- list.files(meanValues_path)
    
    # Loop through the files
    for (file_name in file_list) {
      
      # Check if the file name contains "rest"
      if (grepl("rest", file_name)) {
        # Read the file using readLines()
        file_path <- paste0(meanValues_path, "/", file_name)
        lines <- readLines(file_path)
        
        # Extract decimal value from the text
        decimal_value <- as.numeric(lines[grep("\\d+\\.\\d+", lines)])
        
        # Extract relevant information from the file name
        condition <- sub(".*_(rh_ReCov_rest|lh_ReCov_rest).*\\.txt", "\\1", file_name)
        
        column_name <- condition
        
        # Add the data to the dataframe
        dat_wholeBrain_ignite[subject,column_name] = decimal_value
        
      }
    }
  }
}

## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of wholeBrain lh
## ---------------------------------------------------------------------------------------------
wb_lh <- grep("lh", colnames(dat_wholeBrain_ignite), value = TRUE)

dat_wholeBrain_ignite_lh <- as.data.frame(dat_wholeBrain_ignite[,wb_lh])
colnames(dat_wholeBrain_ignite_lh)[colnames(dat_wholeBrain_ignite_lh) == "dat_wholeBrain_ignite[, wb_lh]"] <- "lh_ReCov_rest"

# Subset the columns for ReCov with the desired pattern
recov_rest_columns <- grep("^lh_ReCov_rest", names(dat_wholeBrain_ignite), value = TRUE)

# Set the kernel values
kernels <- c(100)

# Create a data frame with the kernel values and corresponding means and standard errors
mean_recov_ns = mean(dat_wholeBrain_ignite_lh[, recov_rest_columns], na.rm = TRUE)
se_recov_ns = sd(dat_wholeBrain_ignite_lh[, recov_rest_columns]) / sqrt(length(dat_wholeBrain_ignite_lh[, recov_rest_columns]))


# Create a dataframe with the data for plotting
plot_data_ignite <- data.frame(
  kernel = "100",
  mean_recov_ns = mean_recov_ns,
  se_recov_ns = se_recov_ns)




################################################################################

## PLOT ReCoV

################################################################################
# Ensure that plot_data_ignite has the same columns as plot_data
plot_data_ignite$kernel_numeric <- 100  # or whatever numeric value you want to assign

# Combine the two data frames
combined_plot_data <- rbind(plot_data, plot_data_ignite)


ggplot(combined_plot_data, aes(x = kernel_numeric, y = mean_recov_ns, group = 1)) +
  geom_point(aes(color = ifelse(kernel_numeric == 100, "red", "blue")), size = 2, shape = 23) +
  geom_errorbar(aes(ymin = mean_recov_ns - se_recov_ns, ymax = mean_recov_ns + se_recov_ns), width = 0.2, color = "blue") +
  geom_line(aes(y = mean_recov_ns, color = "blue", linetype="resting-state"), color = "blue", size = 0.5) +
  scale_x_continuous(breaks = c(1, 2.5, 5, 10, 20, 40, 100, 200), 
                     labels = c("Local \n (each vertex)", " ", " ", " ", "", "40 mm","100 mm\n(Temporal region)", "Global \n (whole-brain)"),
                     expand = c(0,20)) +  # Add a bit of space on the right side
  scale_color_manual(values = c("red" = "red", "blue" = "blue")) +
  guides(color="none", linetype="none") +
  xlab("\n Spatial scale") +
  ylab("Signal Covariance") +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.text.x = element_text(angle = 0, vjust = 1, hjust=0.5, size = 8)) +
  ggtitle("Dependency of correlated part of a signal \nin different spatial scale")

ggsave("/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/keyFigures/dependPlot_ReCov_temporal_WB_lh.png",width = 6, height = 4)
  

