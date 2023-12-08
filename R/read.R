
#' Read Tabular Data from a Teams Channel
#'
#' Read in data from a file that's available from a channel in a Microsoft Teams
#' team that you have access to and have been authorised against (see details).
#'
#' @param team Character. The name of a Teams team.
#' @param channel Character. The name of a channel in the Teams team provided to
#'   the 'team' argument.
#' @param filepath Character. The path to a file that contains tabular data to
#'   be read in.
#' @param ... Additional arguments to pass to the function that will be used to
#'   read in the data, which depends on the type of file being read. See
#'   details.
#'
#' @details You need to have a token on your computer that authorises you to use
#'   the scopes required to access data on Teams. The easiest way to do this is
#'   to run a function like [Microsoft365R::list_teams], which will open a
#'   browser window and authorise you automatically. Then you can use
#'   {defenestrate} functions. You only need to do this authorisation once.
#'
#' @details Note that you'll see the message 'Loading Microsoft Graph login for
#'   default tenant' when tokens are being checked. You may also see 'Access
#'   token has expired or is no longer valid; refreshing' when your token is
#'   stale. Use [base::suppressMessages] to hide these messages.
#'
#' @details The exact function used internally by [read_channel_table] to read
#'   data depends on the filetype. For Excel files, [readxl::read_excel]; for
#'   ODS files, [readODS::read_ods]; for CSV and TSV files, [readr::read_csv]
#'   and [readr::read_tsv]; for RDS files, [readr::read_rds]. You can supply
#'   extra arguments from these functions to the '...' (dots) argument. For
#'   example, if reading an xlsx file, you could use the argument `sheet = 1` to
#'   read the first sheet only.
#'
#' @return A data.frame/tibble class object.
#'
#' @export
#'
#' @examples
#'     \dontrun{read_channel_table("Team Name", "Channel Name", "file.csv")}
read_channel_table <- function(
    team      = "Statistics Production Division",
    channel   = "Team files and A_L",
    filepath  = "QPD/Knowledge bank/QPD knowledge bank.xlsx",
    ...
) {

  .check_internet()
  .check_auth(scope_group = "teams")

  if (!is.character(team) | !is.character(channel) | !is.character(filepath)) {
    stop(
      "Arguments 'team', 'channel' and 'filepath' must be character strings.",
      call. = FALSE
    )
  }


  team <- Microsoft365R::get_team(team)
  channel <- team$get_channel(channel)

  file_type <- .extract_file_type(filepath)
  temp_file <- tempfile(fileext = file_type)
  channel$download_file(filepath, temp_file)
  table <- .read_file_type(file_type, temp_file, ...)
  unlink(temp_file)

  return(table)

}

#'Read Tabular Data from OneDrive
#'
#'Read in data from a file that's available from your business's OneDrive, which
#'you have access to and have been authorised against (see details).
#'
#'@param filepath Character. The path to a file that contains tabular data to be
#'  read in, starting from the root of your Business OneDrive folder, i.e. 
#'  C:/Users/your.name/OneDrive - UK Health Security Agency/ (see the files
#'  and folders available from this location by running [list_onedrive_files]
#'  with empty arguments).
#'@param ... Additional arguments to pass to the function that will be used to
#'  read in the data, which depends on the type of file being read. See details.
#'
#' @details You need to have a token on your computer that authorises you to use
#'   the scopes required to access data on Teams. The easiest way to do this is
#'   to run a function like [Microsoft365R::get_business_onedrive], which will
#'   open a browser window and authorise you automatically. Then you can use
#'   {defenestrate} functions. You only need to do this authorisation once.
#'
#'@details Note that you'll see the message 'Loading Microsoft Graph login for
#'  default tenant' when tokens are being checked. You may also see 'Access
#'  token has expired or is no longer valid; refreshing' when your token is
#'  stale. Use [base::suppressMessages] to hide these messages.
#'
#' @details The exact function used internally by [read_onedrive_table] to read
#'   data depends on the filetype. For Excel files, [readxl::read_excel]; for
#'   ODS files, [readODS::read_ods]; for CSV and TSV files, [readr::read_csv]
#'   and [readr::read_tsv]; for RDS files, [readr::read_rds]. You can supply
#'   extra arguments from these functions to the '...' (dots) argument. For
#'   example, if reading an xlsx file, you could use the argument `sheet = 1` to
#'   read the first sheet only.
#'
#'@return A data.frame/tibble class object.
#'
#'@export
#'
#' @examples
#'     \dontrun{read_onedrive_table("Personal/file.csv")}
read_onedrive_table <- function(filepath, ...) {

  .check_internet()
  .check_auth(scope_group = "business_onedrive")

  if (!is.character(filepath)) {
    stop("Argument 'filepath' must be character class.", call. = FALSE)
  }

  business <- Microsoft365R::get_business_onedrive()

  file_type <- .extract_file_type(filepath)
  temp_file <- tempfile(fileext = file_type)
  business$download_file(filepath, temp_file)
  table <- .read_file_type(file_type, temp_file, ...)
  unlink(temp_file)

  return(table)

}
