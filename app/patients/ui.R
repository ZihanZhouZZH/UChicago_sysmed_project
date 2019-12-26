#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyalert)


# Define UI for application that draws a histogram
shinyUI(fluidPage(
    useShinyalert(),

    # Application title
    titlePanel("View your Medical Records"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            textInput('firstname', label = 'First Name', 
                      placeholder = 'Input your first name'),
            textInput('lastname', label = 'Last Name', 
                        placeholder = 'Input your last name'),
            dateInput('birthday', 'Date of Birth'),
            actionButton('login', 'Login')),

        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(
                tabPanel('Personal Information',
                    tableOutput("info1"),
                    tableOutput('info2')
                ),
                tabPanel('Allergies', tableOutput('allergies')),
                tabPanel('Immunizations', tableOutput('immunizations')),
                tabPanel('Body Measures', tableOutput('observations')),
                tabPanel('Encounters',
                    uiOutput('enc_choice'),
                    tableOutput('medications'),
                    tableOutput('careplans')
                )
            )
        )
    )
))