
token = ""

# Load PDF file and parse ------------------------------------------------------
pdf_file = "www/0.pdf"
txt = pdf_text(pdf_file)
document = txt[1] # select the page you want to summarize
document
length(txt)
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

namedentity1="Auftragsnummer"
namedentity2="Betrag"
namedentity3="Rechnungsdatum"
entityextraction = entityextraction(token, document, namedentity1, namedentity2, namedentity3)
entityextraction
return(entityextraction)
test = substring(entityextraction, regexpr("\n", entityextraction) - 10)
test

result1 = substr(entityextraction,0,regexpr("\n", entityextraction)-1)
result1
nchar(result1)
result2 = gsub(substr(entityextraction,0,nchar(result1)+1), '', entityextraction)
result2
result2 = substr(result2,0,regexpr("\n", result2)-2)
result2
nchar(result2)
result3 = substr(entityextraction,nchar(result1)+2+nchar(result2)+2,nchar(entityextraction))
result3

tbl = data.frame(matrix(nrow = 0, ncol = 4)) 
colnames(tbl) = c("Document ID",namedentity1,namedentity2,namedentity3)
tbl[1,2]<-trimws(gsub(".*:","",result1))
tbl[1,3]<-trimws(gsub(".*:","",result2))
tbl[1,4]<-trimws(gsub(".*:","",result3))
tbl

# processing of non-PDF file
df = data.frame(matrix(nrow = 0, ncol = 4)) 

# transcripe audio file
av_audio_convert("www/0.mp4", output = "www/output.wav", format = "wav", sample_rate = 16000)
transcript = predict(whispermodel, "www/output.wav")

# data preparation
col1 = as.data.frame(transcript$data$segment)
col2 = as.data.frame(transcript$data$from)
col3 = as.data.frame(transcript$data$to)
col4 = as.data.frame(transcript$data$text)

df = cbind(col1,col2,col3,col4)
df = df[!duplicated(df[,4]),]

vector = data.frame(matrix(nrow = 0, ncol = 1)) 
for (x in 1:nrow(df)) {
  tokens = count_tokens(df[x,4])
  tokens
  vector = rbind(vector, tokens)
} 
df = cbind(df, vector)
colnames(df) = c("segment","from","to","text","tokens")

string = ""
for (x in 3:nrow(df)) {
  string = glue("{string}{df[x,4]}")
}
typeof(string)
if (sum(df[,5]) <= 2048) {
  document = as.character(string)
  summary = summary("", document)
  summary
} else {
  summary = "File too large."
  summary
}




x = 1
for (x in 1:length(result)) {
  token = count_tokens(result[x,1])
  df[x,3] = cbind(token)
} 
df = df[!(df[,3] < 15 | df[,3]==""), ] # Dirty data pre-processing !!!!!!!!!!!!!!!!!!!!!!!!!
result = df[,1:2]


token = input$text_token
query = input$text_prompt10 

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
token = ""
query = "Wieviel Euro muss soll die Beklagte zahlen?"
n = 3
input$topn

index = semanticsearch(token, as.character(text_chunks$Text_chunk), query, as.integer(n)) 
test = as.data.frame(index)
df[,"similarityscore"] = as.data.frame(index)
# Data post-processing step: Transform LLM result to expected tabular output format
tbl = data.frame(matrix(nrow = 0, ncol = 0)) 

for (x in 1:length(index)-1) {
  newvalue = as.integer(index[x])
  tbl = rbind(tbl,newvalue)
} 

zip::zip(
  zipfile = file,
  files = dir(temp_directory),
  root = temp_directory
)