class @Token
  constructor: (@start_mark, @end_mark) ->

class @DirectiveToken extends @Token
  id: '<directive>'
  constructor: (@name, @value, @start_mark, @end_mark) ->

class @DocumentStartToken extends @Token
  id: '<document start>'

class @DocumentEndToken extends @Token
  id: '<document end>'

class @StreamStartToken extends @Token
  id: '<stream start>'
  constructor: (@start_mark, @end_mark, @encoding) ->

class @StreamEndToken extends @Token
  id: '<stream end>'

class @BlockSequenceStartToken extends @Token
  id: '<block sequence start>'

class @BlockMappingStartToken extends @Token
  id: '<block mapping end>'

class @BlockEndToken extends @Token
  id: '<block end>'

class @FlowSequenceStartToken extends @Token
  id: '['

class @FlowMappingStartToken extends @Token
  id: '{'

class @FlowSequenceEndToken extends @Token
  id: ']'

class @FlowMappingEndToken extends @Token
  id: '}'

class @KeyToken extends @Token
  id: '?'

class @ValueToken extends @Token
  id: ':'

class @BlockEntryToken extends @Token
  id: '-'

class @FlowEntryToken extends @Token
  id: ','

class @AliasToken extends @Token
  id: '<alias>'
  constructor: (@value, @start_mark, @end_mark) ->

class @AnchorToken extends @Token
  id: '<anchor>'
  constructor: (@value, @start_mark, @end_mark) ->

class @TagToken extends @Token
  id: '<tag>'
  constructor: (@value, @start_mark, @end_mark) ->

class @ScalarToken extends @Token
  id: '<scalar>'
  constructor: (@value, @plain, @start_mark, @end_mark, @style) ->