(function() {
  var composer, constructor, parser, reader, resolver, scanner, util;

  util = require('./util');

  reader = require('./reader');

  scanner = require('./scanner');

  parser = require('./parser');

  composer = require('./composer');

  resolver = require('./resolver');

  constructor = require('./constructor');

  this.make_loader = function(Reader, Scanner, Parser, Composer, Resolver, Constructor) {
    if (Reader == null) {
      Reader = reader.Reader;
    }
    if (Scanner == null) {
      Scanner = scanner.Scanner;
    }
    if (Parser == null) {
      Parser = parser.Parser;
    }
    if (Composer == null) {
      Composer = composer.Composer;
    }
    if (Resolver == null) {
      Resolver = resolver.Resolver;
    }
    if (Constructor == null) {
      Constructor = constructor.Constructor;
    }
    return (function() {
      var component, components;

      components = [Reader, Scanner, Parser, Composer, Resolver, Constructor];

      util.extend.apply(util, [_Class.prototype].concat((function() {
        var _i, _len, _results;

        _results = [];
        for (_i = 0, _len = components.length; _i < _len; _i++) {
          component = components[_i];
          _results.push(component.prototype);
        }
        return _results;
      })()));

      function _Class(stream) {
        var _i, _len, _ref;

        components[0].call(this, stream);
        _ref = components.slice(1);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          component = _ref[_i];
          component.call(this);
        }
      }

      return _Class;

    })();
  };

  this.Loader = this.make_loader();

}).call(this);
