# Attach all the classes to the yaml-js object.
@composer    = require './composer'
@constructor = require './constructor'
@errors      = require './errors'
@events      = require './events'
@loader      = require './loader'
@nodes       = require './nodes'
@parser      = require './parser'
@reader      = require './reader'
@resolver    = require './resolver'
@scanner     = require './scanner'
@tokens      = require './tokens'

###
Scan a YAML stream and produce scanning tokens.
###
@scan = (stream, Loader = exports.loader.Loader) ->
  loader = new Loader stream
  loader.get_token() while loader.check_token()

###
Parse a YAML stream and produce parsing events.
###
@parse = (stream, Loader = exports.loader.Loader) ->
  loader = new Loader stream
  loader.get_event() while loader.check_event()

###
Parse the first YAML document in a stream and produce the corresponding
representation tree.
###
@compose = (stream, Loader = exports.loader.Loader) ->
  loader = new Loader stream
  return loader.get_single_node()

###
Parse all YAML documents in a stream and produce corresponding representation
trees.
###
@compose_all = (stream, Loader = exports.loader.Loader) ->
  loader = new Loader stream
  loader.get_node() while loader.check_node()

###
Parse the first YAML document in a stream and produce the corresponding
Javascript object.
###
@load = (stream, Loader = exports.loader.Loader) ->
  loader = new Loader stream
  loader.get_single_data()

###
Parse all YAML documents in a stream and produce the corresponing Javascript
object.
###
@load_all = (stream, Loader = exports.loader.Loader) ->
  loader = new Loader stream
  loader.get_data() while loader.check_data()

###
Register .yml and .yaml requires with yaml-js
###
if require? and require.extensions
  fs = require 'fs'
  require.extensions['.yml'] = require.extensions['.yaml'] = (module, filename) ->
    module.exports = exports.load_all fs.readFileSync filename, 'utf8'