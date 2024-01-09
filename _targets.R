options(
  TARGETS_N_CORES = 35
)

suppressPackageStartupMessages({
  library(targets)
  library(sf)
})

source("R/1_prep.R", encoding = "UTF-8")
source("R/2_calculate_access.R", encoding = "UTF-8")

if (!interactive()) future::plan(future.callr::callr)

tar_option_set(workspace_on_error = TRUE)

list(
  tar_target(h3_resolutions, 7:9),
  tar_target(years, 2010),
  tar_target(modes, c("bicycle", "walk")),
  tar_target(time_thresholds, c(30, 60, 90)),
  tar_target(
    pop_units_dataset,
    "../../data/acesso_oport_v2/pop_units.rds",
    format = "file"
  ),
  tar_target(n_batches, 35),
 
  # 1_prep
  tar_target(pop_units, readRDS(pop_units_dataset), iteration = "group"),
  tar_target(
    batches_by_ttm_size,
    get_batches_by_ttm_size(
      pop_units,
      h3_resolutions[h3_resolutions == 9],
      years[years == 2010],
      modes[modes == "bicycle"],
      n_batches
    ),
    iteration = "group"
  ),
  tar_target(
    ttm_paths,
    create_ttm_paths(batches_by_ttm_size, h3_resolutions, years, modes),
    format = "file_fast",
    pattern = cross(batches_by_ttm_size, h3_resolutions, years, modes),
    retrieval = "worker",
    storage = "worker",
    iteration = "list"
  ),
  tar_target(
    opportunities_paths,
    create_opportunities_paths(batches_by_ttm_size, h3_resolutions, years),
    format = "file_fast",
    pattern = cross(batches_by_ttm_size, h3_resolutions, years),
    retrieval = "worker",
    storage = "worker",
    iteration = "list"
  )
  
  # 2_calculate_access
  
)