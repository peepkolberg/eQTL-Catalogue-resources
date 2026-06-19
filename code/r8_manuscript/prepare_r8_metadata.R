dataset_list = readr::read_tsv("data_tables/r8_dataset_list.tsv", col_names = c("dataset_id"))

upcoming_metadata = readr::read_tsv("data_tables/dataset_metadata_upcoming.tsv")
r8_beta_metadata = readr::read_tsv("data_tables/dataset_metadata_r8_beta.tsv")
r7_metadata = readr::read_tsv("data_tables/dataset_metadata_r7.tsv") %>% dplyr::filter(study_label != "GTEx")
all_meta = dplyr::bind_rows(r7_metadata, r8_beta_metadata, upcoming_metadata)

joint_data = dplyr::filter(all_meta, dataset_id %in% dataset_list$dataset_id)

duplicate_studies = dplyr::group_by(joint_data, study_id, dataset_id) %>% 
  dplyr::summarise(dataset_count = n()) %>% 
  dplyr::filter(dataset_count > 1) %>% 
  dplyr::select(study_id) %>% dplyr::distinct() %>% 
  dplyr::ungroup()

r7_filtered = dplyr::anti_join(r7_metadata, duplicate_studies)
all_meta2 = dplyr::bind_rows(r7_filtered, r8_beta_metadata, upcoming_metadata)
r8_meta = dplyr::filter(all_meta2, dataset_id %in% dataset_list$dataset_id) %>% 
  dplyr::arrange(study_id, dataset_id)
write.table(r8_meta, "data_tables/dataset_metadata_r8.tsv", sep = "\t", quote = F, row.names = F)