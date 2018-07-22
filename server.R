#load libraries
library(ggthemes)
library(stringr)
library(formattable)

shinyServer(function(input, output, session) {

  output$scatterPlot <- renderPlotly({
    print(paste0("State: ", input$name))
    if (length(input$name)==0) print("Please select at least one state")

    else {
      df_storms <- Storm_Data  %>%
        filter(STATE %in% input$name)

      stormData <- dplyr::select(df_storms, EVENT_TYPE, STATE, DEATHS_DIRECT, DEATHS_INDIRECT, INJURIES_DIRECT, INJURIES_INDIRECT, totalPropDamage, totalCropDamage, totalDamage)
      
      # Compute human damage
      topHumanDirectFatalities <- stormData %>% group_by(EVENT_TYPE) %>% summarise(sumHumanDirectFatalities=sum(DEATHS_DIRECT)) %>% arrange(desc(sumHumanDirectFatalities))
      topHumanIndirectFatalities <- stormData %>% group_by(EVENT_TYPE) %>% summarise(sumHumanIndirectFatalities=sum(DEATHS_INDIRECT)) %>% arrange(desc(sumHumanIndirectFatalities))
      topHumanDirectInjuries <- stormData %>% group_by(EVENT_TYPE) %>% summarise(sumHumanDirectInjuries=sum(INJURIES_DIRECT)) %>% arrange(desc(sumHumanDirectInjuries))
      topHumanIndirectInjuries <- stormData %>% group_by(EVENT_TYPE) %>% summarise(sumHumanIndirectInjuries=sum(INJURIES_INDIRECT)) %>% arrange(desc(sumHumanIndirectInjuries))
      
      
      
      # Combine all top damage data sets
      allHumanDamage <- merge(topHumanDirectFatalities, topHumanIndirectFatalities)
      allHumanDamage <- merge(allHumanDamage, topHumanDirectInjuries)
      allHumanDamage <- merge(allHumanDamage, topHumanIndirectInjuries)
      allHumanDamage$sumHumanImpact <- allHumanDamage$sumHumanDirectFatalities + allHumanDamage$sumHumanIndirectFatalities + allHumanDamage$sumHumanDirectInjuries + allHumanDamage$sumHumanIndirectInjuries
      
      # generate top economic damage
      topEconDamage <- stormData %>% group_by(EVENT_TYPE) %>% summarise(sumTotalDamage=sum(totalDamage)) %>% arrange(desc(sumTotalDamage))
      topEconDamage$sumTotalDamage <- currency(topEconDamage$sumTotalDamage, symbol = "$")
      
      # Combine all top damage data sets
      allDamage <- merge(allHumanDamage, topEconDamage)
      
      plot_ly(allDamage, x = ~sumHumanDirectFatalities, y = ~sumHumanDirectInjuries, z = ~sumTotalDamage, color = ~EVENT_TYPE, colors = c('#BF382A', '#0C4B8E')) %>%
        add_markers() %>%
        layout(scene = list(xaxis = list(title = 'Human Fatalities'),
                            yaxis = list(title = 'Human Injuries'),
                            zaxis = list(title = 'Economic Damage')))
    
    }
  })
})
