class: Workflow
cwlVersion: v1.0
id: varscan2_workflow
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
doc: |
    GDC VarScan2

inputs:
  reference:
    type: File
    secondaryFiles: [.fai, ^.dict]
    doc: Human genome reference file with .fai, ^.dict secondary files.
  mpileups:
    type: File[]
    doc: Tumor/Normal mpileup files.
  threads:
    type: int
    default: 8
    doc: Threads for internal multithreading dockers.
  java_opts:
    type: string
    default: '3G'
    doc: Java option flags for all the java cmd. GDC default is 3G.
  output_prefix:
    type: string
    doc: Output filename prefix.
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
  timeout:
    type: int?
    doc: VarScan2 max runtime.

outputs:
  varscan2_vcf:
    type: File
    outputSource: mergevcf/output_vcf_file

steps:
  varscan2:
    run: ../../submodules/varscan-cwl/tools/multi_varscan2.cwl
    in:
      thread_count: threads
      java_opts: java_opts
      tn_pair_pileup: mpileups
      ref_dict:
        source: reference
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
      timeout: timeout
    out: [SNP_SOMATIC_HC, INDEL_SOMATIC_HC]

  update_seqdict_on_snp:
    run: ../../submodules/variant-filtration-cwl/tools/picard_update_sequence_dictionary.cwl
    in:
      input_vcf: varscan2/SNP_SOMATIC_HC
      output_filename:
        source: output_prefix
        valueFrom: $(self + '.snp.upseqdict.vcf')
      sequence_dictionary:
        source: reference
        valueFrom: $(self.secondaryFiles[1])
    out: [output_file]

  remove_non_standard_variants_on_snp:
    run: ../../submodules/variant-filtration-cwl/tools/filter_nonstandard_variants.cwl
    in:
      input_vcf: update_seqdict_on_snp/output_file
      output_filename:
        source: output_prefix
        valueFrom: $(self + '.snp.standard_unsorted.vcf')
    out: [output_file]

  sort_snp_vcf:
    run: ../../tools/picard/picard_sortvcf.cwl
    in:
      ref_dict:
        source: reference
        valueFrom: $(self.secondaryFiles[1])
      output_vcf:
        source: output_prefix
        valueFrom: $(self + '.snp.sorted.vcf.gz')
      input_vcf:
        source: remove_non_standard_variants_on_snp/output_file
        valueFrom: $([self])
    out: [sorted_vcf]

  update_seqdict_on_indel:
    run: ../../submodules/variant-filtration-cwl/tools/picard_update_sequence_dictionary.cwl
    in:
      input_vcf: varscan2/INDEL_SOMATIC_HC
      output_filename:
        source: output_prefix
        valueFrom: $(self + '.indel.upseqdict.vcf')
      sequence_dictionary:
        source: reference
        valueFrom: $(self.secondaryFiles[1])
    out: [output_file]

  remove_non_standard_variants_on_indel:
    run: ../../submodules/variant-filtration-cwl/tools/filter_nonstandard_variants.cwl
    in:
      input_vcf: update_seqdict_on_indel/output_file
      output_filename:
        source: output_prefix
        valueFrom: $(self + '.indel.standard_unsorted.vcf')
    out: [output_file]

  sort_indel_vcf:
    run: ../../tools/picard/picard_sortvcf.cwl
    in:
      ref_dict:
        source: reference
        valueFrom: $(self.secondaryFiles[1])
      output_vcf:
        source: output_prefix
        valueFrom: $(self + '.indel.sorted.vcf.gz')
      input_vcf:
        source: remove_non_standard_variants_on_indel/output_file
        valueFrom: $([self])
    out: [sorted_vcf]

  mergevcf:
    run: ../../submodules/variant-filtration-cwl/tools/picard_merge_vcfs.cwl
    in:
      input_vcf: [sort_snp_vcf/sorted_vcf, sort_indel_vcf/sorted_vcf]
      output_filename:
        source: output_prefix
        valueFrom: $(self + '.raw_somatic_mutation.vcf.gz')
      sequence_dictionary:
        source: reference
        valueFrom: $(self.secondaryFiles[1])
    out: [output_vcf_file]