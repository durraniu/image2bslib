library(shiny)
library(bslib)
library(httr2)
library(jsonlite)
library(base64enc)

ui <- fluidPage(
  
  fileInput("file1", "Choose image",
            multiple = FALSE,
            accept = c("png",
                       "jpg")),
  
  tags$hr(),
  
  uiOutput("code")
)

server <- function(input, output, session) {
  output$code <- renderUI({
    req(input$file1)
    
    # Read and encode the image file
    image_path <- file.path(input$file1$datapath)
    image_data <- base64encode(readBin(image_path, "raw", file.info(image_path)$size))
    
    # Create the payload
    payload <- list(
      messages = list(
        list(
          role = "system",
          content = "You are a an expert in developing shiny web applications in R language."
        ),
        list(
          role = "user",
          content = list(
            list(
              text = 'Create code for only the user interface of the shiny app based on this image. Do not use shinydashboard code.Do not use fluidRow and column functions. Instead, use bslib code. For example, here are some layout functions in bslib package:
              ```
              # example 1
              page_sidebar(
  title = "Penguins dashboard",
  sidebar = sidebar(
    title = "Histogram controls",
    varSelectInput(
      "var", "Select variable",
      dplyr::select_if(penguins, is.numeric)
    ),
    numericInput("bins", "Number of bins", 30)
  ),
  card(
    card_header("Histogram"),
    plotOutput("p")
  )
)
# example 2
page_sidebar(
  title = "Penguins dashboard",
  sidebar = sidebar()
)

# example 3
page_sidebar(
  title = "Penguins dashboard",
  sidebar = sidebar(),
  layout_columns(
    col_widths = c(4, 8, 12),
    row_heights = c(1, 2),
    card(),
    card(),
    card()
  )
)

# example 4
page_navbar(
  title = "Penguins dashboard",
  sidebar = sidebar(),
  nav_spacer(),
  nav_panel("Bill Length", card()),
  nav_panel("Bill Depth", card()),
  nav_panel("Body Mass", card()),
  nav_item(tags$a("Posit", href = "https://posit.co"))
)
              ```
              
              Only provide code. Particularly, refer to this page on bslib docs site https://rstudio.github.io/bslib/articles/dashboards',
              type = "text"
            ),
            list(
              image_url = list(
                url = paste0("data:image/jpeg;base64,", image_data),
                detail = "low"
              ),
              type = "image_url"
            )
          )
        )
      ),
      model = "gpt-4o"
    )
    
    # Create and send the request
    req <- request("https://models.inference.ai.azure.com/chat/completions") |> 
      req_method("POST") |> 
      req_headers(
        "Content-Type" = "application/json",
        "Authorization" = paste("Bearer", Sys.getenv("GITHUB_TOKEN"))
      ) |> 
      req_body_json(payload)
    
    resp <- req |> 
      req_perform()
    
    
    content <- (resp |> 
                  httr2::resp_body_json())$choices[[1]]$message$content 
    
    # Assuming the response is stored in a variable called 'content'
    # cleaned_code <- gsub("```r\n|```", "", content)
    # cat(cleaned_code)
    
    ####################
    cleaned_code_wt_libraries <- content |>
      # Remove code block delimiters
      gsub("```r\n|```", "", x = _) |>
      # Remove library calls
      gsub("library\\([^\\)]+\\)\n", "", x = _) |>
      # Remove 'ui <- ' assignment
      gsub("ui <-\\s+", "", x = _) |>
      # Remove 'server' function
      gsub("server <- function\\(input, output, session\\) \\{\\}\n", "", x = _) |>
      # Remove 'shinyApp' call
      gsub("shinyApp\\(ui = ui, server = server\\)", "", x = _) |>
      # Trim leading and trailing whitespace
      trimws()
    
    print(cleaned_code_wt_libraries)
    
    card(
      eval(parse(text = cleaned_code_wt_libraries))
    )
  })
}

shinyApp(ui, server)