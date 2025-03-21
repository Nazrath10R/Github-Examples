# Rscript predict_ml "nn2501281606" "nn2501281606"

library(dplyr)
library(tidymodels)

# take in arguments from the command line
args <- commandArgs(trailingOnly = TRUE)
model_version <- args[1]
dataset_version <- args[2]

print(paste0("📌 Model version: ", model_version))
print(paste0("📌 Dataset version: ", dataset_version)) 

# Define paths
model_path <- paste0("models/", model_version)
data_path <- paste0("data/", dataset_version, "/")

# Check if model file exists
print(paste0("📂 Checking if model exists: ", model_path))
if (!file.exists(model_path)) {
  stop("❌ ERROR: Model file not found! Check model path and filename.")
}

# Check if required files exist
required_files <- c(
  "qqq_for_aws.csv",
  "srm_table_for_aws.csv",
  "scaling_df_sum.csv",
  "df_design_qqq.csv"
)

found_files <- 0  # Initialize before the loop
# Check if required files exist
for (file in required_files) {
  full_path <- file.path(data_path, paste0(dataset_version, "_", file))
  print(paste0("📂 Checking file: ", full_path))
  
  if (file.exists(full_path)) {
    found_files <- found_files + 1
    print(paste0("✅ Found: ", full_path))
  } else {
    print(paste0("⚠️ Warning: Missing file - ", full_path))
  }
}

# Stop execution if any file is missing
if (found_files != length(required_files)) {
  stop("❌ ERROR: One or more required files are missing!")
}


# Load data
qqq <- read.csv(paste0(data_path, "nn2501281606_qqq_for_aws.csv"))
srm_table <- read.csv(paste0(data_path, "nn2501281606_srm_table_for_aws.csv"))
scaling_df_sum <- read.csv(paste0(data_path, "nn2501281606_scaling_df_sum.csv"))
df_design_qqq <- read.csv(paste0(data_path, "nn2501281606_df_design_qqq.csv"))

print(paste0("✅ Loaded qqq data: ", nrow(qqq), " rows, ", ncol(qqq), " columns"))
print(paste0("✅ Loaded srm_table data: ", nrow(srm_table), " rows, ", ncol(srm_table), " columns"))
print(paste0("✅ Loaded scaling_df_sum data: ", nrow(scaling_df_sum), " rows, ", ncol(scaling_df_sum), " columns"))
print(paste0("✅ Loaded df_design_qqq data: ", nrow(df_design_qqq), " rows, ", ncol(df_design_qqq), " columns"))


## load model
load(model_path)
print(paste0("✅ Loaded Random Forest model: ", model_version))

## Data preperation
feature_list <- unique(qqq[which(qqq$Protein!="ENO1_SPIKE"),]$unique)

print(paste0("📊 Feature List Size: ", length(feature_list)))
if (length(feature_list) == 0) {
  stop("❌ ERROR: No features found! Check dataset preprocessing.")
}


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

missing_features <- setdiff(selected_features, colnames(test_data))
if (length(missing_features) > 0) {
  stop(paste0("❌ ERROR: Missing features in dataset: ", paste(missing_features, collapse = ", ")))
}


# Recipe for preprocessing the full test dataset
test_recipe <- test_data %>%
  recipe(~ ., data = test_data) %>%
  step_select(selected_features) %>%
  prep()

# Extract the test data
processed_test_df <- juice(test_recipe)

# Ensure all factor levels match training data
processed_test_df <- processed_test_df %>%
  mutate(across(where(is.factor), ~ factor(., levels = levels(rf_model$fit$levels))))

print("🔍 processed_test_df preview:")
print(dim(processed_test_df))
print(head(processed_test_df))

print("🧠 RF Model structure:")
print(str(rf_model))

# single_row <- processed_test_df[1, , drop = FALSE]
# print(single_row)

# predict(rf_model, single_row)

# for (col in names(processed_test_df)) {
#   print(paste("🧪", col, ":", class(processed_test_df[[col]])))
#   if (is.factor(processed_test_df[[col]])) {
#     print(levels(processed_test_df[[col]]))
#   }
# }

# Run prediction with error handling
# rf_test_preds <- tryCatch({
#   predict(rf_model, processed_test_df)
# }, error = function(e) {
#   stop(paste0("❌ ERROR in prediction: ", e$message))
# })

# Fix the levels of rf_model$fit$y
if (is.factor(rf_model$fit$y)) {
  if (is.null(attr(rf_model$fit$y, "ordered"))) {
    attr(rf_model$fit$y, "ordered") <- FALSE
  }
}

# str(rf_model$fit$y)

print("🔍 Columns of processed_test_df:")
print(colnames(processed_test_df))

print("🔍 Str of processed_test_df:")
str(processed_test_df)

processed_test_df <- processed_test_df %>%
  mutate(across(everything(), as.numeric))

sapply(processed_test_df, class)

expected_cols <- colnames(rf_model$fit$forest$xlevels)
missing <- setdiff(expected_cols, colnames(processed_test_df))
extra <- setdiff(colnames(processed_test_df), expected_cols)

print(paste("❌ Missing columns:", toString(missing)))
print(paste("⚠️ Extra columns:", toString(extra)))

if (is.null(rf_model$lvl) || length(rf_model$lvl) == 0) {
  rf_model$lvl <- levels(rf_model$fit$y)
}

print("Check rf_model$fit$y class:")
print(class(rf_model$fit$y))
print("Levels:")
print(levels(rf_model$fit$y))

# Monkey patch the model to include a 'post' function that explicitly sets levels
rf_model$spec$method$pred$class$post <- function(result, object) {
  factor(result, levels = object$lvl)
}

print("✅ Predicting using parsnip-wrapped model")
rf_test_preds <- predict(rf_model, new_data = processed_test_df, type = "class")
print(rf_test_preds)


# Check predictions
if (!".pred_class" %in% colnames(rf_test_preds)) {
  stop("❌ ERROR: Model prediction returned unexpected format. Check processed_test_df.")
}

# Prepare the RF predictions dataframe
rf_test_predictions <- data.frame(
  "Sample" = test_data_original$Sample,
  "Disease" = test_data_original$Disease,
  "RF_Predictions" = rf_test_preds$.pred_class
)

# Check if predictions were made
if (nrow(rf_test_predictions) == 0) {
  stop("❌ ERROR: Model produced no predictions!")
} else {
  print(paste0("✅ Model predictions completed. Total predictions: ", nrow(rf_test_predictions)))
}

write.csv(rf_test_predictions, paste0(data_path, "predictions.csv"), row.names = FALSE)

if (file.exists(paste0(data_path, "predictions.csv"))) {
  print("✅ Predictions successfully saved!")
} else {
  stop("❌ ERROR: Failed to save predictions file.")
}
