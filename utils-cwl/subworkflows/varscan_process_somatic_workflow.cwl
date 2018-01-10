#!/usr/bin/env cwl-runner

cwlVersion: v1.0

doc: |
    Run VarScan.v2.3.9 processSomatic pipeline

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: ResourceRequirement
    coresMax: 1

class: Workflow

inputs:
  java_opts:
    type: string
    doc: |
      'JVM arguments should be a quoted, space separated list (e.g. -Xmx8g -Xmx16g -Xms128m -Xmx512m)'
    default: '3G'
  input_vcf:
    type: File
    doc: The VarScan-somatic output file for SNPs or InDels
  min_tumor_freq:
    type: float
    doc: Minimun variant allele frequency in tumor [0.10]
    default: 0.10
  max_normal_freq:
    type: float
    doc: Maximum variant allele frequency in normal [0.05]
    default: 0.05
  p_value:
    type: float
    doc: P-value for high-confidence calling [0.07]
    default: 0.07
  ref_dict:
    type: File
    doc: Reference sequence dictionary file

outputs:
  SOMATIC_HC:
    type: File
    outputSource: picard_update_seq_dict/output_vcf_file

steps:
  process_somatic:
    run: ../../submodules/varscan-cwl/tools/process_somatic.cwl
    in:
      java_opts: java_opts
      input_vcf: input_vcf
      min_tumor_freq: min_tumor_freq
      max_normal_freq: max_normal_freq
      p_value: p_value
    out: [germline_all, germline_hc, loh_all, loh_hc, somatic_all, somatic_hc]

  picard_update_seq_dict:
    run: ../picard-cwl/tools/picard_update_seq_dict.cwl
    in:
      java_opts: java_opts
      input_vcf: process_somatic/somatic_hc
      output_filename:
        source: input_vcf
        valueFrom: $(self.nameroot + '.varscan2.somatic.hc.updated.vcf')
      ref_dict: ref_dict
    out: [output_vcf_file]
