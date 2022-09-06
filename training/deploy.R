# optparse for arguments passed by AzureML job
library(optparse)

#Packages required for EDA and training
library(tidyverse)
library(caret)
library(randomForest)

#code added
library(azuremlsdk)
library(jsonlite)

ws <- load_workspace_from_config()
ws$location

model <- get_model(ws, name = "rmodel")
#model <- file.path(Sys.getenv("AZUREML_MODEL_DIR"), "model.rds")


r_env <- r_environment(name = "deploy_env",custom_docker_image="rocker/tidyverse:latest")

inference_config <- inference_config(
  entry_script = "score.R",
  source_directory = ".",
  environment = r_env)

# Create ACI deployment config
deployment_config <- aci_webservice_deployment_config(cpu_cores = 1,
                                                      memory_gb = 1)
service_name <- "rmode213"
service <- deploy_model(ws, 
                        service_name, 
                        list(model), 
                        inference_config, 
                        deployment_config)
wait_for_deployment(service, show_output = TRUE)


# local_deployment_config <- local_webservice_deployment_config()
# service <- deploy_model(ws, 
#                         service_name, 
#                         list(model), 
#                         inference_config, 
#                         local_deployment_config )