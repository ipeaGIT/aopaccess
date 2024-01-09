# pop_units <- tar_read(pop_units)
# res <- 9
# year <- 2010
# mode <- "bicycle"
# n_batches <- tar_read(n_batches)
get_batches_by_ttm_size <- function(pop_units, res, year, mode, n_batches) {
  # use the file size of 2010 bike res 9 matrices to separate pop units in
  # batches. we try to balance the batches with large and small units so that
  # any calculations that depend on them take approximately the same time.
  
  ttm_paths <- file.path(
    "../../data/acesso_oport_v2/travel_time_matrix",
    paste0("res_", res),
    year,
    mode,
    paste0(pop_units$code_pop_unit, "_", pop_units$treated_name, ".rds")
  )
  
  ttm_sizes <- file.size(ttm_paths)
  names(ttm_sizes) <- 1:nrow(pop_units)
  
  ttm_sizes <- ttm_sizes[order(ttm_sizes)]
  assigned_batch <- 1:length(ttm_sizes) %% n_batches
  names(assigned_batch) <- names(ttm_sizes)
  
  pop_units$batch <- replace(
    NULL,
    list = as.integer(names(assigned_batch)),
    values = assigned_batch
  )
  
  # target groups (which is what we'll use the batches for) need to be specified
  # in the tar_group column. they need to be > 0, so we have to add 1, as the 
  # batches, as calculated, include 0s.
  
  pop_units$tar_group <- pop_units$batch
  pop_units$tar_group <- pop_units$tar_group + 1
  pop_units$batch <- NULL
  
  return(pop_units)
}

# pop_units <- tar_read(batches_by_ttm_size) |> dplyr::filter(tar_group == 1)
# res <- tar_read(h3_resolutions)[1]
# year <- tar_read(years)[1]
# mode <- tar_read(modes)[1]
create_ttm_paths <- function(pop_units, res, year, mode) {
  ttm_paths <- file.path(
    "../../data/acesso_oport_v2/travel_time_matrix",
    paste0("res_", res),
    year,
    mode,
    paste0(pop_units$code_pop_unit, "_", pop_units$treated_name, ".rds")
  )
  
  return(ttm_paths)
}

# pop_units <- tar_read(batches_by_ttm_size) |> dplyr::filter(tar_group == 1)
# res <- tar_read(h3_resolutions)[1]
# year <- tar_read(years)[1]
create_opportunities_paths <- function(pop_units, res, year) {
  opportunities_paths <- file.path(
    "../../data/acesso_oport_v2/hex_grids_with_data",
    paste0("res_", res),
    year,
    paste0(pop_units$code_pop_unit, "_", pop_units$treated_name, ".rds")
  )
  
  return(opportunities_paths)
}
