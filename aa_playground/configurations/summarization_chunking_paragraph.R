# chunk with paragraph
sumtable = data.frame(matrix(nrow = 0, ncol = 0)) 
for (x in 1:nrow(as.data.frame(txt))) {
  newrows = as.data.frame(strsplit(txt, "\\n\\n")[[x]]) # chunk after each paragraph
  sumtable = rbind(sumtable, newrows)
} 

colnames(sumtable) <- c("Text_chunk")

sumtable = sumtable[!(is.na(sumtable$Text_chunk) | sumtable$Text_chunk==""), ]
sumtable = as.data.frame(sumtable)
text_chunks = as.list(sumtable[,1])