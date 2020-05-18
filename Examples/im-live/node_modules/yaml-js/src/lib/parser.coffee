events            = require './events'
{MarkedYAMLError} = require './errors'
tokens            = require './tokens'

class @ParserError extends MarkedYAMLError

class @Parser
  
  DEFAULT_TAGS =
    '!' : '!',
    '!!': 'tag:yaml.org,2002:'
  
  constructor: ->
    @current_event = null
    @yaml_version = null
    @tag_handles = {}
    @states = []
    @marks = []
    @state = 'parse_stream_start'
  
  ###
  Reset the state attributes.
  ###
  dispose: ->
    @states = []
    @state = null
  
  ###
  Check the type of the next event.
  ###
  check_event: (choices...) ->
    if @current_event is null
      @current_event = @[@state]() if @state?
    if @current_event isnt null
      return true if choices.length is 0
      for choice in choices
        return true if @current_event instanceof choice
    return false
  
  ###
  Get the next event.
  ###
  peek_event: ->
    @current_event = @[@state]() if @current_event is null and @state?
    return @current_event
  
  ###
  Get the event and proceed further.
  ###
  get_event: ->
    @current_event = @[@state]() if @current_event is null and @state?
    event = @current_event
    @current_event = null
    return event
  
  # stream ::= STREAM-START implicit_document? explicit_document* STREAM-END
  # implicit_document ::= block_node DOCUMENT-END*
  # explicit_document ::= DIRECTIVE* DOCUMENT-START block_node? DOCUMENT-END*
  
  ###
  Parse the stream start.
  ###
  parse_stream_start: ->
    token = @get_token()
    event = new events.StreamStartEvent token.start_mark, token.end_mark
    
    # Prepare the next state,
    @state = 'parse_implicit_document_start'
    
    return event
  
  ###
  Parse an implicit document.
  ###
  parse_implicit_document_start: ->
    if not @check_token tokens.DirectiveToken, tokens.DocumentStartToken, \
        tokens.StreamEndToken
      @tag_handles = DEFAULT_TAGS
      token = @peek_token()
      start_mark = end_mark = token.start_mark
      event = new events.DocumentStartEvent start_mark, end_mark, false
      
      # Prepare the next state
      @states.push 'parse_document_end'
      @state = 'parse_block_node'
      
      return event
    else
      return @parse_document_start()
  
  ###
  Parse an explicit document.
  ###
  parse_document_start: ->
    # Parse any extra document end indicators
    @get_token() while @check_token tokens.DocumentEndToken
    
    if not @check_token tokens.StreamEndToken
      start_mark = @peek_token().start_mark
      [version, tags] = @process_directives()
      throw new exports.ParserError \
        "expected '<document start>', but found #{@peek_token().id}", \
        @peek_token().start_mark unless @check_token tokens.DocumentStartToken
      token = @get_token()
      end_mark = token.end_mark
      event = new events.DocumentStartEvent start_mark, end_mark, true,
        version, tags
      @states.push 'parse_document_end'
      @state = 'parse_document_content'
    else
      # Parse the end of the stream.
      token = @get_token()
      event = new events.StreamEndEvent token.start_mark, token.end_mark
      throw new Error 'assertion error, states should be empty' \
        unless @states.length is 0
      throw new Error 'assertion error, marks should be empty' \
        unless @marks.length is 0
      @state = null
    return event
  
  ###
  Parse the document end.
  ###
  parse_document_end: ->
    token = @peek_token()
    start_mark = end_mark = token.start_mark
    explicit = no
    if @check_token tokens.DocumentEndToken
      token = @get_token()
      end_mark = token.end_mark
      explicit = yes
    event = new events.DocumentEndEvent start_mark, end_mark, explicit
    
    # Prepare next state.
    @state = 'parse_document_start'
    
    return event
  
  parse_document_content: ->
    if @check_token tokens.DirectiveToken, tokens.DocumentStartToken, \
        tokens.DocumentEndToken, tokens.StreamEndToken
      event = @process_empty_scalar @peek_token().start_mark
      @state = @states.pop()
      return event
    else
      return @parse_block_node()
  
  process_directives: ->
    @yaml_version = null
    @tag_handles = {}
    while @check_token tokens.DirectiveToken
      token = @get_token()
      if token.name is 'YAML'
        throw new exports.ParserError null, null, \
          'found duplicate YAML directive', token.start_mark \
          if @yaml_version isnt null
        [major, minor] = token.value
        throw new exports.ParserError null, null, \
          'found incompatible YAML document (version 1.* is required)',
          token.start_mark if major isnt 1
        @yaml_version = token.value
      else if token.name is 'TAG'
        [handle, prefix] = @tag_handles
        throw new exports.ParserError null, null, \
          "duplicate tag handle #{handle}", token.start_mark \
          if handle of @tag_handles
        @tag_handles[handle] = prefix
    
    tag_handles_copy = null
    for own handle, prefix of @tag_handles
      tag_handles_copy ?= {}
      tag_handles_copy[handle] = prefix
    value = [@yaml_version, tag_handles_copy]
    
    for own handle, prefix of DEFAULT_TAGS
      @tag_handles[handle] = prefix if prefix not of @tag_handles
    
    return value
  
  # block_node_or_indentless_sequence ::= ALIAS
  #   | properties (block_content | indentless_sequence)?
  #   | block_content
  #   | indentless_block_sequence
  # block_node ::= ALIAS
  #   | properties block_content?
  #   | block_content
  # flow_node ::= ALIAS
  #   | properties flow_content?
  #   | flow_content
  # properties ::= TAG ANCHOR? | ANCHOR TAG?
  # block_content ::= block_collection | flow_collection | SCALAR
  # flow_content ::= flow_collection | SCALAR
  # block_collection ::= block_sequence | block_mapping
  # flow_collection ::= flow_sequence | flow_mapping
  
  parse_block_node: -> @parse_node true
  
  parse_flow_node: -> @parse_node()
  
  parse_block_node_or_indentless_sequence: ->
    @parse_node true, true
  
  parse_node: (block = false, indentless_sequence = false) ->
    if @check_token tokens.AliasToken
      token = @get_token()
      event = new events.AliasEvent token.value, token.start_mark,
        token.end_mark
      @state = @states.pop()
    else
      anchor = null
      tag = null
      start_mark = end_mark = tag_mark = null
      if @check_token tokens.AnchorToken
        token = @get_token()
        start_mark = token.start_mark
        end_mark = token.end_mark
        anchor = token.value
        if @check_token tokens.TagToken
          token = @get_token()
          tag_mark = token.start_mark
          end_mark = token.end_mark
          tag = token.value
      else if @check_token tokens.TagToken
        token = @get_token()
        start_mark = tag_mark = token.start_mark
        end_mark = token.end_mark
        tag = token.value
        if @check_token tokens.AnchorToken
          token = @get_token()
          end_mark = token.end_mark
          anchor = token.value
      if tag isnt null
        [handle, suffix] = tag
        if handle isnt null
          throw new exports.ParserError 'while parsing a node', start_mark, \
            "found undefined tag handle #{handle}", tag_mark \
            if handle not of @tag_handles
          tag = @tag_handles[handle] + suffix
        else
          tag = suffix
      
      start_mark = end_mark = @peek_token().start_mark if start_mark is null
      event = null
      implicit = tag is null or tag is '!'
      if indentless_sequence and @check_token tokens.BlockEntryToken
        end_mark = @peek_token().end_mark
        event = new events.SequenceStartEvent anchor, tag, implicit,
          start_mark, end_mark
        @state = 'parse_indentless_sequence_entry'
      else
        if @check_token tokens.ScalarToken
          token = @get_token()
          end_mark = token.end_mark
          if (token.plain and tag is null) or tag is '!'
            implicit = [true, false]
          else if tag is null
            implicit = [false, true]
          else
            implicit = [false, false]
          event = new events.ScalarEvent anchor, tag, implicit, token.value,
            start_mark, end_mark, token.style
          @state = @states.pop()
        else if @check_token tokens.FlowSequenceStartToken
          end_mark = @peek_token().end_mark
          event = new events.SequenceStartEvent anchor, tag, implicit,
            start_mark, end_mark, true
          @state = 'parse_flow_sequence_first_entry'
        else if @check_token tokens.FlowMappingStartToken
          end_mark = @peek_token().end_mark
          event = new events.MappingStartEvent anchor, tag, implicit,
            start_mark, end_mark, true
          @state = 'parse_flow_mapping_first_key'
        else if block and @check_token tokens.BlockSequenceStartToken
          end_mark = @peek_token().end_mark
          event = new events.SequenceStartEvent anchor, tag, implicit,
            start_mark, end_mark, false
          @state = 'parse_block_sequence_first_entry'
        else if block and @check_token tokens.BlockMappingStartToken
          end_mark = @peek_token().end_mark
          event = new events.MappingStartEvent anchor, tag, implicit,
            start_mark, end_mark, false
          @state = 'parse_block_mapping_first_key'
        else if anchor isnt null or tag isnt null
          # Empty scalars are allowed even if a tag or an anchor is specified.
          event = new events.ScalarEvent anchor, tag, [implicit, false], '',
            start_mark, end_mark
          @state = @states.pop()
        else
          if block
            node = 'block'
          else
            node = 'flow'
          token =  @peek_token()
          throw new exports.ParserError "while parsing a #{node} node",
            start_mark, "expected the node content, but found #{token.id}",
            token.start_mark
    return event
  
  # block_sequence ::= BLOCK-SEQUENCE-START (BLOCK-ENTRY block_node?)*
  #   BLOCK-END
  
  parse_block_sequence_first_entry: ->
    token = @get_token()
    @marks.push token.start_mark
    return @parse_block_sequence_entry()
  
  parse_block_sequence_entry: ->
    if @check_token tokens.BlockEntryToken
      token = @get_token()
      if not @check_token tokens.BlockEntryToken, tokens.BlockEndToken
        @states.push 'parse_block_sequence_entry'
        return @parse_block_node()
      else
        @state = 'parse_block_sequence_entry'
        return @process_empty_scalar token.end_mark
    if not @check_token tokens.BlockEndToken
      token = @peek_token()
      throw new exports.ParserError 'while parsing a block collection',
        @marks.slice(-1)[0], "expected <block end>, but found #{token.id}",
        token.start_mark
    token = @get_token()
    event = new events.SequenceEndEvent token.start_mark, token.end_mark
    @state = @states.pop()
    @marks.pop()
    return event
  
  # indentless_sequence ::= (BLOCK-ENTRY block_node?)+
  
  parse_indentless_sequence_entry: ->
    if @check_token tokens.BlockEntryToken
      token = @get_token()
      if not @check_token tokens.BlockEntryToken, tokens.KeyToken, \
          tokens.ValueToken, tokens.BlockEndToken
        @states.push 'parse_indentless_sequence_entry'
        return @parse_block_node()
      else
        @state = 'parse_indentless_sequence_entry'
        return @process_empty_scalar token.end_mark
    token = @peek_token()
    event = new events.SequenceEndEvent token.start_mark, token.start_mark
    @state = @states.pop()
    return event
  
  # block_mapping ::= BLOCK-MAPPING-START
  #   ((KEY block_node_or_indentless_sequence?)?
  #   (VALUE block_node_or_indentless_sequence?)?)* BLOCK-END
  
  parse_block_mapping_first_key: ->
    token = @get_token()
    @marks.push token.start_mark
    return @parse_block_mapping_key()
  
  parse_block_mapping_key: ->
    if @check_token tokens.KeyToken
      token = @get_token()
      if not @check_token tokens.KeyToken, tokens.ValueToken, \
          tokens.BlockEndToken
        @states.push 'parse_block_mapping_value'
        return @parse_block_node_or_indentless_sequence()
      else
        @state = 'parse_block_mapping_value'
        return @process_empty_scalar token.end_mark
    if not @check_token tokens.BlockEndToken
      token = @peek_token()
      throw new exports.ParserError 'while parsing a block mapping',
        @marks.slice(-1)[0], "expected <block end>, but found #{token.id}",
        token.start_mark
    token = @get_token()
    event = new events.MappingEndEvent token.start_mark, token.end_mark
    @state = @states.pop()
    @marks.pop()
    return event
  
  parse_block_mapping_value: ->
    if @check_token tokens.ValueToken
      token = @get_token()
      if not @check_token tokens.KeyToken, tokens.ValueToken, \
          tokens.BlockEndToken
        @states.push 'parse_block_mapping_key'
        return @parse_block_node_or_indentless_sequence()
      else
        @state = 'parse_block_mapping_key'
        return @process_empty_scalar token.end_mark
    else
      @state = 'parse_block_mapping_key'
      token = @peek_token()
      return @process_empty_scalar token.start_mark
  
  # flow_sequence ::= FLOW-SEQUENCE-START
  #   (flow_sequence_entry FLOW-ENTRY)* flow_sequence_entry? FLOW-SEQUENCE-END
  # flow_sequence_entry ::= flow_node | KEY flow_node? (VALUE flow_node?)?
  # 
  # Note that while production rules for both flow_sequence_entry and
  # flow_mapping_entry are equal, their interpretations are different.  For
  # `flow_sequence_entry`, the part `KEY flow_node? (VALUE flow_node?)?`
  # generate an inline mapping (set syntax).
  
  parse_flow_sequence_first_entry: ->
    token = @get_token()
    @marks.push token.start_mark
    return @parse_flow_sequence_entry yes
  
  parse_flow_sequence_entry: (first = no) ->
    if not @check_token tokens.FlowSequenceEndToken
      if not first
        if @check_token tokens.FlowEntryToken
          @get_token()
        else
          token = @peek_token()
          throw new exports.ParserError 'while parsing a flow sequence',
            @marks.slice(-1)[0], "expected ',' or ']', but got #{token.id}",
            token.start_mark
      if @check_token tokens.KeyToken
        token = @peek_token()
        event = new events.MappingStartEvent null, null, true,
          token.start_mark, token.end_mark, true
        @state = 'parse_flow_sequence_entry_mapping_key'
        return event
      else if not @check_token tokens.FlowSequenceEndToken
        @states.push 'parse_flow_sequence_entry'
        return @parse_flow_node()
    token = @get_token()
    event = new events.SequenceEndEvent token.start_mark, token.end_mark
    @state = @states.pop()
    @marks.pop()
    return event
  
  parse_flow_sequence_entry_mapping_key: ->
    token = @get_token()
    if not @check_token tokens.ValueToken, tokens.FlowEntryToken, \
        tokens.FlowSequenceEndToken
      @states.push 'parse_flow_sequence_entry_mapping_value'
      return @parse_flow_node()
    else
      @state = 'parse_flow_sequence_entry_mapping_value'
      return @process_empty_scalar token.end_mark
  
  parse_flow_sequence_entry_mapping_value: ->
    if @check_token tokens.ValueToken
      token = @get_token()
      if not @check_token tokens.FlowEntryToken, tokens.FlowSequenceEndToken
        @states.push 'parse_flow_sequence_entry_mapping_end'
        return @parse_flow_node()
      else
        @state = 'parse_flow_sequence_entry_mapping_end'
        return @process_empty_scalar token.end_mark
    else
      @state = 'parse_flow_sequence_entry_mapping_end'
      token = @peek_token()
      return @process_empty_scalar token.start_mark
  
  parse_flow_sequence_entry_mapping_end: ->
    @state = 'parse_flow_sequence_entry'
    token = @peek_token()
    return new events.MappingEndEvent token.start_mark, token.start_mark
  
  # flow_mapping ::= FLOW-MAPPING-START (flow_mapping_entry FLOW-ENTRY)*
  #   flow_mapping_entry? FLOW-MAPPING-END
  # flow_mapping_entry ::= flow_node | KEY flow_node? (VALUE flow_node?)?
  
  parse_flow_mapping_first_key: ->
    token = @get_token()
    @marks.push token.start_mark
    return @parse_flow_mapping_key yes
  
  parse_flow_mapping_key: (first = no) ->
    if not @check_token tokens.FlowMappingEndToken
      if not first
        if @check_token tokens.FlowEntryToken
          @get_token()
        else
          token = @peek_token()
          throw new exports.ParserError 'while parsing a flow mapping',
            @marks.slice(-1)[0], "expected ',' or '}', but got #{token.id}",
            token.start_mark
      if @check_token tokens.KeyToken
        token = @get_token()
        if not @check_token tokens.ValueToken, tokens.FlowEntryToken, \
            tokens.FlowMappingEndToken
          @states.push 'parse_flow_mapping_value'
          return @parse_flow_node()
        else
          @state = 'parse_flow_mapping_value'
          return @process_empty_scalar token.end_mark
      else if not @check_token tokens.FlowMappingEndToken
        @states.push 'parse_flow_mapping_empty_value'
        return @parse_flow_node()
    token = @get_token()
    event = new events.MappingEndEvent token.start_mark, token.end_mark
    @state = @states.pop()
    @marks.pop()
    return event
  
  parse_flow_mapping_value: ->
    if @check_token tokens.ValueToken
      token = @get_token()
      if not @check_token tokens.FlowEntryToken, tokens.FlowMappingEndToken
        @states.push 'parse_flow_mapping_key'
        return @parse_flow_node()
      else
        @state = 'parse_flow_mapping_key'
        return @process_empty_scalar token.end_mark
    else
      @state = 'parse_flow_mapping_key'
      token = @peek_token()
      return @process_empty_scalar token.start_mark
  
  parse_flow_mapping_empty_value: ->
    @state = 'parse_flow_mapping_key'
    return @process_empty_scalar @peek_token().start_mark
  
  process_empty_scalar: (mark) ->
    return new events.ScalarEvent null, null, [true, false], '', mark, mark