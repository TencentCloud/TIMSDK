nodes       = require './nodes'
util        = require './util'
{YAMLError} = require './errors'

class @ResolverError extends YAMLError

class @BaseResolver
  
  DEFAULT_SCALAR_TAG   = 'tag:yaml.org,2002:str'
  DEFAULT_SEQUENCE_TAG = 'tag:yaml.org,2002:seq'
  DEFAULT_MAPPING_TAG  = 'tag:yaml.org,2002:map'
  
  yaml_implicit_resolvers: {}
  yaml_path_resolvers    : {}
  
  @add_implicit_resolver: (tag, regexp, first = [null]) ->
    unless @::hasOwnProperty 'yaml_implicit_resolvers'
      @::yaml_implicit_resolvers = util.extend {}, @::yaml_implicit_resolvers
    for char in first
      (@::yaml_implicit_resolvers[char] ?= []).push [tag, regexp]
  
  constructor: ->
    @resolver_exact_paths  = []
    @resolver_prefix_paths = []
  
  descend_resolver: (current_node, current_index) ->
    return if util.is_empty @yaml_path_resolvers
    exact_paths  = {}
    prefix_paths = []
    if current_node
      depth = @resolver_prefix_paths.length
      for [path, kind] in @resolver_prefix_paths.slice(-1)[0]
        if @check_resolver_prefix depth, path, kind, current_node, \
            current_index
          if path.length > depth
            prefix_paths.push [path, kind]
          else
            exact_paths[kind] = @yaml_path_resolvers[path][kind]
    else
      for [path, kind] in @yaml_path_resolvers
        if not path
          exact_paths[kind] = @yaml_path_resolvers[path][kind]
        else
          prefix_paths.push [path, kind]
    @resolver_exact_paths.push exact_paths
    @resolver_prefix_paths.push prefix_paths
  
  ascend_resolver: ->
    return if util.is_empty @yaml_path_resolvers
    @resolver_exact_paths.pop()
    @resolver_prefix_paths.pop()
  
  check_resolver_prefix: (depth, path, kind, current_node, current_index) ->
    [node_check, index_check] = path[depth - 1]
    if typeof node_check is 'string'
      return if current_node.tag != node_check
    else if node_check isnt null
      return unless current_node instanceof node_check
    
    return if index_check is true and current_index isnt null
    return if (index_check is false or index_check is null) \
      and current_index is null
    
    if typeof index_check is 'string'
      return if not (current_index instanceof nodes.ScalarNode) \
        and index_check == current_index.value
    else if typeof index_check is 'number'
      return if index_check != current_index
    
    return true
  
  resolve: (kind, value, implicit) ->
    if kind == nodes.ScalarNode and implicit[0]
      if value is ''
        resolvers = @yaml_implicit_resolvers[''] ? []
      else
        resolvers = @yaml_implicit_resolvers[value[0]] ? []
      resolvers = resolvers.concat @yaml_implicit_resolvers[null] ? []
      for [tag, regexp] in resolvers
        return tag if value.match regexp
      implicit = implicit[1]
    
    empty = yes
    for k of @yaml_path_resolvers
      empty = no unless {}[k]?
    if not empty
      exact_paths = @resolver_exact_paths.slice(-1)[0]
      return exact_paths[kind] if kind in exact_paths
      return exact_paths[null] if null in exact_paths
    
    return DEFAULT_SCALAR_TAG   if kind == nodes.ScalarNode
    return DEFAULT_SEQUENCE_TAG if kind == nodes.SequenceNode
    return DEFAULT_MAPPING_TAG  if kind == nodes.MappingNode

class @Resolver extends @BaseResolver

@Resolver.add_implicit_resolver 'tag:yaml.org,2002:bool',
  ///
  ^(?:
    yes|Yes|YES|true|True|TRUE|on|On|ON|
    no|No|NO|false|False|FALSE|off|Off|OFF
  )$
  ///,
  'yYnNtTfFoO'

@Resolver.add_implicit_resolver 'tag:yaml.org,2002:float',
  ///
  ^(?:
      [-+]?(?:[0-9][0-9_]*)\.[0-9_]*(?:[eE][-+][0-9]+)?
    | \.[0-9_]+(?:[eE][-+][0-9]+)?
    | [-+]?[0-9][0-9_]*(?::[0-5]?[0-9])+\.[0-9_]*
    | [-+]?\.(?:inf|Inf|INF)
    | \.(?:nan|NaN|NAN)
  )$
  ///,
  '-+0123456789.'

@Resolver.add_implicit_resolver 'tag:yaml.org,2002:int',
  ///
  ^(?:
      [-+]?0b[01_]+
    | [-+]?0[0-7_]+
    | [-+]?(?:0|[1-9][0-9_]*)
    | [-+]?0x[0-9a-fA-F_]+
    | [-+]?0o[0-7_]+
    | [-+]?[1-9][0-9_]*(?::[0-5]?[0-9])+
  )$
  ///,
  '-+0123456789'

@Resolver.add_implicit_resolver 'tag:yaml.org,2002:merge', /^(?:<<)$/, '<'

@Resolver.add_implicit_resolver 'tag:yaml.org,2002:null',
  /^(?:~|null|Null|NULL|)$/, ['~', 'n', 'N', '']

@Resolver.add_implicit_resolver 'tag:yaml.org,2002:timestamp',
  ///
  ^(?:
      [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]
    |
      [0-9][0-9][0-9][0-9]-[0-9][0-9]?-[0-9][0-9]?
      (?:[Tt]|[\x20\t]+)
      [0-9][0-9]? :[0-9][0-9] :[0-9][0-9] (?:\.[0-9]*)?
      (?:[\x20\t]*(?:Z|[-+][0-9][0-9]?(?::[0-9][0-9])?))?
  )$
  ///,
  '0123456789'

@Resolver.add_implicit_resolver 'tag:yaml.org,2002:value', /^(?:=)$/, '='

# The following resolver is only for documentation purposes.  It cannot work
# because plain scalars cannot start with '!', '&' or '*'.
@Resolver.add_implicit_resolver 'tag:yaml.org,2002:yaml', /^(?:!|&|\*)$/, '!&*'