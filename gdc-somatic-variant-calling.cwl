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
  blocksize:
    type: int
    default: 300000000
    doc: Chromosome chunk size for scatter and gather.
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
  tumor_coclean_bam_uuid:
    type: string
    outputSource: uuid_bam/output
  tumor_coclean_bai_uuid:
    type: string
    outputSource: uuid_bam_index/output
  muse_uuid:
    type: string
    outputSource: uuid_muse/output
  muse_index_uuid:
    type: string
    outputSource: uuid_muse_index/output
  mutect2_uuid:
    type: string
    outputSource: uuid_mutect2/output
  mutect2_index_uuid:
    type: string
    outputSource: uuid_mutect2_index/output
  somaticsniper_uuid:
    type: string
    outputSource: uuid_somaticsniper/output
  somaticsniper_index_uuid:
    type: string
    outputSource: uuid_somaticsniper_index/output
  varscan2_uuid:
    type: string
    outputSource: uuid_varscan2/output
  varscan2_index_uuid:
    type: string
    outputSource: uuid_varscan2_index/output

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

  preparation:
    run: utils-cwl/subworkflows/preparation_workflow.cwl
    in:
      bioclient_config: bioclient_config
      tumor_gdc_id: tumor_gdc_id
      tumor_index_gdc_id: tumor_index_gdc_id
      normal_gdc_id: normal_gdc_id
      normal_index_gdc_id: normal_index_gdc_id
      reference_fa_gdc_id: reference_gdc_id
      reference_fai_gdc_id: reference_faidx_gdc_id
      reference_dict_gdc_id: reference_dict_gdc_id
      known_indel_gdc_id: known_indel_gdc_id
      known_indel_index_gdc_id: known_indel_index_gdc_id
      known_snp_gdc_id: known_snp_gdc_id
      known_snp_index_gdc_id: known_snp_index_gdc_id
      panel_of_normal_gdc_id: panel_of_normal_gdc_id
      panel_of_normal_index_gdc_id: panel_of_normal_index_gdc_id
      cosmic_gdc_id: cosmic_gdc_id
      cosmic_index_gdc_id: cosmic_index_gdc_id
    out: [normal_with_index, tumor_with_index, reference_with_index, known_indel_with_index,known_snp_with_index, panel_of_normal_with_index, cosmic_with_index]

  faidx_to_bed:
    run: utils-cwl/faidxtobed/tools/faidx_to_bed.cwl
    in:
      ref_fai:
        source: preparation/reference_with_index
        valueFrom: $(self.secondaryFiles[0])
      blocksize: blocksize
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
      filename:
        source: preparation/normal_with_index
        valueFrom: $(self.nameroot + '_realn.bam')
    out: [output]

  get_cocleaned_tumor:
    run: utils-cwl/get_file_from_array.cwl
    in:
      filearray: indelrealigner/output_bam
      filename:
        source: preparation/tumor_with_index
        valueFrom: $(self.nameroot + '_realn.bam')
    out: [output]

  rename_normal_input_bai:
    run: utils-cwl/rename_file.cwl
    in:
      input_file:
        source: get_cocleaned_normal/output
        valueFrom: $(self.secondaryFiles[0])
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
      input_file:
        source: get_cocleaned_tumor/output
        valueFrom: $(self.secondaryFiles[0])
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

  samtools_workflow:
    run: utils-cwl/samtools-cwl/workflows/samtools_workflow.cwl
    scatter: region
    in:
      normal_input: make_normal_bam/output
      tumor_input: make_tumor_bam/output
      region: faidx_to_bed/output_bed
      reference: preparation/reference_with_index
      min_MQ: map_q
    out: [normal_chunk, tumor_chunk, chunk_mpileup]

  get_groups:
    run: utils-cwl/divide_groups.cwl
    in:
      inputFile: [samtools_workflow/chunk_mpileup]
    out: [emptyFile, trueFile]

