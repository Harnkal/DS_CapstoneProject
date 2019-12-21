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
    for(i in names(lists)){
        newdf <- data.frame(ID = paste(i, lang, 1:length(lists[[i]]), sep = "."),
                            stringsAsFactors = FALSE)
        newdf["Text"] <- as.character(lists[[i]])
        ## Merging data from different sources
        out <- bind_rows(out, newdf)
    }
    return(data.frame(out))
}

# ptonkens
## function for paralellized tokenization
ptokens <- function(docs, dnames, ncl, tolower = FALSE, ...){
    ## Oppening parallel backend
    cl <- makeCluster(ncl)
    registerDoParallel(cl)
    registerDoSEQ()
    ## tolower
    if(tolower) docs <- tolower(docs)
    ## Separating chunks
    suppressWarnings(lists <- split(docs, 1:ncl))
    suppressWarnings(names <- split(dnames, 1:ncl))
    ## Tokenizing
    out <- foreach(i = 1:ncl, .combine = "+", .packages = "quanteda") %dopar% {
        toks <- tokens(lists[[i]], ...)
        names(toks) <- names[[i]]
        toks
    }
    ## Closing connection
    stopCluster(cl)
    ##Returning output
    out
}





