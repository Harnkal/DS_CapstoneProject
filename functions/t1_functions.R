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
    return(out)
}

# filterProfanity
## This function downloads (if not already downloaded) a list of profanity words
## and loads it into memory and remove this words from the a tokens object.
filterProfanity <- function(tokens){
    ## Define profanity file path
    file_path <- "data/final/en_US/profanity.txt"
    ## Download if not already downloaded
    if(!file.exists(file_path)){
        url <- "https://raw.githubusercontent.com/shutterstock/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/master/en"
        download.file(url, destfile = file_path, method = "curl")
    }
    ## Reads profanity file into memory
    profanity_list <- read.csv(file_path, header = FALSE, stringsAsFactors = FALSE)
    profanity_list <- profanity_list$V1
    ## Removes profanity from tokens
    output <- tokens_remove(tokens, profanity_list)
    ## Pront the number of removed words to the console
    print(paste(length(types(tokens))-length(types(output)), "bad words were removed from the tokens"))
    ## return clean tokens
    return(output)
}



