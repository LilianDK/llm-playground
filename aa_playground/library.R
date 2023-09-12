# Installation of R packages ---------------------------------------------------
print("START: Installation of R packages----------------------------------------")
packages <- c("shiny","bslib","thematic","reticulate","TheOpenAIR","glue","DT","pdftools",
              "knitr","rmarkdown","markdown","remotes","shinycssloaders","reactlog","devtools",
              "av",
              "zip","xopen","whisker","waldo","usethis","urlchecker","textshaping","testthat",
              "systemfonts","sessioninfo","rversions","roxygen2","remotes","rematch2","rcmdcheck",
              "ragg","purrr","ps","profvis","processx","prettyunits","praise","pkgload","pkgdown",
              "pkgbuild","miniUI","ini","httr2","gitcreds","gh","gert","downlit","diffobj","desc",
              "credentials","cpp11","clipr","callr","brio","brew")

installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}
# remotes::install_github("dreamRs/shinyWidgets")
# devtools::install_github("rstudio/gridlayout")
# remotes::install_github("bnosac/audio.whisper", ref = "0.2.1-1")
print("END: Installation of R packages------------------------------------------")

# Loading R libraries ----------------------------------------------------------
# part of the functionalities
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
library(markdown)
library(shinycssloaders)
library(gridlayout) # DOCUMENTATION
library(av)
library(stringr)
library(audio.whisper)
print("START: Loading whisper model---------------------------------------------")
 whispermodel <- whisper("tiny")
# whispermodel <- whisper("base")
# whispermodel <- whisper("small")
# whispermodel <- whisper("medium")
# whispermodel <- whisper("large")
 print("END: Loading whisper model----------------------------------------------")
 
# part of debugging
library(reactlog)
options(shiny.reactlog = TRUE)

# Initializing PYENV -----------------------------------------------------------
# Required if local development environment has to be set 
print("START: Initializing PYENV------------------------------------------------")
local_development = TRUE

if (local_development) {
  # Creating virtual pyenv
  virtualenv_create("py_backend", python=virtualenv_starter(version = "3.11"))
  use_virtualenv("py_backend")
  virtualenv_install("py_backend", c("aleph-alpha-client", "Jinja2"))
  print("INITIALIZED VIRTUAL PYTHON ENVIRONMENT.")
} else {
  install_python(version = "3.11:latest", list = FALSE, force = FALSE)
  print("PYTHON INSTALLED IN VIRTUAL ENVIRONMENT.")
}
print("END: Initializing PYENV--------------------------------------------------")

# Install python packages ------------------------------------------------------
print("START: Install python packages-------------------------------------------")
py_install("aleph-alpha-client")
py_install("Jinja2")
py_install("numpy")
py_install("rpy2")
py_install("markdown")
print("END: Install python packages---------------------------------------------")
