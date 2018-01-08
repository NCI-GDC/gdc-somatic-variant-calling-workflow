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
  - class: ResourceRequirement
    coresMax: 40

inputs:

###BIOCLIENT_INPUTS###
  config_file:
    type: File
  tumor_download_handle:
    type: string
  normal_download_handle:
    type: string
  upload_bucket:
    type: string

###GENERAL_INPUTS###
  job_id:
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
    doc: dbSNP reference file. GDC default is dbSNP build-144. Must be bgzip'd and tabix'd.
  pon:
    type: File
    doc: Panel of normal reference file. Must be bgzip'd and tabix'd.
  cosmic:
    type: File
    doc: Cosmic reference file. GDC default is COSMICv75. Must be bgzip'd and tabix'd.

###MUSE_INPUTS###
  exp_strat:
    type: string
    default: 'E'
    doc: MuSE parameter. GDC default is E. Experiment strategy. E stands for WXS, and G for WGS. (E/G)

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
  muse_vcf:
    type: File
    outputSource: sort_muse_vcf/sorted_vcf
  mutect2_vcf:
    type: File
    outputSource: sort_mutect2_vcf/sorted_vcf
  somaticsniper_vcf:
    type: File
    outputSource: sort_somaticsniper_vcf/sorted_vcf
  varscan2_vcf:
    type: File
    outputSource: varscan2_mergevcf/output_vcf_file
  muse_upload:
    type: File
    outputSource: upload_muse/output
  muse_index_upload:
    type: File
    outputSource: upload_muse_index/output
  mutect2_upload:
    type: File
    outputSource: upload_mutect2/output
  mutect2_index_upload:
    type: File
    outputSource: upload_mutect2_index/output
  somaticsniper_upload:
    type: File
    outputSource: upload_somaticsniper/output
  somaticsniper_index_upload:
    type: File
    outputSource: upload_somaticsniper_index/output
  varscan2_upload:
    type: File
    outputSource: upload_varscan2/output
  varscan2_index_upload:
    type: File
    outputSource: upload_varscan2_index/output

steps:

###PREPARATION###
  prepare_bam_input:
    run: utils-cwl/prepare_bam_input_workflow.cwl
    in:
      config_file: config_file
      tumor_download_handle: tumor_download_handle
      normal_download_handle: normal_download_handle
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

###MUSE_PIPELINE###
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
      output_base: job_id
    out: [merged_file]

  muse_sump:
    run: submodules/muse-cwl/tools/muse_sump.cwl
    in:
      dbsnp: dbsnp
      call_output: awk_merge_muse/merged_file
      exp_strat: exp_strat
      output_base:
        source: job_id
        valueFrom: $(self + '.muse.vcf')
    out: [MUSE_OUTPUT]

  sort_muse_vcf:
    run: utils-cwl/picard-cwl/tools/picard_sortvcf.cwl
    in:
      ref_dict: reference_dict
      output_vcf:
        source: job_id
        valueFrom: $(self + '.muse.vcf.gz')
      input_vcf: muse_sump/MUSE_OUTPUT
    out: [sorted_vcf]

###MUTECT2_PIPELINE###
  mutect2:
    run: submodules/mutect2-cwl/tools/mutect2_somatic_variant.cwl
    scatter: [region, tumor_bam, normal_bam]
    scatterMethod: dotproduct
    in:
      java_heap: java_opts
      ref: reference
      region: faidx_to_bed/output_bed
      tumor_bam: samtools_workflow/tumor_chunk
      normal_bam: samtools_workflow/normal_chunk
      pon: pon
      cosmic: cosmic
      dbsnp: dbsnp
      cont: cont
      duscb: duscb
    out: [MUTECT2_OUTPUT]

  sort_mutect2_vcf:
    run: utils-cwl/picard-cwl/tools/picard_sortvcf.cwl
    in:
      ref_dict: reference_dict
      output_vcf:
        source: job_id
        valueFrom: $(self + '.mutect2.vcf.gz')
      input_vcf: mutect2/MUTECT2_OUTPUT
    out: [sorted_vcf]

