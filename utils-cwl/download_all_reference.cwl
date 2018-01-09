#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

inputs:
  bioclient_config:
    type: File
  main_reference_dict_gdc_id:
    type: string
  main_reference_fa_gdc_id:
    type: string
  main_reference_fai_gdc_id:
    type: string
  full_reference_dict_gdc_id:
    type: string
  full_reference_fa_gdc_id:
    type: string
  full_reference_fai_gdc_id:
    type: string
  known_snp_gdc_id:
    type: string
  known_snp_index_gdc_id:
    type: string
  panel_of_normal_gdc_id:
    type: string
  panel_of_normal_index_gdc_id:
    type: string
  cosmic_gdc_id:
    type: string
  cosmic_index_gdc_id:
    type: string

outputs:
  main_reference_dict:
    type: File
    outputSource: main_reference_dict_download/output
  main_reference_fa:
    type: File
    outputSource: main_reference_fa_download/output
  main_reference_fai:
    type: File
    outputSource: main_reference_fai_download/output
  full_reference_dict:
    type: File
    outputSource: full_reference_dict_download/output
  full_reference_fa:
    type: File
    outputSource: full_reference_fa_download/output
  full_reference_fai:
    type: File
    outputSource: full_reference_fai_download/output
  known_snp:
    type: File
    outputSource: known_snp_download/output
  known_snp_index:
    type: File
    outputSource: known_snp_index_download/output
  panel_of_normal:
    type: File
    outputSource: panel_of_normal_download/output
  panel_of_normal_index:
    type: File
    outputSource: panel_of_normal_index_download/output
  cosmic:
    type: File
    outputSource: cosmic_download/output
  cosmic_index:
    type: File
    outputSource: cosmic_index_download/output

steps:
  main_reference_dict_download:
  run: bioclient/tools/bio_client_download.cwl
  in:
    config-file: bioclient_config
    download_handle: main_reference_dict_gdc_id
  out: [output]

  main_reference_fa_download:
  run: bioclient/tools/bio_client_download.cwl
  in:
    config-file: bioclient_config
    download_handle: main_reference_fa_gdc_id
  out: [output]

  main_reference_fai_download:
  run: bioclient/tools/bio_client_download.cwl
  in:
    config-file: bioclient_config
    download_handle: main_reference_fai_gdc_id
  out: [output]

  full_reference_dict_download:
  run: bioclient/tools/bio_client_download.cwl
  in:
    config-file: bioclient_config
    download_handle: full_reference_dict_gdc_id
  out: [output]

  full_reference_fa_download:
  run: bioclient/tools/bio_client_download.cwl
  in:
    config-file: bioclient_config
    download_handle: full_reference_fa_gdc_id
  out: [output]

  full_reference_fai_download:
  run: bioclient/tools/bio_client_download.cwl
  in:
    config-file: bioclient_config
    download_handle: full_reference_fai_gdc_id
  out: [output]

  known_snp_download:
  run: bioclient/tools/bio_client_download.cwl
  in:
    config-file: bioclient_config
    download_handle: known_snp_gdc_id
  out: [output]

  known_snp_index_download:
  run: bioclient/tools/bio_client_download.cwl
  in:
    config-file: bioclient_config
    download_handle: known_snp_index_gdc_id
  out: [output]

  panel_of_normal_download:
  run: bioclient/tools/bio_client_download.cwl
  in:
    config-file: bioclient_config
    download_handle: panel_of_normal_gdc_id
  out: [output]

  panel_of_normal_index_download:
  run: bioclient/tools/bio_client_download.cwl
  in:
    config-file: bioclient_config
    download_handle: panel_of_normal_index_gdc_id
  out: [output]

  cosmic_download:
  run: bioclient/tools/bio_client_download.cwl
  in:
    config-file: bioclient_config
    download_handle: cosmic_gdc_id
  out: [output]

  cosmic_index_download:
  run: bioclient/tools/bio_client_download.cwl
  in:
    config-file: bioclient_config
    download_handle: cosmic_index_gdc_id
  out: [output]
