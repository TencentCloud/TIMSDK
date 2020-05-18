(function() {
  var Mark, YAMLError, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  _ref = require('./errors'), Mark = _ref.Mark, YAMLError = _ref.YAMLError;

  this.ReaderError = (function(_super) {
    __extends(ReaderError, _super);

    function ReaderError(name, position, character, reason) {
      this.name = name;
      this.position = position;
      this.character = character;
      this.reason = reason;
      ReaderError.__super__.constructor.call(this);
    }

    ReaderError.prototype.toString = function() {
      return "unacceptable character " + (this.character.charCodeAt()) + ": " + this.reason + "\n  in \"" + this.name + "\", position " + this.position;
    };

    return ReaderError;

  })(YAMLError);

  /*
  Reader:
    checks if characters are within the allowed range
    add '\x00' to the end
  */


  this.Reader = (function() {
    var NON_PRINTABLE;

    NON_PRINTABLE = /[^\x09\x0A\x0D\x20-\x7E\x85\xA0-\uD7FF\uE000-\uFFFD]/;

    function Reader(string) {
      this.string = string;
      this.line = 0;
      this.column = 0;
      this.index = 0;
      this.check_printable();
      this.string += '\x00';
    }

    Reader.prototype.peek = function(index) {
      if (index == null) {
        index = 0;
      }
      return this.string[this.index + index];
    };

    Reader.prototype.prefix = function(length) {
      if (length == null) {
        length = 1;
      }
      return this.string.slice(this.index, this.index + length);
    };

    Reader.prototype.forward = function(length) {
      var char, _results;

      if (length == null) {
        length = 1;
      }
      _results = [];
      while (length) {
        char = this.string[this.index];
        this.index++;
        if (__indexOf.call('\n\x85\u2082\u2029', char) >= 0 || (char === '\r' && this.string[this.index] !== '\n')) {
          this.line++;
          this.column = 0;
        } else {
          this.column++;
        }
        _results.push(length--);
      }
      return _results;
    };

    Reader.prototype.get_mark = function() {
      return new Mark(this.name, this.line, this.column, this.string, this.index);
    };

    Reader.prototype.check_printable = function() {
      var character, match, position;

      match = NON_PRINTABLE.exec(this.string);
      if (match) {
        character = match[0];
        position = (this.string.length - this.index) + match.index;
        throw new exports.ReaderError(this.name, position, character.charCodeAt(), 'special characters are not allowed');
      }
    };

    return Reader;

  })();

}).call(this);
