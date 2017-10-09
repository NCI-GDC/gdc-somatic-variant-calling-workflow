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

###AWS_INPUTS###
  aws_config_file:
    type: File
    doc: Shared aws config file.
  aws_shared_credentials_file:
    type: File
    doc: Shared aws credential file.
  normal_s3cfg_section:
    type: string
    doc: Aws section for normal bam file. Should be in the aws config file.
  normal_endpoint_url:
    type: string
    doc: Aws endpoint url for aws section of normal bam file.
  normal_s3url:
    type: string
    doc: Aws s3 url for normal bam file.
  tumor_s3cfg_section:
    type: string
    doc: Aws section for tumor bam file. Should be in the aws config file.
  tumor_endpoint_url:
    type: string
    doc: Aws endpoint url for aws section of tumor bam file.
  tumor_s3url:
    type: string
    doc: Aws s3 url for tumor bam file.

###GENERAL_INPUTS###
  output_id:
    type: string
    doc: Output uuid. Served as a prefix for most VCF outputs.
  java_opts:
    type: string
    default: '3G'
    doc: Java option flags for all the java cmd. GDC default is 3G.
  blocksize:
    type: int
    doc: Chromosome chunk size for scatter and gather.
  usedecoy:
    type: boolean
    default: false
    doc: If specified, it will include all the decoy sequences in the faidx. GDC default is false.

###REFERENCE_FILES###
  reference:
    type: File
    doc: Human genome reference. GDC default is GRCh38.
  reference_faidx:
    type: File
    doc: Human genome reference faidx file.
  reference_dict:
    type: File
    doc: Human genome reference dictionary file.
  dbsnp:
    type: File
    doc: dbSNP reference file. GDC default is dbSNP build-144. Must be bgzip'd and tabix'd for MuSE.

###MUSE_INPUTS###
  exp_strat:
    type: string
    default: 'E'
    doc: MuSE parameter. GDC default is E. Experiment strategy. E stands for WXS, and G for WGS. (E/G)

###SOMATICSNIPER_INPUTS###
  map_q:
    type: int
    default: 1
    doc: Somaticsniper parameter. GDC default is 1. Filtering reads with mapping quality less than this value.
  base_q:
    type: int
    default: 15
    doc: Somaticsniper parameter. GDC default is 15. Filtering somatic snv output with somatic quality less than this value.
  loh:
    type: boolean
    default: true
    doc: Somaticsniper parameter. GDC default is True. Do not report LOH variants as determined by genotypes. (T/F)
  gor:
    type: boolean
    default: true
    doc: Somaticsniper parameter. GDC default is True. Do not report Gain of Reference variants as determined by genotypes. (T/F)
  psc:
    type: boolean
    default: false
    doc: Somaticsniper parameter. GDC default is False. Disable priors in the somatic calculation. Increases sensitivity for solid tumors. (T/F)
  ppa:
    type: boolean
    default: false
    doc: Somaticsniper parameter. GDC default is False. Use prior probabilities accounting for the somatic mutation rate. (T/F)
  pps:
    type: float
    default: 0.01
    doc: Somaticsniper parameter. GDC default is 0.01. Prior probability of a somatic mutation. (implies -J)
  theta:
    type: float
    default: 0.85
    doc: Somaticsniper parameter. GDC default is 0.85. Theta in maq consensus calling model. (for -c/-g)
  nhap:
    type: int
    default: 2
    doc: Somaticsniper parameter. GDC default is 2. Number of haplotypes in the sample.
  pd:
    type: float
    default: 0.001
    doc: Somaticsniper parameter. GDC default is 0.001. Prior of a difference between two haplotypes.
  fout:
    type: string
    default: 'vcf'
    doc: Somaticsniper parameter. GDC default is vcf. Output format. (classic/vcf/bed)

