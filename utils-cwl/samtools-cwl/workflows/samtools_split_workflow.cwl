#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  - id: normal_input
    type: File
  - id: tumor_input
    type: File
  - id: region
    type: File
  - id: prefix
    type: string

outputs:
  - id: normal_chunk
    type: File
    outputSource: index_normal/bam_with_index
  - id: tumor_chunk
    type: File
    outputSource: index_tumor/bam_with_index

steps:
  - id: split_normal
    run: ../tools/samtools_split.cwl
    in:
      - id: input_bam_path
        source: normal_input
      - id: region
        source: region
      - id: output_bam_path
        source: prefix
        valueFrom: $(self + '.normal.bam')
    out:
      - id: output_file

  - id: index_normal
    run: ../tools/samtools_index.cwl
    in:
      - id: input_bam_path
        source: split_normal/output_file
    out:
      - id: bam_with_index

  - id: split_tumor
    run: ../tools/samtools_split.cwl
    in:
      - id: input_bam_path
        source: tumor_input
      - id: region
        source: region
      - id: output_bam_path
        source: prefix
        valueFrom: $(self + '.tumor.bam')
    out:
      - id: output_file

  - id: index_tumor
    run: ../tools/samtools_index.cwl
    in:
      - id: input_bam_path
        source: split_tumor/output_file
    out:
      - id: bam_with_index
