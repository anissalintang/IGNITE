## This code is to make plot of ReCov and GCOV for different kernels from brainStates

library(dplyr)
library(ggplot2)
library(scales)  # for logarithmic scales
library(ggpubr)  # for drawing lines between points
library(nls2)

## Clear variables from workspace
rm(list = setdiff(ls(), lsf.str()))

# Define the directory paths for ReHo and Gcor files
recov_directory <- "/Volumes/gdrive4tb/brainStates/AnissaSurfaceAnalysis_new/ReHo"
gcov_directory <- "/Volumes/gdrive4tb/brainStates/AnissaSurfaceAnalysis_new/GCOR"

# Define the list of subjects
subjects <- c('sub-01', 'sub-02', 'sub-03', 'sub-04', 'sub-05', 'sub-06', 'sub-07', 'sub-08', 'sub-09', 'sub-10', 'sub-11')

# Create empty data frames for each area
dat_temporal <- data.frame()

# Loop through the subject folders
for (subject in subjects) {
  # Loop through the main folders
  for (main_folder in c(recov_directory, gcov_directory)) {
    # Set the path to the meanValues subfolder for the current subject and main folder
    meanValues_path <- paste0(main_folder, "/meanValues/", subject)
    
    # Get the list of files in the meanValues subfolder
    file_list <- list.files(meanValues_path)
    
    # Loop through the files
    for (file_name in file_list) {
      
      # Check if the file name contains "temporal"
      if (grepl("temporal", file_name)) {
        # Read the file using readLines()
        file_path <- paste0(meanValues_path, "/", file_name)
        lines <- readLines(file_path)
        
        # Extract decimal value from the text
        decimal_value <- as.numeric(lines[grep("\\d+\\.\\d+", lines)])
        
        # Extract relevant information from the file name
        condition <- gsub("sub-\\d+_(\\w+)_temporal_(\\w+)\\.txt", "\\1_\\2", file_name)
        
        column_name <- condition
        
        # Add the data to the dataframe
        dat_temporal[subject,column_name] = decimal_value
        
      }
    }
  }
}

## ---------------------------------------------------------------------------------------------
## New dataframe for plotting of temporal lh
## ---------------------------------------------------------------------------------------------
wb_lh <- grep("lh", colnames(dat_temporal), value = TRUE)

dat_temporal_lh <- dat_temporal[,wb_lh]

# Subset the columns for ReHo and GCOR with the desired pattern
reho_ns_columns <- grep("^ReHo_ns", names(dat_temporal_lh), value = TRUE)
gcor_ns_columns <- grep("^GCOR_ns", names(dat_temporal_lh), value = TRUE)

reho_as_columns <- grep("^ReHo_as", names(dat_temporal_lh), value = TRUE)
gcor_as_columns <- grep("^GCOR_as", names(dat_temporal_lh), value = TRUE)

reho_vs_columns <- grep("^ReHo_vs", names(dat_temporal_lh), value = TRUE)
gcor_vs_columns <- grep("^GCOR_vs", names(dat_temporal_lh), value = TRUE)

# Set the kernel values
kernels <- c(2.5, 5, 10, 20, 40)

# Create a data frame with the kernel values and corresponding means and standard errors
mean_reho_ns = colMeans(dat_temporal_lh[, reho_ns_columns], na.rm = TRUE)
mean_gcor_ns = mean(dat_temporal_lh[, gcor_ns_columns], na.rm = TRUE)

mean_reho_as = colMeans(dat_temporal_lh[, reho_as_columns], na.rm = TRUE)
mean_gcor_as = mean(dat_temporal_lh[, gcor_as_columns], na.rm = TRUE)

mean_reho_vs = colMeans(dat_temporal_lh[, reho_vs_columns], na.rm = TRUE)
mean_gcor_vs = mean(dat_temporal_lh[, gcor_vs_columns], na.rm = TRUE)

se_reho_ns = apply(dat_temporal_lh[, reho_ns_columns], 2, function(x) sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x))))
se_gcor_ns = sd(dat_temporal_lh[, gcor_ns_columns]) / sqrt(length(dat_temporal_lh[, gcor_ns_columns]))

se_reho_as = apply(dat_temporal_lh[, reho_as_columns], 2, function(x) sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x))))
se_gcor_as = sd(dat_temporal_lh[, gcor_as_columns]) / sqrt(length(dat_temporal_lh[, gcor_as_columns]))

se_reho_vs = apply(dat_temporal_lh[, reho_vs_columns], 2, function(x) sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x))))
se_gcor_vs = sd(dat_temporal_lh[, gcor_vs_columns]) / sqrt(length(dat_temporal_lh[, gcor_vs_columns]))



