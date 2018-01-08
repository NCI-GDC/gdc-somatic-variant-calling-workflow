#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

inputs:
  config_file:
    type: File
  tumor_download_handle:
    type: string
  normal_download_handle:
    type: string

outputs:
  normal_input:
    type: File
    outputSource: samtools_index_normal/bam_with_index
  tumor_input:
    type: File
    outputSource: samtools_index_tumor/bam_with_index

steps:
  bioclient_get_normal:
    run: bioclient/tools/bio_client_download.cwl
    in:
      config_file: config_file
      download_handle: normal_download_handle
    out: [output]

  bioclient_get_tumor:
    run: bioclient/tools/bio_client_download.cwl
    in:
      config_file: config_file
      download_handle: tumor_download_handle
    out: [output]

  samtools_index_normal:
    run: samtools-cwl/tools/samtools_index.cwl
    in:
      input_bam_path: bioclient_get_normal/output
    out: [bam_with_index]

  samtools_index_tumor:
    run: samtools-cwl/tools/samtools_index.cwl
    in:
      input_bam_path: bioclient_get_tumor/output
    out: [bam_with_index]
