util        = require './util'
reader      = require './reader'
scanner     = require './scanner'
parser      = require './parser'
composer    = require './composer'
resolver    = require './resolver'
constructor = require './constructor'

@make_loader = (Reader = reader.Reader, Scanner = scanner.Scanner, Parser = parser.Parser, Composer = composer.Composer, Resolver = resolver.Resolver, Constructor = constructor.Constructor) -> class
  components = [Reader, Scanner, Parser, Composer, Resolver, Constructor]
  util.extend.apply util, [@::].concat (component.prototype for component in components)
  
  constructor: (stream) ->
    components[0].call @, stream
    component.call @ for component in components[1..]

@Loader = @make_loader()