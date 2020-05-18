events            = require './events'
{MarkedYAMLError} = require './errors'
nodes             = require './nodes'

class @ComposerError extends MarkedYAMLError

class @Composer
  
  constructor: ->
    @anchors = {}
  
  check_node: ->
    # Drop the STREAM-START event.
    @get_event() if @check_event events.StreamStartEvent
    
    # Are there more documents available?
    return not @check_event events.StreamEndEvent
  
  ###
  Get the root node of the next document.
  ###
  get_node: ->
    return @compose_document() unless @check_event events.StreamEndEvent
  
  get_single_node: ->
    # Drop the STREAM-START event.
    @get_event()
    
    # Compose a document if the stream is not empty.
    document = null
    document = @compose_document() unless @check_event events.StreamEndEvent
    
    # Ensure that the stream contains no more documents.
    unless @check_event events.StreamEndEvent
      event = @get_event()
      throw new exports.ComposerError 'expected a single document in the stream',
        document.start_mark, 'but found another document', event.start_mark
    
    # Drop the STREAM-END event.
    @get_event()
    
    return document
  
  compose_document: ->
    # Drop the DOCUMENT-START event.
    @get_event()
    
    # Compose the root node.
    node = @compose_node()
    
    # Drop the DOCUMENT-END node.
    @get_event()
    
    @anchors = {}
    return node
  
  compose_node: (parent, index) ->
    if @check_event events.AliasEvent
      event = @get_event()
      anchor = event.anchor
      throw new exports.ComposerError null, null, \
        "found undefined alias #{anchor}", event.start_mark \
        if anchor not of @anchors
      return @anchors[anchor]
    
    event = @peek_event()
    anchor = event.anchor
    throw new exports.ComposerError \
      "found duplicate anchor #{anchor}; first occurence", \
      @anchors[anchor].start_mark, 'second occurrence', event.start_mark \
      if anchor isnt null and anchor of @anchors
    
    @descend_resolver parent, index
    if @check_event events.ScalarEvent
      node = @compose_scalar_node anchor
    else if @check_event events.SequenceStartEvent
      node = @compose_sequence_node anchor
    else if @check_event events.MappingStartEvent
      node = @compose_mapping_node anchor
    @ascend_resolver()
    
    return node
  
  compose_scalar_node: (anchor) ->
    event = @get_event()
    tag = event.tag
    tag = @resolve nodes.ScalarNode, event.value, event.implicit \
      if tag is null or tag is '!'
    node = new nodes.ScalarNode tag, event.value, event.start_mark,
      event.end_mark, event.style
    @anchors[anchor] = node if anchor isnt null
    return node
  
  compose_sequence_node: (anchor) ->
    start_event = @get_event()
    tag = start_event.tag
    tag = @resolve nodes.SequenceNode, null, start_event.implicit \
      if tag is null or tag is '!'
    node = new nodes.SequenceNode tag, [], start_event.start_mark, null,
      start_event.flow_style
    @anchors[anchor] = node if anchor isnt null
    index = 0
    while not @check_event events.SequenceEndEvent
      node.value.push @compose_node node, index
      index++
    end_event = @get_event()
    node.end_mark = end_event.end_mark
    return node
  
  compose_mapping_node: (anchor) ->
    start_event = @get_event()
    tag = start_event.tag
    tag = @resolve nodes.MappingNode, null, start_event.implicit \
      if tag is null or tag is '!'
    node = new nodes.MappingNode tag, [], start_event.start_mark, null,
      start_event.flow_style
    @anchors[anchor] = node if anchor isnt null
    while not @check_event events.MappingEndEvent
      item_key   = @compose_node node
      item_value = @compose_node node, item_key
      node.value.push [item_key, item_value]
    end_event = @get_event()
    node.end_mark = end_event.end_mark
    return node