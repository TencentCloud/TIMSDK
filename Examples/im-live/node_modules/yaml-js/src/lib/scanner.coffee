{MarkedYAMLError} = require './errors'
tokens            = require './tokens'
util              = require './util'

###
The Scanner throws these.
###
class @ScannerError extends MarkedYAMLError

###
Represents a possible simple key.
###
class SimpleKey
  constructor: (@token_number, @required, @index, @line, @column, @mark) ->

###
The Scanner class deals with converting a YAML stream into a token stream.
###
class @Scanner
  C_LB      = '\r\n\x85\u2028\u2029'
  C_WS      = '\t '
  C_NUMBERS = '0123456789'

  ESCAPE_REPLACEMENTS =
    '0' : '\x00'
    'a' : '\x07'
    'b' : '\x08'
    't' : '\x09'
    '\t': '\x09'
    'n' : '\x0A'
    'v' : '\x0B'
    'f' : '\x0C'
    'r' : '\x0D'
    'e' : '\x1B'
    ' ' : '\x20'
    '"' : '"'
    '\\': '\\'
    'N' : '\x85'
    '_' : '\xA0'
    'L' : '\u2028'
    'P' : '\u2029'

  ESCAPE_CODES =
    'x': 2
    'u': 4
    'U': 8

  ###
  Initialise the Scanner
  ###
  constructor: ->
    # Have we reached the end of the stream?
    @done = no

    # How many unclosed '{' or '[' have been seen. '0' implies block context.
    @flow_level = 0

    # List of processed tokens not yet emitted.
    @tokens = []

    # Add the STREAM-START token.
    @fetch_stream_start()

    # Number of tokens emitted through the `get_token` method.
    @tokens_taken = 0

    # Current indentation level. '-1' means no indentation has been seen.
    @indent = -1

    # Previous indentation levels.
    @indents = []

    # Simple Key Treatment
    #   A simple key is a key that is not denoted by the '?' indicator, e.g.
    #     block simple key: value
    #     ? not a simple key
    #     : { flow simple key: value }
    #   We emit the KEY token before all keys, so when we find a potential
    #   simple key, we try to locate the corresponding ':' indicator.  Simple
    #   keys should be limited to a single line and 1024 characters.

    # Can a simple key start at the current position?  A simple key may
    # start
    #   at the beginning of the line, not counting indentation spaces
    #     (block context)
    #   after '{', '[', ',' (flow context)
    #   after '?', ':', '-' (block context)
    # In the block context, this flag also signifies if a block collection
    # may start at the current position.
    @allow_simple_key = yes

    # Keep track of possible simple keys.  This is an object.  The key is
    # `flow_level`; there can be no more than one possible simple key for
    # each level.  The value is a SimpleKey object. A simple key may start
    # with ALIAS, ANCHOR, TAG, SCALAR (flow), '[' or '{' tokens.
    @possible_simple_keys = {}

  # API methods.

  ###
  Check if the next token is one of the given types.
  ###
  check_token: (choices...) ->
    @fetch_more_tokens() while @need_more_tokens()
    if @tokens.length isnt 0
      return true if choices.length is 0
      for choice in choices
        return true if @tokens[0] instanceof choice
    return false

  ###
  Return the next token, but do not delete it from the queue.
  ###
  peek_token: ->
    @fetch_more_tokens() while @need_more_tokens()
    return @tokens[0] if @tokens.length isnt 0

  ###
  Return the next token, and remove it from the queue.
  ###
  get_token: ->
    @fetch_more_tokens() while @need_more_tokens()
    if @tokens.length isnt 0
      @tokens_taken++
      return @tokens.shift()

  # Non-API methods.

  need_more_tokens: ->
    return no  if @done
    return yes if @tokens.length is 0

    # The current token may be a potential simple key, so we need to look
    # further.
    @stale_possible_simple_keys()
    return yes if @next_possible_simple_key() == @tokens_taken
    return no

  fetch_more_tokens: ->
    # Eat whitespace and comments until we reach the next token.
    @scan_to_next_token()

    # Remove obsolete possible simple keys
    @stale_possible_simple_keys()

    # Compare the current indentation and column. It may add some tokens and
    # decrease the current indentation level.
    @unwind_indent @column

    # Peek the next character.
    char = @peek()

    # Is it the end of stream?
    return @fetch_stream_end() if char is '\x00'

    # Is it a directive?
    return @fetch_directive() if char is '%' and @check_directive()

    # Is it the document start?
    return @fetch_document_start() if char is '-' and @check_document_start()

    # Is it the document end?
    return @fetch_document_end() if char is '.' and @check_document_end()

    # TODO: support for BOM within a stream.

    # Is it the flow sequence start indicator?
    return @fetch_flow_sequence_start() if char is '['

    # Is it the flow mapping start indicator?
    return @fetch_flow_mapping_start() if char is '{'

    # Is it the flow sequence end indicator?
    return @fetch_flow_sequence_end() if char is ']'

    # Is it the flow mapping end indicator?
    return @fetch_flow_mapping_end() if char is '}'

    # Is it the flow entry indicator?
    return @fetch_flow_entry() if char is ','

    # Is it the block entry indicator?
    return @fetch_block_entry() if char is '-' and @check_block_entry()

    # Is it the key indicator?
    return @fetch_key() if char is '?' and @check_key()

    # Is it the value indicator?
    return @fetch_value() if char is ':' and @check_value()

    # Is it an alias?
    return @fetch_alias() if char is '*'

    # Is it an anchor?
    return @fetch_anchor() if char is '&'

    # Is it a tag?
    return @fetch_tag() if char is '!'

    # Is it a literal scalar?
    return @fetch_literal() if char is '|' and @flow_level is 0

    # Is it a folded scalar?
    return @fetch_folded() if char is '>' and @flow_level is 0

    # Is it a single quoted scalar?
    return @fetch_single() if char is '\''

    # Is it a double quoted scalar?
    return @fetch_double() if char is '"'

    # It must be a plain scalar then.
    return @fetch_plain() if @check_plain()

    # No? It's an error.
    throw new exports.ScannerError 'while scanning for the next token', null,
      "found character #{char} that cannot start any token", @get_mark()

  # Simple keys treatment.

  ###
  Return the number of the nearest possible simple key.
  ###
  next_possible_simple_key: ->
    min_token_number = null
    for own level, key of @possible_simple_keys
      min_token_number = key.token_number \
        if min_token_number is null or key.token_number < min_token_number
    return min_token_number

  ###
  Remove entries that are no longer possible simple keys.  According to the
  YAML spec, simple keys:
    should be limited to a single line
    should be no longer than 1024 characters
  Disabling this procedure will allow simple keys of any length and height
  (may cause problems if indentation is broken though).
  ###
  stale_possible_simple_keys: ->
    for own level, key of @possible_simple_keys
      continue if key.line == @line and @index - key.index <= 1024
      if not key.required
        delete @possible_simple_keys[level]
      else
        throw new exports.ScannerError 'while scanning a simple key',
          key.mark, 'could not find expected \':\'', @get_mark()

  ###
  The next token may start a simple key.  We check if it's possible and save
  its position.  This function is called for ALIAS, ANCHOR, TAG,
  SCALAR (flow),'[' and '{'.
  ###
  save_possible_simple_key: ->
    # Check if a simple key is required at the current position.
    required = @flow_level is 0 and @indent == @column

    # A simple key is required only if it is the first token in the current
    # line.  Therefore it is always allowed.
    throw new Error 'logic failure' if required and not @allow_simple_key

    # If simple keys aren't allowed here we're done.
    return if not @allow_simple_key

    # The next token might be a simple key.  Let's save its number and
    # position.
    @remove_possible_simple_key()
    token_number = @tokens_taken + @tokens.length
    @possible_simple_keys[@flow_level] = new SimpleKey \
      token_number, required, @index, @line, @column, @get_mark()

  ###
  Remove the saved possible simple key at the current flow level.
  ###
  remove_possible_simple_key: ->
    return unless key = @possible_simple_keys[@flow_level]
    if not key.required then delete @possible_simple_keys[@flow_level]
    else
      throw new exports.ScannerError 'while scanning a simple key', key.mark,
        'could not find expected \':\'', @get_mark()

  # Indentation functions

  ###
  In flow context, tokens should respect indentation.
  Actually the condition should be `self.indent >= column` according to
  the spec. But this condition will prohibit intuitively correct
  constructions such as
    key : {
    }
  ###
  unwind_indent: (column) ->
    # In the flow context, indentation is ignored.  We make the scanner less
    # restrictive than the specification requires.
    return if @flow_level isnt 0

    # In block context we may need to issue the BLOCK-END tokens.
    while @indent > column
      mark = @get_mark()
      @indent = @indents.pop()
      @tokens.push new tokens.BlockEndToken mark, mark

  ###
  Check if we need to increase indentation.
  ###
  add_indent: (column) ->
    return false unless column > @indent
    @indents.push @indent
    @indent = column
    return true

  # Fetchers.

  fetch_stream_start: ->
    mark = @get_mark()
    @tokens.push new tokens.StreamStartToken mark, mark, @encoding

  fetch_stream_end: ->
    # Set the current indentation to -1.
    @unwind_indent -1

    # Reset simple keys.
    @remove_possible_simple_key()
    @allow_possible_simple_key = no
    @possible_simple_keys = {}

    mark = @get_mark()
    @tokens.push new tokens.StreamEndToken mark, mark

    # The stream is finished.
    @done = yes

  fetch_directive: ->
    # Set the current indentation to -1.
    @unwind_indent -1

    # Reset simple keys.
    @remove_possible_simple_key()
    @allow_simple_key = no

    # Scan and add DIRECTIVE
    @tokens.push @scan_directive()

  fetch_document_start: ->
    @fetch_document_indicator tokens.DocumentStartToken

  fetch_document_end: ->
    @fetch_document_indicator tokens.DocumentEndToken

  fetch_document_indicator: (TokenClass) ->
    # Set the current indentation to -1.
    @unwind_indent -1

    # Reset simple keys.  Note that there would not be a block collection
    # after '---'.
    @remove_possible_simple_key()
    @allow_simple_key = no

    # Add DOCUMENT-START or DOCUMENT-END.
    start_mark = @get_mark()
    @forward 3
    @tokens.push new TokenClass start_mark, @get_mark()

  fetch_flow_sequence_start: ->
    @fetch_flow_collection_start tokens.FlowSequenceStartToken

  fetch_flow_mapping_start: ->
    @fetch_flow_collection_start tokens.FlowMappingStartToken

  fetch_flow_collection_start: (TokenClass) ->
    # '[' and '{' may start a simple key.
    @save_possible_simple_key()

    # Increase flow level.
    @flow_level++

    # Simple keys are allowed after '[' and '{'
    @allow_simple_key = yes

    # Add FLOW-SEQUENCE-START or FLOW-MAPPING-START.
    start_mark = @get_mark()
    @forward()
    @tokens.push new TokenClass start_mark, @get_mark()

  fetch_flow_sequence_end: ->
    @fetch_flow_collection_end tokens.FlowSequenceEndToken

  fetch_flow_mapping_end: ->
    @fetch_flow_collection_end tokens.FlowMappingEndToken

  fetch_flow_collection_end: (TokenClass) ->
    # Reset possible simple key on the current level.
    @remove_possible_simple_key()

    # Decrease the flow level
    @flow_level--

    # No simple keys after ']' or '}'
    @allow_simple_key = no

    # Add FLOW-SEQUENCE-END or FLOW-MAPPING-END.
    start_mark = @get_mark()
    @forward()
    @tokens.push new TokenClass start_mark, @get_mark()

  fetch_flow_entry: ->
    # Simple keys are allowed after ','.
    @allow_simple_key = yes

    # Reset possible simple key on the current level.
    @remove_possible_simple_key()

    # Add FLOW-ENTRY
    start_mark = @get_mark()
    @forward()
    @tokens.push new tokens.FlowEntryToken start_mark, @get_mark()

  fetch_block_entry: ->
    # Block context needs additional checks
    if @flow_level is 0
      # Are we allowed to start a new entry?
      unless @allow_simple_key
        throw new exports.ScannerError null, null,
          'sequence entries are not allowed here', @get_mark()

      # We may need to add BLOCK-SEQUENCE-START
      if @add_indent @column
        mark = @get_mark()
        @tokens.push new tokens.BlockSequenceStartToken mark, mark

    # It's an error for the block entry to occur in the flow context but we
    # let the parser detect this.

    # Simple keys are allowed after '-'
    @allow_simple_key = yes

    # Reset possible simple key on the current level.
    @remove_possible_simple_key()

    # Add BLOCK-ENTRY
    start_mark = @get_mark()
    @forward()
    @tokens.push new tokens.BlockEntryToken start_mark, @get_mark()

  fetch_key: ->
    # Block context needs additional checks.
    if @flow_level is 0
      # Are we allowed to start a key?
      unless @allow_simple_key
        throw new exports.ScannerError null, null,
          'mapping keys are not allowed here', @get_mark()

      # We may need to add BLOCK-MAPPING-START.
      if @add_indent @column
        mark = @get_mark()
        @tokens.push new tokens.BlockMappingStartToken mark, mark

    # Simple keys are allowed after '?' in the flow context.
    @allow_simple_key = not @flow_level

    # Reset possible simple key on the current level.
    @remove_possible_simple_key()

    # Add KEY.
    start_mark = @get_mark()
    @forward()
    @tokens.push new tokens.KeyToken start_mark, @get_mark()

  fetch_value: ->
    # Do we determine a simple key?
    if key = @possible_simple_keys[@flow_level]
      # Add KEY.
      delete @possible_simple_keys[@flow_level]
      @tokens.splice key.token_number - @tokens_taken, 0,
        new tokens.KeyToken key.mark, key.mark

      # If this key starts a new block mapping we need to add
      # BLOCK-MAPPING-START.
      if @flow_level is 0
        if @add_indent key.column
          @tokens.splice key.token_number - @tokens_taken, 0,
            new tokens.BlockMappingStartToken key.mark, key.mark

      # There cannot be two simple keys one after the other.
      @allow_simple_key = no

    # It must be part of a complex key.
    else
      # Block context needs additional checks.
      # TODO: do we really need them?  Parser will catch them anyway.
      if @flow_level is 0
        # We are allowed to start a complex value if and only if we can start
        # a simple key.
        unless @allow_simple_key
          throw new exports.ScannerError null, null,
            'mapping values are not allowed here', @get_mark()

        # If this value starts a new block mapping we need to add
        # BLOCK-MAPPING-START.  It will be detected as an error later by the
        # parser.
        if @add_indent @column
          mark = @get_mark()
          @tokens.push new tokens.BlockMappingStartToken mark, mark

      # Simple keys are allowed after ':' in the block context.
      @allow_simple_key = not @flow_level

      # Reset possible simple key on the current level.
      @remove_possible_simple_key()

    # Add VALUE.
    start_mark = @get_mark()
    @forward()
    @tokens.push new tokens.ValueToken start_mark, @get_mark()

  fetch_alias: ->
    # ALIAS could be a simple key.
    @save_possible_simple_key()

    # No simple keys after ALIAS.
    @allow_simple_key = no

    # Scan and add ALIAS.
    @tokens.push @scan_anchor tokens.AliasToken

  fetch_anchor: ->
    # ANCHOR could start a simple key.
    @save_possible_simple_key()

    # No simple keys allowed after ANCHOR.
    @allow_simple_key = no

    # Scan and add ANCHOR.
    @tokens.push @scan_anchor tokens.AnchorToken

  fetch_tag: ->
    # TAG could start a simple key
    @save_possible_simple_key()

    # No simple keys after TAG.
    @allow_simple_key = no

    # Scan and add TAG.
    @tokens.push @scan_tag()

  fetch_literal: ->
    @fetch_block_scalar '|'

  fetch_folded: ->
    @fetch_block_scalar '>'

  fetch_block_scalar: (style) ->
    # A simple key may follow a block sclar.
    @allow_simple_key = yes

    # Reset possible simple key on the current level.
    @remove_possible_simple_key()

    # Scan and add SCALAR.
    @tokens.push @scan_block_scalar style

  fetch_single: ->
    @fetch_flow_scalar '\''

  fetch_double: ->
    @fetch_flow_scalar '"'

  fetch_flow_scalar: (style) ->
    # A flow scalar could be a simple key.
    @save_possible_simple_key()

    # No simple keys after flow scalars.
    @allow_simple_key = no

    # Scan and add SCALAR.
    @tokens.push @scan_flow_scalar style

  fetch_plain: ->
    # A plain scalar could be a simple key.
    @save_possible_simple_key()

    # No simple keys after plain scalars.  But note that `scan_plain` will
    # change this flag if the scan is finished at the beginning of the line.
    @allow_simple_key = no

    # Scan and add SCALAR.  May change `allow_simple_key`.
    @tokens.push @scan_plain()

  # Checkers.

  ###
  DIRECTIVE: ^ '%'
  ###
  check_directive: ->
    # The % indicator has already been checked.
    return true if @column is 0
    return false

  ###
  DOCUMENT-START: ^ '---' (' '|'\n')
  ###
  check_document_start: ->
    return true if @column is 0 and @prefix(3) == '---' \
      and @peek(3) in C_LB + C_WS + '\x00'
    return false

  ###
  DOCUMENT-END: ^ '...' (' '|'\n')
  ###
  check_document_end: ->
    return true if @column is 0 and @prefix(3) == '...' \
      and @peek(3) in C_LB + C_WS + '\x00'
    return false

  ###
  BLOCK-ENTRY: '-' (' '|'\n')
  ###
  check_block_entry: ->
    return @peek(1) in C_LB + C_WS + '\x00'

  ###
  KEY (flow context):  '?'
  KEY (block context): '?' (' '|'\n')
  ###
  check_key: ->
    # KEY (flow context)
    return true if @flow_level isnt 0

    # KEY (block context)
    return @peek(1) in C_LB + C_WS + '\x00'

  ###
  VALUE (flow context):  ':'
  VALUE (block context): ':' (' '|'\n')
  ###
  check_value: ->
    # VALUE (flow context)
    return true if @flow_level isnt 0

    # VALUE (block context)
    return @peek(1) in C_LB + C_WS + '\x00'

  ###
  A plain scalar may start with any non-space character except:
    '-', '?', ':', ',', '[', ']', '{', '}',
    '#', '&', '*', '!', '|', '>', '\'', '"',
    '%', '@', '`'.

  It may also start with
    '-', '?', ':'
  if it is followed by a non-space character.

  Note that we limit the last rule to the block context (except the '-'
  character) because we want the flow context to be space independent.
  ###
  check_plain: ->
    char = @peek()
    return char not in C_LB + C_WS + '\x00-?:,[]{}#&*!|>\'"%@`' \
      or (@peek(1) not in C_LB + C_WS + '\x00' \
      and (char is '-' or (@flow_level is 0 and char in '?:')))

  # Scanners.

  ###
  We ignore spaces, line breaks and comments.
  If we find a line break in the block context, we set the flag
  `allow_simple_key` on.
  The byte order mark is stripped if it's the first character in the stream.
  We do not yet support BOM inside the stream as the specification requires.
  Any such mark will be considered as a part of the document.

  TODO: We need to make tab handling rules more sane.  A good rule is
    Tabs cannot precede tokens BLOCK-SEQUENCE-START, BLOCK-MAPPING-START,
    BLOCK-END, KEY (block context), VALUE (block context), BLOCK-ENTRY
  So the tab checking code is
    @allow_simple_key = off if <TAB>
  We also need to add the check for `allow_simple_key is on` to
  `unwind_indent` before issuing BLOCK-END.  Scanners for block, flow and
  plain scalars need to be modified.
  ###
  scan_to_next_token: ->
    @forward() if @index is 0 and @peek() == '\uFEFF'
    found = no
    while not found
      @forward() while @peek() == ' '

      if @peek() == '#'
        @forward() while @peek() not in C_LB + '\x00'

      if @scan_line_break()
        @allow_simple_key = yes if @flow_level is 0
      else
        found = yes

  ###
  See the specification for details.
  ###
  scan_directive: ->
    start_mark = @get_mark()
    @forward()
    name = @scan_directive_name start_mark
    value = null
    if name is 'YAML'
      value = @scan_yaml_directive_value start_mark
      end_mark = @get_mark()
    else if name is 'TAG'
      value = @scan_tag_directive_value start_mark
      end_mark = @get_mark()
    else
      end_mark = @get_mark()
      @forward() while @peek() not in C_LB + '\x00'
    @scan_directive_ignored_line start_mark
    return new tokens.DirectiveToken name, value, start_mark, end_mark

  ###
  See the specification for details.
  ###
  scan_directive_name: (start_mark) ->
    length = 0
    char = @peek length
    while '0' <= char <= '9' or 'A' <= char <= 'Z' or 'a' <= char <= 'z' \
        or char in '-_'
      length++
      char = peek length
    throw new exports.ScannerError 'while scanning a directive', start_mark,
      "expected alphanumeric or numeric character but found #{char}",
      @get_mark() if length is 0

    value = @prefix length
    @forward length
    char = @peek()
    throw new exports.ScannerError 'while scanning a directive', start_mark,
      "expected alphanumeric or numeric character but found #{char}",
      @get_mark() if char not in C_LB + '\x00 '

    return value

  ###
  See the specification for details.
  ###
  scan_yaml_directive_value: (start_mark) ->
    @forward() while @peek() == ' '
    major = @scan_yaml_directive_number start_mark
    throw new exports.ScannerError 'while scanning a directive', start_mark,
      "expected a digit or '.' but found #{@peek()}", @get_mark() \
      if @peek() != '.'

    @forward()
    minor = @scan_yaml_directive_number start_mark
    throw new exports.ScannerError 'while scanning a directive', start_mark,
      "expected a digit or ' ' but found #{@peek()}", @get_mark() \
      if @peek() not in C_LB + '\x00 '

    return [major, minor]

  ###
  See the specification for details.
  ###
  scan_yaml_directive_number: (start_mark) ->
    char = @peek()
    throw new exports.ScannerError 'while scanning a directive', start_mark,
      "expected a digit but found #{char}", @get_mark() \
      unless '0' <= char <= '9'

    length = 0
    length++ while '0' <= @peek(length) <= '9'
    value = parseInt @prefix length
    @forward length

    return value

  ###
  See the specification for details.
  ###
  scan_tag_directive_value: (start_mark) ->
    @forward() while @peek() == ' '
    handle = @scan_tag_directive_handle start_mark

    @forward() while @peek() == ' '
    prefix = @scan_tag_directive_prefix start_mark

    return [handle, prefix]

  ###
  See the specification for details.
  ###
  scan_tag_directive_handle: (start_mark) ->
    value = @scan_tag_handle 'directive', start_mark
    char = @peek()
    throw new exports.ScannerError 'while scanning a directive', start_mark,
      "expected ' ' but found #{char}", @get_mark() if char isnt ' '
    return value

  ###
  See the specification for details.
  ###
  scan_tag_directive_prefix: (start_mark) ->
    value = @scan_tag_uri 'directive', start_mark
    char = @peek()
    throw new exports.ScannerError 'while scanning a directive', start_mark,
      "expected ' ' but found #{char}", @get_mark() \
      if char not in C_LB + '\x00 '
    return value

  ###
  See the specification for details.
  ###
  scan_directive_ignored_line: (start_mark) ->
    @forward() while @peek() == ' '
    if @peek() == '#'
      @forward() while @peek() not in C_LB + '\x00'

    char = @peek()
    throw new exports.ScannerError 'while scanning a directive', start_mark,
      "expected a comment or a line break but found #{char}", @get_mark() \
      if char not in C_LB + '\x00'

    @scan_line_break()

  ###
  The specification does not restrict characters for anchors and aliases.
  This may lead to problems, for instance, the document:
    [ *alias, value ]
  can be interpteted in two ways, as
    [ "value" ]
  and
    [ *alias , "value" ]
  Therefore we restrict aliases to numbers and ASCII letters.
  ###
  scan_anchor: (TokenClass) ->
    start_mark = @get_mark()
    indicator = @peek()
    if indicator is '*'
      name = 'alias'
    else
      name = 'anchor'

    @forward()
    length = 0
    char = @peek length
    while '0' <= char <= '9' or 'A' <= char <= 'Z' or 'a' <= char <= 'z' \
        or char in '-_'
      length++
      char = @peek length
    throw new exports.ScannerError "while scanning an #{name}", start_mark, \
      "expected alphabetic or numeric character but found '#{char}'", \
      @get_mark() if length is 0

    value = @prefix length
    @forward length
    char = @peek()
    throw new exports.ScannerError "while scanning an #{name}", start_mark, \
      "expected alphabetic or numeric character but found '#{char}'", \
      @get_mark() if char not in C_LB + C_WS + '\x00' + '?:,]}%@`'

    return new TokenClass value, start_mark, @get_mark()

  ###
  See the specification for details.
  ###
  scan_tag: ->
    start_mark = @get_mark()
    char = @peek 1
    if char is '<'
      handle = null
      @forward 2
      suffix = @scan_tag_uri 'tag', start_mark
      throw new exports.ScannerError 'while parsing a tag', start_mark, \
        "expected '>' but found #{@peek()}", @get_mark() if @peek() isnt '>'
      @forward()
    else if char in C_LB + C_WS + '\x00'
      handle = null
      suffix = '!'
      @forward()
    else
      length = 1
      use_handle = no
      while char not in C_LB + '\x00 '
        if char is '!'
          use_handle = yes
          break
        length++
        char = @peek length
      if use_handle
        handle = @scan_tag_handle 'tag', start_mark
      else
        handle = '!'
        @forward()
      suffix = @scan_tag_uri 'tag', start_mark
    char = @peek()
    throw new exports.ScannerError 'while scanning a tag', start_mark, \
      "expected ' ' but found #{char}", @get_mark() \
      if char not in C_LB + '\x00 '
    return new tokens.TagToken [handle, suffix], start_mark, @get_mark()

  ###
  See the specification for details.
  ###
  scan_block_scalar: (style) ->
    folded = style is '>'

    chunks = []
    start_mark = @get_mark()

    # Scan the header.
    @forward()
    [chomping, increment] = @scan_block_scalar_indicators start_mark
    @scan_block_scalar_ignored_line start_mark

    # Determine the indentation level and go to the first non-empty line.
    min_indent = @indent + 1
    min_indent = 1 if min_indent < 1
    if not increment?
      [breaks, max_indent, end_mark] = @scan_block_scalar_indentation()
      indent = Math.max min_indent, max_indent
    else
      indent = min_indent + increment - 1
      [breaks, end_mark] = @scan_block_scalar_breaks indent
    line_break = ''

    # Scan the inner part of the block scalar.
    while @column == indent and @peek() != '\x00'
      chunks = chunks.concat breaks
      leading_non_space = @peek() not in ' \t'
      length = 0
      length++ while @peek(length) not in C_LB + '\x00'
      chunks.push @prefix length
      @forward length
      line_break = @scan_line_break()
      [breaks, end_mark] = @scan_block_scalar_breaks indent

      if @column == indent and @peek() != '\x00'
        # Unfortunately, folding rules are ambiguous.  This is the folding
        # according to the specification:
        if folded and line_break is '\n' and leading_non_space \
            and @peek() not in ' \t'
          chunks.push ' ' if util.is_empty breaks
        else
          chunks.push line_break

        # This is Clark Evan's interpretation (also in the spec examples):
        # if folded and line_break is '\n'
        #   if not breaks
        #     if @peek() not in ' \t'
        #       chunks.push ' '
        #     else
        #       chunks.push line_break
        # else
        #   chunks.push line_break
      else
        break

    # Chomp the tail
    chunks.push line_break if chomping isnt false
    chunks = chunks.concat breaks if chomping is true

    # And we're done.
    return new tokens.ScalarToken chunks.join(''), false, start_mark,
      end_mark, style

  ###
  See the specification for details.
  ###
  scan_block_scalar_indicators: (start_mark) ->
    chomping = null
    increment = null
    char = @peek()
    if char in '+-'
      chomping = char is '+'
      @forward()
      char = @peek()
      if char in C_NUMBERS
        increment = parseInt char
        throw new exports.ScannerError 'while scanning a block scalar', \
          start_mark, \
          'expected indentation indicator in the range 1-9 but found 0', \
          @get_mark() if increment is 0
        @forward()
    else if char in C_NUMBERS
      increment = parseInt char
      throw new exports.ScannerError 'while scanning a block scalar', \
        start_mark, \
        'expected indentation indicator in the range 1-9 but found 0', \
        @get_mark() if increment is 0
      @forward()
      char = @peek()
      if char in '+-'
        chomping = char is '+'
        @forward()

    char = @peek()
    throw new exports.ScannerError 'while scanning a block scalar', \
      start_mark,\
      "expected chomping or indentation indicators, but found #{char}", \
      @get_mark() if char not in C_LB + '\x00 '

    return [chomping, increment]

  ###
  See the specification for details.
  ###
  scan_block_scalar_ignored_line: (start_mark) ->
    @forward() while @peek() == ' '
    if @peek() == '#'
      @forward() while @peek() not in C_LB + '\x00'
    char = @peek()
    throw new exports.ScannerError 'while scanning a block scalar', \
      start_mark, "expected a comment or a line break but found #{char}", \
      @get_mark() if char not in C_LB + '\x00'
    @scan_line_break()

  ###
  See the specification for details.
  ###
  scan_block_scalar_indentation: ->
    chunks = []
    max_indent = 0
    end_mark = @get_mark()
    while @peek() in C_LB + ' '
      if @peek() != ' '
        chunks.push @scan_line_break()
        end_mark = @get_mark()
      else
        @forward()
        max_indent = @column if @column > max_indent
    return [chunks, max_indent, end_mark]

  ###
  See the specification for details.
  ###
  scan_block_scalar_breaks: (indent) ->
    chunks = []
    end_mark = @get_mark()
    @forward() while @column < indent and @peek() == ' '
    while @peek() in C_LB
      chunks.push @scan_line_break()
      end_mark = @get_mark()
      @forward() while @column < indent and @peek() == ' '
    return [chunks, end_mark]

  ###
  See the specification for details.
  Note that we loose indentation rules for quoted scalars. Quoted scalars
  don't need to adhere indentation because " and ' clearly mark the beginning
  and the end of them. Therefore we are less restrictive than the
  specification requires. We only need to check that document separators are
  not included in scalars.
  ###
  scan_flow_scalar: (style) ->
    double = style is '"'
    chunks = []
    start_mark = @get_mark()
    quote = @peek()
    @forward()
    chunks = chunks.concat @scan_flow_scalar_non_spaces double, start_mark
    while @peek() != quote
      chunks = chunks.concat  @scan_flow_scalar_spaces double, start_mark
      chunks = chunks.concat @scan_flow_scalar_non_spaces double, start_mark
    @forward()
    return new tokens.ScalarToken chunks.join(''), false, start_mark,
      @get_mark(), style

  ###
  See the specification for details.
  ###
  scan_flow_scalar_non_spaces: (double, start_mark) ->
    chunks = []
    while true
      length = 0
      length++ while @peek(length) not in C_LB + C_WS + '\'"\\\x00'
      if length isnt 0
        chunks.push @prefix length
        @forward length
      char = @peek()
      if not double and char is '\'' and @peek(1) == '\''
        chunks.push '\''
        @forward 2
      else if (double and char is '\'') or (not double and char in '"\\')
        chunks.push char
        @forward()
      else if double and char is '\\'
        @forward()
        char = @peek()
        if char of ESCAPE_REPLACEMENTS
          chunks.push ESCAPE_REPLACEMENTS[char]
          @forward()
        else if char of ESCAPE_CODES
          length = ESCAPE_CODES[char]
          @forward()
          for k in [0...length]
            throw new exports.ScannerError \
              'while scanning a double-quoted scalar', start_mark,
              "expected escape sequence of #{length} hexadecimal numbers, but #{
              }found #{@peek k}", @get_mark() \
              if @peek(k) not in C_NUMBERS + 'ABCDEFabcdef'
          code = parseInt @prefix(length), 16
          chunks.push String.fromCharCode code
          @forward length
        else if char in C_LB
          @scan_line_break()
          chunks = chunks.concat @scan_flow_scalar_breaks double, start_mark
        else
          throw new exports.ScannerError \
            'while scanning a double-quoted scalar', start_mark,
            "found unknown escape character #{char}", @get_mark()
      else
        return chunks

  ###
  See the specification for details.
  ###
  scan_flow_scalar_spaces: (double, start_mark) ->
    chunks = []
    length = 0
    length++ while @peek(length) in C_WS
    whitespaces = @prefix length
    @forward length
    char = @peek()
    throw new exports.ScannerError 'while scanning a quoted scalar', \
      start_mark, 'found unexpected end of stream', @get_mark() \
      if char is '\x00'
    if char in C_LB
      line_break = @scan_line_break()
      breaks = @scan_flow_scalar_breaks double, start_mark
      if line_break isnt '\n'
        chunks.push line_break
      else if not breaks
        chunks.push ' '
      chunks = chunks.concat breaks
    else
      chunks.push whitespaces

    return chunks

  ###
  See the specification for details.
  ###
  scan_flow_scalar_breaks: (double, start_mark) ->
    chunks = []
    while true
      # Instead of checking for indentation, we check for document separators.
      prefix = @prefix 3
      if prefix is '---' or prefix is '...' and @peek(3) in C_LB + C_WS + '\x00'
        throw new exports.ScannerError 'while scanning a quoted scalar',
          start_mark, 'found unexpected document separator', @get_mark()
      @forward() while @peek() in C_WS
      if @peek() in C_LB
        chunks.push @scan_line_break()
      else
        return chunks

  ###
  See the specification for details.
  We add an additional restriction for the flow context:
    plain scalars in the flow context cannot contain ',', ':' and '?'.
  We also keep track of the `allow_simple_key` flag here.
  Indentation rules are loosed for the flow context.
  ###
  scan_plain: ->
    chunks = []
    start_mark = end_mark = @get_mark()
    indent = @indent + 1

    # We allow zero indentation for scalars, but then we need to check for
    # document separators at the beginning of the line.
    # indent = 1 if indent is 0
    spaces = []
    while true
      length = 0
      break if @peek() == '#'

      while true
        char = @peek length
        break \
          if char in C_LB + C_WS + '\x00' or (@flow_level is 0 \
            and char is ':' and @peek(length + 1) in C_LB + C_WS + '\x00') \
            or (@flow_level isnt 0 and char in ',:?[]{}')
        length++

      # It's not clear what we should do with ':' in the flow context.
      if @flow_level isnt 0 and char is ':' \
          and @peek(length + 1) not in C_LB + C_WS + '\x00,[]{}'
        @forward length
        throw new exports.ScannerError 'while scanning a plain scalar',
          start_mark, 'found unexpected \':\'', @get_mark(),
          'Please check http://pyyaml.org/wiki/YAMLColonInFlowContext'
      break if length is 0

      @allow_simple_key = no
      chunks = chunks.concat spaces
      chunks.push @prefix length
      @forward length
      end_mark = @get_mark()
      spaces = @scan_plain_spaces indent, start_mark
      break if not spaces? or spaces.length is 0 or @peek() == '#' \
        or (@flow_level is 0 and @column < indent)
    return new tokens.ScalarToken chunks.join(''), true, start_mark, end_mark

  ###
  See the specification for details.
  The specification is really confusing about tabs in plain scalars.
  We just forbid them completely. Do not use tabs in YAML!
  ###
  scan_plain_spaces: (indent, start_mark) ->
    chunks = []
    length = 0
    length++ while @peek(length) in ' '
    whitespaces = @prefix length
    @forward length
    char = @peek()
    if char in C_LB
      line_break = @scan_line_break()
      @allow_simple_key = yes
      prefix = @prefix 3
      return if prefix is '---' or prefix is '...' \
        and @peek(3) in C_LB + C_WS + '\x00'
      breaks = []
      while @peek() in C_LB + ' '
        if @peek() == ' '
          @forward()
        else
          breaks.push @scan_line_break()
          prefix = @prefix 3
          return if prefix is '---' or prefix is '...' \
            and @peek(3) in C_LB + C_WS + '\x00'

      if line_break isnt '\n'
        chunks.push line_break
      else if breaks.length is 0
        chunks.push ' '
      chunks = chunks.concat breaks
    else if whitespaces
      chunks.push whitespaces
    return chunks

  ###
  See the specification for details.
  For some strange reasons, the specification does not allow '_' in tag
  handles. I have allowed it anyway.
  ###
  scan_tag_handle: (name, start_mark) ->
    char = @peek()
    throw new exports.ScannerError "while scanning a #{name}", start_mark, \
      "expected '!' but found #{char}", @get_mark() if char isnt '!'
    length = 1
    char = @peek length
    if char isnt ' '
      while '0' <= char <= '9' or 'A' <= char <= 'Z' or 'a' <= char <= 'z' \
          or char in '-_'
        length++
        char = @peek length
      if char isnt '!'
        @forward length
        throw new exports.ScannerError "while scanning a #{name}", start_mark,
          "expected '!' but found #{char}", @get_mark()
      length++
    value = @prefix length
    @forward length
    return value

  ###
  See the specification for details.
  Note: we do not check if URI is well-formed.
  ###
  scan_tag_uri: (name, start_mark) ->
    chunks = []
    length = 0
    char = @peek length
    while '0' <= char <= '9' or 'A' <= char <= 'Z' or 'a' <= char <= 'z' \
        or char in '-;/?:@&=+$,_.!~*\'()[]%'
      if char is '%'
        chunks.push @prefix length
        @forward length
        length = 0
        chunks.push @scan_uri_escapes name, start_mark
      else
        length++
      char = @peek length
    if length isnt 0
      chunks.push @prefix length
      @forward length
      length = 0
    throw new exports.ScannerError "while parsing a #{name}", start_mark, \
      "expected URI but found #{char}", @get_mark() if chunks.length is 0
    return chunks.join('')

  ###
  See the specification for details.
  ###
  scan_uri_escapes: (name, start_mark) ->
    bytes = []
    mark = @get_mark()
    while @peek() == '%'
      @forward()
      for k in [0..2]
        throw new exports.ScannerError "while scanning a #{name}", start_mark,
          "expected URI escape sequence of 2 hexadecimal numbers but found
          #{@peek k}", @get_mark()
      bytes.push String.fromCharCode parseInt @prefix(2), 16
      @forward 2
    return bytes.join('')

  ###
  Transforms:
    '\r\n'      :   '\n'
    '\r'        :   '\n'
    '\n'        :   '\n'
    '\x85'      :   '\n'
    '\u2028'    :   '\u2028'
    '\u2029     :   '\u2029'
    default     :   ''
  ###
  scan_line_break: ->
    char = @peek()
    if char in '\r\n\x85'
      if @prefix(2) == '\r\n'
        @forward 2
      else
        @forward()
      return '\n'
    else if char in '\u2028\u2029'
      @forward()
      return char
    return ''