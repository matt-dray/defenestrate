
# {defenestrate}

<!-- badges: start -->
[![Project Status: Inactive – The project has reached a stable, usable state but is no longer being actively developed; support/maintenance will be provided as time allows.](https://www.repostatus.org/badges/latest/inactive.svg)](https://www.repostatus.org/#inactive)
<!-- badges: end -->

The purpose of {defenestrate} is to help me and my team mates interact with files on Microsoft OneDrive and Teams by wrapping and extending functions from the [{Microsoft365R}](https://github.com/Azure/Microsoft365R) package. Your mileage may vary.

Why the name? Something something 'push files out of Windows'.

## Install

You can install the development version of {defenestrate} using {remotes}.

``` r
install.packages("remotes")  # if not yet installed
remotes::install_github("matt-dray/defenestrate")
```

This assumes you've [set up a GitHub Personal Access Token (PAT)](https://happygitwithr.com/https-pat.html), which you can pass to the `auth_token` argument of `install_github()`.

## Authorisation

You must have tokens stored on your computer that prove you're authorised for the 'scopes' (e.g. read, write) needed to interact with each Microsoft service. Authorisation happens automatically through the browser after you run a {Microsoft365R} function. Tokens are time-limited but are automatically refreshed next time you use a {Microsoft365R} function.

Before you use {defenestrate} for the first time you should run a {Microsoft365R} function to get the tokens you need. For example:

* `Microsoft365R::list_teams()` to authorise for the Teams-related scopes
* `Microsoft365R::get_business_onedrive()` to authorise for the OneDrive related-scopes

{defenestrate} will prompt you to do this if you hadn't already.

<details><summary>Click for more on token handling</summary>

Authorisation is handled via [{AzureAuth}](https://github.com/Azure/AzureAuth). Tokens are stored as JSON on your machine in a location resolved using [{rappdirs}](https://github.com/r-lib/rappdirs), e.g. <C:/Users/firstname.lastname/AppData/Local/AzureR/>.

Note that the same Teams authorisation is used regardless of the actual team. You'll only be authorised for the first of these calls, for example:

``` r
Microsoft365R::get_team("Team A")
Microsoft365R::get_team("Team B")
```

But you'll be authorised separately for this one, which has different scopes:

``` r
Microsoft365R::get_business_onedrive()
```

You can always check your stored tokens, which are returned as a list of [R6](https://github.com/r-lib/R6) objects, one element per authorisation:

``` r
AzureAuth::list_azure_tokens()
```

You can extract information from these elements. To extract scopes from the first listed token you could do:

``` r
tokens <- AzureAuth::list_azure_tokens()
tokens[[1]][["scope"]]
```

You can delete all the tokens from your machine. 

``` r
AzureAuth::clean_token_directory()
```

You may want to do this if you run into any trouble with authorisation. Re-run a {Microsoft365R} function to re-authorise automatically in the browser.

</details>

## Examples

### Available resources

You can see the resources available to you on Teams and OneDrive with the `list_*()` functions. These functions simplify the equivalent tasks performed with {Microsoft365R} functions alone.

``` r
list_teams_channels(team = "Team A")
```
```
[1] "Social"      "Team files"      "General"
```

Also available are `list_onedrive_files()` and `list_teams_teams()`.

### Fetch files

You can use the `read_onedrive_table()` and `read_channel_table()` functions to read tabular data (Excel, ods, csv, tsv, rds) from OneDrive or a Teams channel, respectively. 

Here's an example of reading a spreadsheet from a named Teams channel:

``` r
dat <- defenestrate::read_channel_table(
  team      = "Team A",
  channel   = "Team files",
  filepath  = "subfolder/Another subfolder/spreadsheet.xlsx",
  sheet     = 1  # pass extra args to read_excel() via '...'
)

class(dat)
```
```
[1] "tbl_df"     "tbl"      "data.frame"
```

Note that the function automatically selects an appropriate function to read your file given its filetype (e.g. `readr::read_csv()` if the specified file is a csv) and accepts additional arguments you provided via `...`, if any.
