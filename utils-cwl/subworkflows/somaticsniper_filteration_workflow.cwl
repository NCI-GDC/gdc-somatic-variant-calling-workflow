#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  vcf:
    type: File
  pileup:
    type: File

outputs:
  POST_LOH_FILTER:
    type: File
    outputSource: loh_filter/output
  POST_HC_FILTER:
    type: File
    outputSource: highconfidence_filter/output

steps:
  loh_filter:
    run: ../../submodules/somaticsniper-cwl/tools/loh_filter.cwl
    in:
      vcf: vcf
      pileup: pileup
    out: [output]

  highconfidence_filter:
    run: ../../submodules/somaticsniper-cwl/tools/highconfidence_filter.cwl
    in:
      vcf: loh_filter/output
    out: [output]
