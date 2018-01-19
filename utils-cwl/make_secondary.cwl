#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: alpine
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing: |
      ${
           var i
           var ret = [{"entryname": inputs.parent_file.basename, "entry": inputs.parent_file}];
           for( i of inputs.children ) {
               ret.push({"entryname": i.basename, "entry": i})
           }
           return ret
       }

class: CommandLineTool

inputs:
  parent_file:
    type: File

  children:
    type: File[]

outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.parent_file.basename)
    secondaryFiles: |
      ${
         var ret = [];
         var locbase = self.location.substr(0, self.location.lastIndexOf('/'))
         var i
         for( i of inputs.children ) {
           ret.push({"class": "File", "location": locbase + '/' + i.basename})
         }
         return ret
       }

baseCommand: "true"
