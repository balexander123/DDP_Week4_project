shinyUI(fluidPage(

  # Application title
  titlePanel("Ideal Points"),

  # Sidebar with a slider input for number of bins

    sidebarPanel(
      h3("Storm Damage By State"),
      # Select states here
      selectizeInput("name",
                  label = "State Name(s) of Interest",
                  choices = unique(Storm_Data$STATE),
                  multiple = T,
                  options = list(maxItems = 5,
                                 placeholder = 'Select a state'),
                  selected = "California"

                  ),


      # Term plot
      plotOutput("termPlot", height = 200),

      helpText("Data: TBD")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      graphOutput("scatterPlot")
    )
  )
)
