# pop_units <- tar_read(batches_by_ttm_size) |> dplyr::filter(tar_group == 1)
# res <- tar_read(h3_resolutions)[1]
# year <- tar_read(years)[1]
# mode <- tar_read(modes)[1]
# cutoff <- tar_read(time_thresholds)[1]
calculate_cum_access <- function(pop_units, res, year, mode, cutoff) {
  ttm_paths <- file.path(
    "../../data/acesso_oport_v2/travel_time_matrix",
    paste0("res_", res),
    year,
    mode,
    paste0(pop_units$code_pop_unit, "_", pop_units$treated_name, ".rds")
  )
  
  access_paths <- vapply(
    ttm_paths,
    FUN.VALUE = character(1),
    FUN = function(ttm_path) {
      ttm <- readRDS(ttm_path)
    }
  )
}
