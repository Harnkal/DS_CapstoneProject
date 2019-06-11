# t1_functions

## This script has all the functions created to accomplish the task 1, they will
## be used in the other scripts and reports

to_corpus <- function(X, lang = NULL, Source=c("blogs", "news", "twitter")){
    out = list()
    for(i in 1:length(Source)){
        out[[Source[i]]] <- corpus(X[[Source[i]]])
        metadoc(out[[Source[i]]], "language") <- lang
        metadoc(out[[Source[i]]], "source") <- paste(lang, Source[i], 1:ndoc(out[[Source[i]]]), sep = ".")
    }
    return(out)
}
