library(tidyverse)
library(here)
library(table1)

here::i_am("Code/01_make_table_one.R")

#Loading data

file_path = here("CleanData/wide_data_clean.rds")
wide_data_clean=readRDS(file_path)


#Labeling variables for the table
table1::label(wide_data_clean$gender) = "Gender"

table1::label(wide_data_clean$age) = "Age"
units(wide_data_clean$age) = "years"

table1::label(wide_data_clean$height)="Height"
units(wide_data_clean$height) = "m"

table1::label(wide_data_clean$weight)="Weight"
units(wide_data_clean$weight) = "kg"

table1::label(wide_data_clean$pd_years)="PD Dx (y)"

table1::label(wide_data_clean$ed_y) = "Education (y)"

table1::label(wide_data_clean$racial_background) = "Racial Background"

table1::label(wide_data_clean$num_comorbids) = "Comorbidities (#)"

table1::label(wide_data_clean$falls_1_year) = "Falls Past Year (#)"


table1data = wide_data_clean

#Footnote for the table
footnotes = c("For categorical variables: n(%)","SD--> Standard Deviation")

table_one = table1(~age+height+weight+gender+racial_background+pd_years+ed_y+num_comorbids+falls_1_year|intgroup,data=table1data,caption="Table 1: Participant demographics and physical characteristics",footnote=footnotes)

saveRDS(table_one,file=here("Outputs/table_one.rds"))
