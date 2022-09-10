source(here::here('code/get_api_path.R'))
source(here::here('code/notion_client.R'))

url <- get_api_path('https://www.notion.so/5833862c594241598d35c1b18e989ca3?v=cec80e5e893845cc945f9dd6e4ed2e7d')
#notion <- NotionClient$new()
#res <- notion$post(url)
#res$parse("UTF-8")


response <- VERB("POST", 
                 url = glue::glue('https://api.notion.com/{url}'), 
                 add_headers("Authorization" = paste("Bearer", Sys.getenv('NOTION_ACCESS_TOKEN')),
                             'Notion-Version' = '2022-06-28'), 
                 content_type("application/octet-stream"), 
                 accept("application/json"))
r <- content(response, "parsed")

transform_database <- function(query_response) {
    raw <- tibble::enframe(query_response$results)
    df <- NULL
    for (i in 1:nrow(raw)) {
      tmp <- tibble::enframe(unlist(raw[[i,2]]))
      tmp <- tmp %>%
        dplyr::group_by(name) %>%
        dplyr::summarise('value' = paste(value, collapse = ' | '))
      tmp <- tidyr::pivot_wider(tmp)
      df <- dplyr::bind_rows(df, tmp)
    }
    return(df)
}

df <- transform_database(r) %>%
  dplyr::select(contains('plain_text'))

