#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  normal_input:
    type: File
  tumor_input:
    type: File
  region:
    type: File
  reference:
    type: File
  min_MQ:
    type: int
    default: 1

outputs:
  normal_chunk:
    type: File
    outputSource: split/normal_chunk
  tumor_chunk:
    type: File
    outputSource: split/tumor_chunk
  chunk_mpileup:
    type: File
    outputSource: mpileup_pair/output_file

steps:
  split:
    run: samtools_split_workflow.cwl
    in:
      normal_input: normal_input
      tumor_input: tumor_input
      region: region
    out: [normal_chunk, tumor_chunk]

  mpileup_pair:
    run: ../tools/samtools_mpileup.cwl
    in:
      ref: reference
      region: region
      normal_bam: split/normal_chunk
      tumor_bam: split/tumor_chunk
      min_MQ: min_MQ
    out: [output_file]
