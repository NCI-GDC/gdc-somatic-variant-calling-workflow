#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  project_id:
    type: string?

  caller_id:
    type: string[]

  job_id:
    type: string

  experimental_strategy:
    type: string

outputs:
  output_prefix:
    type: string[]
  muse_sump_exp:
    type: string

expression: |
  ${
     var exp = inputs.experimental_strategy.toLowerCase().replace(/[-\s]/g, "_");
     if (exp == 'wxs'){
       var sump = 'E';
     } else {
       var sump = 'G';
     };
     var pid = inputs.project_id ? inputs.project_id + '.': '';
     var pfx = [];
     for (var i = 0; i < inputs.caller_id.length; i++){
       pfx.push(pid + inputs.job_id + '.' + exp + '.' + inputs.caller_id[i].toLowerCase());
     };
     var pfxList = pfx.sort();
     return {'output_prefix': pfxList, 'muse_sump_exp': sump};
   }
