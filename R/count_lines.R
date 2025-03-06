# setwd("Github-Examples/")

# Load CSV file
data <- read.csv("data/example.csv")

# Count number of unique biomarkers
num_unique_biomarkers <- length(unique(data$BiomarkerId))
cat("Number of unique biomarkers:", num_unique_biomarkers, "\n")