# Create a dataframe with the data for plotting
plot_data <- data.frame(
  kernel = c("1","2.5", "5", "10", "20", "40", "GCOR"),
  mean_reho_ns = c(1, mean_reho_ns["ReHo_ns_lh_2_5"], mean_reho_ns["ReHo_ns_lh_5"], mean_reho_ns["ReHo_ns_lh_10"],
                   mean_reho_ns["ReHo_ns_lh_20"], mean_reho_ns["ReHo_ns_lh_40"], mean_gcor_ns),
  mean_reho_as = c(1, mean_reho_as["ReHo_as_lh_2_5"], mean_reho_as["ReHo_as_lh_5"], mean_reho_as["ReHo_as_lh_10"],
                   mean_reho_as["ReHo_as_lh_20"], mean_reho_as["ReHo_as_lh_40"], mean_gcor_as),
  mean_reho_vs = c(1, mean_reho_vs["ReHo_vs_lh_2_5"], mean_reho_vs["ReHo_vs_lh_5"], mean_reho_vs["ReHo_vs_lh_10"],
                   mean_reho_vs["ReHo_vs_lh_20"], mean_reho_vs["ReHo_vs_lh_40"], mean_gcor_vs),
  se_reho_ns = c(0, se_reho_ns["ReHo_ns_lh_2_5"], se_reho_ns["ReHo_ns_lh_5"], se_reho_ns["ReHo_ns_lh_10"],
                 se_reho_ns["ReHo_ns_lh_20"], se_reho_ns["ReHo_ns_lh_40"], se_gcor_ns),
  se_reho_as = c(0, se_reho_as["ReHo_as_lh_2_5"], se_reho_as["ReHo_as_lh_5"], se_reho_as["ReHo_as_lh_10"],
                 se_reho_as["ReHo_as_lh_20"], se_reho_as["ReHo_as_lh_40"], se_gcor_as),
  se_reho_vs = c(0, se_reho_vs["ReHo_vs_lh_2_5"], se_reho_vs["ReHo_vs_lh_5"], se_reho_vs["ReHo_vs_lh_10"],
                 se_reho_vs["ReHo_vs_lh_20"], se_reho_vs["ReHo_vs_lh_40"], se_gcor_vs))

plot_data$kernel <- factor(plot_data$kernel, levels = c("1","2.5", "5", "10", "20", "40", "GCOR"))

# Modify the 'kernel' variable to be numeric
plot_data <- plot_data %>%
  mutate(kernel = as.character(kernel),  # Convert factor to character
         kernel_numeric = case_when(
           kernel == "1"    ~ 1,
           kernel == "2.5"    ~ 2.5,
           kernel == "5"      ~ 5,
           kernel == "10"     ~ 10,
           kernel == "20"     ~ 20,
           kernel == "40"     ~ 40,
           kernel == "GCOR"   ~ 200
         ))

# Create the plot
ggplot(plot_data, aes(x = kernel_numeric, group = 1)) +
  geom_point(aes(y = mean_reho_ns), color = "black", size = 2, shape = 23, fill = "black") +
  geom_point(aes(y = mean_reho_as), color = "red", size = 2, shape = 23, fill = "red") +
  # geom_point(aes(y = mean_reho_vs), color = "blue", size = 2, shape = 23, fill = "blue") +
  
  geom_errorbar(aes(ymin = mean_reho_ns - se_reho_ns, ymax = mean_reho_ns + se_reho_ns), width = 0.2, color = "black") +
  geom_errorbar(aes(ymin = mean_reho_as - se_reho_as, ymax = mean_reho_as + se_reho_as), width = 0.2, color = "red") +
  # geom_errorbar(aes(ymin = mean_reho_vs - se_reho_vs, ymax = mean_reho_vs + se_reho_vs), width = 0.2, color = "blue") +
  
  geom_line(aes(y = mean_reho_ns, color = "resting-state"), linewidth = 0.5) +
  geom_line(aes(y = mean_reho_as, color = "acoustic stimulus"), linewidth = 0.5) +
  # geom_line(aes(y = mean_reho_vs, color = "blue"), color = "blue", linewidth = 0.5) +
  
  scale_color_manual(values = c("resting-state" = "black", "acoustic stimulus" = "red")) +
  scale_x_continuous(breaks = c(1, 2.5, 5, 10, 20, 40, 100, 200), 
                     labels = c("Local \n (each vertex)", " " , " ", " ", "", "40 mm","100 mm\n(Temporal region)", "Global \n (whole-brain)"),
                     expand = c(0,20)) +  # Add a bit of space on the right side
  guides(linetype="none") +
  xlab("\n Spatial scale") +
  ylab("Signal Correlation") +
  ggtitle("Auditory region - left hemisphere") +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.text.x = element_text(angle = 0, vjust = 1, hjust=0.5, size = 6),
        legend.margin = margin(r = 10, l = 0, unit = "mm"),
        legend.title = element_text(size=6),
        legend.text = element_text(size=6),
        axis.title.x = element_text(size=7),
        axis.title.y = element_text(size=7),
        axis.text.y = element_text(size=6),
        legend.position = "bottom") + 
  labs(color = "Condition")