###SOMATICSNIPER_PIPELINE###
  somaticsniper:
    run: utils-cwl/somaticsniper_workflow.cwl
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
    out: [ANNOTATED_VCF]

  sort_somaticsniper_vcf:
    run: utils-cwl/picard-cwl/tools/picard_sortvcf.cwl
    in:
      ref_dict: reference_dict
      output_vcf:
        source: job_id
        valueFrom: $(self + '.somaticsniper.vcf.gz')
      input_vcf: somaticsniper/ANNOTATED_VCF
    out: [sorted_vcf]

###VARSCAN2_PIPELINE###
  varscan2:
    run: utils-cwl/varscan_workflow.cwl
    scatter: tn_pair_pileup
    in:
      java_opts: java_opts
      tn_pair_pileup: samtools_workflow/chunk_mpileup
      ref_dict: reference_dict
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
      ref_dict: reference_dict
      output_vcf:
        source: job_id
        valueFrom: $(self + '.snp.varscan2.vcf.gz')
      input_vcf: varscan2/SNP_SOMATIC_HC
    out: [sorted_vcf]

  sort_indel_vcf:
    run: utils-cwl/picard-cwl/tools/picard_sortvcf.cwl
    in:
      ref_dict: reference_dict
      output_vcf:
        source: job_id
        valueFrom: $(self + '.indel.varscan2.vcf.gz')
      input_vcf: varscan2/INDEL_SOMATIC_HC
    out: [sorted_vcf]

  varscan2_mergevcf:
    run: utils-cwl/picard-cwl/tools/picard_mergevcf.cwl
    in:
      java_opts: java_opts
      input_vcf: [sort_snp_vcf/sorted_vcf, sort_indel_vcf/sorted_vcf]
      output_filename:
        source: job_id
        valueFrom: $(self + '.varscan2.vcf.gz')
      ref_dict: reference_dict
    out: [output_vcf_file]

###UPLOAD###
  upload_muse:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: config_file
      upload_bucket: upload_bucket
      upload_key:
        source: [job_id, sort_muse_vcf/sorted_vcf]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: sort_muse_vcf/sorted_vcf
    out: [output]

  upload_muse_index:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: config_file
      upload_bucket: upload_bucket
      upload_key:
        source: [job_id, sort_muse_vcf/sorted_vcf]
        valueFrom: $(self[0])/$(self[1].secondaryFiles[0].basename)
      local_file:
        source: sort_muse_vcf/sorted_vcf
        valueFrom: $(self.secondaryFiles[0])
    out: [output]

  upload_mutect2:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: config_file
      upload_bucket: upload_bucket
      upload_key:
        source: [job_id, sort_mutect2_vcf/sorted_vcf]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: sort_mutect2_vcf/sorted_vcf
    out: [output]

  upload_mutect2_index:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: config_file
      upload_bucket: upload_bucket
      upload_key:
        source: [job_id, sort_mutect2_vcf/sorted_vcf]
        valueFrom: $(self[0])/$(self[1].secondaryFiles[0].basename)
      local_file:
        source: sort_mutect2_vcf/sorted_vcf
        valueFrom: $(self.secondaryFiles[0])
    out: [output]

  upload_somaticsniper:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: config_file
      upload_bucket: upload_bucket
      upload_key:
        source: [job_id, sort_somaticsniper_vcf/sorted_vcf]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: sort_somaticsniper_vcf/sorted_vcf
    out: [output]

  upload_somaticsniper_index:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: config_file
      upload_bucket: upload_bucket
      upload_key:
        source: [job_id, sort_somaticsniper_vcf/sorted_vcf]
        valueFrom: $(self[0])/$(self[1].secondaryFiles[0].basename)
      local_file:
        source: sort_somaticsniper_vcf/sorted_vcf
        valueFrom: $(self.secondaryFiles[0])
    out: [output]

  upload_varscan2:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: config_file
      upload_bucket: upload_bucket
      upload_key:
        source: [job_id, varscan2_mergevcf/output_vcf_file]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: varscan2_mergevcf/output_vcf_file
    out: [output]

  upload_varscan2_index:
    run: utils-cwl/bioclient/tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: config_file
      upload_bucket: upload_bucket
      upload_key:
        source: [job_id, varscan2_mergevcf/output_vcf_file]
        valueFrom: $(self[0])/$(self[1].secondaryFiles[0].basename)
      local_file:
        source: varscan2_mergevcf/output_vcf_file
        valueFrom: $(self.secondaryFiles[0])
    out: [output]
