# t1_functions

## This script has all the functions created to accomplish the task 1, they will
## be used in the other scripts and reports

# to_df
## to_df transforms the list outputed by the read.data function into a dataframe.
to_df <- function(lists, lang){
    ## Loading dplyr package
    require(dplyr, quietly = TRUE)
    ## Creating output data frame.
    out <- data.frame(ID = character(), 
                      Text = character(),
                      stringsAsFactors = FALSE)
    ## Transforming the data
    for(name in names(lists)){
        newdf <- data.frame(ID = paste(name, lang, 1:length(lists[[name]]), sep = "."),
                            stringsAsFactors = FALSE)
        newdf["Text"] <- as.character(lists[[name]])
        ## Merging data from different sources
        out <- bind_rows(out, newdf)
    }
    return(data.frame(out))
}

# ptonkens
## function for paralellized tokenization.
## (since the last time I did anything in this document a lot of things changed 
## changed, it seems like quanteda runs much faster if I don't paralellize it 
## manualy, maybe it is paralellizing it by itself, anyways, this function is 
## only a wrapper now) (it seems like it is using my GPU, which explains why it 
## is so much faster)
## added functionality to filter profanity before tokenization for offensive 
## phrasal verbs and offensive expressions with more than a word
ptokens <- function(docs, dnames, tolower = FALSE, ...){
    ## tolower
    if(tolower) docs <- tolower(docs)
    ## Tokenizing
    toks <- tokens(docs, ...)
    names(toks) <- dnames
    ##Returning output
    return(toks)
}

# filterProfanity
## This function removes words from a list from the a tokens object.
## (2022 no idea why this function exists, could have been a single call of 
## tokens_remove, go figure the mind of the younger me)
filterProfanity <- function(tokens, profanity_list){
    ## Removes profanity from tokens
    output <- tokens_remove(tokens, profanity_list)
    ## Pront the number of removed words to the console
    print(paste(length(types(tokens))-length(types(output)), "bad words were removed from the tokens"))
    ## return clean tokens
    return(output)
}

# filterProfDocs
## This function removes documents that contain words or expressions from a list
## of profane words.
## This function takes two arguments:
##   - docs: a list or vector of documents
##   - plist: a list of words and expressions to be filtered out of the documents list
## This function returns a logical vector with the documents to keep
filterProfDocs <- function(docs, plist) {
    # pbar = progress_bar$new(total = length(plist))
    # filter <- logical(length = length(docs))
    # for(prof in plist) {
    #     pbar$tick()
    #     pattern <-  paste("\\b", prof, "\\b", sep = "")
    #     filter[!filter] <- grepl(pattern, docs[!filter], ignore.case = TRUE)
    # }
    # return(filter)
    nc <- detectCores()-1
    cl = makePSOCKcluster(nc)
    registerDoParallel(cl)
    
    suppressWarnings(pchunks <- split(plist, 1:nc))
    
    filterLists <- foreach(pchunk = pchunks, .combine = "c") %dopar% {
        pattern = paste("\\b",pchunk,"\\b", sep = "",collapse = "|")
        list(grepl(pattern, docs, ignore.case = TRUE))
    }
    stopCluster(cl)
    filterLists <- matrix(unlist(filterLists), ncol = nc)
    filter = rowSums(filterLists) == 0
    return(filter)
}



