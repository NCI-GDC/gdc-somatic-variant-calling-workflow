class: Workflow
cwlVersion: v1.0
id: gpas-somatic-mutation-calling-workflow
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
doc: |
    GPAS somatic mutation calling workflow.

inputs:

###BIOCLIENT_INPUTS###
  bioclient_config:
    type: File
  tumor_gdc_id:
    type: string
  tumor_index_gdc_id:
    type: string
  normal_gdc_id:
    type: string
  normal_index_gdc_id:
    type: string
  reference_gdc_id:
    type: string
    doc: Human genome reference. GDC default is GRCh38.
  reference_faidx_gdc_id:
    type: string
    doc: Human genome reference faidx file.
  reference_dict_gdc_id:
    type: string
    doc: Human genome reference dictionary file.
  known_indel_gdc_id:
    type: string
    doc: INDEL reference file.
  known_indel_index_gdc_id:
    type: string
  known_snp_gdc_id:
    type: string
    doc: dbSNP reference file. GDC default is dbSNP build-144.
  known_snp_index_gdc_id:
    type: string
  panel_of_normal_gdc_id:
    type: string
    doc: Panel of normal reference file.
  panel_of_normal_index_gdc_id:
    type: string
  cosmic_gdc_id:
    type: string
    doc: Cosmic reference file. GDC default is COSMICv75.
  cosmic_index_gdc_id:
    type: string
  upload_bucket:
    type: string

###GRAPH_INPUTS###
  project_id:
    type: string?
  muse_caller_id:
    type: string
    default: 'muse'
  mutect2_caller_id:
    type: string
    default: 'mutect2'
  somaticsniper_caller_id:
    type: string
    default: 'somaticsniper'
  varscan2_caller_id:
    type: string
    default: 'varscan2'
  experimental_strategy:
    type: string

###GENERAL_INPUTS###
  job_uuid:
    type: string
    doc: Job id. Served as a prefix for most VCF outputs.
  java_opts:
    type: string
    default: '3G'
    doc: Java option flags for all the java cmd. GDC default is 3G.
  threads:
    type: int
    default: 8
    doc: Threads for internal multithreading dockers.
  usedecoy:
    type: boolean
    default: false
    doc: If specified, it will include all the decoy sequences in the faidx. GDC default is false.

###GATK_INPUTS###
  gatk_logging_level:
    default: INFO
    type: string
  rtc_maxIntervalSize:
    type: int
    default: 500
  rtc_minReadsAtLocus:
    type: int
    default: 4
  rtc_mismatchFraction:
    type: double
    default: 0.0
  rtc_num_threads:
    type: int
    default: 1
  rtc_windowSize:
    type: int
    default: 10
  ir_consensusDeterminationModel:
    type: string
    default: USE_READS
  ir_entropyThreshold:
    type: double
    default: 0.15
  ir_LODThresholdForCleaning:
    type: double
    default: 5.0
  ir_maxConsensuses:
    type: int
    default: 30
  ir_maxIsizeForMovement:
    type: int
    default: 3000
  ir_maxPositionalMoveAllowed:
    type: int
    default: 200
  ir_maxReadsForConsensuses:
    type: int
    default: 120
  ir_maxReadsForRealignment:
    type: int
    default: 20000
  ir_maxReadsInMemory:
    type: int
    default: 1500000
  ir_noOriginalAlignmentTags:
    type: boolean
    default: true
  ir_nWayOut:
    type: string
    default: "_realn.bam"

###MUSE_INPUTS###

###MUTECT2_INPUTS###
  cont:
    type: float
    default: 0.02
    doc: MuTect2 parameter. GDC default is 0.02. Contamination estimation score.
  duscb:
    type: boolean
    default: false
    doc: MuTect2 parameter. GDC default is False. If set, MuTect2 will not use soft clipped bases.

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
  tumor_coclean_bam_uuid:
    type: string
    outputSource: gpas_upload/tumor_coclean_bam_uuid
  tumor_coclean_bai_uuid:
    type: string
    outputSource: gpas_upload/tumor_coclean_bai_uuid
  muse_uuid:
    type: string
    outputSource: gpas_upload/muse_uuid
  muse_index_uuid:
    type: string
    outputSource: gpas_upload/muse_index_uuid
  mutect2_uuid:
    type: string
    outputSource: gpas_upload/mutect2_uuid
  mutect2_index_uuid:
    type: string
    outputSource: gpas_upload/mutect2_index_uuid
  somaticsniper_uuid:
    type: string
    outputSource: gpas_upload/somaticsniper_uuid
  somaticsniper_index_uuid:
    type: string
    outputSource: gpas_upload/somaticsniper_index_uuid
  varscan2_uuid:
    type: string
    outputSource: gpas_upload/varscan2_uuid
  varscan2_index_uuid:
    type: string
    outputSource: gpas_upload/varscan2_index_uuid

