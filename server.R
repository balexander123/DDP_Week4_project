#load libraries
library(ggthemes)
library(stringr)

shinyServer(function(input, output, session) {

  output$scatterPlot <- renderGraph({
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
      allHumanDamage$totalDamage <- Storm_Data$totalDamage
      
      # generate top economic damage
      allEconDamage <- allHumanDamage %>% group_by(EVENT_TYPE) %>% summarise(sumTotalDamage=sum(totalDamage)) %>% select(eventType, sumHumanImpact, sumHumanFatalities, sumHumanInjuries) %>% arrange(desc(sumTotalDamage))
      allEconDamage$sumTotalDamage <- currency(allEconDamage$sumTotalDamage, symbol = "$")
      
      # Combine all top damage data sets
      allDamage <- merge(allHumanDamage, allEconDamage)
      
      ggideal_point <- ggplot(df_trend) +
        geom_line(aes(x=Year, y=Ideal.point, by=Name, color=Name)) +
        labs(x = "Year") +
        labs(y = "Ideology") +
        labs(title = "Ideal Points for Countries") +
        scale_colour_hue("clarity",l=70, c=150) +
        theme_few()
      
      p <- plot_ly(allDamage, x = ~wt, y = ~hp, z = ~qsec, color = ~am, colors = c('#BF382A', '#0C4B8E')) %>%
        add_markers() %>%
        layout(scene = list(xaxis = list(title = 'Weight'),
                            yaxis = list(title = 'Gross horsepower'),
                            zaxis = list(title = '1/4 mile time')))

      # Year range
      min_Year <- min(df_trend$Year)
      max_Year <- max(df_trend$Year)

      # use gg2list() to convert from ggplot->plotly
      gg <- gg2list(ggideal_point)

      # Send this message up to the browser client, which will get fed through to
      # Plotly's javascript graphing library embedded inside the graph
      return(list(
          list(
              id="scatterPlot",
              task="newPlot",
              data=gg$data,
              layout=gg$layout
          )
      ))
    }
  })
})
