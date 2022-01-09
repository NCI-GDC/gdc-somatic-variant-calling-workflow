class: Workflow
cwlVersion: v1.0
id: muse_workflow
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
doc: |
    GDC MuSE

inputs:
  reference:
    type: File
    secondaryFiles: [.fai, ^.dict]
    doc: Human genome reference file with .fai, ^.dict secondary files.
  bed:
    type: File
    doc: BED file.
  normal_bam:
    type: File
    secondaryFiles: .bai
    doc: Normal BAM file with .bai index.
  tumor_bam:
    type: File
    secondaryFiles: .bai
    doc: Tumor BAM file with .bai index.
  threads:
    type: int
    default: 8
    doc: Threads for internal multithreading dockers.
  dbsnp:
    type: File
    secondaryFiles: .tbi
    doc: dbSNP reference file. GDC default is dbSNP build-144.
  exp_strat:
    type: string
    doc: Experimental strategy. (E|G)
  output_prefix:
    type: string
    doc: Output filename prefix.
  timeout:
    type: int?
    doc: MuSE max runtime.

outputs:
  muse_vcf:
    type: File
    outputSource: sort_muse_vcf/sorted_vcf

steps:
  muse_call:
    run: ../../submodules/muse-cwl/tools/multi_muse_call.cwl
    in:
      ref: reference
      region: bed
      normal_bam: normal_bam
      tumor_bam: tumor_bam
      thread_count: threads
      timeout: timeout
    out: [output_file]

  muse_sump:
    run: ../../submodules/muse-cwl/tools/muse_sump.cwl
    in:
      dbsnp: dbsnp
      call_output: muse_call/output_file
      exp_strat: exp_strat
      output_base:
        source: output_prefix
        valueFrom: $(self + '.raw_somatic_mutation.vcf')
    out: [MUSE_OUTPUT]

  remove_non_standard_variants:
    run: ../../submodules/variant-filtration-cwl/tools/filter_nonstandard_variants.cwl
    in:
      input_vcf: muse_sump/MUSE_OUTPUT
      output_filename:
        source: output_prefix
        valueFrom: $(self + '.standard_unsorted.vcf')
    out: [output_file]

  sort_muse_vcf:
    run: ../../tools/picard/picard_sortvcf.cwl
    in:
      ref_dict:
        source: reference
        valueFrom: $(self.secondaryFiles[1])
      output_vcf:
        source: output_prefix
        valueFrom: $(self + '.raw_somatic_mutation.vcf.gz')
      input_vcf:
        source: remove_non_standard_variants/output_file
        valueFrom: $([self])
    out: [sorted_vcf]
