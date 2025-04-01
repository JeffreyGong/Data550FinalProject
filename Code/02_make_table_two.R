library(tidyverse)
library(here)
library(kableExtra)

here::i_am("Code/02_make_table_two.R")

#Loading data

file_path = here("CleanData/wide_data_clean.rds")
wide_data_clean=readRDS(file_path)


#Creating subsets of data for specific tables/graphs
table2data = wide_data_clean |> select(c(intgroup,ipa_tot,bdi_total_score,fogq_total_Pre,fogq_total_Post,gfq_total_Pre,gfq_total_Post,pdq_39si_Pre,pdq_39si_Post,pdq_8si_Pre,pdq_8si_Post,abc_avg_Pre,abc_avg_Post,sf12_pcs_Pre,sf12_pcs_Post,sf12_mcs_Pre,sf12_mcs_Post,pase_score_total_Pre,pase_score_total_Post))

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

# function to create tables
Group.tables = function(data, stratify, remove, tableName) {
  # includes inputs for columns to stratify and to remove
  t = arsenal::tableby(stratify~.,data = data |> select(-remove),control = c(numeric.stats="meansd")) |> summary(digits = 1, digits.p = 2, digits.pct = 0) |> as.data.frame()
  # reformat a little
  t[,1] = t[,1] |>
    str_remove_all("&nbsp;&nbsp;&nbsp;")
  t[t=="NA"] = ""
  
  colnames(t)[1] = "Metric"
  
  
  #Pull the variable names down onto the same column as Mean(SD)  
  t = t |>
    mutate(Metric=if_else(str_detect(Metric,"Mean"),lag(Metric),Metric)) |>
    filter(`p value`=="") |> select(!`p value`)
  
  #Get Timepoint into its own column 
  t = t |>
    mutate(Timepoint=case_when(str_detect(Metric,"_Pre") ~ "Pre",
                               str_detect(Metric,"_Post") ~ "Post",
                               .default = "")) |> relocate(Timepoint,.after=Metric)
  
  #Delete redudant timepoint info, redundant variable names
  t = t |>
    mutate(Metric=case_when(str_detect(Metric,"_Pre") ~ gsub("_Pre","",Metric,fixed=TRUE),
                            str_detect(Metric,"_Post") ~ "",
                            .default = Metric))
  
  # print
  
  kable_output = kableExtra::kable(t) |> kableExtra::kable_classic() |> kable_styling()
  
  return(kable_output)
}


add_pre_post= function(input_list) {
  # Apply suffixes "_Pre" and "_Post" to each string in the input list
  output_list <- unlist(lapply(input_list, function(x) c(paste0(x, "_Pre"), paste0(x, "_Post"))))
  
  return(output_list)
}

metric_labels_pre_post = add_pre_post(metric_labels)

names(table2data) = c(
  "intgroup",
  "Impact on Participation and Autonomy Total Score",
  "Beck Depression Inventory Score",
  metric_labels_pre_post
)

table_two = Group.tables(table2data,table2data$intgroup,c("intgroup"),"Table 2")

saveRDS(table_two,file=here("Outputs/table_two.rds"))
