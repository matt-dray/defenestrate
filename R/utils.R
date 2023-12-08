#' Check for Internet
#'
#' @return Nothing if there's an internet connection, otherwise a warning.
.check_internet <- function() {

  if (!curl::has_internet()) {
    warning("You aren't connected to the internet.", call. = FALSE)
  }

}

#' Check for a Specified Token
#'
#' @param scope_group Character. The name for a set of scopes that allow access
#'   to Microsoft services. See details.
#'
#' @details Each Microsoft product requires a token that covers particular
#'   scopes of interaction. The names of these, as used in the `scope_group`
#'   argument, are analogous to the associated functions in 'Microsoft365R':
#'   `"team"` for using Teams, the token for which is generated when you use
#'   [Microsoft365R::list_teams]; `"business_onedrive"` for using OneDrive, the
#'   token for which is generated when you use
#'   [Microsoft365R::get_business_onedrive].
#'
#' @return Nothing if the specified token is found, otherwise an error.
.check_auth <- function(scope_group = c("teams", "business_onedrive")) {

  scope_group <- match.arg(scope_group)

  tokens <- AzureAuth::list_azure_tokens()

  if (length(tokens) == 0) {

    if (scope_group == "teams") {
      code_to_run <- "list_teams()"
    }

    if (scope_group == "business_onedrive") {
      code_to_run <- "get_business_onedrive()"
    }

    stop(
      "You don't have any stored tokens. ",
      "Authorise in the browser first by running Microsoft365R::", code_to_run, ".",
      call. = FALSE
    )

  }

  if (scope_group == "teams") {
    scope_strings <- c(
      "https://graph.microsoft.com/Group.ReadWrite.All",
      "https://graph.microsoft.com/Directory.Read.All",
      "openid",
      "offline_access"
    )
  }

  if (scope_group == "business_onedrive") {
    scope_strings <- c(
      "https://graph.microsoft.com/Files.ReadWrite.All",
      "https://graph.microsoft.com/User.Read",
      "openid",
      "offline_access"
    )
  }

  scope_matches <- lapply(
    tokens,
    function(token) all(token$scope %in% scope_strings)
  )

  has_required_token <- length(Filter(isTRUE, scope_matches)) > 0

  if (!has_required_token) {

    if (scope_group == "teams") {
      code_to_run <- "list_teams()"
    }

    if (scope_group == "business_onedrive") {
      code_to_run <- "get_business_onedrive()"
    }

    stop(
      "You don't have a stored token for this scope. ",
      "Authorise in the browser first by running Microsoft365R::", code_to_run, ".",
      call. = FALSE
    )

  }

}

#' Identify File Type and Check that It's Valid
#'
#' @param filepath Character. The path to a file that contains tabular data to
#'   be read in.
#'
#' @return A character string representing the filetype.
.extract_file_type <- function(filepath) {

  file_type <- tolower(tools::file_ext(filepath))

  if (!grepl("xl", file_type) & !file_type %in% c("ods", "csv", "tsv", "rds")) {
    stop(
      "The file extension should be an Excel format like xlsx, ",
      "otherwise ods, csv, tsv or rds.",
      call. = FALSE
    )
  }

  return(file_type)

}

#' Choose a Function to Read a Given File Type and Read It
#'
#' @param file_type Character. The file extension of the file being read.
#' @param temp_file Character. A filepath to a temporary file where the data
#'   will be written.
#' @param ... Additional arguments to pass to the function that will be used to
#'   read in the data, which depends on the type of file being read.
#'
#' @return A data.frame/tibble if the file exists and can be read.
.read_file_type <- function(file_type, temp_file, ...) {

  if (grepl("xl", file_type)) {
    table <- readxl::read_excel(temp_file, ...)
  }

  if (file_type == "ods") {
    table <- readODS::read_ods(temp_file, ...)
  }

  if (file_type == "csv") {
    table <- readr::read_csv(temp_file, ...)
  }

  if (file_type == "tsv") {
    table <- readr::read_tsv(temp_file, ...)
  }

  if (file_type == "rds") {
    table <- readr::read_rds(temp_file, ...)
  }

  if (is.null(table)) {
    warning("No table was returned. Check that the file exists.", call. = FALSE)
  }

  table

}
