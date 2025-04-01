library(tidyverse)
library(here)
library(kableExtra)
library(lme4)
library(lmerTest)
library(broom.mixed)

here::i_am("Code/03_make_table_three.R")

#Loading data

file_path = here("CleanData/long_data.rds")

AllData=readRDS(file_path)

table3data = AllData |> select(c(record_id,intgroup,Timepoint,fogq_total,gfq_total,pdq_39si,pdq_8si,abc_avg,sf12_pcs,sf12_mcs,pase_score_total))

#Function: Fit random intercept linear models for each variable in list(id as random intercept, group, timepoint, and their interaction as fixed effects), extract coefficients, display in table

make_model_table = function(data,outcomes,id_var,group_var,time_var,row_labels) {
  
  
  #Make the model formula for each variable
  results = lapply(outcomes, function(var){
    formula = as.formula(
      paste(var, "~", group_var, "*", time_var, "+ (1|", id_var, ")")
    )
    
    #Fit linear mixed effects model
    
    model = lmer(formula,data)
    
    
    # Extract coefficients and p-values
    tidy_model = broom.mixed::tidy(model,effects="fixed")
    tidy_model$variable = var
    
    #View(tidy_model)
    
    tidy_model = tidy_model |>
      filter(term!="(Intercept)") |>
      select(variable,term,estimate,p.value)
    
    return(tidy_model)
    
  })
  
  
  # Combine all results into a single data frame
  results_df = bind_rows(results)
  
  results_df = results_df |> pivot_wider(
    id_cols=variable,
    names_from = term,
    values_from = c(estimate,p.value)
  )
  
  colnames(results_df) = c("var","group","time","grouptime","group_p","time_p","grouptime_p")
  
  results_df = results_df |> select(var,group,group_p,time,time_p,grouptime,grouptime_p) |>
    mutate(var=row_labels)
  
  #Round to 3 digits
  results_df = results_df |>
    mutate_if(is.numeric,round,digits=3)
  #View(results_df)
  
  # Display as a kable
  results_df %>%
    kable(col.names = c("Variable", "$\\beta_{Group}$", "P-value","$\\beta_{Time}$","P-value","$\\beta_{Group*Time}$","P-value"),
          caption = "Model Coefficients and P-values") %>%
    kable_styling(full_width = FALSE, bootstrap_options = c("striped", "hover"))
}

metrics = table3data |> select(!c(record_id,intgroup,Timepoint)) |> names()

#List of labels for the variables
metric_labels = 
  c("Freezing of Gait Total Score",
    "Gaits and Falls Total Score",
    "PDQ-39 Summary Index Score",
    "PDQ-8 Single Index Score",
    "ABC Average Score",
    "SF12 Physical Component Summary",
    "SF12 Mental Component Summary",
    "PASE Total Score"
  )

table_three = make_model_table(table3data,metrics,"record_id","intgroup","Timepoint",metric_labels)    


saveRDS(table_three,file=here("Outputs/table_three.rds"))
