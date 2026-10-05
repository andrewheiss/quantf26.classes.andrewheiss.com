library(tidyverse)
library(countrycode)
library(readxl)
library(WDI)

# Get stuff from the World Bank
wdi_raw <- WDI(
  indicator = c(
    gdp_per_cap = "NY.GDP.PCAP.KD",
    life_expectancy = "SP.DYN.LE00.IN",
    internet_use_prop = "IT.NET.USER.ZS",
    urban_prop = "SP.URB.TOTL.IN.ZS",
    women_parliament_prop = "SG.GEN.PARL.ZS",
    unemployment_rate = "SL.UEM.TOTL.ZS",
    population = "SP.POP.TOTL"
  ),
  start = 2011,
  end = 2025,
  extra = TRUE
)

# Clean up the happiness data and join the World Bank stuff to it
happiness_raw <- read_excel("data/raw_data/WHR26_Data_Figure_2.1.xlsx")

happiness <- happiness_raw |>
  mutate(
    continent = countrycode(
      `Country name`,
      origin = "country.name",
      destination = "continent",
      custom_match = c("Kosovo" = "Europe")
    ),
    iso3c = countrycode(
      `Country name`,
      origin = "country.name",
      destination = "iso3c",
      custom_match = c("Kosovo" = "XKX", "Somaliland Region" = "SML")
    )
  ) |>
  left_join(wdi_raw, by = join_by(iso3c, Year == year)) |>
  drop_na(gdp_per_cap, life_expectancy) |>
  mutate(population_millions = population / 1000000) |>
  select(
    country = `Country name`,
    year = Year,
    continent,
    region,
    income_group = income,
    iso3c,
    happiness = `Life evaluation (3-year average)`,
    life_expectancy,
    gdp_per_cap,
    internet_use_prop,
    urban_prop,
    women_parliament_prop,
    unemployment_rate,
    population_millions
  )

# Save it for class
write_csv(
  happiness,
  here::here("projects", "regression-playground", "data", "world_happiness.csv")
)
