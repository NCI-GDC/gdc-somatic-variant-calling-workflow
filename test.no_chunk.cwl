#!/usr/bin/env cwl-runner

cwlVersion: v1.0

doc: |
    GDC Somatic Variant Calling Workflow

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  normal_with_index:
    type: File
    secondaryFiles:
      - '.bai'
      - '^.bai'
  tumor_with_index:
    type: File
    secondaryFiles:
      - '.bai'
      - '^.bai'
  reference_with_index:
    type: File
    secondaryFiles:
      - '.fai'
      - '^.dict'
  known_indel_with_index:
    type: File
    secondaryFiles:
      - '.tbi'
  known_snp_with_index:
    type: File
    secondaryFiles:
      - '.tbi'
  panel_of_normal_with_index:
    type: File
    secondaryFiles:
      - '.tbi'
  cosmic_with_index:
    type: File
    secondaryFiles:
      - '.tbi'
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
    default: 150000
  ir_noOriginalAlignmentTags:
    type: boolean
    default: true
  ir_nWayOut:
    type: string
    default: ".bam"

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
  tumor_coclean_bam:
    type: File[]
    outputSource: indelrealigner/output_bam

steps:

###PREPARATION###
  prepare_file_prefix:
    run: ./utils-cwl/make_prefix.cwl
    in:
      project_id: project_id
      muse_caller_id: muse_caller_id
      mutect2_caller_id: mutect2_caller_id
      somaticsniper_caller_id: somaticsniper_caller_id
      varscan2_caller_id: varscan2_caller_id
      job_id: job_uuid
      experimental_strategy: experimental_strategy
    out: [output_prefix, muse_sump_exp]

  faidx_to_bed:
    run: utils-cwl/faidxtobed/tools/faidx_to_bed.no_chunk.cwl
    in:
      ref_fai:
        source: preparation/reference_with_index
        valueFrom: $(self.secondaryFiles[0])
      usedecoy: usedecoy
    out: [output_bed]

  realignertargetcreator:
    run: utils-cwl/gatk/tools/gatk_realignertargetcreator.cwl
    in:
      input_file: [preparation/normal_with_index, preparation/tumor_with_index]
      known: preparation/known_indel_with_index
      log_to_file:
        source: job_uuid
        valueFrom: $(self + '.realignertargetcreator.log')
      logging_level: gatk_logging_level
      maxIntervalSize: rtc_maxIntervalSize
      minReadsAtLocus: rtc_minReadsAtLocus
      mismatchFraction: rtc_mismatchFraction
      output_name:
        source: job_uuid
        valueFrom: $(self + '.intervals')
      num_threads: rtc_num_threads
      windowSize: rtc_windowSize
      reference_sequence: preparation/reference_with_index
      intervals: faidx_to_bed/output_bed
    out: [output_intervals, output_log]

  indelrealigner:
    run: utils-cwl/gatk/tools/gatk_indelrealigner.cwl
    in:
      consensusDeterminationModel: ir_consensusDeterminationModel
      entropyThreshold: ir_entropyThreshold
      input_file: [preparation/normal_with_index, preparation/tumor_with_index]
      knownAlleles: preparation/known_indel_with_index
      log_to_file:
        source: job_uuid
        valueFrom: $(self + '.indelrealigner.log')
      logging_level: gatk_logging_level
      LODThresholdForCleaning: ir_LODThresholdForCleaning
      maxConsensuses: ir_maxConsensuses
      maxIsizeForMovement: ir_maxIsizeForMovement
      maxPositionalMoveAllowed: ir_maxPositionalMoveAllowed
      maxReadsForConsensuses: ir_maxReadsForConsensuses
      maxReadsForRealignment: ir_maxReadsForRealignment
      maxReadsInMemory: ir_maxReadsInMemory
      noOriginalAlignmentTags: ir_noOriginalAlignmentTags
      nWayOut: ir_nWayOut
      reference_sequence: preparation/reference_with_index
      targetIntervals: realignertargetcreator/output_intervals
    out: [output_bam, output_log]

  get_cocleaned_normal:
    run: utils-cwl/get_file_from_array.cwl
    in:
      filearray: indelrealigner/output_bam
      filename: preparation/normal_with_index
    out: [output]

  get_cocleaned_normal_bai:
    run: utils-cwl/get_file_from_array.cwl
      in:
        filearray: indelrealigner/output_bam
        filename:
          source: preparation/normal_with_index
          valueFrom: $(self.secondaryFiles[0])
      out: [output]

  get_cocleaned_tumor:
    run: utils-cwl/get_file_from_array.cwl
      in:
        filearray: indelrealigner/output_bam
        filename: preparation/tumor_with_index
      out: [output]

  get_cocleaned_tumor_bai:
    run: utils-cwl/get_file_from_array.cwl
      in:
        filearray: indelrealigner/output_bam
        filename:
          source: preparation/tumor_with_index
          valueFrom: $(self.secondaryFiles[0])
      out: [output]

  rename_normal_input_bai:
    run: utils-cwl/rename_file.cwl
    in:
      input_file: get_cocleaned_normal_bai/output
      output_filename:
        source: get_cocleaned_normal/output
        valueFrom: $(self.basename + '.bai')
    out: [ out_file ]

  make_normal_bam:
    run: utils-cwl/make_secondary.cwl
    in:
      parent_file: get_cocleaned_normal/output
      children:
        source: rename_normal_input_bai/out_file
        valueFrom: $([self])
    out: [ output ]

  rename_tumor_input_bai:
    run: utils-cwl/rename_file.cwl
    in:
      input_file: get_cocleaned_tumor_bai/output
      output_filename:
        source: get_cocleaned_tumor/output
        valueFrom: $(self.basename + '.bai')
    out: [ out_file ]

  make_tumor_bam:
    run: utils-cwl/make_secondary.cwl
    in:
      parent_file: get_cocleaned_tumor/output
      children:
        source: rename_tumor_input_bai/out_file
        valueFrom: $([self])
    out: [ output ]
