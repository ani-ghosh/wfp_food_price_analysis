# global data link
library(xml2)
library(rvest)
library(rjson)

dir.create("data/raw", showWarnings = FALSE, recursive = TRUE)
dir.create("data/interim", showWarnings = FALSE, recursive = TRUE)

gu <- "https://data.humdata.org/dataset/31579af5-3895-4002-9ee3-c50857480785/resource/0f2ef8c4-353f-4af1-af97-9e48562ad5b1/download/wfp_countries_global.csv"
download.file(gu, "data/global_wfp_countries.csv", mode = "wb")

d <- read.csv("data/global_wfp_countries.csv")

getWFPdata <- function(i, d){
  url <- d$url[i]
  page <- read_html(url)
  link <- page %>%
    html_nodes("a") %>%
    html_attr("href") %>%
    .[grepl("/download/wfp_food_prices", .)] %>%
    .[!grepl("qc", .)]
  link <- file.path("https://data.humdata.org", link)
  download.file(link, file.path("data/raw", basename(link)), mode = "wb")
}

lapply(2:nrow(d), getWFPdata, d)

# convert all the data in a single fst file
library(fst)
library(tidyverse)

f <- list.files("data/raw/", pattern = "csv$", full.names = TRUE)
da <- lapply(f, read_csv)
dd <- bind_rows(da)

write.fst(dd, paste0("data/interim/wfp_food_prices_all_countries_updated_", format(Sys.time(), "%Y-%m"), ".fst"),100)
