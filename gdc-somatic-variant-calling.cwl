#!/usr/bin/env cwl-runner

cwlVersion: v1.0

doc: |
    GDC Somatic Variant Calling Workflow

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  aws_config_file:
    type: File
  aws_shared_credentials_file:
    type: File
  normal_s3cfg_section:
    type: string
  normal_endpoint_url:
    type: string
  normal_s3url:
    type: string
  tumor_s3cfg_section:
    type: string
  tumor_endpoint_url:
    type: string
  tumor_s3url:
    type: string
  blocksize:
    type: int
  usedecoy:
    type: boolean
  reference:
    type: File
  reference_faidx:
    type: File
  reference_dict:
    type: File
  map_q:
    type: int
    default: 1
  base_q:
    type: int
    default: 15
  loh:
    type: boolean
    default: true
  gor:
    type: boolean
    default: true
  psc:
    type: boolean
    default: false
  ppa:
    type: boolean
    default: false
  pps:
    type: float
    default: 0.01
  theta:
    type: float
    default: 0.85
  nhap:
    type: int
    default: 2
  pd:
    type: float
    default: 0.001
  fout:
    type: string
    default: vcf
  output_id:
    type: string

outputs:
  somaticsniper_vcfs:
    type:
      type: array
      items: File
    outputSource: picardsortvcf/sorted_output_vcf

steps:
  prepare_bam_input:
    run: utils-cwl/prepare_bam_input.cwl
    in:
      aws_config_file: aws_config_file
      aws_shared_credentials_file: aws_shared_credentials_file
      normal_s3cfg_section: normal_s3cfg_section
      normal_endpoint_url: normal_endpoint_url
      normal_s3url: normal_s3url
      tumor_s3cfg_section: tumor_s3cfg_section
      tumor_endpoint_url: tumor_endpoint_url
      tumor_s3url: tumor_s3url
    out: [normal_input, tumor_input]

  faidx_to_bed:
    run: utils-cwl/faidxtobed/tools/faidx_to_bed.cwl
    in:
      ref_fai: reference_faidx
      blocksize: blocksize
      usedecoy: usedecoy
    out: [output_bed]

  samtools_workflow:
    run: utils-cwl/samtools-cwl/workflows/samtools_workflow.cwl
    scatter: region
    in:
      normal_input: prepare_bam_input/normal_input
      tumor_input: prepare_bam_input/tumor_input
      region: faidx_to_bed/output_bed
      reference: reference
      min_MQ: map_q
    out: [normal_chunk, tumor_chunk, chunk_mpileup]

  somaticsniper:
    run: submodules/somaticsniper-cwl/workflows/somaticsniper_workflow.cwl
    scatter: [normal_input, tumor_input, mpileup]
    scatterMethod: dotproduct
    in:
      normal_input: samtools_workflow/normal_chunk
      tumor_input: samtools_workflow/tumor_chunk
      mpileup: samtools_workflow/chunk_mpileup
      reference: reference
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
    out: [RAW_VCF, POST_LOH_VCF, POST_HC_VCF]

  picardsortvcf:
    run: utils-cwl/picard-cwl/tools/picard_sortvcf.cwl
    scatter: [input_vcf, output_vcf]
    scatterMethod: dotproduct
    in:
      ref_dict: reference_dict
      input_vcf: [somaticsniper/RAW_VCF, somaticsniper/POST_LOH_VCF, somaticsniper/POST_HC_VCF]
      output_vcf:
        source: output_id
        valueFrom: [$(self + '.raw.vcf.gz'), $(self + '.loh.vcf.gz'), $(self + '.hc.vcf.gz')]
    out: [sorted_output_vcf]
