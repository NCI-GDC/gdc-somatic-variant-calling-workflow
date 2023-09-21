class: Workflow
cwlVersion: v1.0
id: gpas_stage_workflow
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
doc: |
  Stage input files.

inputs:
  normal: File
  normal_index: File
  tumor: File
  tumor_index: File
  reference: File
  reference_fai: File
  reference_dict: File
  indel: File
  indel_index: File
  dbsnp: File
  dbsnp_index: File
  pon: File
  pon_index: File
  cosmic: File
  cosmic_index: File

outputs:
  normal_with_index:
    type: File
    outputSource: make_normal_bam/output
  tumor_with_index:
    type: File
    outputSource: make_tumor_bam/output
  reference_with_index:
    type: File
    outputSource: make_reference/output
  pon_with_index:
    type: File
    outputSource: make_pon/output
  cosmic_with_index:
    type: File
    outputSource: make_cosmic/output
  dbsnp_with_index:
    type: File
    outputSource: make_dbsnp/output
  indel_with_index:
    type: File
    outputSource: make_indel/output

steps:
  standardize_normal_bai:
    run: ../../tools/util/rename_file.cwl
    in:
      input_file: normal_index
      output_filename:
        source: normal_index
        valueFrom: |
          ${
             return self.basename.lastIndexOf('.bam') !== -1 ?
                    self.basename.substr(0, self.basename.lastIndexOf('.bam')) + '.bai' :
                    self.basename
           }
    out: [ out_file ]

  make_normal_bam:
    run: ../../tools/util/make_secondary.cwl
    in:
      parent_file: normal
      children: standardize_normal_bai/out_file
    out: [ output ]

  standardize_tumor_bai:
    run: ../../tools/util/rename_file.cwl
    in:
      input_file: tumor_index
      output_filename:
        source: tumor_index
        valueFrom: |
          ${
             return self.basename.lastIndexOf('.bam') !== -1 ?
                    self.basename.substr(0, self.basename.lastIndexOf('.bam')) + '.bai' :
                    self.basename
           }
    out: [ out_file ]

  make_tumor_bam:
    run: ../../tools/util/make_secondary.cwl
    in:
      parent_file: tumor
      children: standardize_tumor_bai/out_file
    out: [ output ]

  make_reference:
    run: ../../tools/util/make_secondary.cwl
    in:
      fasta_file: reference
      fasta_fai: reference_fai
      fasta_dict: reference_dict
    out: [ output ]

  make_pon:
    run: ../../tools/util/make_secondary.cwl
    in:
      parent_file: pon
      children: pon_index
    out: [ output ]

  make_cosmic:
    run: ../../tools/util/make_secondary.cwl
    in:
      parent_file: cosmic
      children: cosmic_index
    out: [ output ]

  make_dbsnp:
    run: ../../tools/util/make_secondary.cwl
    in:
      parent_file: dbsnp
      children: dbsnp_index
    out: [ output ]

  make_indel:
    run: ../../tools/util/make_secondary.cwl
    in:
      parent_file: indel
      children: indel_index
    out: [ output ]
