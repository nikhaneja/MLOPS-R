# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

library(jsonlite)
print("in score.R file")
init <- function()
{
  print("in init function")
  # model_path <- Sys.getenv("AZUREML_MODEL_DIR")
  # print(model_path)
  print("trying to load model")
  modell <- readRDS("model.rds")
  #model <- readRDS(file.path(model_path, "model.rds"))
  message("model is loaded")
  
  function(data)
  {
    print("in data function")
    plant <- as.data.frame(fromJSON(data))
    prediction <- predict(modell, plant)
    result <- as.character(prediction)
    toJSON(result)
  }
}