################################################################################

## Adding ReHo data from IGNITE sparse rest

################################################################################
# Define the directory paths
reho_directory_ignite <- "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/temporal"

# Define the list of subjects
#subjects <- list.files(path = "/Volumes/gdrive4tb/IGNITE/sparse_rest/preprocessed", full.names = FALSE, recursive = FALSE)
subjects <- c("IGNTFA_00065", "IGNTBR_00075", "IGNTCA_00067", "IGNTCK_00066", "IGNTFM_00060", "IGNTGS_00049", "IGNTIV_00045", "IGNTLX_00069", "IGNTMN_00051", "IGNTNF_00054", "IGNTOH_00059", "IGNTPO_00071", "IGTTFJ_00074",  "IGTTKA_00017", "IGTTRK_00006")

# Create empty data frames for each area
dat_wholeBrain_ignite <- data.frame()

# Loop through the subject folders
for (subject in subjects) {
  # Loop through the main folders
  for (main_folder in reho_directory_ignite) {
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
        condition <- sub(".*_(rh_ReHo_rest|lh_ReHo_rest).*\\.txt", "\\1", file_name)
        
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
colnames(dat_wholeBrain_ignite_lh)[colnames(dat_wholeBrain_ignite_lh) == "dat_wholeBrain_ignite[, wb_lh]"] <- "lh_ReHo_rest"

# Subset the columns for ReHo with the desired pattern
reho_rest_columns <- grep("^lh_ReHo_rest", names(dat_wholeBrain_ignite), value = TRUE)

# Set the kernel values
kernels <- c(100)

# Create a data frame with the kernel values and corresponding means and standard errors
mean_reho_ns = mean(dat_wholeBrain_ignite_lh[, reho_rest_columns], na.rm = TRUE)
se_reho_ns = sd(dat_wholeBrain_ignite_lh[, reho_rest_columns]) / sqrt(length(dat_wholeBrain_ignite_lh[, reho_rest_columns]))


# Create a dataframe with the data for plotting
plot_data_ignite <- data.frame(
  kernel = "100",
  mean_reho_ns = mean_reho_ns,
  se_reho_ns = se_reho_ns)




################################################################################

## PLOT ReHo

################################################################################
# Ensure that plot_data_ignite has the same columns as plot_data
plot_data_ignite$kernel_numeric <- 100

# Combine the two data frames
combined_plot_data <- rbind(plot_data, plot_data_ignite)


ggplot(combined_plot_data, aes(x = kernel_numeric, y = mean_reho_ns, group = 1)) +
  geom_point(aes(color = ifelse(kernel_numeric == 100, "red", "blue")), size = 2, shape = 23) +
  geom_errorbar(aes(ymin = mean_reho_ns - se_reho_ns, ymax = mean_reho_ns + se_reho_ns), width = 0.2, color = "blue") +
  geom_line(aes(y = mean_reho_ns, color = "blue", linetype="resting-state"), color = "blue", size = 0.5) +
  scale_x_continuous(breaks = c(1, 2.5, 5, 10, 20, 40, 100, 200), 
                     labels = c("Local \n (each vertex)", " " , " ", " ", "", "40 mm","100 mm\n(Temporal region)", "Global \n (whole-brain)"),
                     expand = c(0,20)) +  # Add a bit of space on the right side
  scale_color_manual(values = c("red" = "red", "blue" = "blue")) +
  guides(color="none", linetype="none") +
  xlab("\n Spatial scale") +
  ylab("Signal Correlation") +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.text.x = element_text(angle = 0, vjust = 1, hjust=0.5, size = 8)) +
  ggtitle("Dependency of correlated part of a signal \nin different spatial scale")







# Remove the 100mm data point
combined_data <- combined_plot_data[!combined_plot_data$kernel == '100', ]

# Add data point (0,1)
combined_data <- rbind(combined_data, data.frame(kernel = 0, mean_reho_ns = 1, se_reho_ns = 0, kernel_numeric = 0))

# Fit the exponential model with different start values
#fit_subset <- nls(mean_reho_ns ~ a*exp(-b*kernel_numeric) + c, data = combined_data, start = list(a = max(combined_data$mean_reho_ns), b = 0.1, c = min(combined_data$mean_reho_ns)))

fit_subset <- nls(mean_reho_ns ~ a*exp(-b*kernel_numeric^c) + d,
               data = combined_data,
               start = list(a = max(combined_data$mean_reho_ns), b = 0.05, c = 1, d = min(combined_data$mean_reho_ns)))

fit_subset <- nls(mean_reho_ns ~ exp(-kernel_numeric/rho), data = combined_data, start = list(rho = 1))

(rho_estimated <- coef(fit_subset)["rho"])
(half_width <- -rho_estimated * log(0.5))


# Generate a sequence for smoother plotting
smooth_kernel = seq(min(combined_data$kernel_numeric), max(combined_data$kernel_numeric), by = 0.1)
predicted_values = predict(fit_subset, newdata = data.frame(kernel_numeric = smooth_kernel))

# Plot the original data points along with the smoother curve
ggplot(combined_plot_data, aes(x = kernel_numeric, y = mean_reho_ns)) +
  geom_point(aes(color = ifelse(kernel_numeric == 100, "red", "blue")), size = 2, shape = 23) +
  geom_errorbar(aes(ymin = mean_reho_ns - se_reho_ns, ymax = mean_reho_ns + se_reho_ns), width = 0.2, color = "blue") +
  geom_line(data = data.frame(kernel_numeric = smooth_kernel, mean_reho_ns = predicted_values), aes(x = kernel_numeric, y = mean_reho_ns, color = "blue", linetype="resting-state"), size = 0.5) +
  # Formatting and Labels
  scale_x_continuous(breaks = c(0, 2.5, 5, 10, 20, 40, 100, 200), 
                     labels = c("0", " ", " ", " ", "", "40 mm","100 mm\n(Temporal region)", "Global \n (whole-brain)"),
                     expand = c(0,20)) +
  scale_color_manual(values = c("red" = "red", "blue" = "blue")) +
  guides(color="none") +
  xlab("\n Spatial scale") +
  ylab("Signal Correlation") +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.text.x = element_text(angle = 0, vjust = 1, hjust=0.5, size = 8)) +
  # Add the vertical dashed line representing half-width on x-axis
  geom_vline(xintercept = half_width, linetype="dashed", color = "blue", size = 0.5) + 
  # Add the horizontal dashed line representing correlation of 0.5 on y-axis
  geom_hline(yintercept = 0.5, linetype="dashed", color = "blue", size = 0.5) + 
  ggtitle("Dependency of correlated part of a signal \nin different spatial scale")


# Use ggplot2 to create the plot
ggplot(combined_plot_data, aes(x = kernel_numeric, y = mean_reho_ns)) +
  geom_point(aes(color = ifelse(kernel_numeric == 100, "red", "blue")), size = 2, shape = 23) +
  geom_errorbar(aes(ymin = mean_reho_ns - se_reho_ns, ymax = mean_reho_ns + se_reho_ns), width = 0.2, color = "blue") +
  geom_line(data = data.frame(kernel_numeric = smooth_kernel, mean_reho_ns = predicted_values), aes(x = kernel_numeric, y = mean_reho_ns, color = "blue", linetype="resting-state"), size = 0.5) +
  geom_segment(aes(x = half_width, y = -Inf, xend = half_width, yend = 0.5), linetype="dashed", color = "blue", size = 0.5) +
  geom_segment(aes(x = -Inf, y = 0.5, xend = half_width, yend = 0.5), linetype="dashed", color = "blue", size = 0.5) +
  # Adding the text next to the intersection
  annotate("text", x = half_width + 5, y = 0.5, label = "half-width at 14.22 mm", color = "blue", hjust = 0, vjust = -1) +
  scale_x_continuous(breaks = c(0, 2.5, 5, 10, 20, 40, 100, 200), 
                     labels = c("0", " ", " ", " ", "", "40 mm","100 mm\n(Temporal region)", "Global \n (whole-brain)"),
                     expand = c(0,20)) +
  scale_color_manual(values = c("red" = "red", "blue" = "blue")) +
  guides(color="none") +
  xlab("\n Spatial scale") +
  ylab("Signal Correlation") +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.text.x = element_text(angle = 0, vjust = 1, hjust=0.5, size = 8)) +
  ggtitle("Dependency of correlated part of a signal \nin different spatial scale")






#ggsave("/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/keyFigures/dependPlot_ReHo_temporal_WB_lh.png",width = 6, height = 4)
  

