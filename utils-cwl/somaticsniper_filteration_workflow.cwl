#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  - id: vcf
    type: File
  - id: pileup
    type: File

outputs:
  - id: POST_LOH_FILTER
    type: File
    outputSource: loh_filter/output
  - id: POST_HC_FILTER
    type: File
    outputSource: highconfidence_filter/output

steps:
  - id: loh_filter
    run: ../submodules/somaticsniper-cwl/tools/loh_filter.cwl
    in:
      - id: vcf
        source: vcf
      - id: pileup
        source: pileup
    out:
      - id: output

  - id: highconfidence_filter
    run: ../submodules/somaticsniper-cwl/tools/highconfidence_filter.cwl
    in:
      - id: vcf
        source: loh_filter/output
    out:
      - id: output
