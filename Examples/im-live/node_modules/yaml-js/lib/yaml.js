(function() {
  var fs;

  this.composer = require('./composer');

  this.constructor = require('./constructor');

  this.errors = require('./errors');

  this.events = require('./events');

  this.loader = require('./loader');

  this.nodes = require('./nodes');

  this.parser = require('./parser');

  this.reader = require('./reader');

  this.resolver = require('./resolver');

  this.scanner = require('./scanner');

  this.tokens = require('./tokens');

  /*
  Scan a YAML stream and produce scanning tokens.
  */


  this.scan = function(stream, Loader) {
    var loader, _results;

    if (Loader == null) {
      Loader = exports.loader.Loader;
    }
    loader = new Loader(stream);
    _results = [];
    while (loader.check_token()) {
      _results.push(loader.get_token());
    }
    return _results;
  };

  /*
  Parse a YAML stream and produce parsing events.
  */


  this.parse = function(stream, Loader) {
    var loader, _results;

    if (Loader == null) {
      Loader = exports.loader.Loader;
    }
    loader = new Loader(stream);
    _results = [];
    while (loader.check_event()) {
      _results.push(loader.get_event());
    }
    return _results;
  };

  /*
  Parse the first YAML document in a stream and produce the corresponding
  representation tree.
  */


  this.compose = function(stream, Loader) {
    var loader;

    if (Loader == null) {
      Loader = exports.loader.Loader;
    }
    loader = new Loader(stream);
    return loader.get_single_node();
  };

  /*
  Parse all YAML documents in a stream and produce corresponding representation
  trees.
  */


  this.compose_all = function(stream, Loader) {
    var loader, _results;

    if (Loader == null) {
      Loader = exports.loader.Loader;
    }
    loader = new Loader(stream);
    _results = [];
    while (loader.check_node()) {
      _results.push(loader.get_node());
    }
    return _results;
  };

  /*
  Parse the first YAML document in a stream and produce the corresponding
  Javascript object.
  */


  this.load = function(stream, Loader) {
    var loader;

    if (Loader == null) {
      Loader = exports.loader.Loader;
    }
    loader = new Loader(stream);
    return loader.get_single_data();
  };

  /*
  Parse all YAML documents in a stream and produce the corresponing Javascript
  object.
  */


  this.load_all = function(stream, Loader) {
    var loader, _results;

    if (Loader == null) {
      Loader = exports.loader.Loader;
    }
    loader = new Loader(stream);
    _results = [];
    while (loader.check_data()) {
      _results.push(loader.get_data());
    }
    return _results;
  };

  /*
  Register .yml and .yaml requires with yaml-js
  */


  if ((typeof require !== "undefined" && require !== null) && require.extensions) {
    fs = require('fs');
    require.extensions['.yml'] = require.extensions['.yaml'] = function(module, filename) {
      return module.exports = exports.load_all(fs.readFileSync(filename, 'utf8'));
    };
  }

}).call(this);
