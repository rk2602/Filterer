#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Contact Nicholas Parham at nick-99@att.net for comments or corrections.

library(shiny)
library(DT)
library(dplyr)
library(PeriodicTable)
library(shinycssloaders)
library(shinythemes)
library(sjmisc)

options(shiny.maxRequestSize = 30*1024^2) # max file size set at 30 MB

# Define UI for application that draws a histogram
navbarPage(title = tags$div(img(src='llnl-logo.png', height = 25, width = 150), 'SCDC'), theme = shinytheme('readable'),

  tabPanel(title = 'Home',
           
    # Page title
    titlePanel('LLNL Surface Complexation Database Filterer'),
    br(),
    h4('Welcome'),
    br(),
    em('The Filterer'),
    p('This tab serves to subset the output from the Unifier.  It requires three user inputs:'),
    tags$ol(tags$li(strong('sc.dataset.csv'), '- output from', em('the Unifier')),
            tags$li(strong('Minerals'), '- minerals desired in the subset'),
            tags$li(strong('Sorbents'), '- sorbents desired in the subset')),
    
    br(),
    h4('Scan Tool'),
    p('Scan your Dataset.csv file for missing minerals from mineral-ref.xlsx below:'),
    fileInput('dataset.test', label = 'Select Dataset.csv file'),
    fileInput('mineral.test', label = 'Select mineral-ref.xlsx file'),
    actionButton('scan', 'Scan'),
    br(),
    tableOutput('missing'),
    br(),
    p('Note: Densities are g/cm3, molar masses are g/mol, sites are sites/nm2, and names 
    are case sensitive.  If nothing shows, there are no minerals or compounds missing.')
  ),    
  
  tabPanel(title = 'Filterer',
           
           # Page title
           titlePanel('LLNL Surface Complexation Database Converter'),
           
           # Sidebar area with user inputs
           sidebarPanel(
             
             # User inputs here
             fileInput('clean.dataset', label = h4('Select sc.dataset file')),
             hr(),
             uiOutput('mineral.dropdown'),
             hr(),
             uiOutput('sorbent.dropdown'),
             hr(),
             actionButton('filter', 'Filter'),
             hr(),
             downloadButton('downloadSubset', 'Download')
           ),
           
           # Main display area
           mainPanel(
             withSpinner(DT::dataTableOutput('sc.subset'), size = 2, proxy.height = '500px')
           )
  ),
  
  tabPanel(title = 'Contact',
           
           # Page title
           titlePanel('LLNL Surface Complexation Database Converter'),
           br(),
           h4('Contact Info'),
           p('Please contact Nicholas Parham at ', strong('(305) 877 8223'), ' or ', strong('nick-99@att.net'), 
           ' with questions, comments, or corrections.  This application was sponsored by Mavrik Zavarin, PhD.')
           )
)  

