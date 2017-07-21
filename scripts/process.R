library(magrittr)

# ---- Functions ----

list_remote_files <- function(url, pattern = NULL) {
  response <- suppressWarnings(httr::GET(url, config = list(dirlistonly = TRUE)))
  tbl <- response$content %>%
    rawToChar() %>%
    textConnection() %>%
    read.table(stringsAsFactors = FALSE)
  files <- tbl[[ncol(tbl)]]
  if (!is.null(pattern)) {
    files[grepl(pattern, files)]
  } else {
    files
  }
}

build_golive_url <- function(path, row) {
  "ftp://dtn.rc.colorado.edu/work/nsidc0710/nsidc0710_landsat8_golive_ice_velocity_v1/" %>%
    paste0(sprintf("p%03d_r%03d/", path, row))
}

download_golive_files <- function(path, row, dir = ".") {
  url <- build_golive_url(path = path, row = row)
  files <- list_remote_files(url, pattern = "\\.nc$")
  for (file in files) {
    destfile <- file.path(dir, file)
    if (!file.exists(destfile)) {
      download.file(
        url = paste0(url, file),
        destfile = destfile
      )
    }
  }
}

doy_to_date <- function(year, doy) {
  origin <- as.Date(paste0(year, "-01-01"))
  as.Date(as.numeric(doy) - 1, origin = origin)
}

parse_golive_dates <- function(files) {
  m <- regexec("([0-9]{4})_([0-9]{3})_([0-9]{4})_([0-9]{3})", files)
  regmatches(files, m) %>%
    lapply(function(x) {
      list(
        from = doy_to_date(x[2], x[3]),
        to = doy_to_date(x[4], x[5])
      )
    }) %>%
    data.table::rbindlist()
}

process_golive_file <- function(file, outfile, variables = c("vx", "vy", "corr", "del_corr"), names = variables, ...) {
  nc <- ncdf4::nc_open(file)
  # Dimensions
  x <- ncdf4::ncvar_get(nc, "x")
  y <- ncdf4::ncvar_get(nc, "y")
  # Raster extent
  dx = abs(unique(diff(x)))
  dy = abs(unique(diff(y)))
  extent <- raster::extent(
    c(
      xmn = min(x) - dx / 2,
      xmx = max(x) + dx / 2,
      ymn = min(y) - dy / 2,
      ymx = max(y) + dy / 2
    )
  )
  # Variables
  stack <- variables %>%
    lapply(function(var) {
      ncdf4::ncvar_get(nc, var)
    }) %>%
    lapply(t) %>%
    lapply(raster::raster, crs = "+init=epsg:32606") %>%
    lapply(raster::setExtent, extent) %>%
    raster::stack() %>%
    set_names(names)
  # Write to file
  raster::writeRaster(stack, filename = outfile, datatype = "FLT4S", suffix = "names", ...)
}

# ---- Download files ----
DIR <- "archive"

for (path in 66:67) {
  download_golive_files(path = path, row = 17, dir = DIR)
}

# ---- Process files ----
OUTDIR <- "data"

files <- list.files(DIR, full.names = TRUE)
# Check which files have already been processed
dates <- parse_golive_dates(files)
basenames <- paste0(format(dates$from, "%Y%m%d"), "_", format(dates$from, "%Y%m%d"))
exists <- basenames %in% (list.files(outdir) %>% substr(1, 17))
# Process remaining files
for (i in which(!exists)) {
  process_golive_file(
    file = files[i],
    outfile = file.path(OUTDIR, paste0(basenames[i], ".tif")),
    variables = c("vx", "vy", "corr", "del_corr"),
    names = c("vx", "vy", "corr", "dcorr"),
    bylayer = TRUE
  )
}
