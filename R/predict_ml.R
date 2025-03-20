
# Rscript predict_ml "nn2501281606" "nn2501281606"

# take in arguments from the command line
args <- commandArgs(trailingOnly = TRUE)
model_version <- args[1]
dataset_version <- args[2]

library(dplyr)
library(tidymodels)

# Define paths
model_path <- paste0("models/", model_version)
data_path <- paste0("data/", dataset_version, "/")

# model_path <- "C:/Users/naz/Documents/Github-Examples/R/models/nn2501281606_rf_model.Rds"
# data_path <- "C:/Users/naz/Documents/Github-Examples/R/data/1/"

# Load data
qqq <- read.csv(paste0(data_path, "nn2501281606_qqq_for_aws.csv"))
srm_table <- read.csv(paste0(data_path, "nn2501281606_srm_table_for_aws.csv"))
scaling_df_sum <- read.csv(paste0(data_path, "nn2501281606_scaling_df_sum.csv"))
df_design_qqq <- read.csv(paste0(data_path, "nn2501281606_df_design_qqq.csv"))


## load model
load(paste0(model_path, "_rf_model.Rds"))

## Data preperation
feature_list <- unique(qqq[which(qqq$Protein!="ENO1_SPIKE"),]$unique)

qqq_df <- qqq %>% select(biomarkerid_z, unique, sample, Fragment, QuantBestarea)
qqq_df$frag_mean_int <- NA

qqq_biomarkerid_z <- unique(qqq_df$biomarkerid_z)
samples <- unique(qqq_df$sample)

qqq_df_mean_frag <- data.frame()

for(x in 1:length(qqq_biomarkerid_z)) {
  
  qqq_df_biomarker_sub <- qqq_df[which(qqq_df$biomarkerid_z == qqq_biomarkerid_z[x]),]
  
  for(y in 1:length(samples)) {
    
    qqq_df_sub <- qqq_df_biomarker_sub[which(qqq_df_biomarker_sub$sample == samples[y]),]
    qqq_df_sub$frag_mean_int <- mean(qqq_df_sub$QuantBestarea)
    qqq_df_sub <- qqq_df_sub %>% select(-Fragment, -QuantBestarea) %>% unique()
    qqq_df_mean_frag <- rbind(qqq_df_mean_frag, qqq_df_sub)
    
  }
}

qqq_df_mean_frag_adj <- qqq_df_mean_frag

for(x in 1:nrow(qqq_df_mean_frag_adj)) {
  
  scaling_factor <- scaling_df_sum[which(scaling_df_sum$biomarkerid_z==qqq_df_mean_frag_adj[x,]$biomarkerid_z),]$scaling
  
  qqq_df_mean_frag_adj[x,]$frag_mean_int <-
    qqq_df_mean_frag_adj[x,]$frag_mean_int * scaling_factor
}

qqq_df_mean_frag <- qqq_df_mean_frag_adj

qqq_df_mean_frag["frag_mean_int"][qqq_df_mean_frag["frag_mean_int"] == 0] <- NA
qqq_df_mean_frag$frag_mean_int <- log2(qqq_df_mean_frag$frag_mean_int)
qqq_df_mean_frag$frag_mean_int[is.na(qqq_df_mean_frag$frag_mean_int)] <- 0

qqq_df_norm <- qqq_df_mean_frag
rownames(qqq_df_norm) <- NULL
qqq_df_norm$biomarkerid_z <- NULL


# transpose this into the same format as dda
test_empty <- as.data.frame(matrix(ncol = length(unique(qqq$unique))+2,
                                   nrow = length(unique(qqq_df_norm$sample))))

colnames(test_empty) <- c("Disease", "Sample", unique(qqq$unique))

test_empty$Sample <- unique(qqq_df_norm$sample)
test_empty$Disease <- df_design_qqq[match(test_empty$Sample, df_design_qqq$AnalysisID),]$disease

for(x in 1:nrow(test_empty)) {
  
  sam <- test_empty[x,]$Sample
  qqq_df_norm_sub <- qqq_df_norm[which(qqq_df_norm$sample==sam),]
  
  for(y in 3:ncol(test_empty)) {
    uni <- colnames(test_empty)[y]
    qqq_df_norm_sub_sub <- qqq_df_norm_sub[which(qqq_df_norm_sub$unique==uni),]
    test_empty[x,y] <- qqq_df_norm_sub_sub$frag_mean_int
  }
}

qqq_test <- test_empty
qqq_test[, 3:ncol(qqq_test)] <- 
  lapply(qqq_test[, 3:ncol(qqq_test)], as.numeric)


qqq_test_scaled <- qqq_test
qqq_eno_ints <- mean(c(qqq_test$NVPLYK.1.21, qqq_test$HLADLSK.1.21,
                       qqq_test$VNQIGTLSESIK.2.21))

for(x in 3:ncol(qqq_test_scaled)) {
  qqq_test_scaled[,x] <- qqq_test_scaled[,x] / qqq_eno_ints
}



test_data <- qqq_test_scaled

test_data_original <- test_data
test_data$Disease <- NULL



# feature list
selected_features=feature_list

# Recipe for preprocessing the full test dataset
test_recipe <- test_data %>%
  recipe(~ ., data = test_data) %>%
  step_select(selected_features) %>%
  prep()

# Extract the test data
processed_test_df <- juice(test_recipe)

# Random Forest predictions
rf_test_preds <- predict(rf_model, processed_test_df)

# Prepare the RF predictions dataframe
rf_test_predictions <- data.frame(
  "Sample" = test_data_original$Sample,
  "Disease" = test_data_original$Disease,
  "RF_Predictions" = rf_test_preds$.pred_class
)

print(paste0("correct predictions: ",
             length(which(rf_test_predictions$Disease==rf_test_predictions$RF_Predictions)),
             " / 12"))

write.csv(rf_test_predictions, paste0(data_path, "predictions.csv"), row.names = FALSE)


print("✅ Predictions saved!")
