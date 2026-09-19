#!/usr/bin/env Rscript
#
# Convert rendered reveal.js slide decks to PDF using decktape.
#
# Best to run this as a Quarto project post-render script, but in a separate
# profile so it doesn't run *every time* the site re-renders.
#
# This checks the modified time of each slideshow's .qmd file and only converts
# to PDF if there's a change. It then sticks the rendered PDF in the same folder
# as the .qmd file for the slideshow, using the name of the parent folder (so
# slides/01-intro/index.qmd becomes slides/01-intro/01-intro.pdf)
#
# This also adds `?decktape=true`` to the URL so that a script in
# slides/_metadata.yml can inject the .decktape-export class to <html> so that I
# can make CSS tweaks to the version of HTML slides that get converted
#
# Usage (from the project root):
#   ./bin/slides-to-pdf.R                    # update every out-of-date deck
#   ./bin/slides-to-pdf.R 07-wrangling-data  # convert just one deck, forced
#   ./bin/slides-to-pdf.R --force            # reconvert everything
#   ./bin/slides-to-pdf.R --help

suppressPackageStartupMessages({
  library(optparse)
  library(cli)
})
options(rlang_backtrace_on_error = "none")

chrome_path <- "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
site_dir <- "_site/slides"
src_dir <- "slides"

parser <- OptionParser(
  usage = "%prog [deck-name] [options]",
  description = "Convert rendered reveal.js slide decks in _site/slides/ to PDF with decktape.",
  option_list = list(
    make_option(
      c("-f", "--force"),
      action = "store_true",
      default = FALSE,
      help = "Reconvert every deck, even if its cached PDF looks up to date"
    )
  )
)
parsed <- parse_args(parser, positional_arguments = c(0, 1))
filter <- if (length(parsed$args) == 1) parsed$args[1] else ""
force <- parsed$options$force

if (!dir.exists(site_dir)) {
  cli_abort("No {.path {site_dir}} found — run {.code quarto render} first.")
}

if (!file.exists(chrome_path)) {
  cli_abort("Google Chrome not found at {.path {chrome_path}}")
}

decks <- list.files(
  site_dir,
  pattern = "^index\\.html$",
  recursive = TRUE,
  full.names = TRUE
)
decks <- decks[dirname(dirname(decks)) == site_dir]
deck_names <- basename(dirname(decks))

if (nzchar(filter) && !(filter %in% deck_names)) {
  cli_abort(c(
    "No deck named {.field {filter}} in {.path {site_dir}}.",
    "i" = "Available decks: {.field {deck_names}}"
  ))
}

for (deck in decks) {
  dir <- dirname(deck)
  name <- basename(dir)

  if (nzchar(filter) && name != filter) next

  out <- file.path(dir, paste0(name, ".pdf"))
  src <- file.path(src_dir, name)
  cached <- file.path(src, paste0(name, ".pdf"))

  stale <- TRUE
  if (dir.exists(src) && file.exists(cached)) {
    src_files <- list.files(src, recursive = TRUE, full.names = TRUE)
    stale <- any(file.info(src_files)$mtime > file.info(cached)$mtime)
  }

  if (force || identical(filter, name) || stale) {
    url <- paste0("file://", normalizePath(deck), "?decktape=true")

    cli_alert("Converting {.field {name}}...")
    status <- system2("npx", shQuote(c(
      "--yes", "decktape@latest",
      paste0("--chrome-path=", chrome_path),
      "--chrome-arg=--no-sandbox",
      paste0("--pdf-title=", name),
      "--pdf-author=Andrew Heiss",
      "reveal",
      url,
      cached
    )))
    if (status != 0) {
      cli_abort("decktape failed for {.field {name}}")
    }
    cli_alert_success("Converted {.field {name}}")
  } else {
    cli_alert_info("Skipping {.field {name}} (PDF already up to date)")
  }

  file.copy(cached, out, overwrite = TRUE)
}

cli_alert_success("Done!")
