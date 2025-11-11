cwlVersion: v1.0
class: CommandLineTool
id: root_vcf
requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/bio-alpine:{{ bio_alpine }}"
  - class: InitialWorkDirRequirement
    listing:
      - entryname: $(inputs.parent_file.basename)
        entry: $(inputs.parent_file)
      - entryname: $(inputs.children.basename)
        entry: $(inputs.children)
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
  parent_file:
    type: File

  children:
    type: File

outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.parent_file.basename)
    secondaryFiles:
      - $(inputs.children.basename) 

baseCommand: "true"

