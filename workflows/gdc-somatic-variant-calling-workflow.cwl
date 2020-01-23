class: Workflow
cwlVersion: v1.0
id: gdc-somatic-variant-calling-workflow
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
doc: |
    GDC somatic variant calling workflow

inputs:

###GENERAL_INPUTS###
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
  tumor_bam:
    type: File
    secondaryFiles: .bai
  normal_bam:
    type: File
    secondaryFiles: .bai
  reference:
    type: File
    secondaryFiles: [.fai, ^.dict]
    doc: Human genome reference. GDC default is GRCh38.
  known_indel:
    type: File
    secondaryFiles: .tbi
    doc: INDEL reference file.
  known_snp:
    type: File
    secondaryFiles: .tbi
    doc: dbSNP reference file. GDC default is dbSNP build-144.
  panel_of_normal:
    type: File
    secondaryFiles: .tbi
    doc: Panel of normal reference file.
  cosmic:
    type: File
    secondaryFiles: .tbi
    doc: Cosmic reference file. GDC default is COSMICv75.

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
    default: 150000
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
  cocleaned_tumor_bam:
    type: File
    outputSource: gdc_gatk3_coclean/cocleaned_tumor_bam
  gdc_muse_vcf:
    type: File
    outputSource: gdc_muse/muse_vcf
  gdc_mutect2_vcf:
    type: File
    outputSource: gdc_gatk3_mutect2/mutect2_vcf
  gdc_somaticsniper_vcf:
    type: File
    outputSource: gdc_somaticsniper/somaticsniper_vcf
  gdc_varscan2_vcf:
    type: File
    outputSource: gdc_varscan2/varscan2_vcf

steps:
  prepare_vcf_prefix:
    run: ../tools/util/make_prefix.cwl
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
    run: ../tools/util/faidx_to_bed.cwl
    in:
      ref_fai:
        source: reference
        valueFrom: $(self.secondaryFiles[0])
      usedecoy: usedecoy
    out: [output_bed]

  gdc_gatk3_coclean:
    run: ./subworkflows/gatk3_coclean_workflow.cwl
    in:
      job_uuid: job_uuid
      normal_bam: normal_bam
      tumor_bam: tumor_bam
      reference: reference
      known_indel: known_indel
      bed_file: faidx_to_bed/output_bed
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
    out: [ cocleaned_normal_bam, cocleaned_tumor_bam ]

  gdc_samtools_mpileup:
    run: ./subworkflows/samtools_mpileup_workflow.cwl
    in:
      reference: reference
      bed_file: faidx_to_bed/output_bed
      normal_bam: gdc_gatk3_coclean/cocleaned_normal_bam
      tumor_bam: gdc_gatk3_coclean/cocleaned_tumor_bam
      threads: threads
      map_q: map_q
    out: [ all_mpileups, true_mpileups ]

  gdc_muse:
    run: ./subworkflows/muse_workflow.cwl
    in:
      reference: reference
      bed: faidx_to_bed/output_bed
      normal_bam: gdc_gatk3_coclean/cocleaned_normal_bam
      tumor_bam: gdc_gatk3_coclean/cocleaned_tumor_bam
      threads: threads
      dbsnp: known_snp
      exp_strat: prepare_vcf_prefix/muse_sump_exp
      output_prefix:
        source: prepare_vcf_prefix/output_prefix
        valueFrom: $(self[0])
    out: [ muse_vcf ]

  gdc_gatk3_mutect2:
    run: ./subworkflows/gatk3_mutect2_workflow.cwl
    in:
      reference: reference
      bed: faidx_to_bed/output_bed
      normal_bam: gdc_gatk3_coclean/cocleaned_normal_bam
      tumor_bam: gdc_gatk3_coclean/cocleaned_tumor_bam
      threads: threads
      dbsnp: known_snp
      cosmic: cosmic
      pon: panel_of_normal
      output_prefix:
        source: prepare_vcf_prefix/output_prefix
        valueFrom: $(self[1])
      java_opts: java_opts
      cont: cont
      duscb: duscb
    out: [ mutect2_vcf ]

  gdc_somaticsniper:
    run: ./subworkflows/somaticsniper_workflow.cwl
    in:
      reference: reference
      normal_bam: gdc_gatk3_coclean/cocleaned_normal_bam
      tumor_bam: gdc_gatk3_coclean/cocleaned_tumor_bam
      mpileups: gdc_samtools_mpileup/all_mpileups
      threads: threads
      output_prefix:
        source: prepare_vcf_prefix/output_prefix
        valueFrom: $(self[2])
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
    out: [ somaticsniper_vcf ]

  gdc_varscan2:
    run: ./subworkflows/varscan2_workflow.cwl
    in:
      reference: reference
      mpileups: gdc_samtools_mpileup/true_mpileups
      threads: threads
      java_opts: java_opts
      output_prefix:
        source: prepare_vcf_prefix/output_prefix
        valueFrom: $(self[3])
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
    out: [ varscan2_vcf ]

