library(tidyverse)
library(haven)

# Arab Barometer Wave VIII (2023–2024)
# https://www.arabbarometer.org/survey-data/data-downloads/
barometer_raw <- read_stata(
  "projects/intro-dataviz/data/ArabBarometer_WaveVIII_English_v3.dta"
)

# Turn "Don't know" and "Refused to answer" into NA
clean_answer <- function(x) {
  x <- as.character(as_factor(x))
  if_else(x %in% c("Don’t know", "Refused to answer"), NA, x)
}

barometer <- barometer_raw |>
  mutate(across(c(Q13, Q1002, Q104, Q103, Q409, Q516_4), clean_answer)) |>
  transmute(
    id = row_number(),
    country = as.character(as_factor(COUNTRY)),
    weight = WT,
    urban_rural = Q13,
    age = if_else(Q1001 <= 100, as.numeric(Q1001), NA),
    gender = Q1002,
    # Q104: Have you ever thought about emigrating from [country]?
    thought_emigrating = Q104,
    # Q103: Most people can be trusted, or must be very careful?
    trust_people = Q103,
    # Q409: How often do you use the internet?
    uses_internet = case_when(
      Q409 == "Do not use" ~ "No",
      !is.na(Q409) ~ "Yes"
    ),
    # Q516_4: Democracy may have problems, yet it's better than other systems
    # (only asked of half the sample)
    democracy_best = case_when(
      Q516_4 %in% c("Strongly agree", "Agree") ~ "Agree",
      Q516_4 %in% c("Strongly disagree", "Disagree") ~ "Disagree"
    )
  )

# Save it for class
write_csv(barometer, "data/arab_barometer.csv")
