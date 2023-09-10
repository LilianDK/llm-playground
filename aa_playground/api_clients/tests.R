# Install and or load packages - set variables ---------------------------------
packages <- c("pdftools","reticulate","glue")

installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

library(pdftools)
library(reticulate)
library(glue)

# Put the path to your python environment here 
use_python("/Users/USERNAME/.pyenv/versions/3.11.4/bin/python")

py_install("aleph-alpha-client")
py_install("Jinja2")
py_install("numpy")
py_install("rpy2")

# Get your python file
source_python("api_clients/aa_summarization.py")

token = "TOKEN"

# Load PDF file and parse ------------------------------------------------------
pdf_file = "www/Testfile.pdf"
txt = pdf_text(pdf_file)
document = txt[2] # select the page you want to summarize
document

# Call Aleph Alpha API ---------------------------------------------------------
summary = summary(token, document)
summary




df = data.frame(matrix(nrow = 0, ncol = 0)) 
for (x in 1:nrow(as.data.frame(txt))) {
  newrows = as.data.frame(strsplit(txt, "\\n\\n")[[x]]) # chunk after each paragraph
  newrows['page'] <- x # add page number
  colnames(newrows) = colnames(df)
  df = rbind(df, newrows)
} 

colnames(df) <- c("Text_chunk","page")

df = df[!(is.na(df$Text_chunk) | df$Text_chunk==""), ]
text_chunks = as.list(df)

# Semantic search
query = "Wieviel muss die Klägerin zahlen?"
index = semanticsearch(token, text_chunks$Text_chunk, query, as.integer(3))

# Data post-processing step: Transform LLM result to expected tabular output format
tbl = data.frame(matrix(nrow = 0, ncol = 0)) 

for (x in 1:length(index)-1) {
  newvalue = as.integer(index[x])
  tbl = rbind(tbl,newvalue)
} 

vector = as.matrix(tbl[1])

results = df[vector,]

string = ""
for (x in 1:nrow(results)) {
  string = glue("{string}{results[x,1]}")
}

string = trimws(gsub("[\r\n]", "", string))

qna = qna(token, string, query)

localization = qna[[1]]
score = qna[[2]]
nlg = trimws(qna[[4]])

