# defenestrate 0.1.0

* Set up package with license, readme and news.
* Added `read_channel_table()` and `read_onedrive_table()` functions for reading tabular data from Teams and OneDrive.
* Added `list_teams_teams()`, `list_teams_channels()` and `list_onedrive_files()` functions that return to the user a vector of available teams, channels and files. These functions shortcut the equivalent {Microsoft365R} calls and simplify the output.
* Added util functions to simplify the shared function-body content of the `read_*()` functions.
