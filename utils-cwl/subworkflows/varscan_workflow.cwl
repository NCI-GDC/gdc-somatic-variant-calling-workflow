#!/usr/bin/env cwl-runner

cwlVersion: v1.0

doc: |
    Run VarScan.v2.3.9 pipeline

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: ResourceRequirement
    coresMax: 2

class: Workflow

inputs:
  java_opts:
    doc: Java option flags for all the java cmd
    type: string
    default: '3G'
  tn_pair_pileup:
    doc: samtools mpileup files from t/n pair
    type: File
  min_coverage:
    doc: Minimum coverage in normal and tumor to call variant (8)
    type: int
    default: 8
  min_cov_normal:
    doc: Minimum coverage in normal to call somatic (8)
    type: int
    default: 8
  min_cov_tumor:
    doc: Minimum coverage in tumor to call somatic (6)
    type: int
    default: 6
  min_var_freq:
    doc: Minimum variant frequency to call a heterozygote (0.10)
    type: float
    default: 0.10
  min_freq_for_hom:
    doc: Minimum frequency to call homozygote (0.75)
    type: float
    default: 0.75
  normal_purity:
    doc: Estimated purity (non-tumor content) of normal sample (1.00)
    type: float
    default: 1.00
  tumor_purity:
    doc: Estimated purity (tumor content) of tumor sample (1.00)
    type: float
    default: 1.00
  vs_p_value:
    doc: P-value threshold to call a heterozygote (0.99) when running varscan somatic
    type: float
    default: 0.99
  somatic_p_value:
    doc: P-value threshold to call a somatic site (0.05)
    type: float
    default: 0.05
  strand_filter:
    doc: If set to 1, removes variants with >90% strand bias (0)
    type: int
    default: 0
  validation:
    doc: If set, outputs all compared positions even if non-variant
    type: boolean
    default: false
  output_vcf:
    doc: If set to 1, output VCF instead of VarScan native format
    type: int
    default: 1
  min_tumor_freq:
    doc: Minimun variant allele frequency in tumor [0.10]
    type: float
    default: 0.10
  max_normal_freq:
    doc: Maximum variant allele frequency in normal [0.05]
    type: float
    default: 0.05
  vps_p_value:
    doc: P-value for high-confidence calling [0.07]
    type: float
    default: 0.07
  ref_dict:
    doc: reference sequence dictionary file
    type: File

outputs:
  SNP_SOMATIC_HC:
    type: File
    outputSource: varscan_process_somatic_snp/SOMATIC_HC
  INDEL_SOMATIC_HC:
    type: File
    outputSource: varscan_process_somatic_indel/SOMATIC_HC

steps:
  varscan_somatic:
    run: ../../submodules/varscan-cwl/tools/varscan_somatic.cwl
    in:
      java_opts: java_opts
      tn_pair_pileup: tn_pair_pileup
      min_coverage: min_coverage
      min_cov_normal: min_cov_normal
      min_cov_tumor: min_cov_tumor
      min_var_freq: min_var_freq
      min_freq_for_hom: min_freq_for_hom
      normal_purity: normal_purity
      tumor_purity: tumor_purity
      p_value: vs_p_value
      somatic_p_value: somatic_p_value
      strand_filter: strand_filter
      validation: validation
      output_vcf: output_vcf
    out: [snp_output, indel_output]

  varscan_process_somatic_snp:
    run: varscan_process_somatic_workflow.cwl
    in:
      java_opts: java_opts
      input_vcf: varscan_somatic/snp_output
      min_tumor_freq: min_tumor_freq
      max_normal_freq: max_normal_freq
      p_value: vps_p_value
      ref_dict: ref_dict
    out: [SOMATIC_HC]

  varscan_process_somatic_indel:
    run: varscan_process_somatic_workflow.cwl
    in:
      java_opts: java_opts
      input_vcf: varscan_somatic/indel_output
      min_tumor_freq: min_tumor_freq
      max_normal_freq: max_normal_freq
      p_value: vps_p_value
      ref_dict: ref_dict
    out: [SOMATIC_HC]
