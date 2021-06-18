#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Contact Nicholas Parham (NP) at nick-99@att.net for comments or corrections.

library(shiny)
library(readxl)
library(dplyr)
library(DT)
library(sjmisc)
library(PeriodicTable)
library(data.table)

   #########################
###### FILE DEPENDENCIES ######
   #########################

elements.list = read.csv('elementlist.csv') # should be a dependency
elements = elements.list$symbols

   #################
###### FUNCTIONS ######
   #################

s_element = function(element){ # isolate element name for use in mass() function
    if (unlist(stringr::str_split(element, '[(]'), use.names = F)[1] %in% elements){
        if (length(unlist(stringr::str_split(element, '[+]'), use.names = F)) > 1){
            symbol = unlist(stringr::str_split(element, '[(]'), use.names = F)[1]
        }else if (length(unlist(stringr::str_split(element, '[-]'), use.names = F)) > 1){
            symbol = unlist(stringr::str_split(element, '[(]'), use.names = F)[1]
        }else{
            symbol = 'H' # default if element not found
        }
        if (is.null(symbol) | is.na(symbol)){
            symbol = 'H'
        }
    }else{
        symbol = 'H'
    }
    return(symbol)
}

   ####################
###### SERVER LOGIC ######
   ####################

shinyServer(function(input, output) {
    
       ################
    ###### HOME TAB ######
       ################
    
    missingInput = eventReactive(input$scan, {
        filepath = input$dataset.test
        dataset = read.csv(filepath$datapath)
        filepath2 = input$mineral.test
        mineral.ref = read_excel(filepath2$datapath)
        
        minerals = unique(c(dataset$Mineral, 
                            dataset$Electrolyte1,
                            dataset$Electrolyte2,
                            dataset$Electrolyte3,
                            dataset$Electrolyte4,
                            dataset$Electrolyte5,
                            dataset$Electrolyte6,
                            dataset$Sorbent))
        ref.minerals = unique(mineral.ref$minerals)
        elements.list = read.csv('elementlist.csv') # should be a dependency
        elements = elements.list$symbols
        
        # filter out elements
        for (i in c(1:length(minerals))){
            if (unlist(stringr::str_split(minerals[i], '[(]'), use.names = F)[1] %in% elements){
                if (length(unlist(stringr::str_split(minerals[i], '[+]'), use.names = F)) > 1){
                    minerals[i] = 'Element'
                }else if (length(unlist(stringr::str_split(minerals[i], '[-]'), use.names = F)) > 1){
                    minerals[i] = 'Element'
                }else{
                    # not element
                }
            }
        }

        missing = minerals[!(minerals %in% ref.minerals) & !(minerals == '') & !(is.na(minerals)) 
                           & !(minerals == 'Element') & !(minerals == 'pH')]
        missing = data.frame(missing = missing) # output missing from mineral-ref
        missing
    })
    
    output$missing = renderTable({
        missing = missingInput()
        missing
    })

       ##################
    ###### FILTERER TAB ######
       ##################
    
    clean.datasetInput = reactive({ # read in Clean-Dataset.xlsx as dataframe
        filepath = input$clean.dataset
        clean.dataset = read.csv(filepath$datapath)
        clean.dataset
    })
    
    output$mineral.dropdown = renderUI({
        if (is.null(input$clean.dataset)){
            clean.dataset = data.frame(Mineral = character(), Sorbent = character())
        }else{
            clean.dataset = clean.datasetInput()
        }
        minerals = unique(clean.dataset$Mineral)
        selectInput('mineral.select', label = h4('Mineral(s)'), choices = minerals, multiple = T)
    })
    
    output$sorbent.dropdown = renderUI({
        if (is.null(input$clean.dataset)){
            clean.dataset = data.frame(Mineral = character(), Sorbent = character())
        }else{
            clean.dataset = clean.datasetInput()
        }
        sorbents = unique(clean.dataset$Sorbent)
        selectInput('sorbent.select', label = h4('Sorbent(s)'), choices = sorbents, multiple = T)
    })
    
    sc.subset = eventReactive(input$filter, {
        clean.dataset = clean.datasetInput()
        minerals = input$mineral.select
        sorbents = input$sorbent.select
        sc.subset = clean.dataset[clean.dataset$Mineral %in% minerals & clean.dataset$Sorbent %in% sorbents,]
        sc.subset
    })

    output$sc.subset = DT::renderDataTable({ # output subset to UI
        sc.subset = sc.subset()
        sc.subset
    })
    
    output$downloadSubset = downloadHandler(
        filename = function() {
            paste('sc.subset', '.csv', sep = '')
        },
        content = function(file) {
            write.csv(sc.subset(), file, row.names = F) # user must import in Excel, not just open
        })
    
       
})
