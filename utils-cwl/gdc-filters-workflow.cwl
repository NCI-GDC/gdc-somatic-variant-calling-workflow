#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - $import: ../submodules/variant-filtration-cwl/tools/schemas.cwl

inputs:
###MUSE###MUTECT2###
###VARSCAN2###
###SOMATICSNIPER###
outputs:
steps:
  muse_mutect2_filtration:
    run: ../submodules/variant-filtration-cwl/worflows/gdc-fiters.minimal.cwl
    in:
    out:
  varscan2_filtration:
    run: ../submodules/variant-filtration-cwl/worflows/gdc-filters.with-fpfilter.cwl
    in:
    out:
  somaticsniper_filtration:
    run: ../submodules/variant-filtration-cwl/worflows/gdc-filters.with-fpfilter.with-somaticscore.cwl
    in:
    out:
