Data550_FinalProject_QuestionnaireReport.html: Code/05_render_report.R \
Data550_FinalProject_QuestionnaireReport.Rmd Outputs/table_one.rds Outputs/table_two.rds Outputs/table_three.rds Outputs/exit_plot.rds
	Rscript Code/05_render_report.R

CleanData/wide_data_clean.rds CleanData/long_data.rds&: \
	Code/00_clean_data.R Data/QuestionnaireData.rds
	Rscript Code/00_clean_data.R
	
Outputs/table_one.rds: Code/01_make_table_one.R CleanData/wide_data_clean.rds
	Rscript Code/01_make_table_one.R
	
Outputs/table_two.rds: Code/02_make_table_two.R CleanData/wide_data_clean.rds
	Rscript Code/02_make_table_two.R
	
Outputs/table_three.rds: Code/03_make_table_three.R CleanData/long_data.rds
	Rscript Code/03_make_table_three.R
	
Outputs/exit_plot.rds: Code/04_exit_qs.R CleanData/wide_data_clean.rds
	Rscript Code/04_exit_qs.R
	
clean:
	rm Outputs/*.rds CleanData/*.rds report/*.html
	
.PHONY: install
install:
	Rscript -e "renv::restore(prompt=FALSE)"
	
report/Data550_FinalProject_QuestionnaireReport.html:
	docker run -v /"$$(pwd)/report":/home/rstudio/project/report jeffreygong9900/data550finalproject
	
.PHONY: report_mac
report_mac:
	docker run -v "$$(pwd)/report":/home/rstudio/project/report jeffreygong9900/data550finalproject
	
