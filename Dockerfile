FROM rocker/tidyverse as base

RUN apt-get update && \
    apt-get install -y --no-install-recommends cmake libnlopt0 


RUN mkdir /home/rstudio/project
WORKDIR /home/rstudio/project

RUN mkdir -p renv
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

RUN mkdir renv/.cache
ENV RENV_PATHS_CACHE renv/.cache

RUN R -e "renv::restore()"

##### DO NOT EDIT STAGE 1 BUILD LINES ABOVE #####

FROM rocker/tidyverse

WORKDIR /home/rstudio/project
COPY --from=base /home/rstudio/project .

COPY Makefile .
COPY Data550_FinalProject_QuestionnaireReport.Rmd .

RUN mkdir Data
RUN mkdir CleanData
RUN mkdir Code
RUN mkdir Outputs
RUN mkdir report

COPY Data/QuestionnaireData.rds Data

COPY Code/ /home/rstudio/project/Code/

CMD make && mv Data550_FinalProject_QuestionnaireReport.html report/


