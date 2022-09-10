# get path to enter into API from url 
get_api_path <- function(url) {
  # detect if database URL 
  # https://www.notion.so/{workspace_name}/{database_id}?v={view_id}
  if (stringr::str_detect(url, "\\?v\\=")) {
    path <- fs::path_file(url)
    id <- stringr::str_split(path, "\\?v\\=")[[1]][[1]]
    return(glue::glue("v1/databases/{id}/query"))
  } else if (stringr::str_detect(url, "\\#")) {
    # is block 
    id <- stringr::str_split(url, "\\#")[[1]][[2]]
    return(glue::glue("v1/blocks/{id}"))
  } else { # page 
    path <- fs::path_file(url)
    parts <- stringr::str_split(path, "\\-") 
    id <- parts[[1]][[length(parts[[1]])]]
    return(glue::glue("v1/pages/{id}"))
  }
}

# "TESTS"
# page
# get_api_path("https://www.notion.so/Quick-Note-a35e567ca6db4e9e93f72e450b5177de")
# # database
# get_api_path("http://www.notion.so/5833862c594241598d35c1b18e989ca3?v=cec80e5e893845cc945f9dd6e4ed2e7d")
# # block
# get_api_path("https://www.notion.so/TestZ-2e96c943be94470bb076277b8d0c46a6#d5f45db985e940068cd6caf2fea3f2b5")
