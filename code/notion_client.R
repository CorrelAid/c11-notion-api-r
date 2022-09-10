library(httr)
library(magrittr)
# functions to write
# url builder (take base url, asset type and identifier and output format?)
# if we write the functions outside the classes and set them later in the class
# code readability is higher imo

#' @title Repair URL by appending trailing slash
#' @param path The path, for example appended to the base URL.
#' @return The path string with optionally an appended trailing slash.
#' @noRd
append_slash <- function(path) {
  if (substr(path, nchar(path), nchar(path)) != "/") {
    return(paste0(path, "/"))
  } else {
    return(path)
  }
}

#' Helper function to convert R list to JSON-like string
#'
#' @description
#' Converts R lists to JSON-like strings for POST request's body.
#'
#' #' @keywords internal
#'
#' @param list R list that should be converted to the JSON-like string
#'
#' @examples
#' \dontrun{
#' example_body <- list_as_json_char(list(
#'   "name" = "A survey object created via API/R",
#'   "asset_type" = "survey"
#' ))
#' }
#'
list_as_json_char <- function(list) {
  jsonlite::toJSON(x = list, pretty = TRUE, auto_unbox = TRUE) %>%
    as.character()
}


#' @title Access Read-Only Active Bindings
#'
#' @description
#' Template function to create a read-only active binding.
#' @param private Pointer to the private env of an object
#' @param field character(1) the name of the active binding field. It is assumed
#' that a private field prefixed with a single dot exists, that serves as
#' storage.
#' @param val The value passed to the active binding. If it is not missing,
#' the function will stop.
#' @return The value of the active binding-related storage field.
read_only_active <- function(private, field, val) {
  assert_string(field)
  if (!missing(val)) {
    ui_stop(sprintf("Field '%s' is read-only.", field))
  } else {
    return(private[[paste0(".", field)]])
  }
}

#' @title NotionClient
#' @description
#' A class to interact with the Notion API, extending [`crul::HttpClient`].
#' @importFrom crul HttpClient
#' @export
NotionClient <- R6::R6Class("NotionClient",
                            inherit = crul::HttpClient,
                            public = list(
                              
                              # Public Methods ===========================================================
                              
                              #' @description
                              #' Initialization method for class "NotionClient".
                              #' @param base_url character. The full base URL of the API.
                              #' @param notion_token character. The API token. Defaults to requesting
                              #'  the system environment variable `NOTION_ACCESS_TOKEN`.
                              initialize = function(base_url = "https://api.notion.com/",
                                                    notion_token = Sys.getenv("NOTION_ACCESS_TOKEN")) {
                                checkmate::assert_string(base_url)
                                checkmate::assert_string(notion_token)
                                
                                if (notion_token == "") {
                                  usethis::ui_stop(
                                    "No valid token detected. Set the notion_token environment
                    variable or pass the token directly to the function
                    (not recommended)."
                                  )
                                }
                                private$notion_token <- notion_token
                                private$base_url <- base_url
                                
                                super$initialize(
                                  url = base_url,
                                  headers = list(
                                    Authorization = paste0("Bearer ", notion_token),
                                    `Notion-Version` = "2021-05-13"
                                    # "content-type" = "application/json"
                                  )
                                )
                              },
                              #' @description
                              #' Perform a GET request (with additional checks)
                              #'
                              #' @details
                              #' Extension of the `crul::HttpClient$get()` method that checks
                              #' the HttpResponse object on status, that it is of type
                              #' `application/json`, and parses the response text subsequently from
                              #' JSON to R list representation.
                              #' @param path character. Path component of the endpoint.
                              #' @param query list. A named list which is parsed to the query
                              #'  component. The order is not hierarchical.
                              #' @param ... crul-options. Additional option arguments, see
                              #'  [`crul::HttpClient`] for reference
                              #' @return the server response as a crul::HttpResponse object.
                              get = function(path, query = list(), ...) {
                                res <- super$get(
                                  path = path,
                                  query = query,
                                  ...
                                )
                                return(res)
                              },
                              
                              #' @description
                              #' Perform a POST request
                              #'
                              #' @details
                              #' Extension of the `crul::HttpClient$post()` method.
                              #' @param path character. Path component of the endpoint.
                              #' @param body R list. A data payload to be sent to the server.
                              #' @param ... crul-options. Additional option arguments, see
                              #'  [`crul::HttpClient`] for reference
                              #' @return Returns an object of class `crul::HttpResponse`.
                              post = function(path, body, ...) {
                                checkmate::assert_string(path)
                                checkmate::assert_list(body)
                                
                                #path <- append_slash(path)
                                res <- super$post(path = path, body = body, ...)
                                res$raise_for_status()
                                return(res)
                              }
                            ), # <end public>
                            private = list(
                              
                              # Private Fields ===========================================================
                              
                              base_url = "", 
                              notion_token = ""
                            ) # <end private>
)

# test
#source(here::here("code/get_api_path.R"))
#url <- get_api_path('https://www.notion.so/TestZ-2e96c943be94470bb076277b8d0c46a6')
#notion <- NotionClient$new()
#res <- notion$get(url)
#res$parse("UTF-8")
