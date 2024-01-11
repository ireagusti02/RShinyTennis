# ---
# title: "Court Finder"
# author: "Irene and Sam R"
# date: "2023-11-10"
# output: r_document
# ---

# Libraries 
library(dplyr) 
library(ggplot2) 
library(shiny) 
library(tidyr) 
library(plotly) 
library(DT) 
library(maps) 
library(maptools) 
library(shinythemes) 
library(shinycssloaders) 
library(stringr) 
library(leaflet)
library(rsconnect)
 
# Please see "CitationsSources.txt" for citations and sources. 

# Please see "Info.txt" for motivation, explanation of data sources, 
# description of features, and relevant findings. 

# Reading data 
data = read.csv("CleanData.csv")
state_polys = read.csv("state_polys.csv")

# Define UI
ui <- fluidPage(
  
  #Navbar structure for UI
  navbarPage("Tennis Courts", theme = shinytheme("yeti"),
             
             # tabPanel Start 
             tabPanel("Court Finder", fluid = TRUE,
                      
                      # Sidebar layout with a input and output definitions
                      sidebarLayout(
                        
                        # One sidebar panel 
                        sidebarPanel(width = 3, 
                          
                          # Title 
                          titlePanel("Desired Court Characteristics"),
                          
                          # Using hr() to create a line break 
                          hr(), 
                          
                          # fluidRow 
                          fluidRow(column(9, offset = 1, 
                                          
                                          # Select State  
                                          selectInput(
                                            inputId = "StateFinder", 
                                            label = "Select State", 
                                            choices = State, 
                                            selected = "Florida", 
                                            width = "220px"),
                                          
                                          hr(), 
                                          
                                          #Select Public and/or Private
                                          checkboxGroupInput(
                                            inputId = "AccessFinder",
                                            label = "Select Access:",
                                            choices = c("Public", "Private"), 
                                            selected = "Public"),
                                          
                                          helpText("You must select at least one input."), 
                                          
                                          hr(), 
                                          
                                          # Select which Surface(s) to plot
                                          checkboxGroupInput(
                                            inputId = "SurfaceFinder",
                                            label = "Select Surface(s):",
                                            choices = c("Hard", "Clay", "Grass"), 
                                            selected = "Hard"),
                                          
                                          helpText("You must select at least one input."), 
                                          
                                          hr(), 
                                          
                                          # Court Count 
                                          sliderInput(inputId = "Count", 
                                                      label = "Court Count", 
                                                      min = 1, 
                                                      max = 50, 
                                                      value = c(1,6), 
                                                      width = "220px"), 
                                          
                                          hr(), 
                                          
                                          ) # column 
                                   
                                   ),  # fluidRow 
                          
                          ), # sidebarPanel 
                        
                        mainPanel(
                          
                          # withSpinner displays a graphic when changing inputs 
                          withSpinner(plotlyOutput(outputId = "scatterplotFinder")), 
                          
                          hr(),
                          
                          # Break without a line displayed 
                          br(), 
                          
                          fluidRow(withSpinner(dataTableOutput(outputId = "schoolstableFinder")))
                          
                          ) # mainPanel 
                        
                        ) # sidebarLayout  
                      
             ), #tabPanel 
             
             # tabPanel 2
             tabPanel("Street Map", fluid = TRUE,
                      
                        mainPanel(width = 12, length = 12, 
                                  withSpinner(leafletOutput(outputId = "name", height = "90vh")), 
                          ) 
                      
             ) #tabPanel  
             
  ) # navbarPage  
  
) # fluidPage  

