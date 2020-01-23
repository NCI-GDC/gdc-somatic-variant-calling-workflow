class: ExpressionTool
cwlVersion: v1.0
id: divide_groups
requirements:
  - class: InlineJavascriptRequirement
doc: |
  Divide file array on filesize.

inputs:
  inputFile:
    type: File[]

outputs:
  emptyFile:
    type:
      type: array
      items: File

  trueFile:
    type:
      type: array
      items: File

expression: |
  ${
    var emptyFile = [];
    var trueFile = [];
    for (var i = 0; i < inputs.inputFile.length; i++){
      if (inputs.inputFile[i].size == 0){
        emptyFile.push(inputs.inputFile[i]);
      } else {
        trueFile.push(inputs.inputFile[i])
      }
    };
    return {'emptyFile': emptyFile, 'trueFile': trueFile};
  }
