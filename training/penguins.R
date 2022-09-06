# optparse for arguments passed by AzureML job
library(optparse)

#Packages required for EDA and training
library(tidyverse)
library(caret)
library(randomForest)

#code added
library(azuremlsdk)

loaded_ws <- load_workspace_from_config()
loaded_ws$location

ds <- get_default_datastore(loaded_ws)

download_from_datastore(ds, target_path=".", prefix="penguins")


# sp_auth <- service_principal_authentication(
#   tenant_id = "abaf275e-b740-4c4f-a7b8-c4e129fd72a3",
#   service_principal_id = "783b5f42-2743-4b12-aeae-4811ed4ec59b",
#   service_principal_password = "CBW8Q~oqId5ysXnRBukWxEVkG8y6GfJyUInw4a6O" )
# ws <- get_workspace( "poc-workspace",
#                      subscription_id = "37c36dbc-0442-420d-a7a5-caf5ddf7cea3", 
#                      resource_group = "ML-POC",
#                      auth = sp_auth )
# ws$location
# Parse input arguments from AzureML job
# options <- list(
#   make_option(c("-d", "--data_folder"), default="./data")
# )
# opt_parser <- OptionParser(option_list = options)
# opt <- parse_args(opt_parser)

# Single argument passed is the path to the mounted data folder. Read in the penguins dataset.
penguins <- read.csv(file.path("./penguins", "penguins.csv"), header=TRUE)

# Sample factor features in the data
penguins %>%
  dplyr::select(where(is.factor)) %>%
  glimpse()

# Count penguins for each species / island
penguins %>%
  count(species, island, .drop = FALSE)

# Count penguins for each species / sex
penguins %>%
  count(species, sex, .drop = FALSE)

# Sample numeric features in the data
penguins %>%
  dplyr::select(body_mass_g, ends_with("_mm")) %>%
  glimpse()

# Train a random forest model to predict sex of the penguin by all other features
split <- createDataPartition(penguins$sex, p = 0.8, list = FALSE)

test <- penguins[-split,] # Save 20% of data for test validation here
train <- penguins[split,] # 80% of data 

# Fro training, use 10-fold cross-validation maximizing accuracy
control <- trainControl(method="cv", number=10)
metric <- "Accuracy"

# Train model
set.seed(123)
fit.rf <- train(sex~., data=train, method="rf", metric=metric, trControl=control)

# Model output
print(fit.rf)

# Get predictions
predictions <- predict(fit.rf, test)

# Get confusion matrix
confMat <- confusionMatrix(predictions, as.factor(test$sex))
print(confMat)

# Create ./outputs directory and save any model artifacts to it.
# Anything in ./outputs will be uploaded to the AzureML experiment
output_dir = "outputs"
if (!dir.exists(output_dir)){
  dir.create(output_dir)
}
saveRDS(fit.rf, file = "./outputs/model.rds")
message("Model saved")