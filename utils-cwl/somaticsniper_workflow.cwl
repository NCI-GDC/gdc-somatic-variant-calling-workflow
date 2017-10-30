#!/usr/bin/env cwl-runner

cwlVersion: v1.0

doc: |
    Run Somaticsniper (v1.0.5) pipeline

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  
inputs:
  normal_input:
    type: File
    doc: normal input bam for samtools splitting
  tumor_input:
    type: File
    doc: tumor input bam for samtools splitting
  mpileup:
    type: File
    doc: mpileup file on t/n pair
  reference:
    type: File
    doc: human reference genome
  map_q:
    type: int
    default: 1
    doc: filtering reads with mapping quality less than this value
  base_q:
    type: int
    default: 15
    doc: filtering somatic snv output with somatic quality less than this value
  loh:
    type: boolean
    default: true
    doc: do not report LOH variants as determined by genotypes (T/F)
  gor:
    type: boolean
    default: true
    doc: do not report Gain of Reference variants as determined by genotypes (T/F)
  psc:
    type: boolean
    default: false
    doc: disable priors in the somatic calculation. Increases sensitivity for solid tumors (T/F)
  ppa:
    type: boolean
    default: false
    doc: Use prior probabilities accounting for the somatic mutation rate (T/F)
  pps:
    type: float
    default: 0.01
    doc: prior probability of a somatic mutation (implies -J)
  theta:
    type: float
    default: 0.85
    doc: theta in maq consensus calling model (for -c/-g)
  nhap:
    type: int
    default: 2
    doc: number of haplotypes in the sample
  pd:
    type: float
    default: 0.001
    doc: prior of a difference between two haplotypes
  fout:
    type: string
    default: 'vcf'
    doc: output format (classic/vcf/bed)

outputs:
  ANNOTATED_VCF:
    type: File
    outputSource: annotate_back/annotated_vcf

steps:
  somaticsniper_calling:
    run: ../submodules/somaticsniper-cwl/tools/somaticsniper_tool.cwl
    in:
      ref: reference
      map_q: map_q
      base_q: base_q
      loh: loh
      gor: gor
      psc: psc
      ppa: ppa
      pps: pps
      theta: theta
      nhap: nhap
      pd: pd
      fout: fout
      normal: normal_input
      tumor: tumor_input
    out: [output]

  filteration_workflow:
    run: somaticsniper_filteration_workflow.cwl
    in:
      vcf: somaticsniper_calling/output
      pileup: mpileup
    out: [POST_LOH_FILTER,POST_HC_FILTER]

  annotate_back:
    run: somaticsniper-raw-annotation/tools/annotation.cwl
    in:
      raw_vcf: somaticsniper_calling/output
      post_hc: filteration_workflow/POST_HC_FILTER
      output_name:
        source: tumor_input
        valueFrom: $(self.nameroot + '.annotated.vcf')
    out: [annotated_vcf]
