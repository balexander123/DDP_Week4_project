shinyUI(
  
  fluidPage(

  # Application title
  titlePanel("Storm Damage"),

  # Sidebar with a slider input for number of bins

    sidebarPanel(
      h3("2017 Storm Damage By State"),
      # Select states here
      selectizeInput("name",
                  label = "State Name(s) of Interest",
                  choices = unique(Storm_Data$STATE),
                  multiple = T,
                  options = list(maxItems = 5,
                                 placeholder = 'Select a state'),
                  selected = "CALIFORNIA"

                  ),

      helpText("Data source: https://www1.ncdc.noaa.gov/pub/data/swdi/stormevents"),
      helpText('Choose state(s) of interest to graph 3D scatter plot of fatalites (x), injuries (y) and economic damage (z)'),
      helpText(''),
      helpText('Hover over points to see storm type'),
      helpText('Rotate the plot by clicking and moving mouse pointer')
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotlyOutput("scatterPlot", height="600px")
    )
  )
)
