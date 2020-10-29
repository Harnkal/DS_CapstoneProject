# t0_functions

## This script has all the functions created to accomplish the task 0, they will
## be used in the other scripts and reports


# get.data
## used to download and extract the datasets into the data directory.
get.data <- function() {
    ## Downloading and allocating
    if(!dir.exists("data")) dir.create("data")
    if(!file.exists("data/Coursera-SwiftKey.zip")) {
        download.file("https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip",
                      "data/Coursera-SwiftKey.zip")
    }
    ## Extracting
    if(!dir.exists("data/final")) unzip("data/Coursera-SwiftKey.zip", exdir = "data")
}

# read.data
## Used to read the project data into R. It takes the following arguments:
##   - lang: the language in which you want to read that can be "en_US", "de_DE", 
##           "fi_FI" and "ru_RU" for English, German, Finnish and Russian 
##           respectively.
##   - s: from which source you want to read you can choose one or more from
##        "blogs", "news"and "twitter".
##   - n: The number of lines to read from each file. n = -1L means that all the 
##        lines should be read.
## This function returns a list that contains a list element for each of the read
## files.
read.data <- function(lang = "en_US", s = c("blogs", "news", "twitter"), n = -1L) {
    ## Setting source directory
    directory <- paste("./data/final/", lang, "/", sep="")
    ## Creating output list
    out = list()
    for (i in 1:length(s)) {
        ## Opening connection
        con <- file(paste(directory, lang, ".", s[i], ".txt", sep=""))
        ## Reading from connection and storing in the output list
        out[[s[i]]] <- readLines(con, n = n, warn = FALSE, encoding="UTF-8")
        ## Closing connection
        close(con)
    }
    return(out)
} 