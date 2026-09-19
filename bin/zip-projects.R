#!/usr/bin/env Rscript
#
# Zip up each folder in projects/ into a downloadable .zip file.
#
# Best to run this as a Quarto project post-render script, but in a separate
# profile so it doesn't run *every time* the site re-renders.
#
# Every folder directly inside projects/ (e.g. projects/02-problem-set/) is
# rezipped each time this runs, so the .zip file will always reflect what's in
# th efolders. 
#
# Junk files like .DS_Store and Thumbs.db are excluded.
#
# And importantly, the .zip file contents aren't wrapped in an extra top-level
# folder matching the zip's name! Without doing that, Windows sticks the
# extracted files in a doubled up folder like 02-problem-set/02-problem-set/
# which is annoying
#
# Usage (from the project root):
#   ./bin/zip-projects.R

suppressPackageStartupMessages({
  library(cli)
  library(fs)
})
options(rlang_backtrace_on_error = "none")

projects_dir <- "projects"

junk_pattern <- "(^|/)(\\.DS_Store|__MACOSX|Thumbs\\.db|desktop\\.ini)($|/)|\\.zip$"

if (!dir_exists(projects_dir)) {
  cli_abort("No {.path {projects_dir}} folder found.")
}

project_folders <- dir_ls(projects_dir, type = "directory")

if (length(project_folders) == 0) {
  cli_alert_info("No folders found in {.path {projects_dir}}.")
  quit(status = 0)
}

for (folder in project_folders) {
  name <- path_file(folder)
  zip_path <- path_abs(path(projects_dir, paste0(name, ".zip")))

  all_files <- dir_ls(folder, recurse = TRUE, type = "file", all = TRUE)

  # Get all the files relative to the project's folder (not relative to
  # projects/!). Otherwise the list of files will have the parent folder name
  # built in and Windows will add a subfolder :(
  rel_files <- path_rel(all_files, start = folder)
  rel_files <- rel_files[!grepl(junk_pattern, rel_files)]

  if (length(rel_files) == 0) {
    cli_alert_warning("Skipping {.field {name}} (nothing to zip)")
    next
  }

  # root = folder here makes sure all the files are zipped up relative to the
  # folder, so Windows doesn't make any subfolders
  if (file_exists(zip_path)) {
    file_delete(zip_path)
  }
  zip::zip(zip_path, rel_files, root = folder)

  cli_alert_success(
    "Zipped {.field {name}} {symbol$arrow_right} {.path {path_file(zip_path)}}"
  )
}

cli_alert_success("Done!")
