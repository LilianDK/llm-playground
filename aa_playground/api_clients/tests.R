library(pdftools)
library(reticulate)
library(glue)
use_python("/Users/lilian.do-khac/.pyenv/versions/3.11.4/bin/python")
py_install("numpy")
py_install("rpy2")

source_python("api_clients/aa_semantic_search_inmemo.py")
source_python("api_clients/aa_qna.py")

token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MjcyLCJ0b2tlbl9pZCI6MzA4NH0.SyDVglcLc5FLLF86GV9z0D4WfxQF0uvAmeW8YlnG7to"

# Data pre-processing step: Parsing PDF input to input format for semantic search
pdf_file = "www/0.pdf"
txt = pdf_text(pdf_file)
#document = txt[1]

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
query = "Wieviel Euro muss soll die Beklagte zahlen?"
index = semanticsearch(token, text_chunks$Text_chunk, query, as.integer(3))

# Data post-processing step: Transform LLM result to expected tabular output format
tbl = data.frame(matrix(nrow = 0, ncol = 0)) 

for (x in 1:length(index)-1) {
  newvalue = as.integer(index[x]$item())
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

