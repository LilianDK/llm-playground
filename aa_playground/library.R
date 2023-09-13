# Installation of R packages ---------------------------------------------------
print("START: Installation of R packages--------------------------------------")
library(remotes)

#remotes::install_github("dreamRs/shinyWidgets")
#remotes::install_github("rstudio/gridlayout")
#remotes::install_github("bnosac/audio.whisper", ref = "0.2.1-1")

# Loading R libraries ----------------------------------------------------------
# part of the functionalities
library(shiny)
library(shinyWidgets)
library(bslib)
library(reticulate)
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
library(thematic)
library(TheOpenAIR)
library(knitr)
print("START: Loading whisper model-------------------------------------------")
whispermodel <- whisper("tiny")
# whispermodel <- whisper("base")
# whispermodel <- whisper("small")
# whispermodel <- whisper("medium")
# whispermodel <- whisper("large")
print("END: Loading whisper model---------------------------------------------")

# part of debugging
library(reactlog)
options(shiny.reactlog = TRUE)

Sys.setenv(RETICULATE_PYTHON_ENV = "py_backend")

version <- "3.11"

print("INITIALIZED VIRTUAL PYTHON ENVIRONMENT---------------------------------")
if (Sys.getenv("RUNS_IN_CONTAINER") == "TRUE") {
  if (!virtualenv_exists()) {
    install_python(version)
    virtualenv_create(python = virtualenv_starter(version), requirements = "requirements.txt")
  }
} else{
  virtualenv_create(python = virtualenv_starter(version))
  print("START: Install python packages-----------------------------------------")
  virtualenv_install(requirements = "requirements.txt")
  print("END: Install python packages-------------------------------------------")
}
print("END: Initializing PYENV--------------------------------------------------")

# Creating virtual pyenv
use_virtualenv("py_backend")


