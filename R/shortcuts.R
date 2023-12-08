
#' List Available Teams
#'
#' A shortcut for listing Teams teams that you have access to and have been
#' authorised against (see details) without needing to interact with the R6
#' object returned by [Microsoft365R::get_team].
#'
#' @details You must have completed the authorisation process for Teams. To do
#'   this, run `Microsoft365R::list_teams()`, which will open the browser for
#'   automatic authorisation. A token authorising you for the required scopes
#'   will be stored on your computer.
#'
#' @details Note that you'll see the message 'Loading Microsoft Graph login for
#'   default tenant' when tokens are being checked. You may also see 'Access
#'   token has expired or is no longer valid; refreshing' when your token is
#'   stale. Use [base::suppressMessages] to hide these messages.
#'
#' @return Character. Names of Teams teams available to you.
#'
#' @export
#'
#' @examples \dontrun{list_teams_teams()}
list_teams_teams <- function() {

  .check_internet()
  .check_auth(scope_group = "teams")

  teams <- Microsoft365R::list_teams()

  unlist(lapply(teams, function(team) team[["properties"]][["displayName"]]))

}

#' List Available Channels in a Teams Team
#'
#' A shortcut for listing channels in a Teams team that you have access to and
#' have been authorised against (see details) without needing to interact with
#' the R6 object returned by [Microsoft365R::get_team].
#'
#' @param team Character. The name of a Teams team.
#'
#' @details You must have completed the authorisation process for Teams. To do
#'   this, run `Microsoft365R::list_teams()`, which will open the browser for
#'   automatic authorisation. A token authorising you for the required scopes
#'   will be stored on your computer.
#'
#' @details Note that you'll see the message 'Loading Microsoft Graph login for
#'   default tenant' when tokens are being checked. You may also see 'Access
#'   token has expired or is no longer valid; refreshing' when your token is
#'   stale. Use [base::suppressMessages] to hide these messages.
#'
#' @return Character. Names of Teams channels available to you.
#'
#' @export
#'
#' @examples \dontrun{list_teams_channels("Statistics Production Division"))}
list_teams_channels <- function(team = "Statistics Production Division") {

  .check_internet()
  .check_auth(scope_group = "teams")

  if (!is.character(team)) {
    stop("Argument 'team' must be character class.", call. = FALSE)
  }

  team <- Microsoft365R::get_team(team)
  channels <- team$list_channels()

  unlist(
    lapply(
      channels,
      function(channel) channel[["properties"]][["displayName"]]
    )
  )

}

#' List Available Files in a Business OneDrive Directory
#'
#' A shortcut for listing files in a directory in a business OneDrive that you
#' have access to and have been authorised against (see details) without needing
#' to interact with the R6 object returned by
#' [Microsoft365R::get_business_onedrive].
#'
#' @param filepath Character. The path to a OneDrive directory starting from the
#'   root of your business OneDrive directory. Defaults to `NULL`, which will
#'   return the directories and files available to you from the root.
#'
#' @details You must have completed the authorisation process for the channel
#'   that you want to read from. To do this, run
#'   `Microsoft365R::get_business_onedrive()`, which will open the browser for
#'   automatic authorisation. A token authorising you for the required scopes
#'   will be stored on your computer.
#'
#' @details Note that you'll see the message 'Loading Microsoft Graph login for
#'   default tenant' when tokens are being checked. You may also see 'Access
#'   token has expired or is no longer valid; refreshing' when your token is
#'   stale. Use [base::suppressMessages] to hide these messages.
#'
#' @return Character. The names of directories (suffixed with a forward slash)
#'   and files (suffixed with a file extension) available from the provided
#'   filepath.
#'
#' @export
#'
#' @examples \dontrun{list_onedrive_files("Personal")}
list_onedrive_files <- function(filepath = NULL) {

  .check_internet()
  .check_auth(scope_group = "business_onedrive")

  if (!is.null(filepath) & !is.character(filepath)) {
    stop("Argument 'filepath' must be character class.", call. = FALSE)
  }

  business <- Microsoft365R::get_business_onedrive()

  if (is.null(filepath)) {
    files_df <- business$list_files()
  }

  if (!is.null(filepath)) {
    files_df <- business$list_files(filepath)
  }

  files_df[["name_new"]] <- with(
    files_df,
    ifelse(isdir, paste0(name, "/"), name)
  )

  files_df[["name_new"]]

}
