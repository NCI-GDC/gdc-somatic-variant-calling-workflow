class: ExpressionTool
cwlVersion: v1.0
id: make_prefix
requirements:
  - class: InlineJavascriptRequirement
doc: |
  Make VCF filename prefix.

inputs:
  project_id:
    type: string?

  muse_caller_id:
    type: string

  mutect2_caller_id:
    type: string

  somaticsniper_caller_id:
    type: string

  varscan2_caller_id:
    type: string

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
     var cid = [];
     cid.push(inputs.muse_caller_id);
     cid.push(inputs.mutect2_caller_id);
     cid.push(inputs.somaticsniper_caller_id);
     cid.push(inputs.varscan2_caller_id);
     var pfx = [];
     for (var i = 0; i < cid.length; i++){
       pfx.push(pid + inputs.job_id + '.' + exp + '.' + cid[i].toLowerCase());
     };
     return {'output_prefix': pfx, 'muse_sump_exp': sump};
   }
