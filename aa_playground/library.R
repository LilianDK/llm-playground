# Required if local development environment has to be set due to reticulate having issues to find the right path
local_development = TRUE

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
  # Put the path to your python environment here
  use_python("/Users/lilian.do-khac/.pyenv/versions/3.11.4/bin/python")
} else {
  install_python(version = "3.11:latest", list = FALSE, force = FALSE)
}

py_install("aleph-alpha-client")
py_install("Jinja2")
py_install("numpy")
py_install("rpy2")
py_install("markdown")