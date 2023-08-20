# Required if local development environment has to be set due to reticulate having issues to find the right path
local_development = FALSE

packages <- c("shiny","bslib","reticulate","TheOpenAIR","glue","DT","pdftools","knitr","rmarkdown","thematic","remotes")

installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}
#remotes::install_github("dreamRs/shinyWidgets")

library(shiny)
library(shinyWidgets)
library(bslib)
library(thematic)
library(reticulate)
library(TheOpenAIR)
library(glue)
library(DT)
library(pdftools)
library(rmarkdown)

if (local_development) {
  
  # Put the path to your python environment here
  use_python("/Users/USERNAME/.pyenv/versions/3.11.4/bin/python")
}

py_install("aleph-alpha-client")
py_install("Jinja2")