###MUSE_PIPELINE###
  muse_call:
    run: submodules/muse-cwl/tools/muse_call.cwl
    scatter: [region, tumor_bam, normal_bam]
    scatterMethod: dotproduct
    in:
      ref: preparation/reference_with_index
      region: faidx_to_bed/output_bed
      tumor_bam: samtools_workflow/tumor_chunk
      normal_bam: samtools_workflow/normal_chunk
    out: [output_file]

  merge_muse:
    run: submodules/muse-cwl/tools/MergeMuSE.cwl
    in:
      call_outputs: muse_call/output_file
      merged_name:
        source: prepare_file_prefix/output_prefix
        valueFrom: $(self[0] + '.txt')
    out: [merged_file]

  muse_sump:
    run: submodules/muse-cwl/tools/muse_sump.cwl
    in:
      dbsnp: preparation/known_snp_with_index
      call_output: merge_muse/merged_file
      exp_strat: prepare_file_prefix/muse_sump_exp
      output_base:
        source: prepare_file_prefix/output_prefix
        valueFrom: $(self[0] + '.raw_somatic_mutation.vcf')
    out: [MUSE_OUTPUT]

  sort_muse_vcf:
    run: utils-cwl/picard-cwl/tools/picard_sortvcf.cwl
    in:
      ref_dict:
        source: preparation/reference_with_index
        valueFrom: $(self.secondaryFiles[1])
      output_vcf:
        source: prepare_file_prefix/output_prefix
        valueFrom: $(self[0] + '.raw_somatic_mutation.vcf.gz')
      input_vcf: muse_sump/MUSE_OUTPUT
    out: [sorted_vcf]

###MUTECT2_PIPELINE###
  mutect2:
    run: submodules/mutect2-cwl/tools/mutect2_somatic_variant.cwl
    scatter: [region, tumor_bam, normal_bam]
    scatterMethod: dotproduct
    in:
      java_heap: java_opts
      ref: preparation/reference_with_index
      region: faidx_to_bed/output_bed
      tumor_bam: samtools_workflow/tumor_chunk
      normal_bam: samtools_workflow/normal_chunk
      pon: preparation/panel_of_normal_with_index
      cosmic: preparation/cosmic_with_index
      dbsnp: preparation/known_snp_with_index
      cont: cont
      duscb: duscb
    out: [MUTECT2_OUTPUT]

  sort_mutect2_vcf:
    run: utils-cwl/picard-cwl/tools/picard_sortvcf.cwl
    in:
      ref_dict:
        source: preparation/reference_with_index
        valueFrom: $(self.secondaryFiles[1])
      output_vcf:
        source: prepare_file_prefix/output_prefix
        valueFrom: $(self[1] + '.raw_somatic_mutation.vcf.gz')
      input_vcf: mutect2/MUTECT2_OUTPUT
    out: [sorted_vcf]

###SOMATICSNIPER_PIPELINE###
  somaticsniper:
    run: utils-cwl/subworkflows/somaticsniper_workflow.cwl
    scatter: [normal_input, tumor_input, mpileup]
    scatterMethod: dotproduct
    in:
      normal_input: samtools_workflow/normal_chunk
      tumor_input: samtools_workflow/tumor_chunk
      mpileup: samtools_workflow/chunk_mpileup
      reference: preparation/reference_with_index
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
    out: [ANNOTATED_VCF]

  sort_somaticsniper_vcf:
    run: utils-cwl/picard-cwl/tools/picard_sortvcf.cwl
    in:
      ref_dict:
        source: preparation/reference_with_index
        valueFrom: $(self.secondaryFiles[1])
      output_vcf:
        source: prepare_file_prefix/output_prefix
        valueFrom: $(self[2] + '.raw_somatic_mutation.vcf.gz')
      input_vcf: somaticsniper/ANNOTATED_VCF
    out: [sorted_vcf]

###VARSCAN2_PIPELINE###
  varscan2:
    run: utils-cwl/subworkflows/varscan_workflow.cwl
    scatter: tn_pair_pileup
    in:
      java_opts: java_opts
      tn_pair_pileup: get_groups/trueFile
      ref_dict:
        source: preparation/reference_with_index
        valueFrom: $(self.secondaryFiles[1])
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
    out: [SNP_SOMATIC_HC, INDEL_SOMATIC_HC]

  sort_snp_vcf:
    run: utils-cwl/picard-cwl/tools/picard_sortvcf.cwl
    in:
      ref_dict:
        source: preparation/reference_with_index
        valueFrom: $(self.secondaryFiles[1])
      output_vcf:
        source: prepare_file_prefix/output_prefix
        valueFrom: $(self[3] + '.snp.vcf.gz')
      input_vcf: varscan2/SNP_SOMATIC_HC
    out: [sorted_vcf]

  sort_indel_vcf:
    run: utils-cwl/picard-cwl/tools/picard_sortvcf.cwl
    in:
      ref_dict:
        source: preparation/reference_with_index
        valueFrom: $(self.secondaryFiles[1])
      output_vcf:
        source: prepare_file_prefix/output_prefix
        valueFrom: $(self[3] + '.indel.vcf.gz')
      input_vcf: varscan2/INDEL_SOMATIC_HC
    out: [sorted_vcf]

  varscan2_mergevcf:
    run: utils-cwl/picard-cwl/tools/picard_mergevcf.cwl
    in:
      java_opts: java_opts
      input_vcf: [sort_snp_vcf/sorted_vcf, sort_indel_vcf/sorted_vcf]
      output_filename:
        source: prepare_file_prefix/output_prefix
        valueFrom: $(self[3] + '.raw_somatic_mutation.vcf.gz')
      ref_dict:
        source: preparation/reference_with_index
        valueFrom: $(self.secondaryFiles[1])
    out: [output_vcf_file]

