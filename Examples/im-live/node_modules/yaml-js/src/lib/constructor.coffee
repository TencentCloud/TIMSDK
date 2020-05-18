{MarkedYAMLError} = require './errors'
nodes             = require './nodes'
util              = require './util'

class @ConstructorError extends MarkedYAMLError

class @BaseConstructor

  yaml_constructors      : {}
  yaml_multi_constructors: {}

  @add_constructor: (tag, constructor) ->
    unless @::hasOwnProperty 'yaml_constructors'
      @::yaml_constructors = util.extend {}, @::yaml_constructors
    @::yaml_constructors[tag] = constructor

  @add_multi_constructor: (tag_prefix, multi_constructor) ->
    unless @::hasOwnProperty 'yaml_multi_constructors'
      @::yaml_multi_constructors = util.extend {}, @::yaml_multi_constructors
    @::yaml_multi_constructors[tag_prefix] = multi_constructor

  constructor: ->
    @constructed_objects   = {}
    @constructing_nodes    = []
    @deferred_constructors = []

  ###
  Are there more documents available?
  ###
  check_data: -> @check_node()

  ###
  Construct and return the next document.
  ###
  get_data: ->
    return @construct_document @get_node() if @check_node()

  ###
  Ensure that the stream contains a single document and construct it.
  ###
  get_single_data: ->
    node = @get_single_node()
    return @construct_document node if node?
    return null

  construct_document: (node) ->
    data = @construct_object node
    while not util.is_empty @deferred_constructors
      @deferred_constructors.pop()()
    return data

  defer: (f) -> @deferred_constructors.push f

  construct_object: (node) ->
    return @constructed_objects[node.unique_id] \
      if node.unique_id of @constructed_objects
    throw new exports.ConstructorError null, null, \
      'found unconstructable recursive node', node.start_mark \
      if node.unique_id in @constructing_nodes
    @constructing_nodes.push node.unique_id

    constructor = null
    tag_suffix  = null
    if node.tag of @yaml_constructors
      constructor = @yaml_constructors[node.tag]
    else
      for tag_prefix of @yaml_multi_constructors
        if node.tag.indexOf tag_prefix is 0
          tag_suffix = node.tag[tag_prefix.length...]
          constructor = @yaml_multi_constructors[tag_prefix]
          break
      if not constructor?
        if null of @yaml_multi_constructors
          tag_suffix = node.tag
          constructor = @yaml_multi_constructors[null]
        else if null of @yaml_constructors
          constructor = @yaml_constructors[null]
        else if node instanceof nodes.ScalarNode
          constructor = @construct_scalar
        else if node instanceof nodes.SequenceNode
          constructor = @construct_sequence
        else if node instanceof nodes.MappingNode
          constructor = @construct_mapping
    object = constructor.call @, tag_suffix ? node, node
    @constructed_objects[node.unique_id] = object
    @constructing_nodes.pop()
    return object

  construct_scalar: (node) ->
    throw new exports.ConstructorError null, null, \
      "expected a scalar node but found #{node.id}", node.start_mark \
      unless node instanceof nodes.ScalarNode
    node.value

  construct_sequence: (node) ->
    throw new exports.ConstructorError null, null, \
      "expected a sequence node but found #{node.id}", node.start_mark \
      unless node instanceof nodes.SequenceNode
    @construct_object child for child in node.value

  construct_mapping: (node) ->
    throw new ConstructorError null, null, \
      "expected a mapping node but found #{node.id}", node.start_mark \
      unless node instanceof nodes.MappingNode
    mapping = {}
    for [key_node, value_node] in node.value
      key = @construct_object key_node
      throw new exports.ConstructorError 'while constructing a mapping', \
        node.start_mark, 'found unhashable key', key_node.start_mark \
        if typeof key is 'object'
      value = @construct_object value_node
      mapping[key] = value
    return mapping

  construct_pairs: (node) ->
    throw new exports.ConstructorError null, null, \
      "expected a mapping node but found #{node.id}", node.start_mark \
      unless node instanceof nodes.MappingNode
    pairs = []
    for [key_node, value_node] in node.value
      key = @construct_object key_node
      value = @construct_object value_node
      pairs.push [key, value]
    return pairs

