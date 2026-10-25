library(tidyverse)

# Simulated M&Ms for practicing sampling, standard errors, and confidence
# intervals. Colors are drawn from the plain M&M mix at Mars's Cleveland, TN
# factory, so we know the true population parameters.
true_mix <- tribble(
  ~color,   ~p,
  "blue",   0.207,
  "brown",  0.124,
  "green",  0.198,
  "orange", 0.205,
  "red",    0.131,
  "yellow", 0.135
)

set.seed(1234)

# A giant vat of 10,000 M&Ms, one row per M&M (like moderndive's bowl)
mm_vat <- tibble(
  mm_id = 1:10000,
  color = sample(true_mix$color, size = 10000, replace = TRUE, prob = true_mix$p)
)

# A class of 30 students, each with one 45 g bag. Bags are filled by weight,
# not count, so each one has roughly 50 M&Ms (≈0.9 g each). One row per bag,
# with the same columns as the cleaned Google Form data
mm_bags <- tibble(bag = 1:30) |>
  mutate(n = round(rnorm(n(), mean = 50, sd = 2))) |>
  mutate(
    counts = map(n, \(x) {
      rmultinom(1, size = x, prob = true_mix$p)[, 1] |>
        set_names(true_mix$color) |>
        as.list() |>
        as_tibble()
    })
  ) |>
  unnest(counts) |>
  mutate(name = paste("Student", bag), .after = bag) |>
  select(-n)

write_csv(true_mix, "data/mm_true_mix.csv")
write_csv(mm_vat, "data/mm_vat.csv")
write_csv(mm_bags, "data/mm_bags_simulated.csv")

# Copies for the class project
dir.create("projects/mm-sampling/data", showWarnings = FALSE, recursive = TRUE)
file.copy(
  c("data/mm_true_mix.csv", "data/mm_vat.csv", "data/mm_bags_simulated.csv"),
  "projects/mm-sampling/data",
  overwrite = TRUE
)
