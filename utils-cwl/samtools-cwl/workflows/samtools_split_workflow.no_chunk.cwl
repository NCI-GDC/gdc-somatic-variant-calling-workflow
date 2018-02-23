#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  normal_input:
    type: File
  tumor_input:
    type: File
  region:
    type: File

outputs:
  normal_chunk:
    type: File
    outputSource: index_normal/bam_with_index
  tumor_chunk:
    type: File
    outputSource: index_tumor/bam_with_index

steps:
  split_normal:
    run: ../tools/samtools_split.no_chunk.cwl
    in:
      input_bam_path: normal_input
      region: region
    out: [output_file]

  index_normal:
    run: ../tools/samtools_index.cwl
    in:
      input_bam_path: split_normal/output_file
    out: [bam_with_index]

  split_tumor:
    run: ../tools/samtools_split.no_chunk.cwl
    in:
      input_bam_path: tumor_input
      region: region
    out: [output_file]

  index_tumor:
    run: ../tools/samtools_index.cwl
    in:
      input_bam_path: split_tumor/output_file
    out: [bam_with_index]
