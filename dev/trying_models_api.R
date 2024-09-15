PAYLOAD_FILE="payload.json"
IMAGE_DATA="`cat \"$(pwd)/sample.jpg\" | base64`"
echo '{
        "messages": [
            {
                "role": "system",
                "content": "You are a helpful assistant that describes images in details."
            },
            {
                "role": "user",
                "content": [{"text": "What''s in this image?", "type": "text"}, {"image_url": {"url":"data:image/jpeg;base64,'"${IMAGE_DATA}"'","detail":"low"}, "type": "image_url"}]
            }
        ],
        "model": "gpt-4o-mini"
    }' > "$PAYLOAD_FILE"

curl -X POST "https://models.inference.ai.azure.com/chat/completions" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $GITHUB_TOKEN" \
-d @payload.json
echo
rm -f "$PAYLOAD_FILE"











PAYLOAD_FILE="payload.json"
IMAGE_DATA="`cat \"$(pwd)/ui.png\" | base64`"
echo '{
        "messages": [
            {
                "role": "system",
                "content": "You are a an expert in developing shiny web applications in R language."
            },
            {
                "role": "user",
                "content": [{"text": "Create code for only the user interface of the shiny app based on this image. Do not use shinydashboard code. Instead, use bslib code. Do not explain anything. Only provide code. Particularly, refer to this page on bslib docs site https://rstudio.github.io/bslib/articles/dashboards", "type": "text"}, {"image_url": {"url":"data:image/jpeg;base64,'"${IMAGE_DATA}"'","detail":"low"}, "type": "image_url"}]
            }
        ],
        "model": "gpt-4o"
    }' > "$PAYLOAD_FILE"

curl -X POST "https://models.inference.ai.azure.com/chat/completions" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $GITHUB_TOKEN" \
-d @payload.json
echo
rm -f "$PAYLOAD_FILE"