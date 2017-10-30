#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

inputs:
  aws_config_file:
    type: File
  aws_shared_credentials_file:
    type: File
  normal_s3cfg_section:
    type: string
  normal_endpoint_url:
    type: string
  normal_s3url:
    type: string
  tumor_s3cfg_section:
    type: string
  tumor_endpoint_url:
    type: string
  tumor_s3url:
    type: string

outputs:
  normal_input:
    type: File
    outputSource: samtools_index_normal/bam_with_index
  tumor_input:
    type: File
    outputSource: samtools_index_tumor/bam_with_index

steps:
  aws_get_normal:
    run: aws/tools/aws_s3_get.cwl
    in:
      aws_config_file: aws_config_file
      aws_shared_credentials_file: aws_shared_credentials_file
      s3cfg_section: normal_s3cfg_section
      endpoint_url: normal_endpoint_url
      s3url: normal_s3url
    out: [output]

  aws_get_tumor:
    run: aws/tools/aws_s3_get.cwl
    in:
      aws_config_file: aws_config_file
      aws_shared_credentials_file: aws_shared_credentials_file
      s3cfg_section: tumor_s3cfg_section
      endpoint_url: tumor_endpoint_url
      s3url: tumor_s3url
    out: [output]

  samtools_index_normal:
    run: samtools-cwl/tools/samtools_index.cwl
    in:
      input_bam_path: aws_get_normal/output
    out: [bam_with_index]

  samtools_index_tumor:
    run: samtools-cwl/tools/samtools_index.cwl
    in:
      input_bam_path: aws_get_tumor/output
    out: [bam_with_index]
