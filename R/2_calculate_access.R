# ttm_paths <- tar_read(ttm_paths, branches = 1)[[1]]
# opportunities_paths <- tar_read(opportunities_paths, branches = 1)[[1]]
# mode <- tar_read(modes)[1]
# cutoffs <- tar_read(time_thresholds)
calculate_cum_access <- function(ttm_paths,
                                 opportunities_paths,
                                 mode,
                                 cutoffs) {
  access_dir <- "../../data/acesso_oport_v2/accessibility"
  if (!dir.exists(access_dir)) dir.create(access_dir)
  
  # the mode argument is actually never used, but is needed to create the
  # pattern used (in the targets configuration) to match each ttm to its
  # correspondent land use data
  
  access_paths <- purrr::map2_chr(
    ttm_paths,
    opportunities_paths,
    function(ttm_path, opportunities_path) {
      ttm <- readRDS(ttm_path)
      opportunities <- readRDS(opportunities_path)
      opportunities$id <- opportunities$h3_address
    
      cum_access <- accessibility::cumulative_cutoff(
        ttm,
        opportunities,
        opportunity = "pop_total",
        travel_cost = "travel_time_p50",
        cutoff = cutoffs
      )
      
      # cells without people and opportunities are not included in the travel
      # time matrix. consequently, they are not added to the accessibility
      # dataset either. we manually imput these cells to the data, with access
      # as 0
      
      cum_access <- fill_missing_ids(
        cum_access,
        opportunities,
        cutoffs = cutoffs
      )
      
      # extract only the <res>/<year>/<mode>/<pop_unit> portion of the path to
      # generate the accessibility path
      
      path_portion <- stringr::str_extract(
        ttm_path,
        "res_\\d*\\/\\d{4}\\/(bicycle|walk|car)\\/.*\\.rds$"
      )
      
      path <- file.path(access_dir, path_portion)
      
      data_dir <- dirname(path)
      if (!dir.exists(data_dir)) dir.create(data_dir, recursive = TRUE)
      
      saveRDS(cum_access, path)
      
      path
    }
  )
  
  return(access_paths)
}

fill_missing_ids <- function(access_df, opportunities, cutoffs) {
  unique_ids <- opportunities$id
  
  possible_combinations <- data.table::CJ(
    id = unique_ids,
    travel_time_p50 = cutoffs
  )
  
  if (nrow(access_df) < nrow(possible_combinations)) {
    possible_combinations[
      access_df,
      on = c("id", "travel_time_p50"),
      pop_total := i.pop_total
    ]
    possible_combinations[is.na(pop_total), pop_total := 0]
  }
  
  return(possible_combinations[])
}
