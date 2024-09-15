library(httr2)
library(jsonlite)
library(base64enc)

# Read and encode the image file
image_path <- file.path(getwd(), "ui.png")
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
          text = "Create code for only the user interface of the shiny app based on this image. Do not use shinydashboard code.Do not use fluidRow and column functions. Instead, use bslib code. Do not explain anything. Only provide code. Particularly, refer to this page on bslib docs site https://rstudio.github.io/bslib/articles/dashboards",
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

# save(resp, file="resp.rda")
content <- (resp |> 
  httr2::resp_body_json())$choices[[1]]$message$content 

# Assuming the response is stored in a variable called 'content'
cleaned_code <- gsub("```r\n|```", "", content)

cleaned_code_wt_libraries <- content |>
  # Remove code block delimiters
  gsub("```r\n|```", "", x = _) |>
  # Remove library calls
  gsub("library\\([^\\)]+\\)\n", "", x = _) |>
  # Remove 'ui <- ' assignment
  gsub("ui <-\\s+", "", x = _) |>
  # Trim leading and trailing whitespace
  trimws()

cat(cleaned_code_wt_libraries)
