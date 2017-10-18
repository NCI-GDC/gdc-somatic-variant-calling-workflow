#!/usr/bin/env cwl-runner

cwlVersion: v1.0

doc: |
    Run VarScan.v2.3.9 processSomatic pipeline

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: ResourceRequirement
  
class: Workflow

inputs:
  - id: java_opts
    type: string
    doc: |
      'JVM arguments should be a quoted, space separated list (e.g. -Xmx8g -Xmx16g -Xms128m -Xmx512m)'
    default: '3G'
  - id: input_vcf
    type: File
    doc: The VarScan-somatic output file for SNPs or InDels
  - id: min_tumor_freq
    type: float
    doc: Minimun variant allele frequency in tumor [0.10]
    default: 0.10
  - id: max_normal_freq
    type: float
    doc: Maximum variant allele frequency in normal [0.05]
    default: 0.05
  - id: p_value
    type: float
    doc: P-value for high-confidence calling [0.07]
    default: 0.07
  - id: ref_dict
    type: File
    doc: Reference sequence dictionary file

outputs:
  - id: GERMLINE_ALL
    type: File
    outputSource: process_somatic/germline_all
  - id: GERMLINE_HC
    type: File
    outputSource: process_somatic/germline_hc
  - id: LOH_ALL
    type: File
    outputSource: process_somatic/loh_all
  - id: LOH_HC
    type: File
    outputSource: process_somatic/loh_hc
  - id: SOMATIC_ALL
    type: File
    outputSource: process_somatic/somatic_all
  - id: SOMATIC_HC
    type: File
    outputSource: picard_update_seq_dict/output_vcf_file

steps:
  - id: process_somatic
    run: ../submodules/varscan-cwl/tools/process_somatic.cwl
    in:
      - id: java_opts
        source: java_opts
      - id: input_vcf
        source: input_vcf
      - id: min_tumor_freq
        source: min_tumor_freq
      - id: max_normal_freq
        source: max_normal_freq
      - id: p_value
        source: p_value
    out:
      - id: germline_all
      - id: germline_hc
      - id: loh_all
      - id: loh_hc
      - id: somatic_all
      - id: somatic_hc

  - id: picard_update_seq_dict
    run: picard-cwl/tools/picard_update_seq_dict.cwl
    in:
      - id: java_opts
        source: java_opts
      - id: input_vcf
        source: process_somatic/somatic_hc
      - id: output_filename
        source: input_vcf
        valueFrom: $(self.nameroot + '.varscan2.somatic.hc.updated.vcf')
      - id: ref_dict
        source: ref_dict
    out:
      - id: output_vcf_file
