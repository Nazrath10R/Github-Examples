# setwd("Github-Examples/")

# Load CSV file
data <- read.csv("data/example.csv")

# Count number of unique biomarkers
num_unique_biomarkers <- length(unique(data$BiomarkerId))
cat("Number of unique biomarkers:", num_unique_biomarkers, "\n")

# Count missing values per column
missing_counts <- length(which(is.na(data$QuantBestarea)))
cat("Missing intensities:\n")
print(missing_counts)

# Summary statistics for numeric columns
summary_stats <- summary(data$QuantBestarea)
cat("Summary statistics of intensities:\n")
print(summary_stats)

# Create a subset of the data
subset_data <- data[which(data$BiomarkerId == 204306), ]
write.csv(subset_data, "data/subset_example.csv", row.names = FALSE)
cat("Subset CSV file created: data/subset_example.csv\n")

# Fail the workflow if there are less than 5 unique biomarkers
if (num_unique_biomarkers < 5) {
  stop("Error: Less than 5 unique biomarkers found! Failing the workflow.")
}
