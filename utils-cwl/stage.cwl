#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: ubuntu:xenial-20161010
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

class: CommandLineTool

inputs:
  normal:
    type: File
  normal_index:
    type: File
  tumor:
    type: File
  tumor_index:
    type: File
  reference:
    type: File
  reference_fai:
    type: File
  reference_dict:
    type: File
  dbsnp:
    type: File
  dbsnp_index:
    type: File
  pon:
    type: File
  pon_index:
    type: File
  cosmic:
    type: File
  cosmic_index:
    type: File

outputs:
  normal_with_index:
    type: File
    outputBinding:
      glob: $(inputs.normal.basename)
    secondaryFiles:
      - '^.bai'
  tumor_with_index:
    type: File
    outputBinding:
      glob: $(inputs.tumor.basename)
    secondaryFiles:
      - '^.bai'
  reference_with_index:
    type: File
    outputBinding:
      glob: $(inputs.reference.basename)
    secondaryFiles:
      - '.fai'
      - '^.dict'
  pon_with_index:
    type: File
    outputBinding:
      glob: $(inputs.pon.basename)
    secondaryFiles:
      - '.tbi'
  cosmic_with_index:
    type: File
    outputBinding:
      glob: $(inputs.cosmic.basename)
    secondaryFiles:
      - '.tbi'
  dbsnp_with_index:
    type: File
    outputBinding:
      glob: $(inputs.dbsnp.basename)
    secondaryFiles:
      - '.tbi'

arguments:
  - valueFrom: |
      ${
         var cmd = "cp " + inputs.normal.path + " " +  inputs.tumor.path + " " + inputs.reference.path + " "
                         + inputs.dbsnp.path + " " + inputs.pon.path + " " + inputs.cosmic.path + " "
                         + inputs.normal_index.path + " " +  inputs.tumor_index.path + " " + inputs.reference_fai.path + " "
                         + inputs.dbsnp_index.path + " " + inputs.pon_index.path + " " + inputs.cosmic_index.path + " "
                         + inputs.reference_dict.path + " .";
         return cmd
      }
    shellQuote: false

baseCommand: []
