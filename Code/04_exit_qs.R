library(tidyverse)
library(here)
library(likert)

here::i_am("Code/02_make_table_two.R")

#Loading data

file_path = here("CleanData/wide_data_clean.rds")
wide_data_clean=readRDS(file_path)

#Function for making a likert divergence plot

#Arguments:
#data --> a tibble with likert scale responses as strings(assuming the variables come with a timepoint suffix)
#questions--> a list of the questionnaire items, in the same order as the variables above
#timepoint --> a string of the timepoint you want(the suffix of the variables you want)
#group --> a string of the intervention group you want

likert_divergence = function(data,questions,timepoint,group=NA,numlevels=7) {
  
  likert_data = data 
  
  #If there is a group argument filter for group
  if(!is.na(group))
  {
    likert_data = filter(likert_data,intgroup==group)
  }
  
  #If there is timepoint argument filter for timepoint
  if(!is.na(timepoint))
  {
    likert_data = select(likert_data,ends_with(timepoint))
  }
  else{
    likert_data=select(likert_data,!c(record_id,intgroup))
  }
  
  #Convert into factor
  
  if(numlevels==7)
  {
    likert_data = likert_data |>
      lapply(factor, levels = c(
        "Strongly disagree", "Disagree", "Somewhat disagree", "Neither disagree nor agree", "Somewhat agree", "Agree", "Strongly agree"
      )) |>
      data.frame()
  }
  else if(numlevels==5)
  {
    likert_data = likert_data |>
      lapply(factor, levels = c(
        "Strongly disagree", "Somewhat disagree", "Neither disagree nor agree", "Somewhat agree", "Strongly agree"
      )) |>
      data.frame()
  }
  else
  {
    return("Error, number of levels not supported")
  }
  
  #Convert variable names into meaningful names
  colnames(likert_data) = questions
  
  #Make the divergence plot for pre questionnaires
  likert_data_plot = likert(likert_data)
  
  p = plot(likert_data_plot, plot.percents = FALSE, group.order=questions, ordered=FALSE, legend.position = "top")
  return(p)
}

#Visualizing exit survey responses

#Get the exit questionnaire responses
exit_qs = wide_data_clean |> 
  select(starts_with("exit"),record_id,intgroup) # |> 
 # select(!(exit_studyguide:exit_13))

#Recode numbers into meaningful strings
exit_qs_likert = exit_qs |>
  mutate(across(starts_with("exit"), ~ case_when(
    . == 1 ~ "Strongly agree",
    . == 2 ~ "Somewhat agree",
    . == 3 ~ "Neither disagree nor agree",
    . == 4 ~ "Somewhat disagree",
    . == 5 ~ "Strongly disagree"
  )))



exit_question_list = c("I enjoyed participating in this program.", "My balance has improved.", 
                       "My walking has improved.", 
                       "My mood has improved.", "My coordination has improved.", 
                       "My strength has improved.", "My endurance has improved.", 
                       "I would continue participating.", "I have been more physically active.", 
                       "I have been more mentally active.")

exit_plot = likert_divergence(exit_qs_likert,exit_question_list,NA,numlevels=5)


saveRDS(exit_plot,file=here("Outputs/exit_plot.rds"))
