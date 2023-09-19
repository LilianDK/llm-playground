newframe = ""
for (x in 1:nrow(as.data.frame(txt))) {
  x = as.data.frame(unlist(strsplit(txt[x], "(?<![^!?.])\\s+", perl=T))) # chunk after each sentence
  newframe = rbind(newframe, x)
} 

newframe = newframe[!(is.na(newframe) | newframe==""), ]
newframe = as.data.frame(newframe)

chunksize = 5 # number of sentences that are concatenated
overlap = 1 # number of sentences with overlap in respective chunk
windowdf = data.frame(matrix(nrow = 0, ncol = 0)) 
tokendf = data.frame(matrix(nrow = 0, ncol = 0)) 
endchunk = chunksize # start chunk
windowchunk = "" # concatenated string
# window dataframe with concatenated n sentences init
for (x in 1:chunksize) {
  print(x)
  windowchunk = paste(windowchunk, newframe[x,1], sep = " ", collapse = " ")
  tokensize = count_tokens(windowchunk)
} 

windowdf = rbind(windowdf, windowchunk)
tokendf = rbind(tokendf, tokensize)
colnames(windowdf) = c("text_chunks")
colnames(tokendf) = c("token_size")
windowdf
# window dataframe with concatenated n sentences rest
maxwindow = round(nrow(as.data.frame(newframe))/(chunksize-overlap))-1
print(glue("Maxwindow is: {maxwindow}"))
start = chunksize+1-overlap
for (y in start:maxwindow) {
  print(glue("Current row is: {y}"))      
  # concatenate n sentences
  windowchunk = ""
  nextchunk = endchunk+1-overlap+chunksize-overlap
  print(glue("Starting from row {endchunk} to last row {nextchunk}."))   
  for (x in endchunk:nextchunk) {
    #print(x)
    windowchunk = paste(windowchunk, newframe[endchunk,1], sep = " ", collapse = " ")
    tokensize = count_tokens(windowchunk)
  } 
  
  # window dataframe with concatenated n sentences per row
  windowdf = rbind(windowdf, windowchunk)
  tokendf = rbind(tokendf, tokensize)
  endchunk = nextchunk
  
} 

windowdf = as.data.frame(windowdf)
windowdf = na.omit(windowdf)
windowdf = windowdf[!duplicated(windowdf["text_chunks"])]
text_chunks = as.list(windowdf[,1])