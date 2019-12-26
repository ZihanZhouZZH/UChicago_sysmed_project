#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(feather)
library(dplyr)
library(tidyverse)
library(qwraps2)
library(magrittr)
library(gdata)
library(shinyalert)

allergies = read_feather('data/allergies.feather')
careplans = read_feather('data/careplans.feather')
conditions = read_feather('data/conditions.feather')
encounters = read_feather('data/encounters.feather')
immunizations = read_feather('data/immunizations.feather')
medications = read_feather('data/medications.feather')
observations = read_feather('data/observations.feather')
patients = read_feather('data/patients.feather')
procedures = read_feather('data/procedures.feather')

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    output$slider1 <- renderText({ input$firstname })
    
    observeEvent(input$login, {
        records <- patients %>%
            filter(toupper(input$firstname) == str_remove(toupper(FIRST), '[0-9]+')) %>%
            filter(toupper(input$lastname) == str_remove(toupper(LAST), '[0-9]+')) %>%
            filter(BIRTHDATE == input$birthday)
        
        if(nrow(records) == 0){
            shinyalert('No matching records.', type = 'error')
        }
        
        else{
            records$FIRST <- str_remove(records$FIRST, '[0-9]+')
            records$LAST <- str_remove(records$LAST, '[0-9]+')
            if(!is.na(records$MAIDEN))
                records$MAIDEN <- str_remove(records$MAIDEN, '[0-9]+')
            
            get_na <- function(df){
                # get a single row table with all NAs
                m <- ncol(df)
                tmp <- df[1,]
                tmp[1,] <- rep(NA, m)
                return(tmp)
            }
            
            id <- records$ID
            ######## Personal Information ########
            output$info1 <- renderTable(records[,1:9], striped = TRUE, 
                                       hover = TRUE, bordered = TRUE)
            output$info2 <- renderTable({
                records[,17] <- as.integer(records[,17])
                records[,10:17]
                }
                , striped = TRUE, 
                                       hover = TRUE, bordered = TRUE)
            
            ######## Allergies ########
            aller <- allergies %>%
                filter(PATIENT == id) %>%
                dplyr::select(START, STOP, DESCRIPTION)
            
            if(nrow(aller) == 0)
                output$allergies <- renderTable(get_na(aller))
            else
                output$allergies <- renderTable(aller)
            
            ######## Immunizations ########
            immu <- immunizations %>%
                dplyr::filter(PATIENT == id) %>%
                dplyr::select(DATE, DESCRIPTION)
            
            if(nrow(immu) == 0)
                output$immunizations <- renderTable(get_na(immu))
            else
                output$immunizations <- renderTable(immu)
            
            ######## Observations ########
            obs <- observations %>%
                filter(PATIENT == id) %>%
                dplyr::select(DATE, DESCRIPTION, VALUE, UNITS)
            
            if(nrow(obs) == 0)
                output$observations <- renderTable(get_na(obs))
            else
                output$observations <- renderTable(obs)
            
            ######## Encounters ########
            enc <- encounters %>%
                filter(PATIENT == id)
            
            output$enc_choice <- renderUI({
                selectInput('encounter', 'Select encounter', 
                            choices = enc$DATE)
            })
            
            observeEvent(input$encounter, {
                enc_id <- as.character(enc[enc$DATE == input$encounter, 'ID'])
            
                medi <- medications %>%
                    dplyr::filter(ENCOUNTER == enc_id) %>%
                    dplyr::select(START, STOP, DESCRIPTION, REASONDESCRIPTION)
                colnames(medi)[3:4] <- c('MEDICINE', 'REASON')
            
                carep <- careplans %>%
                    dplyr::filter(ENCOUNTER == enc_id) %>%
                    dplyr::select(START, STOP, DESCRIPTION, REASONDESCRIPTION)
                colnames(carep)[3:4] <- c('CAREPLAN', 'REASON')
            
                if(nrow(medi) == 0)
                    output$medications <- renderTable(get_na(medi))
                else
                    output$medications <- renderTable(medi)
            
                if(nrow(carep) == 0)
                    output$careplans <- renderTable(get_na(carep))
                else
                    output$careplans <- renderTable(carep)
            })
 
        }
            
            
    })
    
    
})