###UPLOAD###
  rename_tumor_bam:
    run: ./utils-cwl/rename_file.cwl
    in:
      input_file:
        source: indelrealigner/output_bam
        valueFrom: $(self[0])
      output_filename:
        source: job_uuid
        valueFrom: $(self + '.tumor_cocleaned.bam')
    out: [out_file]

  rename_tumor_bai:
    run: ./utils-cwl/rename_file.cwl
    in:
      input_file:
        source: indelrealigner/output_bam
        valueFrom: $(self[0].secondaryFiles[0])
      output_filename:
        source: job_uuid
        valueFrom: $(self + '.tumor_cocleaned.bai')
    out: [out_file]

  upload_bam:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, rename_tumor_bam/out_file]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: rename_tumor_bam/out_file
    out: [output]

  upload_bam_index:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, rename_tumor_bai/out_file]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: rename_tumor_bai/out_file
    out: [output]

  upload_muse:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, sort_muse_vcf/sorted_vcf]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: sort_muse_vcf/sorted_vcf
    out: [output]

  upload_muse_index:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, sort_muse_vcf/sorted_vcf]
        valueFrom: $(self[0])/$(self[1].secondaryFiles[0].basename)
      local_file:
        source: sort_muse_vcf/sorted_vcf
        valueFrom: $(self.secondaryFiles[0])
    out: [output]

  upload_mutect2:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, sort_mutect2_vcf/sorted_vcf]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: sort_mutect2_vcf/sorted_vcf
    out: [output]

  upload_mutect2_index:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, sort_mutect2_vcf/sorted_vcf]
        valueFrom: $(self[0])/$(self[1].secondaryFiles[0].basename)
      local_file:
        source: sort_mutect2_vcf/sorted_vcf
        valueFrom: $(self.secondaryFiles[0])
    out: [output]

  upload_somaticsniper:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, sort_somaticsniper_vcf/sorted_vcf]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: sort_somaticsniper_vcf/sorted_vcf
    out: [output]

  upload_somaticsniper_index:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, sort_somaticsniper_vcf/sorted_vcf]
        valueFrom: $(self[0])/$(self[1].secondaryFiles[0].basename)
      local_file:
        source: sort_somaticsniper_vcf/sorted_vcf
        valueFrom: $(self.secondaryFiles[0])
    out: [output]

  upload_varscan2:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, varscan2_mergevcf/output_vcf_file]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: varscan2_mergevcf/output_vcf_file
    out: [output]

  upload_varscan2_index:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, varscan2_mergevcf/output_vcf_file]
        valueFrom: $(self[0])/$(self[1].secondaryFiles[0].basename)
      local_file:
        source: varscan2_mergevcf/output_vcf_file
        valueFrom: $(self.secondaryFiles[0])
    out: [output]

###EXTRACT_UUID###
  uuid_bam:
    run: utils-cwl/emit_json_value.cwl
    in:
      input: upload_bam/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_bam_index:
    run: utils-cwl/emit_json_value.cwl
    in:
      input: upload_bam_index/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_muse:
    run: utils-cwl/emit_json_value.cwl
    in:
      input: upload_muse/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_muse_index:
    run: utils-cwl/emit_json_value.cwl
    in:
      input: upload_muse_index/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_mutect2:
    run: utils-cwl/emit_json_value.cwl
    in:
      input: upload_mutect2/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_mutect2_index:
    run: utils-cwl/emit_json_value.cwl
    in:
      input: upload_mutect2_index/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_somaticsniper:
    run: utils-cwl/emit_json_value.cwl
    in:
      input: upload_somaticsniper/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_somaticsniper_index:
    run: utils-cwl/emit_json_value.cwl
    in:
      input: upload_somaticsniper_index/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_varscan2:
    run: utils-cwl/emit_json_value.cwl
    in:
      input: upload_varscan2/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_varscan2_index:
    run: utils-cwl/emit_json_value.cwl
    in:
      input: upload_varscan2_index/output
      key:
        valueFrom: 'did'
    out: [output]