class @Constructor extends @BaseConstructor

  BOOL_VALUES =
    on   : true
    off  : false
    true : true
    false: false
    yes  : true
    no   : false

  TIMESTAMP_REGEX = \
    ///
    ^
    ([0-9][0-9][0-9][0-9]) #  1: year
    -([0-9][0-9]?)         #  2: month
    -([0-9][0-9]?)         #  3: day
    (?:
      (?:[Tt]|[\x20\t]+)
      ([0-9][0-9]?)        #  4: hour
      :([0-9][0-9])        #  5: minute
      :([0-9][0-9])        #  6: second
      (?:
        \.([0-9]*)         #  7: fraction
      )?
      (?:
        [\x20\t]*
        (
          Z
        |
          ([-+])           #  9: tz_sign
          ([0-9][0-9]?)    # 10: tz_hour
          (?:
            :([0-9][0-9])  # 11: tz_minute
          )?
        )                  #  8: tz
      )?
    )?
    $
    ///
  TIMESTAMP_PARTS =
    year     : 1
    month    : 2
    day      : 3
    hour     : 4
    minute   : 5
    second   : 6
    fraction : 7
    tz       : 8
    tz_sign  : 9
    tz_hour  : 10
    tz_minute: 11

  yaml_constructors      : {}
  yaml_multi_constructors: {}

  construct_scalar: (node) ->
    if node instanceof nodes.MappingNode
      for [key_node, value_node] in node.value
        return @construct_scalar value_node \
          if key_node.tag is 'tag:yaml.org,2002:value'
    return super node

  flatten_mapping: (node) ->
    merge = []
    index = 0
    while index < node.value.length
      [key_node, value_node] = node.value[index]
      if key_node.tag == 'tag:yaml.org,2002:merge'
        node.value.splice index, 1
        #delete node.value[index]
        if value_node instanceof nodes.MappingNode
          @flatten_mapping value_node
          merge = merge.concat value_node.value
        else if value_node instanceof nodes.SequenceNode
          submerge = []
          for subnode in value_node.value
            throw new exports.ConstructorError \
              'while constructing a mapping', node.start_mark,
              "expected a mapping for merging, but found #{subnode.id}",
              subnode.start_mark unless subnode instanceof nodes.MappingNode
            @flatten_mapping subnode
            submerge.push subnode.value
          submerge.reverse()
          merge = merge.concat value for value in submerge
        else
          throw new exports.ConstructorError 'while constructing a mapping',
            node.start_mark, "expected a mapping or list of mappings for
            merging but found #{value_node.id}", value_node.start_mark
      else if key_node.tag == 'tag:yaml.org,2002:value'
        key_node.tag = 'tag:yaml.org,2002:str'
        index++
      else
        index++
    if merge.length
      node.value = merge.concat node.value

  construct_mapping: (node) ->
    @flatten_mapping node if node instanceof nodes.MappingNode
    return super node

  construct_yaml_null: (node) ->
    @construct_scalar node
    return null

  construct_yaml_bool: (node) ->
    value = @construct_scalar node
    return BOOL_VALUES[value.toLowerCase()]

  construct_yaml_int: (node) ->
    value = @construct_scalar node
    value = value.replace /_/g, ''
    sign  = if value[0] is '-' then -1 else 1
    value = value[1...] if value[0] in '+-'

    if value is '0'
      return 0
    else if value.indexOf('0b') is 0
      return sign * parseInt value[2...], 2
    else if value.indexOf('0x') is 0
      return sign * parseInt value[2...], 16
    else if value.indexOf('0o') is 0
      return sign * parseInt value[2...], 8
    else if value[0] is '0'
      return sign * parseInt value, 8
    else if ':' in value
      digits = (parseInt part for part in value.split /:/g)
      digits.reverse()
      base  = 1
      value = 0
      for digit in digits
        value += digit * base
        base *= 60
      return sign * value
    else
      return sign * parseInt value

  construct_yaml_float: (node) ->
    value = @construct_scalar node
    value = value.replace(/_/g, '').toLowerCase()
    sign  = if value[0] is '-' then -1 else 1
    value = value[1...] if value[0] in '+-'

    if value is '.inf'
      return sign * Infinity
    else if value is '.nan'
      return NaN
    else if ':' in value
      digits = (parseFloat part for part in value.split /:/g)
      digits.reverse()
      base  = 1
      value = 0.0
      for digit in digits
        value += digit * base
        base *= 60
      return sign * value
    else
      return sign * parseFloat value

  construct_yaml_binary: (node) ->
    value = @construct_scalar node
    try
      return atob value if window?
      return new Buffer(value, 'base64').toString 'ascii'
    catch error
      throw new exports.ConstructorError null, null,
        "failed to decode base64 data: #{error}", node.start_mark

  construct_yaml_timestamp: (node) ->
    value  = @construct_scalar node
    match  = node.value.match TIMESTAMP_REGEX
    values = {}
    values[key] = match[index] for key, index of TIMESTAMP_PARTS

    year  = parseInt values.year
    month = parseInt(values.month) - 1
    day   = parseInt values.day
    return new Date Date.UTC year, month, day unless values.hour

    hour        = parseInt values.hour
    minute      = parseInt values.minute
    second      = parseInt values.second
    millisecond = 0
    if values.fraction
      fraction = values.fraction[0...6]
      fraction += '0' while fraction.length < 6
      fraction = parseInt fraction
      millisecond = Math.round fraction / 1000
    if values.tz_sign
      tz_sign = if values.tz_sign is '-' then 1 else -1
      hour   += tz_sign * tz_hour   if tz_hour   = parseInt values.tz_hour
      minute += tz_sign * tz_minute if tz_minute = parseInt values.tz_minute
    date = new Date Date.UTC year, month, day, hour, minute, second, millisecond
    return date

  construct_yaml_pair_list: (type, node) ->
    list = []
    throw new exports.ConstructorError "while constructing #{type}", \
      node.start_mark, "expected a sequence but found #{node.id}", \
      node.start_mark unless node instanceof nodes.SequenceNode

    @defer =>
      for subnode in node.value
        throw new exports.ConstructorError "while constructing #{type}", \
          node.start_mark, \
          "expected a mapping of length 1 but found #{subnode.id}", \
          subnode.start_mark unless subnode instanceof nodes.MappingNode

        throw new exports.ConstructorError "while constructing #{type}", \
          node.start_mark, \
          "expected a mapping of length 1 but found #{subnode.id}", \
          subnode.start_mark unless subnode.value.length is 1

        [key_node, value_node] = subnode.value[0]
        key   = @construct_object key_node
        value = @construct_object value_node
        list.push [key, value]
    return list

  construct_yaml_omap: (node) ->
    @construct_yaml_pair_list 'an ordered map', node

  construct_yaml_pairs: (node) ->
    @construct_yaml_pair_list 'pairs', node

  construct_yaml_set: (node) ->
    data = []
    @defer => data.push item for item of @construct_mapping node
    return data

  construct_yaml_str: (node) ->
    @construct_scalar node

  construct_yaml_seq: (node) ->
    data = []
    @defer => data.push item for item in @construct_sequence node
    return data

  construct_yaml_map: (node) ->
    data = {}
    @defer => data[key] = value for key, value of @construct_mapping node
    return data

  construct_yaml_object: (node, klass) ->
    data = new klass
    @defer =>
      data[key] = value for key, value of @construct_mapping node, true
    return data

  construct_undefined: (node) ->
    throw new exports.ConstructorError null, null,
      "could not determine a constructor for the tag #{node.tag}",
      node.start_mark

