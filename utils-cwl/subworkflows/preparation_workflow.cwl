#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

inputs:
  bioclient_config:
    type: File
  tumor_gdc_id:
    type: string
  tumor_index_gdc_id:
    type: string
  normal_gdc_id:
    type: string
  normal_index_gdc_id:
    type: string
  reference_dict_gdc_id:
    type: string
  reference_fa_gdc_id:
    type: string
  reference_fai_gdc_id:
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
  normal_with_index:
    type: File
    outputSource: stage/normal_with_index
  tumor_with_index:
    type: File
    outputSource: stage/tumor_with_index
  reference_with_index:
    type: File
    outputSource: stage/reference_with_index
  known_snp_with_index:
    type: File
    outputSource: stage/dbsnp_with_index
  panel_of_normal_with_index:
    type: File
    outputSource: stage/pon_with_index
  cosmic_with_index:
    type: File
    outputSource: stage/cosmic_with_index

steps:
  normal_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: normal_gdc_id
    out: [output]

  tumor_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: tumor_gdc_id
    out: [output]

  normal_index_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: normal_index_gdc_id
    out: [output]

  tumor_index_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: tumor_index_gdc_id
    out: [output]

  reference_dict_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: reference_dict_gdc_id
    out: [output]

  reference_fa_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: reference_fa_gdc_id
    out: [output]

  reference_fai_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: reference_fai_gdc_id
    out: [output]

  known_snp_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: known_snp_gdc_id
    out: [output]

  known_snp_index_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: known_snp_index_gdc_id
    out: [output]

  panel_of_normal_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: panel_of_normal_gdc_id
    out: [output]

  panel_of_normal_index_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: panel_of_normal_index_gdc_id
    out: [output]

  cosmic_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: cosmic_gdc_id
    out: [output]

  cosmic_index_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: cosmic_index_gdc_id
    out: [output]

  stage:
    run: ../stage.cwl
    in:
      normal: normal_download/output
      normal_index: normal_index_download/output
      tumor: tumor_download/output
      tumor_index: tumor_index_download/output
      reference: reference_fa_download/output
      reference_fai: reference_fai_download/output
      reference_dict: reference_dict_download/output
      dbsnp: known_snp_download/output
      dbsnp_index: known_snp_index_download/output
      pon: panel_of_normal_download/output
      pon_index: panel_of_normal_index_download/output
      cosmic: cosmic_download/output
      cosmic_index: cosmic_index_download/output
    out: [normal_with_index, tumor_with_index, reference_with_index, dbsnp_with_index, pon_with_index, cosmic_with_index]
