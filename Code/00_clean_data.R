library(tidyverse)
library(here)

here::i_am("Code/00_clean_data.R")

#Loading data

file_path = here("Data/QuestionnaireData.rds")

AllData=readRDS(file_path)

#Making a timepoint variable
AllData = AllData |> mutate(Timepoint = case_match(redcap_event_name,"pre_questionnaires_arm_1"~"Pre","post_questionnaire_arm_1"~"Post")) |>
  mutate(Timepoint = factor(Timepoint,levels=c("Pre","Post")))

#Getting the treatment group variable onto the questionnaire data rows
AllData = AllData |>
  group_by(record_id) |>
  mutate(treatgroup = max(treatgroup,na.rm=TRUE)) |>
  ungroup() |>
  filter(!redcap_event_name=="randomization_arm_1")


#Getting the height/weight variables onto the questionnaire data rows
AllData = AllData |>
  group_by(record_id) |>
  mutate(height = if_else(Timepoint=="Pre",max(height,na.rm=TRUE),NA)) |>
  mutate(weight = if_else(Timepoint=="Pre",max(weight,na.rm=TRUE),NA)) |>
  ungroup() |>
  filter(!redcap_event_name=="pre_assessment_arm_1")

#Fixing -Inf in height and weight columns
AllData$height[AllData$height==-Inf] = NA
AllData$weight[AllData$weight==-Inf] = NA

#Correcting the missing intervention group for MST501
AllData[AllData$record_id=="MST501","treatgroup"] = 1

#Recoding treatgroup
AllData = AllData |> mutate(intgroup = case_match(treatgroup,1 ~ 'Isolated',2~'Coupled'))

saveRDS(AllData,file=here("CleanData/long_data.rds"))


#Pivoting wider
values = AllData |> select(!(record_id:redcap_repeat_instance|c(intgroup,Timepoint))) |> names()

wide_data = AllData |>
  pivot_wider(
    names_from = Timepoint,
    values_from = values,
    id_cols=c(record_id,intgroup)
  )

#Cleaning up the tibble

wide_data_clean = wide_data |>
  mutate(across(where(is.character),~ na_if(.x,""))) #Replace empty cells with NA

na_columns = wide_data_clean |> 
  select(where(~all(is.na(.)))) |> colnames() #Identify all columns with all NA


wide_data_clean = wide_data |> select(-all_of(na_columns)) #Remove all columns with only NA

single_columns = wide_data |> select(all_of(na_columns)) |> select(ends_with("_Post")) |> colnames() #Find all of the removed columns that are _Post


pre_to_rename = gsub("_Post$","_Pre",single_columns) #Identify the columns to remove the _Pre from


wide_data_clean = wide_data_clean |> 
  rename_with(~ gsub("_Pre$","",.x) , .cols = any_of(pre_to_rename)) #Remove _Pre from columns where the _Post has been removed

wide_data_clean = wide_data_clean |> 
  rename_with(~ gsub("_Post$","",.x) , .cols = starts_with("exit")) #Remove _Post from the exit survey variables, since there is no Pre from them


#Recoding variables from numbers to descriptive strings

wide_data_clean = wide_data_clean |> mutate(gender = case_match(gender, 1 ~ "Male",2 ~ "Female"))

wide_data_clean = wide_data_clean |> mutate( marital_status = case_match(marital_status,1~"Single",2~"Married/Partner",3~"Separate/Divorced",4~"Widowed"))

wide_data_clean = wide_data_clean |> mutate(education = case_match(education,1~"No formal education",2~"Less than high school graduate",3~"High school graduate/GED",4~"Vocational training",5~"Some college/Associate's degree",6~"Bachelor's degree",7~"Master's degree",8~"Doctoral degree"))

wide_data_clean = wide_data_clean |> mutate( ethnic_background = case_match(ethnic_background, 1~"Hispanic/Latino/Spanish",2~"Not Hispanic/Latino/Spanish",3~"Other",4~"Prefer not to say"))

wide_data_clean = wide_data_clean |> mutate( leave_the_house = case_match(leave_the_house,1~"Less than once/week",2~"1-2 times/week",3~"3-4 times/week",4~"Every day"))

wide_data_clean = wide_data_clean |> mutate( side_onset = case_match(side_onset,1~"Left",2~"Right",3~"Bilateral"))



#For race make a new variable, if more than one was checked = multiracial

wide_data_clean$multiracial = wide_data_clean |> select(racial_background___1:racial_background___7) |> rowSums() 

wide_data_clean = wide_data_clean |> mutate(racial_background = case_when(
  multiracial > 1 ~ "Multiracial",
  racial_background___1 == 1 ~ "Black/African-American",
  racial_background___2 == 1 ~ "Asian",
  racial_background___3 == 1 ~ "Native Hawaiian or Pacific Islander",
  racial_background___4 == 1 ~ "Native American",
  racial_background___5 == 1 ~ "White/Caucasian",
  racial_background___7 == 1 ~ "Other"
))


wide_data_clean = wide_data_clean |> relocate(racial_background,.before = racial_background___1) |> select(!racial_background___1:racial_background___7)

saveRDS(wide_data_clean,file=here("CleanData/wide_data_clean.rds"))


