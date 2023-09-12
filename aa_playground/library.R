# Required if local development environment has to be set due to reticulate having issues to find the right path
local_development = FALSE

packages <- c("shiny","bslib","thematic","reticulate","TheOpenAIR","glue","DT","pdftools",
              "knitr","rmarkdown","markdown","remotes","shinycssloaders","reactlog","devtools",
              "av")

installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}
# remotes::install_github("dreamRs/shinyWidgets")
# devtools::install_github("rstudio/gridlayout")
# remotes::install_github("bnosac/audio.whisper", ref = "0.2.1-1")

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
 whispermodel <- whisper("tiny")
# whispermodel <- whisper("base")
# whispermodel <- whisper("small")
# whispermodel <- whisper("medium")
# whispermodel <- whisper("large")

# part of debugging
library(reactlog)

options(shiny.reactlog = TRUE)

if (local_development) {
  # Creating virtual pyenv
  virtualenv_create("py_backend", python=virtualenv_starter(version = "3.11"))
  use_virtualenv("py_backend")
  virtualenv_install("py_backend", c("aleph-alpha-client", "Jinja2"))
} else {
  install_python(version = "3.11:latest", list = FALSE, force = FALSE)
}

py_install("aleph-alpha-client")
py_install("Jinja2")
#py_install("numpy")
py_install("rpy2")
py_install("markdown")