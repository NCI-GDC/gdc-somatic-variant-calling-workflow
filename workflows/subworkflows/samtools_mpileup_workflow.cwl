#!/usr/bin/env cwl-runner

cwlVersion: v1.0

doc: |
    GDC Somatic Variant Calling Workflow

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  reference:
    type: File
    secondaryFiles: [.fai, ^.dict]
    doc: Human genome reference file with .fai, ^.dict secondary files.
  bed_file:
    type: File
    doc: BED file.
  normal_bam:
    type: File
    secondaryFiles: .bai
    doc: Normal BAM file with .bai index.
  tumor_bam:
    type: File
    secondaryFiles: .bai
    doc: Tumor BAM file with .bai index.
  threads:
    type: int
    default: 4
    doc: Threads for internal multithreading dockers.
  map_q:
    type: int
    default: 1
    doc: Map quality.

outputs:
  all_mpileups:
    type: File[]
    outputSource: multi_samtools_mpileup/output_file
  true_mpileups:
    type: File[]
    outputSource: get_groups/trueFile

steps:
  multi_samtools_mpileup:
    run: ../../submodules/samtools-mpileup-cwl/tools/multi_samtools_mpileup.cwl
    in:
      ref: reference
      min_MQ: map_q
      region: bed_file
      normal_bam: normal_bam
      tumor_bam: tumor_bam
      thread_count: threads
    out: [output_file]

  get_groups:
    run: ../../tools/util/divide_groups.cwl
    in:
      inputFile: [multi_samtools_mpileup/output_file]
    out: [emptyFile, trueFile]
