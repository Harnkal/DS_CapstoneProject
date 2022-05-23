library(quanteda)
library(data.table)

"%!in%" <- Negate("%in%")

ngkm_train <- function(token_object, ngrams = 2, lambda = 0.4, k = 0, npred = 3, 
                       no_pred_list = c("<unk>", "<no>", "<url>")) {
    
    ## Vars prep
    new.cols <- paste("word_", 0:(ngrams-1), sep="")
    new.cols[new.cols=="word_0"] <- "word"
    independent_cols <- rev(setdiff(new.cols, "word"))
    
    ## Creating prediction table
    pred_table <- dfm(tokens_ngrams(token_object, n = 1:ngrams))
    pred_table <- featfreq(pred_table)
    
    pred_table <- data.frame(pred_table)
    names(pred_table) <- "frequency"
    pred_table["full_token"] <- row.names(pred_table)
    
    pred_table <- as.data.table(pred_table)
    
    pred_table[, paste("V", 1:ngrams, sep="") := tstrsplit(full_token, "_", fixed = TRUE, fill = "<NA>")]
    pred_table[, full_token := NULL]
    pred_table[, ngram := rowSums(.SD != "<NA>"), .SDcol = 2:(ngrams+1)]
    for (i in 1:ngrams) {
        for (j in 1:ngrams) {
            sd <- ((j<i)*i+(j>=i)*(j-i+1))+1
            pred_table[ngram == j, new.cols[i] := .SD, .SDcol = sd]
        }
    }
    pred_table[, paste("V", 1:ngrams, sep="") := rep(NULL, ngrams)]
    
    setcolorder(pred_table, append(rev(new.cols), "frequency"))
    
    
    pred_table[, prob := frequency/sum(frequency), by = independent_cols]
    
    pred_table <- subset(pred_table, frequency > k)
    pred_table <- subset(pred_table, word %!in% no_pred_list)
    pred_table <- pred_table[, head(.SD, npred), by = independent_cols]
    
    pred_table[, adjprob := prob * (lambda ^ (ngrams - ngram))]
    
    setorder(pred_table, -adjprob)
    
    ## additional info
    input_dictionary <- unique(unlist(pred_table[,0:(ngrams-1)]))
    
    cutpoint <-  max(nchar(input_dictionary))*5*ngrams
    
    ## assembling model
    model <- list(pred_table, input_dictionary, cutpoint, ngrams, lambda, k, npred)
    names(model) <-  c("pred_table", "input_dictionary", "cutpoint", "ngrams", "lambda", "k", "npred")
    
    ## returning
    return(model)
}

ngkm_replace <- function(input, what = c("url", "no", "_"), replacement = c("aurlthatwillbereplaced", "anothatwillbereplaced", " ")) {
    
    if (length(replacement) != length(what)){
        stop("length of replacement must be equal to the length of what")
    }
    
    if ("url" %in% what) {
        regex <- "(((((http|ftp|https|gopher|telnet|file|localhost):\\/\\/)|(www\\.)|(xn--)){1}([\\w_-]+(?:(?:\\.[\\w_-]+)+))([\\w.,@?^=%&:\\/~+#-]*[\\w@?^=%&\\/~+#-])?)|(([\\w_-]{2,200}(?:(?:\\.[\\w_-]+)*))((\\.[\\w_-]+\\/([\\w.,@?^=%&:\\/~+#-]*[\\w@?^=%&\\/~+#-])?)|(\\.((org|com|net|edu|gov|mil|int|arpa|biz|info|unknown|one|ninja|network|host|coop|tech)|(jp|br|it|cn|mx|ar|nl|pl|ru|tr|tw|za|be|uk|eg|es|fi|pt|th|nz|cz|hu|gr|dk|il|sg|uy|lt|ua|ie|ir|ve|kz|ec|rs|sk|py|bg|hk|eu|ee|md|is|my|lv|gt|pk|ni|by|ae|kr|su|vn|cy|am|ke))))))(?!(((ttp|tp|ttps):\\/\\/)|(ww\\.)|(n--)))"
        input <- gsub(regex, replacement[what == "url"], input, perl = TRUE)
    }
    
    if ("no" %in% what) {
        regex <- "([0-9])+(\\/([0-9])+)?(\\.([0-9])+)?"
        input <- gsub(regex, replacement[what == "no"], input, perl = TRUE)
    } 
    
    if ("_" %in% what) {
        regex <- "_"
        input <- gsub(regex, replacement[what == "_"], input, perl = TRUE)
    }
    
    return(input)
}

ngkm_prep <- function(input, model){
    input <- substr(input, nchar(input)-model$cutpoint, nchar(input))
    
    input <- tolower(input)
    input <- ngkm_replace(input)
    
    tokens <- tokens(input, what = "word", remove_punct = TRUE,
                     remove_symbols = TRUE, remove_numbers = TRUE, 
                     remove_url = TRUE, remove_separators=TRUE,
                     split_hyphens = TRUE, split_tags = TRUE)
    tokens <- tokens_select(tokens, startpos = -model$ngrams+1, endpos = -1)
    
    tokens <- tokens_replace(tokens, "aurlthatwillbereplaced", "<url>")
    tokens <- tokens_replace(tokens, "anothatwillbereplaced", "<no>")
    
    unk <- unique(unlist(tokens))
    unk <- unk[unk %!in% model$input_dictionary]
    tokens <- tokens_replace(tokens, unk, rep("<unk>", length(unk)))
    
    return(tokens)
}

ngkm_predict <- function(input, model) {
    pred_tokens <- ngkm_prep(input, model)[[1]]
    
    search_fields <- paste("word_", (model$ngrams-1):1, sep = "")
    
    pred <- model$pred_table
    
    for (i in 1:(model$ngrams-1)) {
        pred <- pred[get(search_fields[i]) == pred_tokens[i]|get(search_fields[i])== "<NA>",]
    }
    
    pred <- setorder(pred, -adjprob)
    
    pred <- pred[, head(.SD, 1), by = "word"]
    
    pred <- head(pred, model$npred)
    
    return(pred)
}