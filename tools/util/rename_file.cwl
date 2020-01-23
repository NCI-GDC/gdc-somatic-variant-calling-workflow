class: CommandLineTool
cwlVersion: v1.0
id: rename_file
requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing: |
      ${
        var ret_list = [
          {"entry": inputs.input_file, "writable": false, "entryname": inputs.output_filename},
        ];
        return ret_list
      }
doc: |
    Renames the file.

inputs:
  input_file:
    type: File
    doc: The file to rename

  output_filename:
    type: string
    doc: the updated name of the output file

outputs:
  out_file:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)

baseCommand: 'true'