# Define server
server <- function(input, output, session) {
  
  # Reactive function to filter and display one state at a time 
  state_polys_finder = reactive({
    req(input$StateFinder)
    filteredPolys = filter(state_polys, region %in% input$StateFinder)
    return(filteredPolys)
  })
  
  # Reactive function for the graph/table's four filters 
  data_finder <- reactive({
    req(input$SurfaceFinder)
    req(input$AccessFinder)
    req(input$StateFinder)
    req(input$Count)
    
    filtered_data <- data %>%
      filter(Surface %in% input$SurfaceFinder) %>%
      filter(Access %in% input$AccessFinder) %>% 
      filter(State %in% input$StateFinder) %>% 
      filter(between(Count, input$Count[1], input$Count[2])) 
  
    return(filtered_data)
  })
  
  # Graph output 
  output$scatterplotFinder <- renderPlotly({
    input$SurfaceFinder 
    input$AccessFinder
    input$StateFinder
    input$Count
    isolate({
      
      # Checking if there is a court that matches selected inputs 
      # If not, print a message and a grayed out state 
      if (length(data_finder()$Name) == 0) {
        
        ggplotly(
        
        # ggplot to display a message if there are no courts which match the 
        # selected characteristics 
        ggplot() +
          geom_polygon(data = state_polys_finder(), 
                       aes(x = long, y = lat, group = group), 
                       color = "white", fill = "grey") +
          coord_quickmap() + 
          theme_void() + 
          ggtitle("No courts with selected characteristics") +
          theme(plot.title = element_text(face = "bold", 
                                          color = "black", 
                                          size = 20))
        
        )
          
      } else {
        
        ggplotly(
      
        ggplot() + 
          
          # State depictions 
          geom_polygon(data = state_polys_finder(), 
                       aes(x = long, y = lat, group = group),
                       color = "black", 
                       fill = "azure3", 
                       size = 0.8, alpha = 0.3) +
          
          # Projection of the state with smooth lines 
          coord_quickmap() + 
          
          # Points plotted by longitude and latitude, colored by surface and 
          # shape by public 
          geom_point(data = data_finder(), 
                     aes(x = Longitude, y = Latitude, 
                         color = Surface, 
                         text = paste("Name: ", Name, "<br>Access: ", 
                                      Access, "<br>Surface: ", Surface),
                         shape = Access), size = 4, alpha = 0.5) + 
          
          theme_void() + 
          
          # Color and shape will always be used, 
          # so setting color to both labels and shape to ""
          # to remove extra unwanted Access label 
          labs(color = "Surface and Access", shape = "") + 
          
          # Setting up the Surface Legend 
          {if(length(input$Surface) <= 1) 
            scale_color_manual(guide = "none", 
                               values = c("Hard" = "#1E90FF", 
                                          "Clay" = "firebrick", 
                                          "Grass" = "green"))
          } +
          
          {if(length(input$Surface) < 1)
            scale_color_manual(values = c("Hard" = "#1E90FF", 
                                          "Clay" = "firebrick", 
                                          "Grass" = "green"))
          } + 
          
          # Changing the size of legend text 
          theme(legend.text = element_text(size = 12),
                legend.title = element_text(size = 15)), 
        
        tooltip = c("text")) %>% 
          
          layout(xaxis = list(showgrid = FALSE, zeroline = FALSE, 
                              showticklabels = FALSE,
                              linecolor = 'transparent', linewidth = 0),
                 yaxis = list(showgrid = FALSE, zeroline = FALSE, 
                              showticklabels = FALSE,
                              linecolor = 'transparent', linewidth = 0)) 
      
      } 
      
    }) 
    
  })
  
  # Output for the data table 
  output$schoolstableFinder = DT::renderDataTable({
    DT::datatable(data_finder()[c("Name", "City", "Access", "Count", "Wall", 
                                  "Indoor", "Lights", "Proshop", "Surface")], 
                  rownames = FALSE) 
  }) 
  
  # Graph output 
  output$name <- renderLeaflet({
    input$SurfaceFinder 
    input$AccessFinder
    input$StateFinder
    input$Count
    isolate({
      
      leaflet(data = data_finder()) %>% 
        addTiles() %>% 
        addCircleMarkers(lng = ~Longitude, lat = ~Latitude,
                         label = ~paste(Name),
                         popup = ~paste("Name: ", Name, "<br>Access: ", Access, "<br>Surface: ", Surface),
                         fillOpacity = 0.6,
                         radius = 5, 
                         color = "slateblue", 
                         stroke = FALSE 
                         
        ) 
      
    }) 
    
  })
  
}

# Run the application
shinyApp(ui = ui, server = server)
