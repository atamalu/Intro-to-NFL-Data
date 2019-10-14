df <- get_data('news')
sents <- textdata::lexicon_afinn()

x <- df$analysis[1]
x

#####################
##### Get words #####
#####################
to_word_vec <- function(x){
  
  delims <- c('\\s', '-', '\\&apos\\;') # separators
  delims <- paste(delims, collapse = "|")
  
  all.words <- strsplit(x, delims) # split into item for each word
  
  ##### Apply to every word (x = word) ---------------
  all.words <- sapply(all.words, function(x){ 
    x <- gsub('[^[:alpha:]]', '', x) # only keep alphabetic chars
    x <- ifelse(nchar(x) < 3, '', x) # remove if less than 3 letters
    x <- x[x != ''] # remove blanks
    x <- tolower(x) # lowercase 
    }) 
  all.words <- as.vector(all.words)
  
  return(all.words)
  
}

#######################################################

words <- to_word_vec(df$analysis[1])
word.vec <- words

n_occurs <- function(word.vec){
  whichunique <- unique(word.vec)
  a <- sapply(whichunique, function(x){
    length(regmatches(word.vec, gregexpr(x, word.vec)))
  })
  lengths(regmatches(word.vec, gregexpr(whichunique, word.vec)))
}

lengths(regmatches(word.vec, gregexpr(whichunique, word.vec)))
