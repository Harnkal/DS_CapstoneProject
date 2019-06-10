# p_functions

## This script has all the functions created for this project, they will be used 
## in the other scripts and reports


# get.data
## used to download and extract the datasets into the data directory.
get.data <- function() {
    ## Downloading and allocating
    if(!dir.exists("data")) dir.create("data")
    if(!file.exists("data/Coursera-SwiftKey.zip")) {
        download.file("https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip",
                      "data/Coursera-SwiftKey.zip")
    }
    if(!dir.exists("data/final")) unzip("data/Coursera-SwiftKey.zip", exdir = "data")
}

# read.data
## Used to read the data into R. It takes as agument the language you want to
## read that can be "en_US", "de_DE", "fi_FI" and ru_RU for English, German,
## Finnish and Russian respectively.
read.data <- function(lang = "en_US") {
    require(tm)
    directory <- paste("./data/final/", lang, sep = "")
    VCorpus(DirSource(directory), readerControl = list(language = lang))
} 