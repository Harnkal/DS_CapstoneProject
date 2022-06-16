# Author: Rafael Rocha
# Notes:
# - Although it is not mandatory anymore, I decided to split this app in 2 files
#   so I can program using both my screens

# Loading packages
Sys.setlocale("LC_ALL","English")

library(shiny)
library(shinythemes)
library(ggplot2)
library(markdown)

library(ngkm)

# Defining the ui
ui <- fixedPage(
    theme = shinytheme("darkly"),
    navbarPage("Capstone App",
        tabPanel("App",
            sidebarPanel(
                h3("Control Panel"),
                sliderInput(inputId = "lambda", 
                    label = "Lambda:", 
                    min = 0, 
                    max = 1, 
                    value = 0.25,
                    step = 0.05),
                checkboxInput("automode", "Activate nonsense mode"),
                selectInput("automodetype", "Nonsense mode type:",
                    c(
                        "random",
                        "carousel",
                        "always first",
                        "always second",
                        "always third",
                        "always forth",
                        "always fifth",
                        "always last"
                    )),
                actionButton("clear", "Restart")
                
            ), # sidebar panel
            mainPanel(
                h3("Input"),
                textAreaInput("txt", "", "",
                    width = '100%',
                    height = '200px'),
                
                h3("Output"),
                h4("Input tokens"),
                verbatimTextOutput("input_tokens"),
                
                h4("Predictions"),
                plotOutput(outputId = "prediction", 
                    click = "plot_click", 
                    hover = hoverOpts(id ="plot_hover")),
                
            ), # main panel
            
        ), # panel1
        tabPanel("About the App", 
            includeMarkdown("about_demonstrator.md")
        ), # panel2
        tabPanel("About the Algorithm", 
            withMathJax(includeMarkdown("about_algorithm.md"))
        ), # panel3
        tabPanel("Downloads", 
            includeMarkdown("downloads.md")
        ), # panel3
    ) # navbar
) # ui

# Defining the server
server <- function(input, output, session) {
    
    hover <- reactiveVal(0)
    selection <- reactiveVal(0)
    pred <- reactiveVal(0)
    
    model <- reactive({
        ngkmodel$pred_table <- ngkmodel$pred_table[, adjprob := prob * (input$lambda ^ (ngkmodel$ngrams - ngram))]
        ngkmodel$lambda <- input$lambda
        ngkmodel
    }) # adjust lambda 
    
    observeEvent(input$clear, {
        updateTextInput(inputId = "txt", value = "")
        updateTextInput(inputId = "lambda", value = 0.25)
        updateTextInput(inputId = "automode", value = FALSE)
        selection(0)
    })
    
    observeEvent(c(input$txt, input$automode, input$lambda), {
        if(grepl("\\s$", input$txt) | input$txt == "") {
            req(model())
            
            pred(ngkm_predict(input$txt, model()))
            if(input$automode) {
                if(input$automodetype == "random") {
                    selection(sample(1:6, 1))
                    hover(selection())
                }
                if(input$automodetype == "carousel") {
                    selection(selection()+1)
                    if(selection() > 6){
                        selection(1)
                    }
                    hover(selection())
                }
                if(input$automodetype == "always first") {
                    selection(1)
                    hover(selection())
                }
                if(input$automodetype == "always second") {
                    selection(2)
                    hover(selection())
                }
                if(input$automodetype == "always third") {
                    selection(3)
                    hover(selection())
                }
                if(input$automodetype == "always forth") {
                    selection(4)
                    hover(selection())
                }
                if(input$automodetype == "always fifth") {
                    selection(5)
                    hover(selection())
                }
                if(input$automodetype == "always last") {
                    selection(6)
                    hover(selection())
                }
                
                
                new_word <- pred()$word[selection()]
                new_text <- paste(input$txt, new_word, sep = " ")
                new_text <- gsub("^ *|(?<= ) | *$", "", new_text, perl = TRUE)
                
                updateTextInput(inputId = "txt", value = new_text)
            }
        }
    }) # predict
    
    observeEvent(input$plot_click, {
        new_word <- pred()$word[round(input$plot_click[[1]])]
        new_text <- gsub("^ *|(?<= ) | *$", "", input$txt, perl = TRUE)
        new_text <- paste(new_text, new_word, "", sep = " ")
        
        updateTextInput(inputId = "txt", value = new_text)
    })
    
    ## Update hover position
    observeEvent(input$plot_hover, {
        hover(round(input$plot_hover[[1]]))
    })
    
    ## Outputs
    output$input_tokens <- renderText({
        input_tokens <- ngkm_prep(input$txt, ngkmodel)
        paste(unlist(input_tokens), collapse = " ")
    }) # input_tokens
    
    output$prediction <- renderPlot({
        req(pred())
        req(hover())
        
        colors <- palette.colors(5, "Set 1")
        names(colors) <- 1:5
        
        plot <- ggplot(pred(), mapping = aes(x = factor(word, levels = word), y = adjprob, fill = factor(ngram, level = 1:5))) +
            scale_fill_manual(values = colors) + 
            geom_bar(stat = "identity", position = "dodge") + 
            theme(legend.position = "bottom",
                text = element_text(size=20)) +
            labs(title = "Next Word Prediction",
                x = "Word",
                y = "Adjusted Probability",
                fill = "ngram")
        
        if(hover() > 0){
            plot <- plot + geom_rect(aes(xmin = hover() - 0.45, xmax = hover() + 0.45, 
                ymin = 0, ymax = max(adjprob)),
                fill = "transparent", color = "black", size = 1.5)
        }
        
        plot
    }) # prediction
    
} # server


shinyApp(ui, server)