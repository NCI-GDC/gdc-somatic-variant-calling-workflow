cwlVersion: v1.0
class: CommandLineTool
id: root_vcf
requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/bio-alpine:{{ bio_alpine }}"
  - class: InitialWorkDirRequirement
    listing:
      - entryname: $(inputs.fasta_file.basename)
        entry: $(inputs.fasta_file)
      - entryname: $(inputs.fasta_fai.basename)
        entry: $(inputs.fasta_fai)
      - entryname: $(inputs.fasta_dict.basename)
        entry: $(inputs.fasta_dict)
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 500
    ramMax: 500
    tmpdirMin: 1
    tmpdirMax: 1
    outdirMin: 1
    outdirMax: 1

inputs:
  fasta_file:
    type: File

  fasta_fai:
    type: File

  fasta_dict:
    type: File

outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.fasta_file.basename)
    secondaryFiles:
      - .fai
      - ^.dict

baseCommand: "true"