@Constructor.add_constructor 'tag:yaml.org,2002:null',
  @Constructor::construct_yaml_null

@Constructor.add_constructor 'tag:yaml.org,2002:bool',
  @Constructor::construct_yaml_bool

@Constructor.add_constructor 'tag:yaml.org,2002:int',
  @Constructor::construct_yaml_int

@Constructor.add_constructor 'tag:yaml.org,2002:float',
  @Constructor::construct_yaml_float

@Constructor.add_constructor 'tag:yaml.org,2002:binary',
  @Constructor::construct_yaml_binary

@Constructor.add_constructor 'tag:yaml.org,2002:timestamp',
  @Constructor::construct_yaml_timestamp

@Constructor.add_constructor 'tag:yaml.org,2002:omap',
  @Constructor::construct_yaml_omap

@Constructor.add_constructor 'tag:yaml.org,2002:pairs',
  @Constructor::construct_yaml_pairs

@Constructor.add_constructor 'tag:yaml.org,2002:set',
  @Constructor::construct_yaml_set

@Constructor.add_constructor 'tag:yaml.org,2002:str',
  @Constructor::construct_yaml_str

@Constructor.add_constructor 'tag:yaml.org,2002:seq',
  @Constructor::construct_yaml_seq

@Constructor.add_constructor 'tag:yaml.org,2002:map',
  @Constructor::construct_yaml_map

@Constructor.add_constructor null,
  @Constructor::construct_undefined