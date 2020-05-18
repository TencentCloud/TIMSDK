(function() {
  var _ref, _ref1, _ref10, _ref11, _ref12, _ref13, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.Token = (function() {
    function Token(start_mark, end_mark) {
      this.start_mark = start_mark;
      this.end_mark = end_mark;
    }

    return Token;

  })();

  this.DirectiveToken = (function(_super) {
    __extends(DirectiveToken, _super);

    DirectiveToken.prototype.id = '<directive>';

    function DirectiveToken(name, value, start_mark, end_mark) {
      this.name = name;
      this.value = value;
      this.start_mark = start_mark;
      this.end_mark = end_mark;
    }

    return DirectiveToken;

  })(this.Token);

  this.DocumentStartToken = (function(_super) {
    __extends(DocumentStartToken, _super);

    function DocumentStartToken() {
      _ref = DocumentStartToken.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    DocumentStartToken.prototype.id = '<document start>';

    return DocumentStartToken;

  })(this.Token);

  this.DocumentEndToken = (function(_super) {
    __extends(DocumentEndToken, _super);

    function DocumentEndToken() {
      _ref1 = DocumentEndToken.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    DocumentEndToken.prototype.id = '<document end>';

    return DocumentEndToken;

  })(this.Token);

  this.StreamStartToken = (function(_super) {
    __extends(StreamStartToken, _super);

    StreamStartToken.prototype.id = '<stream start>';

    function StreamStartToken(start_mark, end_mark, encoding) {
      this.start_mark = start_mark;
      this.end_mark = end_mark;
      this.encoding = encoding;
    }

    return StreamStartToken;

  })(this.Token);

  this.StreamEndToken = (function(_super) {
    __extends(StreamEndToken, _super);

    function StreamEndToken() {
      _ref2 = StreamEndToken.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    StreamEndToken.prototype.id = '<stream end>';

    return StreamEndToken;

  })(this.Token);

  this.BlockSequenceStartToken = (function(_super) {
    __extends(BlockSequenceStartToken, _super);

    function BlockSequenceStartToken() {
      _ref3 = BlockSequenceStartToken.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    BlockSequenceStartToken.prototype.id = '<block sequence start>';

    return BlockSequenceStartToken;

  })(this.Token);

  this.BlockMappingStartToken = (function(_super) {
    __extends(BlockMappingStartToken, _super);

    function BlockMappingStartToken() {
      _ref4 = BlockMappingStartToken.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    BlockMappingStartToken.prototype.id = '<block mapping end>';

    return BlockMappingStartToken;

  })(this.Token);

  this.BlockEndToken = (function(_super) {
    __extends(BlockEndToken, _super);

    function BlockEndToken() {
      _ref5 = BlockEndToken.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    BlockEndToken.prototype.id = '<block end>';

    return BlockEndToken;

  })(this.Token);

  this.FlowSequenceStartToken = (function(_super) {
    __extends(FlowSequenceStartToken, _super);

    function FlowSequenceStartToken() {
      _ref6 = FlowSequenceStartToken.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    FlowSequenceStartToken.prototype.id = '[';

    return FlowSequenceStartToken;

  })(this.Token);

  this.FlowMappingStartToken = (function(_super) {
    __extends(FlowMappingStartToken, _super);

    function FlowMappingStartToken() {
      _ref7 = FlowMappingStartToken.__super__.constructor.apply(this, arguments);
      return _ref7;
    }

    FlowMappingStartToken.prototype.id = '{';

    return FlowMappingStartToken;

  })(this.Token);

  this.FlowSequenceEndToken = (function(_super) {
    __extends(FlowSequenceEndToken, _super);

    function FlowSequenceEndToken() {
      _ref8 = FlowSequenceEndToken.__super__.constructor.apply(this, arguments);
      return _ref8;
    }

    FlowSequenceEndToken.prototype.id = ']';

    return FlowSequenceEndToken;

  })(this.Token);

  this.FlowMappingEndToken = (function(_super) {
    __extends(FlowMappingEndToken, _super);

    function FlowMappingEndToken() {
      _ref9 = FlowMappingEndToken.__super__.constructor.apply(this, arguments);
      return _ref9;
    }

    FlowMappingEndToken.prototype.id = '}';

    return FlowMappingEndToken;

  })(this.Token);

  this.KeyToken = (function(_super) {
    __extends(KeyToken, _super);

    function KeyToken() {
      _ref10 = KeyToken.__super__.constructor.apply(this, arguments);
      return _ref10;
    }

    KeyToken.prototype.id = '?';

    return KeyToken;

  })(this.Token);

  this.ValueToken = (function(_super) {
    __extends(ValueToken, _super);

    function ValueToken() {
      _ref11 = ValueToken.__super__.constructor.apply(this, arguments);
      return _ref11;
    }

    ValueToken.prototype.id = ':';

    return ValueToken;

  })(this.Token);

  this.BlockEntryToken = (function(_super) {
    __extends(BlockEntryToken, _super);

    function BlockEntryToken() {
      _ref12 = BlockEntryToken.__super__.constructor.apply(this, arguments);
      return _ref12;
    }

    BlockEntryToken.prototype.id = '-';

    return BlockEntryToken;

  })(this.Token);

  this.FlowEntryToken = (function(_super) {
    __extends(FlowEntryToken, _super);

    function FlowEntryToken() {
      _ref13 = FlowEntryToken.__super__.constructor.apply(this, arguments);
      return _ref13;
    }

    FlowEntryToken.prototype.id = ',';

    return FlowEntryToken;

  })(this.Token);

  this.AliasToken = (function(_super) {
    __extends(AliasToken, _super);

    AliasToken.prototype.id = '<alias>';

    function AliasToken(value, start_mark, end_mark) {
      this.value = value;
      this.start_mark = start_mark;
      this.end_mark = end_mark;
    }

    return AliasToken;

  })(this.Token);

  this.AnchorToken = (function(_super) {
    __extends(AnchorToken, _super);

    AnchorToken.prototype.id = '<anchor>';

    function AnchorToken(value, start_mark, end_mark) {
      this.value = value;
      this.start_mark = start_mark;
      this.end_mark = end_mark;
    }

    return AnchorToken;

  })(this.Token);

  this.TagToken = (function(_super) {
    __extends(TagToken, _super);

    TagToken.prototype.id = '<tag>';

    function TagToken(value, start_mark, end_mark) {
      this.value = value;
      this.start_mark = start_mark;
      this.end_mark = end_mark;
    }

    return TagToken;

  })(this.Token);

  this.ScalarToken = (function(_super) {
    __extends(ScalarToken, _super);

    ScalarToken.prototype.id = '<scalar>';

    function ScalarToken(value, plain, start_mark, end_mark, style) {
      this.value = value;
      this.plain = plain;
      this.start_mark = start_mark;
      this.end_mark = end_mark;
      this.style = style;
    }

    return ScalarToken;

  })(this.Token);

}).call(this);