###VARSCAN2_INPUTS###
  min_coverage:
    type: int
    default: 8
    doc: Varscan2 parameter. GDC default is 8. Minimum coverage in normal and tumor to call variant.
  min_cov_normal:
    type: int
    default: 8
    doc: Varscan2 parameter. GDC default is 8. Minimum coverage in normal to call somatic.
  min_cov_tumor:
    type: int
    default: 6
    doc: Varscan2 parameter. GDC default is 6. Minimum coverage in tumor to call somatic.
  min_var_freq:
    type: float
    default: 0.10
    doc: Varscan2 parameter. GDC default is 0.10. Minimum variant frequency to call a heterozygote.
  min_freq_for_hom:
    type: float
    default: 0.75
    doc: Varscan2 parameter. GDC default is 0.75. Minimum frequency to call homozygote.
  normal_purity:
    type: float
    default: 1.00
    doc: Varscan2 parameter. GDC default is 1.00. Estimated purity (non-tumor content) of normal sample.
  tumor_purity:
    type: float
    default: 1.00
    doc: Varscan2 parameter. GDC default is 1.00. Estimated purity (tumor content) of tumor sample.
  vs_p_value:
    type: float
    default: 0.99
    doc: Varscan2 parameter. GDC default is 0.99. P-value threshold to call a heterozygote when running varscan somatic.
  somatic_p_value:
    type: float
    default: 0.05
    doc: Varscan2 parameter. GDC default is 0.05. P-value threshold to call a somatic site.
  strand_filter:
    type: int
    default: 0
    doc: Varscan2 parameter. GDC default is 0. If set to 1, removes variants with >90% strand bias.
  validation:
    type: boolean
    default: false
    doc: Varscan2 parameter. GDC default is False. If set, outputs all compared positions even if non-variant.
  output_vcf:
    type: int
    default: 1
    doc: Varscan2 parameter. GDC default is 1. If set to 1, output VCF instead of VarScan native format.
  min_tumor_freq:
    type: float
    default: 0.10
    doc: Varscan2 parameter. GDC default is 0.10. Minimun variant allele frequency in tumor.
  max_normal_freq:
    type: float
    default: 0.05
    doc: Varscan2 parameter. GDC default is 0.05. Maximum variant allele frequency in normal.
  vps_p_value:
    type: float
    default: 0.07
    doc: Varscan2 parameter. GDC default is 0.07. P-value for high-confidence calling.

outputs:
  somaticsniper_vcf:
    type:
      type: array
      items: File
    outputSource: somaticsniper/RAW_VCF

  varscan2_vcf:
    type:
      type: array
      items: File
    outputSource: varscan2/MAIN_OUTPUT

  muse_vcf:
    type: File
    outputSource: muse_sump/MUSE_OUTPUT

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

  varscan2:
    run: utils-cwl/varscan_workflow.cwl
    scatter: tn_pair_pileup
    in:
      java_opts: java_opts
      tn_pair_pileup: samtools_workflow/chunk_mpileup
      ref_dict: reference_dict
      prefix: output_id
      min_coverage: min_coverage
      min_cov_normal: min_cov_normal
      min_cov_tumor: min_cov_tumor
      min_var_freq: min_var_freq
      min_freq_for_hom: min_freq_for_hom
      normal_purity: normal_purity
      tumor_purity: tumor_purity
      vs_p_value: vs_p_value
      somatic_p_value: somatic_p_value
      strand_filter: strand_filter
      validation: validation
      output_vcf: output_vcf
      min_tumor_freq: min_tumor_freq
      max_normal_freq: max_normal_freq
      vps_p_value: vps_p_value
    out: [GERMLINE_ALL, GERMLINE_HC, LOH_ALL, LOH_HC, SOMATIC_ALL, SOMATIC_HC, MAIN_OUTPUT]

  muse_call:
    run: submodules/muse-cwl/tools/muse_call.cwl
    scatter: [region, tumor_bam, normal_bam]
    scatterMethod: dotproduct
    in:
      ref: reference
      region: faidx_to_bed/output_bed
      tumor_bam: samtools_workflow/tumor_chunk
      normal_bam: samtools_workflow/normal_chunk
    out: [output_file]

  awk_merge_muse:
    run: submodules/muse-cwl/tools/awk_merge.cwl
    in:
      call_outputs: muse_call/output_file
      output_base: output_id
    out: [merged_file]

  muse_sump:
    run: submodules/muse-cwl/tools/muse_sump.cwl
    in:
      dbsnp: dbsnp
      call_output: awk_merge_muse/merged_file
      exp_strat: exp_strat
      output_base:
        source: output_id
        valueFrom: $(self + '.muse.vcf')
    out: [MUSE_OUTPUT]