steps:

  gpas_extract:
    run: ./workflows/gpas-extract-workflow.cwl
    in:
      bioclient_config: bioclient_config
      tumor_gdc_id: tumor_gdc_id
      tumor_index_gdc_id: tumor_index_gdc_id
      normal_gdc_id: normal_gdc_id
      normal_index_gdc_id: normal_index_gdc_id
      reference_dict_gdc_id: reference_dict_gdc_id
      reference_fa_gdc_id: reference_gdc_id
      reference_fai_gdc_id: reference_faidx_gdc_id
      known_indel_gdc_id: known_indel_gdc_id
      known_indel_index_gdc_id: known_indel_index_gdc_id
      known_snp_gdc_id: known_snp_gdc_id
      known_snp_index_gdc_id: known_snp_index_gdc_id
      panel_of_normal_gdc_id: panel_of_normal_gdc_id
      panel_of_normal_index_gdc_id: panel_of_normal_index_gdc_id
      cosmic_gdc_id: cosmic_gdc_id
      cosmic_index_gdc_id: cosmic_index_gdc_id
    out: [
      normal_with_index,
      tumor_with_index,
      reference_with_index,
      known_indel_with_index,
      known_snp_with_index,
      panel_of_normal_with_index,
      cosmic_with_index
    ]

  gdc_somatic_variant_calling:
    run: ./workflows/gdc-somatic-variant-calling-workflow.cwl
    in:
      project_id: project_id
      muse_caller_id: muse_caller_id
      mutect2_caller_id: mutect2_caller_id
      somaticsniper_caller_id: somaticsniper_caller_id
      varscan2_caller_id: varscan2_caller_id
      experimental_strategy: experimental_strategy
      tumor_bam: gpas_extract/tumor_with_index
      normal_bam: gpas_extract/normal_with_index
      reference: gpas_extract/reference_with_index
      known_indel: gpas_extract/known_indel_with_index
      known_snp: gpas_extract/known_snp_with_index
      panel_of_normal: gpas_extract/panel_of_normal_with_index
      cosmic: gpas_extract/cosmic_with_index
      job_uuid: job_uuid
      java_opts: java_opts
      threads: threads
      usedecoy: usedecoy
      gatk_logging_level: gatk_logging_level
      rtc_maxIntervalSize: rtc_maxIntervalSize
      rtc_minReadsAtLocus: rtc_minReadsAtLocus
      rtc_mismatchFraction: rtc_mismatchFraction
      rtc_num_threads: rtc_num_threads
      rtc_windowSize: rtc_windowSize
      ir_consensusDeterminationModel: ir_consensusDeterminationModel
      ir_entropyThreshold: ir_entropyThreshold
      ir_LODThresholdForCleaning: ir_LODThresholdForCleaning
      ir_maxConsensuses: ir_maxConsensuses
      ir_maxIsizeForMovement: ir_maxIsizeForMovement
      ir_maxPositionalMoveAllowed: ir_maxPositionalMoveAllowed
      ir_maxReadsForConsensuses: ir_maxReadsForConsensuses
      ir_maxReadsForRealignment: ir_maxReadsForRealignment
      ir_maxReadsInMemory: ir_maxReadsInMemory
      ir_noOriginalAlignmentTags: ir_noOriginalAlignmentTags
      ir_nWayOut: ir_nWayOut
      cont: cont
      duscb: duscb
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
    out: [
      cocleaned_tumor_bam,
      gdc_muse_vcf,
      gdc_mutect2_vcf,
      gdc_somaticsniper_vcf,
      gdc_varscan2_vcf
    ]

  gpas_upload:
    run: ./workflows/gpas-upload-workflow.cwl
    in:
      job_uuid: job_uuid
      bioclient_config: bioclient_config
      upload_bucket: upload_bucket
      tumor_bam: gdc_somatic_variant_calling/cocleaned_tumor_bam
      gdc_muse_vcf: gdc_somatic_variant_calling/gdc_muse_vcf
      gdc_mutect2_vcf: gdc_somatic_variant_calling/gdc_mutect2_vcf
      gdc_somaticsniper_vcf: gdc_somatic_variant_calling/gdc_somaticsniper_vcf
      gdc_varscan2_vcf: gdc_somatic_variant_calling/gdc_varscan2_vcf
    out: [
      tumor_coclean_bam_uuid,
      tumor_coclean_bai_uuid,
      muse_uuid,
      muse_index_uuid,
      mutect2_uuid,
      mutect2_index_uuid,
      somaticsniper_uuid,
      somaticsniper_index_uuid,
      varscan2_uuid,
      varscan2_index_uuid
    ]
