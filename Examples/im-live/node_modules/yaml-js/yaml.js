(function() {
    var root = this, modules, require_from, register, error;
    if (typeof global == "undefined") {
        var global;
        if (typeof window != "undefined") {
            global = window;
        } else {
            global = {};
        }
    }
    modules = {};
    require_from = function(parent, from) {
        return function(name) {
            if (modules[from] && modules[from][name]) {
                modules[from][name].parent = parent;
                if (modules[from][name].initialize) {
                    modules[from][name].initialize();
                }
                return modules[from][name].exports;
            } else {
                return error(name, from);
            }
        };
    };
    register = function(names, directory, callback) {
        var module = {
            exports: {},
            initialize: function() {
                callback.call(module.exports, global, module, module.exports, require_from(module, directory), undefined);
                delete module.initialize;
            },
            parent: null
        };
        for (var from in names) {
            modules[from] = modules[from] || {};
            for (var j in names[from]) {
                var name = names[from][j];
                modules[from][name] = module;
            }
        }
    };
    error = function anonymous(name, from) {
        var message = "Warn: could not find module " + name;
        console.log(message);
    };
    register({
        "0": [ "./events" ]
    }, 0, function(global, module, exports, require, window) {
        (function() {
            var _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, __hasProp = {}.hasOwnProperty, __extends = function(child, parent) {
                for (var key in parent) {
                    if (__hasProp.call(parent, key)) child[key] = parent[key];
                }
                function ctor() {
                    this.constructor = child;
                }
                ctor.prototype = parent.prototype;
                child.prototype = new ctor;
                child.__super__ = parent.prototype;
                return child;
            };
            this.Event = function() {
                function Event(start_mark, end_mark) {
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                }
                return Event;
            }();
            this.NodeEvent = function(_super) {
                __extends(NodeEvent, _super);
                function NodeEvent(anchor, start_mark, end_mark) {
                    this.anchor = anchor;
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                }
                return NodeEvent;
            }(this.Event);
            this.CollectionStartEvent = function(_super) {
                __extends(CollectionStartEvent, _super);
                function CollectionStartEvent(anchor, tag, implicit, start_mark, end_mark) {
                    this.anchor = anchor;
                    this.tag = tag;
                    this.implicit = implicit;
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                }
                return CollectionStartEvent;
            }(this.NodeEvent);
            this.CollectionEndEvent = function(_super) {
                __extends(CollectionEndEvent, _super);
                function CollectionEndEvent() {
                    _ref = CollectionEndEvent.__super__.constructor.apply(this, arguments);
                    return _ref;
                }
                return CollectionEndEvent;
            }(this.Event);
            this.StreamStartEvent = function(_super) {
                __extends(StreamStartEvent, _super);
                function StreamStartEvent(start_mark, end_mark, explicit, version, tags) {
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                    this.explicit = explicit;
                    this.version = version;
                    this.tags = tags;
                }
                return StreamStartEvent;
            }(this.Event);
            this.StreamEndEvent = function(_super) {
                __extends(StreamEndEvent, _super);
                function StreamEndEvent() {
                    _ref1 = StreamEndEvent.__super__.constructor.apply(this, arguments);
                    return _ref1;
                }
                return StreamEndEvent;
            }(this.Event);
            this.DocumentStartEvent = function(_super) {
                __extends(DocumentStartEvent, _super);
                function DocumentStartEvent(start_mark, end_mark, explicit, version, tags) {
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                    this.explicit = explicit;
                    this.version = version;
                    this.tags = tags;
                }
                return DocumentStartEvent;
            }(this.Event);
            this.DocumentEndEvent = function(_super) {
                __extends(DocumentEndEvent, _super);
                function DocumentEndEvent(start_mark, end_mark, explicit) {
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                    this.explicit = explicit;
                }
                return DocumentEndEvent;
            }(this.Event);
            this.AliasEvent = function(_super) {
                __extends(AliasEvent, _super);
                function AliasEvent() {
                    _ref2 = AliasEvent.__super__.constructor.apply(this, arguments);
                    return _ref2;
                }
                return AliasEvent;
            }(this.NodeEvent);
            this.ScalarEvent = function(_super) {
                __extends(ScalarEvent, _super);
                function ScalarEvent(anchor, tag, implicit, value, start_mark, end_mark, style) {
                    this.anchor = anchor;
                    this.tag = tag;
                    this.implicit = implicit;
                    this.value = value;
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                    this.style = style;
                }
                return ScalarEvent;
            }(this.NodeEvent);
            this.SequenceStartEvent = function(_super) {
                __extends(SequenceStartEvent, _super);
                function SequenceStartEvent() {
                    _ref3 = SequenceStartEvent.__super__.constructor.apply(this, arguments);
                    return _ref3;
                }
                return SequenceStartEvent;
            }(this.CollectionStartEvent);
            this.SequenceEndEvent = function(_super) {
                __extends(SequenceEndEvent, _super);
                function SequenceEndEvent() {
                    _ref4 = SequenceEndEvent.__super__.constructor.apply(this, arguments);
                    return _ref4;
                }
                return SequenceEndEvent;
            }(this.CollectionEndEvent);
            this.MappingStartEvent = function(_super) {
                __extends(MappingStartEvent, _super);
                function MappingStartEvent() {
                    _ref5 = MappingStartEvent.__super__.constructor.apply(this, arguments);
                    return _ref5;
                }
                return MappingStartEvent;
            }(this.CollectionStartEvent);
            this.MappingEndEvent = function(_super) {
                __extends(MappingEndEvent, _super);
                function MappingEndEvent() {
                    _ref6 = MappingEndEvent.__super__.constructor.apply(this, arguments);
                    return _ref6;
                }
                return MappingEndEvent;
            }(this.CollectionEndEvent);
        }).call(this);
    });
    register({
        "0": [ "./errors" ]
    }, 0, function(global, module, exports, require, window) {
        (function() {
            var __indexOf = [].indexOf || function(item) {
                for (var i = 0, l = this.length; i < l; i++) {
                    if (i in this && this[i] === item) return i;
                }
                return -1;
            }, __hasProp = {}.hasOwnProperty, __extends = function(child, parent) {
                for (var key in parent) {
                    if (__hasProp.call(parent, key)) child[key] = parent[key];
                }
                function ctor() {
                    this.constructor = child;
                }
                ctor.prototype = parent.prototype;
                child.prototype = new ctor;
                child.__super__ = parent.prototype;
                return child;
            };
            this.Mark = function() {
                function Mark(name, line, column, buffer, pointer) {
                    this.name = name;
                    this.line = line;
                    this.column = column;
                    this.buffer = buffer;
                    this.pointer = pointer;
                }
                Mark.prototype.get_snippet = function(indent, max_length) {
                    var break_chars, end, head, start, tail, _ref, _ref1;
                    if (indent == null) {
                        indent = 4;
                    }
                    if (max_length == null) {
                        max_length = 75;
                    }
                    if (this.buffer == null) {
                        return null;
                    }
                    break_chars = "\0\r\n\u2028\u2029";
                    head = "";
                    start = this.pointer;
                    while (start > 0 && (_ref = this.buffer[start - 1], __indexOf.call(break_chars, _ref) < 0)) {
                        start--;
                        if (this.pointer - start > max_length / 2 - 1) {
                            head = " ... ";
                            start += 5;
                            break;
                        }
                    }
                    tail = "";
                    end = this.pointer;
                    while (end < this.buffer.length && (_ref1 = this.buffer[end], __indexOf.call(break_chars, _ref1) < 0)) {
                        end++;
                        if (end - this.pointer > max_length / 2 - 1) {
                            tail = " ... ";
                            end -= 5;
                            break;
                        }
                    }
                    return "" + (new Array(indent)).join(" ") + head + this.buffer.slice(start, end) + tail + "\n" + (new Array(indent + this.pointer - start + head.length)).join(" ") + "^";
                };
                Mark.prototype.toString = function() {
                    var snippet, where;
                    snippet = this.get_snippet();
                    where = '  in "' + this.name + '", line ' + (this.line + 1) + ", column " + (this.column + 1);
                    if (snippet) {
                        return where;
                    } else {
                        return "" + where + ":\n" + snippet;
                    }
                };
                return Mark;
            }();
            this.YAMLError = function(_super) {
                __extends(YAMLError, _super);
                function YAMLError() {
                    YAMLError.__super__.constructor.call(this);
                    this.stack = this.toString() + "\n" + (new Error).stack.split("\n").slice(1).join("\n");
                }
                return YAMLError;
            }(Error);
            this.MarkedYAMLError = function(_super) {
                __extends(MarkedYAMLError, _super);
                function MarkedYAMLError(context, context_mark, problem, problem_mark, note) {
                    this.context = context;
                    this.context_mark = context_mark;
                    this.problem = problem;
                    this.problem_mark = problem_mark;
                    this.note = note;
                    MarkedYAMLError.__super__.constructor.call(this);
                }
                MarkedYAMLError.prototype.toString = function() {
                    var lines;
                    lines = [];
                    if (this.context != null) {
                        lines.push(this.context);
                    }
                    if (this.context_mark != null && (this.problem == null || this.problem_mark == null || this.context_mark.name !== this.problem_mark.name || this.context_mark.line !== this.problem_mark.line || this.context_mark.column !== this.problem_mark.column)) {
                        lines.push(this.context_mark.toString());
                    }
                    if (this.problem != null) {
                        lines.push(this.problem);
                    }
                    if (this.problem_mark != null) {
                        lines.push(this.problem_mark.toString());
                    }
                    if (this.note != null) {
                        lines.push(this.note);
                    }
                    return lines.join("\n");
                };
                return MarkedYAMLError;
            }(this.YAMLError);
        }).call(this);
    });
    register({
        "0": [ "./nodes" ]
    }, 0, function(global, module, exports, require, window) {
        (function() {
            var unique_id, _ref, _ref1, __hasProp = {}.hasOwnProperty, __extends = function(child, parent) {
                for (var key in parent) {
                    if (__hasProp.call(parent, key)) child[key] = parent[key];
                }
                function ctor() {
                    this.constructor = child;
                }
                ctor.prototype = parent.prototype;
                child.prototype = new ctor;
                child.__super__ = parent.prototype;
                return child;
            };
            unique_id = 0;
            this.Node = function() {
                function Node(tag, value, start_mark, end_mark) {
                    this.tag = tag;
                    this.value = value;
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                    this.unique_id = "node_" + unique_id++;
                }
                return Node;
            }();
            this.ScalarNode = function(_super) {
                __extends(ScalarNode, _super);
                ScalarNode.prototype.id = "scalar";
                function ScalarNode(tag, value, start_mark, end_mark, style) {
                    this.tag = tag;
                    this.value = value;
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                    this.style = style;
                    ScalarNode.__super__.constructor.apply(this, arguments);
                }
                return ScalarNode;
            }(this.Node);
            this.CollectionNode = function(_super) {
                __extends(CollectionNode, _super);
                function CollectionNode(tag, value, start_mark, end_mark, flow_style) {
                    this.tag = tag;
                    this.value = value;
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                    this.flow_style = flow_style;
                    CollectionNode.__super__.constructor.apply(this, arguments);
                }
                return CollectionNode;
            }(this.Node);
            this.SequenceNode = function(_super) {
                __extends(SequenceNode, _super);
                function SequenceNode() {
                    _ref = SequenceNode.__super__.constructor.apply(this, arguments);
                    return _ref;
                }
                SequenceNode.prototype.id = "sequence";
                return SequenceNode;
            }(this.CollectionNode);
            this.MappingNode = function(_super) {
                __extends(MappingNode, _super);
                function MappingNode() {
                    _ref1 = MappingNode.__super__.constructor.apply(this, arguments);
                    return _ref1;
                }
                MappingNode.prototype.id = "mapping";
                return MappingNode;
            }(this.CollectionNode);
        }).call(this);
    });
    register({
        "0": [ "./composer" ]
    }, 0, function(global, module, exports, require, window) {
        (function() {
            var MarkedYAMLError, events, nodes, _ref, __hasProp = {}.hasOwnProperty, __extends = function(child, parent) {
                for (var key in parent) {
                    if (__hasProp.call(parent, key)) child[key] = parent[key];
                }
                function ctor() {
                    this.constructor = child;
                }
                ctor.prototype = parent.prototype;
                child.prototype = new ctor;
                child.__super__ = parent.prototype;
                return child;
            };
            events = require("./events");
            MarkedYAMLError = require("./errors").MarkedYAMLError;
            nodes = require("./nodes");
            this.ComposerError = function(_super) {
                __extends(ComposerError, _super);
                function ComposerError() {
                    _ref = ComposerError.__super__.constructor.apply(this, arguments);
                    return _ref;
                }
                return ComposerError;
            }(MarkedYAMLError);
            this.Composer = function() {
                function Composer() {
                    this.anchors = {};
                }
                Composer.prototype.check_node = function() {
                    if (this.check_event(events.StreamStartEvent)) {
                        this.get_event();
                    }
                    return !this.check_event(events.StreamEndEvent);
                };
                Composer.prototype.get_node = function() {
                    if (!this.check_event(events.StreamEndEvent)) {
                        return this.compose_document();
                    }
                };
                Composer.prototype.get_single_node = function() {
                    var document, event;
                    this.get_event();
                    document = null;
                    if (!this.check_event(events.StreamEndEvent)) {
                        document = this.compose_document();
                    }
                    if (!this.check_event(events.StreamEndEvent)) {
                        event = this.get_event();
                        throw new exports.ComposerError("expected a single document in the stream", document.start_mark, "but found another document", event.start_mark);
                    }
                    this.get_event();
                    return document;
                };
                Composer.prototype.compose_document = function() {
                    var node;
                    this.get_event();
                    node = this.compose_node();
                    this.get_event();
                    this.anchors = {};
                    return node;
                };
                Composer.prototype.compose_node = function(parent, index) {
                    var anchor, event, node;
                    if (this.check_event(events.AliasEvent)) {
                        event = this.get_event();
                        anchor = event.anchor;
                        if (!(anchor in this.anchors)) {
                            throw new exports.ComposerError(null, null, "found undefined alias " + anchor, event.start_mark);
                        }
                        return this.anchors[anchor];
                    }
                    event = this.peek_event();
                    anchor = event.anchor;
                    if (anchor !== null && anchor in this.anchors) {
                        throw new exports.ComposerError("found duplicate anchor " + anchor + "; first occurence", this.anchors[anchor].start_mark, "second occurrence", event.start_mark);
                    }
                    this.descend_resolver(parent, index);
                    if (this.check_event(events.ScalarEvent)) {
                        node = this.compose_scalar_node(anchor);
                    } else if (this.check_event(events.SequenceStartEvent)) {
                        node = this.compose_sequence_node(anchor);
                    } else if (this.check_event(events.MappingStartEvent)) {
                        node = this.compose_mapping_node(anchor);
                    }
                    this.ascend_resolver();
                    return node;
                };
                Composer.prototype.compose_scalar_node = function(anchor) {
                    var event, node, tag;
                    event = this.get_event();
                    tag = event.tag;
                    if (tag === null || tag === "!") {
                        tag = this.resolve(nodes.ScalarNode, event.value, event.implicit);
                    }
                    node = new nodes.ScalarNode(tag, event.value, event.start_mark, event.end_mark, event.style);
                    if (anchor !== null) {
                        this.anchors[anchor] = node;
                    }
                    return node;
                };
                Composer.prototype.compose_sequence_node = function(anchor) {
                    var end_event, index, node, start_event, tag;
                    start_event = this.get_event();
                    tag = start_event.tag;
                    if (tag === null || tag === "!") {
                        tag = this.resolve(nodes.SequenceNode, null, start_event.implicit);
                    }
                    node = new nodes.SequenceNode(tag, [], start_event.start_mark, null, start_event.flow_style);
                    if (anchor !== null) {
                        this.anchors[anchor] = node;
                    }
                    index = 0;
                    while (!this.check_event(events.SequenceEndEvent)) {
                        node.value.push(this.compose_node(node, index));
                        index++;
                    }
                    end_event = this.get_event();
                    node.end_mark = end_event.end_mark;
                    return node;
                };
                Composer.prototype.compose_mapping_node = function(anchor) {
                    var end_event, item_key, item_value, node, start_event, tag;
                    start_event = this.get_event();
                    tag = start_event.tag;
                    if (tag === null || tag === "!") {
                        tag = this.resolve(nodes.MappingNode, null, start_event.implicit);
                    }
                    node = new nodes.MappingNode(tag, [], start_event.start_mark, null, start_event.flow_style);
                    if (anchor !== null) {
                        this.anchors[anchor] = node;
                    }
                    while (!this.check_event(events.MappingEndEvent)) {
                        item_key = this.compose_node(node);
                        item_value = this.compose_node(node, item_key);
                        node.value.push([ item_key, item_value ]);
                    }
                    end_event = this.get_event();
                    node.end_mark = end_event.end_mark;
                    return node;
                };
                return Composer;
            }();
        }).call(this);
    });
    register({
        "0": [ "./util" ]
    }, 0, function(global, module, exports, require, window) {
        (function() {
            var __slice = [].slice, __hasProp = {}.hasOwnProperty;
            this.extend = function() {
                var destination, k, source, sources, v, _i, _len;
                destination = arguments[0], sources = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
                for (_i = 0, _len = sources.length; _i < _len; _i++) {
                    source = sources[_i];
                    for (k in source) {
                        v = source[k];
                        destination[k] = v;
                    }
                }
                return destination;
            };
            this.is_empty = function(obj) {
                var key;
                if (Array.isArray(obj) || typeof obj === "string") {
                    return obj.length === 0;
                }
                for (key in obj) {
                    if (!__hasProp.call(obj, key)) continue;
                    return false;
                }
                return true;
            };
        }).call(this);
    });
    register({
        "0": [ "./constructor" ]
    }, 0, function(global, module, exports, require, window) {
        (function() {
            var MarkedYAMLError, nodes, util, _ref, _ref1, __hasProp = {}.hasOwnProperty, __extends = function(child, parent) {
                for (var key in parent) {
                    if (__hasProp.call(parent, key)) child[key] = parent[key];
                }
                function ctor() {
                    this.constructor = child;
                }
                ctor.prototype = parent.prototype;
                child.prototype = new ctor;
                child.__super__ = parent.prototype;
                return child;
            }, __indexOf = [].indexOf || function(item) {
                for (var i = 0, l = this.length; i < l; i++) {
                    if (i in this && this[i] === item) return i;
                }
                return -1;
            };
            MarkedYAMLError = require("./errors").MarkedYAMLError;
            nodes = require("./nodes");
            util = require("./util");
            this.ConstructorError = function(_super) {
                __extends(ConstructorError, _super);
                function ConstructorError() {
                    _ref = ConstructorError.__super__.constructor.apply(this, arguments);
                    return _ref;
                }
                return ConstructorError;
            }(MarkedYAMLError);
            this.BaseConstructor = function() {
                BaseConstructor.prototype.yaml_constructors = {};
                BaseConstructor.prototype.yaml_multi_constructors = {};
                BaseConstructor.add_constructor = function(tag, constructor) {
                    if (!this.prototype.hasOwnProperty("yaml_constructors")) {
                        this.prototype.yaml_constructors = util.extend({}, this.prototype.yaml_constructors);
                    }
                    return this.prototype.yaml_constructors[tag] = constructor;
                };
                BaseConstructor.add_multi_constructor = function(tag_prefix, multi_constructor) {
                    if (!this.prototype.hasOwnProperty("yaml_multi_constructors")) {
                        this.prototype.yaml_multi_constructors = util.extend({}, this.prototype.yaml_multi_constructors);
                    }
                    return this.prototype.yaml_multi_constructors[tag_prefix] = multi_constructor;
                };
                function BaseConstructor() {
                    this.constructed_objects = {};
                    this.constructing_nodes = [];
                    this.deferred_constructors = [];
                }
                BaseConstructor.prototype.check_data = function() {
                    return this.check_node();
                };
                BaseConstructor.prototype.get_data = function() {
                    if (this.check_node()) {
                        return this.construct_document(this.get_node());
                    }
                };
                BaseConstructor.prototype.get_single_data = function() {
                    var node;
                    node = this.get_single_node();
                    if (node != null) {
                        return this.construct_document(node);
                    }
                    return null;
                };
                BaseConstructor.prototype.construct_document = function(node) {
                    var data;
                    data = this.construct_object(node);
                    while (!util.is_empty(this.deferred_constructors)) {
                        this.deferred_constructors.pop()();
                    }
                    return data;
                };
                BaseConstructor.prototype.defer = function(f) {
                    return this.deferred_constructors.push(f);
                };
                BaseConstructor.prototype.construct_object = function(node) {
                    var constructor, object, tag_prefix, tag_suffix, _ref1;
                    if (node.unique_id in this.constructed_objects) {
                        return this.constructed_objects[node.unique_id];
                    }
                    if (_ref1 = node.unique_id, __indexOf.call(this.constructing_nodes, _ref1) >= 0) {
                        throw new exports.ConstructorError(null, null, "found unconstructable recursive node", node.start_mark);
                    }
                    this.constructing_nodes.push(node.unique_id);
                    constructor = null;
                    tag_suffix = null;
                    if (node.tag in this.yaml_constructors) {
                        constructor = this.yaml_constructors[node.tag];
                    } else {
                        for (tag_prefix in this.yaml_multi_constructors) {
                            if (node.tag.indexOf(tag_prefix === 0)) {
                                tag_suffix = node.tag.slice(tag_prefix.length);
                                constructor = this.yaml_multi_constructors[tag_prefix];
                                break;
                            }
                        }
                        if (constructor == null) {
                            if (null in this.yaml_multi_constructors) {
                                tag_suffix = node.tag;
                                constructor = this.yaml_multi_constructors[null];
                            } else if (null in this.yaml_constructors) {
                                constructor = this.yaml_constructors[null];
                            } else if (node instanceof nodes.ScalarNode) {
                                constructor = this.construct_scalar;
                            } else if (node instanceof nodes.SequenceNode) {
                                constructor = this.construct_sequence;
                            } else if (node instanceof nodes.MappingNode) {
                                constructor = this.construct_mapping;
                            }
                        }
                    }
                    object = constructor.call(this, tag_suffix != null ? tag_suffix : node, node);
                    this.constructed_objects[node.unique_id] = object;
                    this.constructing_nodes.pop();
                    return object;
                };
                BaseConstructor.prototype.construct_scalar = function(node) {
                    if (!(node instanceof nodes.ScalarNode)) {
                        throw new exports.ConstructorError(null, null, "expected a scalar node but found " + node.id, node.start_mark);
                    }
                    return node.value;
                };
                BaseConstructor.prototype.construct_sequence = function(node) {
                    var child, _i, _len, _ref1, _results;
                    if (!(node instanceof nodes.SequenceNode)) {
                        throw new exports.ConstructorError(null, null, "expected a sequence node but found " + node.id, node.start_mark);
                    }
                    _ref1 = node.value;
                    _results = [];
                    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                        child = _ref1[_i];
                        _results.push(this.construct_object(child));
                    }
                    return _results;
                };
                BaseConstructor.prototype.construct_mapping = function(node) {
                    var key, key_node, mapping, value, value_node, _i, _len, _ref1, _ref2;
                    if (!(node instanceof nodes.MappingNode)) {
                        throw new ConstructorError(null, null, "expected a mapping node but found " + node.id, node.start_mark);
                    }
                    mapping = {};
                    _ref1 = node.value;
                    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                        _ref2 = _ref1[_i], key_node = _ref2[0], value_node = _ref2[1];
                        key = this.construct_object(key_node);
                        if (typeof key === "object") {
                            throw new exports.ConstructorError("while constructing a mapping", node.start_mark, "found unhashable key", key_node.start_mark);
                        }
                        value = this.construct_object(value_node);
                        mapping[key] = value;
                    }
                    return mapping;
                };
                BaseConstructor.prototype.construct_pairs = function(node) {
                    var key, key_node, pairs, value, value_node, _i, _len, _ref1, _ref2;
                    if (!(node instanceof nodes.MappingNode)) {
                        throw new exports.ConstructorError(null, null, "expected a mapping node but found " + node.id, node.start_mark);
                    }
                    pairs = [];
                    _ref1 = node.value;
                    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                        _ref2 = _ref1[_i], key_node = _ref2[0], value_node = _ref2[1];
                        key = this.construct_object(key_node);
                        value = this.construct_object(value_node);
                        pairs.push([ key, value ]);
                    }
                    return pairs;
                };
                return BaseConstructor;
            }();
            this.Constructor = function(_super) {
                var BOOL_VALUES, TIMESTAMP_PARTS, TIMESTAMP_REGEX;
                __extends(Constructor, _super);
                function Constructor() {
                    _ref1 = Constructor.__super__.constructor.apply(this, arguments);
                    return _ref1;
                }
                BOOL_VALUES = {
                    on: true,
                    off: false,
                    "true": true,
                    "false": false,
                    yes: true,
                    no: false
                };
                TIMESTAMP_REGEX = /^([0-9][0-9][0-9][0-9])-([0-9][0-9]?)-([0-9][0-9]?)(?:(?:[Tt]|[\x20\t]+)([0-9][0-9]?):([0-9][0-9]):([0-9][0-9])(?:\.([0-9]*))?(?:[\x20\t]*(Z|([-+])([0-9][0-9]?)(?::([0-9][0-9]))?))?)?$/;
                TIMESTAMP_PARTS = {
                    year: 1,
                    month: 2,
                    day: 3,
                    hour: 4,
                    minute: 5,
                    second: 6,
                    fraction: 7,
                    tz: 8,
                    tz_sign: 9,
                    tz_hour: 10,
                    tz_minute: 11
                };
                Constructor.prototype.yaml_constructors = {};
                Constructor.prototype.yaml_multi_constructors = {};
                Constructor.prototype.construct_scalar = function(node) {
                    var key_node, value_node, _i, _len, _ref2, _ref3;
                    if (node instanceof nodes.MappingNode) {
                        _ref2 = node.value;
                        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
                            _ref3 = _ref2[_i], key_node = _ref3[0], value_node = _ref3[1];
                            if (key_node.tag === "tag:yaml.org,2002:value") {
                                return this.construct_scalar(value_node);
                            }
                        }
                    }
                    return Constructor.__super__.construct_scalar.call(this, node);
                };
                Constructor.prototype.flatten_mapping = function(node) {
                    var index, key_node, merge, submerge, subnode, value, value_node, _i, _j, _len, _len1, _ref2, _ref3;
                    merge = [];
                    index = 0;
                    while (index < node.value.length) {
                        _ref2 = node.value[index], key_node = _ref2[0], value_node = _ref2[1];
                        if (key_node.tag === "tag:yaml.org,2002:merge") {
                            node.value.splice(index, 1);
                            if (value_node instanceof nodes.MappingNode) {
                                this.flatten_mapping(value_node);
                                merge = merge.concat(value_node.value);
                            } else if (value_node instanceof nodes.SequenceNode) {
                                submerge = [];
                                _ref3 = value_node.value;
                                for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
                                    subnode = _ref3[_i];
                                    if (!(subnode instanceof nodes.MappingNode)) {
                                        throw new exports.ConstructorError("while constructing a mapping", node.start_mark, "expected a mapping for merging, but found " + subnode.id, subnode.start_mark);
                                    }
                                    this.flatten_mapping(subnode);
                                    submerge.push(subnode.value);
                                }
                                submerge.reverse();
                                for (_j = 0, _len1 = submerge.length; _j < _len1; _j++) {
                                    value = submerge[_j];
                                    merge = merge.concat(value);
                                }
                            } else {
                                throw new exports.ConstructorError("while constructing a mapping", node.start_mark, "expected a mapping or list of mappings for            merging but found " + value_node.id, value_node.start_mark);
                            }
                        } else if (key_node.tag === "tag:yaml.org,2002:value") {
                            key_node.tag = "tag:yaml.org,2002:str";
                            index++;
                        } else {
                            index++;
                        }
                    }
                    if (merge.length) {
                        return node.value = merge.concat(node.value);
                    }
                };
                Constructor.prototype.construct_mapping = function(node) {
                    if (node instanceof nodes.MappingNode) {
                        this.flatten_mapping(node);
                    }
                    return Constructor.__super__.construct_mapping.call(this, node);
                };
                Constructor.prototype.construct_yaml_null = function(node) {
                    this.construct_scalar(node);
                    return null;
                };
                Constructor.prototype.construct_yaml_bool = function(node) {
                    var value;
                    value = this.construct_scalar(node);
                    return BOOL_VALUES[value.toLowerCase()];
                };
                Constructor.prototype.construct_yaml_int = function(node) {
                    var base, digit, digits, part, sign, value, _i, _len, _ref2;
                    value = this.construct_scalar(node);
                    value = value.replace(/_/g, "");
                    sign = value[0] === "-" ? -1 : 1;
                    if (_ref2 = value[0], __indexOf.call("+-", _ref2) >= 0) {
                        value = value.slice(1);
                    }
                    if (value === "0") {
                        return 0;
                    } else if (value.indexOf("0b") === 0) {
                        return sign * parseInt(value.slice(2), 2);
                    } else if (value.indexOf("0x") === 0) {
                        return sign * parseInt(value.slice(2), 16);
                    } else if (value.indexOf("0o") === 0) {
                        return sign * parseInt(value.slice(2), 8);
                    } else if (value[0] === "0") {
                        return sign * parseInt(value, 8);
                    } else if (__indexOf.call(value, ":") >= 0) {
                        digits = function() {
                            var _i, _len, _ref3, _results;
                            _ref3 = value.split(/:/g);
                            _results = [];
                            for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
                                part = _ref3[_i];
                                _results.push(parseInt(part));
                            }
                            return _results;
                        }();
                        digits.reverse();
                        base = 1;
                        value = 0;
                        for (_i = 0, _len = digits.length; _i < _len; _i++) {
                            digit = digits[_i];
                            value += digit * base;
                            base *= 60;
                        }
                        return sign * value;
                    } else {
                        return sign * parseInt(value);
                    }
                };
                Constructor.prototype.construct_yaml_float = function(node) {
                    var base, digit, digits, part, sign, value, _i, _len, _ref2;
                    value = this.construct_scalar(node);
                    value = value.replace(/_/g, "").toLowerCase();
                    sign = value[0] === "-" ? -1 : 1;
                    if (_ref2 = value[0], __indexOf.call("+-", _ref2) >= 0) {
                        value = value.slice(1);
                    }
                    if (value === ".inf") {
                        return sign * Infinity;
                    } else if (value === ".nan") {
                        return NaN;
                    } else if (__indexOf.call(value, ":") >= 0) {
                        digits = function() {
                            var _i, _len, _ref3, _results;
                            _ref3 = value.split(/:/g);
                            _results = [];
                            for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
                                part = _ref3[_i];
                                _results.push(parseFloat(part));
                            }
                            return _results;
                        }();
                        digits.reverse();
                        base = 1;
                        value = 0;
                        for (_i = 0, _len = digits.length; _i < _len; _i++) {
                            digit = digits[_i];
                            value += digit * base;
                            base *= 60;
                        }
                        return sign * value;
                    } else {
                        return sign * parseFloat(value);
                    }
                };
                Constructor.prototype.construct_yaml_binary = function(node) {
                    var error, value;
                    value = this.construct_scalar(node);
                    try {
                        if (typeof window !== "undefined" && window !== null) {
                            return atob(value);
                        }
                        return (new Buffer(value, "base64")).toString("ascii");
                    } catch (_error) {
                        error = _error;
                        throw new exports.ConstructorError(null, null, "failed to decode base64 data: " + error, node.start_mark);
                    }
                };
                Constructor.prototype.construct_yaml_timestamp = function(node) {
                    var date, day, fraction, hour, index, key, match, millisecond, minute, month, second, tz_hour, tz_minute, tz_sign, value, values, year;
                    value = this.construct_scalar(node);
                    match = node.value.match(TIMESTAMP_REGEX);
                    values = {};
                    for (key in TIMESTAMP_PARTS) {
                        index = TIMESTAMP_PARTS[key];
                        values[key] = match[index];
                    }
                    year = parseInt(values.year);
                    month = parseInt(values.month) - 1;
                    day = parseInt(values.day);
                    if (!values.hour) {
                        return new Date(Date.UTC(year, month, day));
                    }
                    hour = parseInt(values.hour);
                    minute = parseInt(values.minute);
                    second = parseInt(values.second);
                    millisecond = 0;
                    if (values.fraction) {
                        fraction = values.fraction.slice(0, 6);
                        while (fraction.length < 6) {
                            fraction += "0";
                        }
                        fraction = parseInt(fraction);
                        millisecond = Math.round(fraction / 1e3);
                    }
                    if (values.tz_sign) {
                        tz_sign = values.tz_sign === "-" ? 1 : -1;
                        if (tz_hour = parseInt(values.tz_hour)) {
                            hour += tz_sign * tz_hour;
                        }
                        if (tz_minute = parseInt(values.tz_minute)) {
                            minute += tz_sign * tz_minute;
                        }
                    }
                    date = new Date(Date.UTC(year, month, day, hour, minute, second, millisecond));
                    return date;
                };
                Constructor.prototype.construct_yaml_pair_list = function(type, node) {
                    var list, _this = this;
                    list = [];
                    if (!(node instanceof nodes.SequenceNode)) {
                        throw new exports.ConstructorError("while constructing " + type, node.start_mark, "expected a sequence but found " + node.id, node.start_mark);
                    }
                    this.defer(function() {
                        var key, key_node, subnode, value, value_node, _i, _len, _ref2, _ref3, _results;
                        _ref2 = node.value;
                        _results = [];
                        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
                            subnode = _ref2[_i];
                            if (!(subnode instanceof nodes.MappingNode)) {
                                throw new exports.ConstructorError("while constructing " + type, node.start_mark, "expected a mapping of length 1 but found " + subnode.id, subnode.start_mark);
                            }
                            if (subnode.value.length !== 1) {
                                throw new exports.ConstructorError("while constructing " + type, node.start_mark, "expected a mapping of length 1 but found " + subnode.id, subnode.start_mark);
                            }
                            _ref3 = subnode.value[0], key_node = _ref3[0], value_node = _ref3[1];
                            key = _this.construct_object(key_node);
                            value = _this.construct_object(value_node);
                            _results.push(list.push([ key, value ]));
                        }
                        return _results;
                    });
                    return list;
                };
                Constructor.prototype.construct_yaml_omap = function(node) {
                    return this.construct_yaml_pair_list("an ordered map", node);
                };
                Constructor.prototype.construct_yaml_pairs = function(node) {
                    return this.construct_yaml_pair_list("pairs", node);
                };
                Constructor.prototype.construct_yaml_set = function(node) {
                    var data, _this = this;
                    data = [];
                    this.defer(function() {
                        var item, _results;
                        _results = [];
                        for (item in _this.construct_mapping(node)) {
                            _results.push(data.push(item));
                        }
                        return _results;
                    });
                    return data;
                };
                Constructor.prototype.construct_yaml_str = function(node) {
                    return this.construct_scalar(node);
                };
                Constructor.prototype.construct_yaml_seq = function(node) {
                    var data, _this = this;
                    data = [];
                    this.defer(function() {
                        var item, _i, _len, _ref2, _results;
                        _ref2 = _this.construct_sequence(node);
                        _results = [];
                        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
                            item = _ref2[_i];
                            _results.push(data.push(item));
                        }
                        return _results;
                    });
                    return data;
                };
                Constructor.prototype.construct_yaml_map = function(node) {
                    var data, _this = this;
                    data = {};
                    this.defer(function() {
                        var key, value, _ref2, _results;
                        _ref2 = _this.construct_mapping(node);
                        _results = [];
                        for (key in _ref2) {
                            value = _ref2[key];
                            _results.push(data[key] = value);
                        }
                        return _results;
                    });
                    return data;
                };
                Constructor.prototype.construct_yaml_object = function(node, klass) {
                    var data, _this = this;
                    data = new klass;
                    this.defer(function() {
                        var key, value, _ref2, _results;
                        _ref2 = _this.construct_mapping(node, true);
                        _results = [];
                        for (key in _ref2) {
                            value = _ref2[key];
                            _results.push(data[key] = value);
                        }
                        return _results;
                    });
                    return data;
                };
                Constructor.prototype.construct_undefined = function(node) {
                    throw new exports.ConstructorError(null, null, "could not determine a constructor for the tag " + node.tag, node.start_mark);
                };
                return Constructor;
            }(this.BaseConstructor);
            this.Constructor.add_constructor("tag:yaml.org,2002:null", this.Constructor.prototype.construct_yaml_null);
            this.Constructor.add_constructor("tag:yaml.org,2002:bool", this.Constructor.prototype.construct_yaml_bool);
            this.Constructor.add_constructor("tag:yaml.org,2002:int", this.Constructor.prototype.construct_yaml_int);
            this.Constructor.add_constructor("tag:yaml.org,2002:float", this.Constructor.prototype.construct_yaml_float);
            this.Constructor.add_constructor("tag:yaml.org,2002:binary", this.Constructor.prototype.construct_yaml_binary);
            this.Constructor.add_constructor("tag:yaml.org,2002:timestamp", this.Constructor.prototype.construct_yaml_timestamp);
            this.Constructor.add_constructor("tag:yaml.org,2002:omap", this.Constructor.prototype.construct_yaml_omap);
            this.Constructor.add_constructor("tag:yaml.org,2002:pairs", this.Constructor.prototype.construct_yaml_pairs);
            this.Constructor.add_constructor("tag:yaml.org,2002:set", this.Constructor.prototype.construct_yaml_set);
            this.Constructor.add_constructor("tag:yaml.org,2002:str", this.Constructor.prototype.construct_yaml_str);
            this.Constructor.add_constructor("tag:yaml.org,2002:seq", this.Constructor.prototype.construct_yaml_seq);
            this.Constructor.add_constructor("tag:yaml.org,2002:map", this.Constructor.prototype.construct_yaml_map);
            this.Constructor.add_constructor(null, this.Constructor.prototype.construct_undefined);
        }).call(this);
    });
    register({
        "0": [ "./reader" ]
    }, 0, function(global, module, exports, require, window) {
        (function() {
            var Mark, YAMLError, _ref, __hasProp = {}.hasOwnProperty, __extends = function(child, parent) {
                for (var key in parent) {
                    if (__hasProp.call(parent, key)) child[key] = parent[key];
                }
                function ctor() {
                    this.constructor = child;
                }
                ctor.prototype = parent.prototype;
                child.prototype = new ctor;
                child.__super__ = parent.prototype;
                return child;
            }, __indexOf = [].indexOf || function(item) {
                for (var i = 0, l = this.length; i < l; i++) {
                    if (i in this && this[i] === item) return i;
                }
                return -1;
            };
            _ref = require("./errors"), Mark = _ref.Mark, YAMLError = _ref.YAMLError;
            this.ReaderError = function(_super) {
                __extends(ReaderError, _super);
                function ReaderError(name, position, character, reason) {
                    this.name = name;
                    this.position = position;
                    this.character = character;
                    this.reason = reason;
                    ReaderError.__super__.constructor.call(this);
                }
                ReaderError.prototype.toString = function() {
                    return "unacceptable character " + this.character.charCodeAt() + ": " + this.reason + '\n  in "' + this.name + '", position ' + this.position;
                };
                return ReaderError;
            }(YAMLError);
            this.Reader = function() {
                var NON_PRINTABLE;
                NON_PRINTABLE = /[^\x09\x0A\x0D\x20-\x7E\x85\xA0-\uD7FF\uE000-\uFFFD]/;
                function Reader(string) {
                    this.string = string;
                    this.line = 0;
                    this.column = 0;
                    this.index = 0;
                    this.check_printable();
                    this.string += "\0";
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
                        if (__indexOf.call("\n₂\u2029", char) >= 0 || char === "\r" && this.string[this.index] !== "\n") {
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
                        position = this.string.length - this.index + match.index;
                        throw new exports.ReaderError(this.name, position, character.charCodeAt(), "special characters are not allowed");
                    }
                };
                return Reader;
            }();
        }).call(this);
    });
    register({
        "0": [ "./tokens" ]
    }, 0, function(global, module, exports, require, window) {
        (function() {
            var _ref, _ref1, _ref10, _ref11, _ref12, _ref13, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9, __hasProp = {}.hasOwnProperty, __extends = function(child, parent) {
                for (var key in parent) {
                    if (__hasProp.call(parent, key)) child[key] = parent[key];
                }
                function ctor() {
                    this.constructor = child;
                }
                ctor.prototype = parent.prototype;
                child.prototype = new ctor;
                child.__super__ = parent.prototype;
                return child;
            };
            this.Token = function() {
                function Token(start_mark, end_mark) {
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                }
                return Token;
            }();
            this.DirectiveToken = function(_super) {
                __extends(DirectiveToken, _super);
                DirectiveToken.prototype.id = "<directive>";
                function DirectiveToken(name, value, start_mark, end_mark) {
                    this.name = name;
                    this.value = value;
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                }
                return DirectiveToken;
            }(this.Token);
            this.DocumentStartToken = function(_super) {
                __extends(DocumentStartToken, _super);
                function DocumentStartToken() {
                    _ref = DocumentStartToken.__super__.constructor.apply(this, arguments);
                    return _ref;
                }
                DocumentStartToken.prototype.id = "<document start>";
                return DocumentStartToken;
            }(this.Token);
            this.DocumentEndToken = function(_super) {
                __extends(DocumentEndToken, _super);
                function DocumentEndToken() {
                    _ref1 = DocumentEndToken.__super__.constructor.apply(this, arguments);
                    return _ref1;
                }
                DocumentEndToken.prototype.id = "<document end>";
                return DocumentEndToken;
            }(this.Token);
            this.StreamStartToken = function(_super) {
                __extends(StreamStartToken, _super);
                StreamStartToken.prototype.id = "<stream start>";
                function StreamStartToken(start_mark, end_mark, encoding) {
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                    this.encoding = encoding;
                }
                return StreamStartToken;
            }(this.Token);
            this.StreamEndToken = function(_super) {
                __extends(StreamEndToken, _super);
                function StreamEndToken() {
                    _ref2 = StreamEndToken.__super__.constructor.apply(this, arguments);
                    return _ref2;
                }
                StreamEndToken.prototype.id = "<stream end>";
                return StreamEndToken;
            }(this.Token);
            this.BlockSequenceStartToken = function(_super) {
                __extends(BlockSequenceStartToken, _super);
                function BlockSequenceStartToken() {
                    _ref3 = BlockSequenceStartToken.__super__.constructor.apply(this, arguments);
                    return _ref3;
                }
                BlockSequenceStartToken.prototype.id = "<block sequence start>";
                return BlockSequenceStartToken;
            }(this.Token);
            this.BlockMappingStartToken = function(_super) {
                __extends(BlockMappingStartToken, _super);
                function BlockMappingStartToken() {
                    _ref4 = BlockMappingStartToken.__super__.constructor.apply(this, arguments);
                    return _ref4;
                }
                BlockMappingStartToken.prototype.id = "<block mapping end>";
                return BlockMappingStartToken;
            }(this.Token);
            this.BlockEndToken = function(_super) {
                __extends(BlockEndToken, _super);
                function BlockEndToken() {
                    _ref5 = BlockEndToken.__super__.constructor.apply(this, arguments);
                    return _ref5;
                }
                BlockEndToken.prototype.id = "<block end>";
                return BlockEndToken;
            }(this.Token);
            this.FlowSequenceStartToken = function(_super) {
                __extends(FlowSequenceStartToken, _super);
                function FlowSequenceStartToken() {
                    _ref6 = FlowSequenceStartToken.__super__.constructor.apply(this, arguments);
                    return _ref6;
                }
                FlowSequenceStartToken.prototype.id = "[";
                return FlowSequenceStartToken;
            }(this.Token);
            this.FlowMappingStartToken = function(_super) {
                __extends(FlowMappingStartToken, _super);
                function FlowMappingStartToken() {
                    _ref7 = FlowMappingStartToken.__super__.constructor.apply(this, arguments);
                    return _ref7;
                }
                FlowMappingStartToken.prototype.id = "{";
                return FlowMappingStartToken;
            }(this.Token);
            this.FlowSequenceEndToken = function(_super) {
                __extends(FlowSequenceEndToken, _super);
                function FlowSequenceEndToken() {
                    _ref8 = FlowSequenceEndToken.__super__.constructor.apply(this, arguments);
                    return _ref8;
                }
                FlowSequenceEndToken.prototype.id = "]";
                return FlowSequenceEndToken;
            }(this.Token);
            this.FlowMappingEndToken = function(_super) {
                __extends(FlowMappingEndToken, _super);
                function FlowMappingEndToken() {
                    _ref9 = FlowMappingEndToken.__super__.constructor.apply(this, arguments);
                    return _ref9;
                }
                FlowMappingEndToken.prototype.id = "}";
                return FlowMappingEndToken;
            }(this.Token);
            this.KeyToken = function(_super) {
                __extends(KeyToken, _super);
                function KeyToken() {
                    _ref10 = KeyToken.__super__.constructor.apply(this, arguments);
                    return _ref10;
                }
                KeyToken.prototype.id = "?";
                return KeyToken;
            }(this.Token);
            this.ValueToken = function(_super) {
                __extends(ValueToken, _super);
                function ValueToken() {
                    _ref11 = ValueToken.__super__.constructor.apply(this, arguments);
                    return _ref11;
                }
                ValueToken.prototype.id = ":";
                return ValueToken;
            }(this.Token);
            this.BlockEntryToken = function(_super) {
                __extends(BlockEntryToken, _super);
                function BlockEntryToken() {
                    _ref12 = BlockEntryToken.__super__.constructor.apply(this, arguments);
                    return _ref12;
                }
                BlockEntryToken.prototype.id = "-";
                return BlockEntryToken;
            }(this.Token);
            this.FlowEntryToken = function(_super) {
                __extends(FlowEntryToken, _super);
                function FlowEntryToken() {
                    _ref13 = FlowEntryToken.__super__.constructor.apply(this, arguments);
                    return _ref13;
                }
                FlowEntryToken.prototype.id = ",";
                return FlowEntryToken;
            }(this.Token);
            this.AliasToken = function(_super) {
                __extends(AliasToken, _super);
                AliasToken.prototype.id = "<alias>";
                function AliasToken(value, start_mark, end_mark) {
                    this.value = value;
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                }
                return AliasToken;
            }(this.Token);
            this.AnchorToken = function(_super) {
                __extends(AnchorToken, _super);
                AnchorToken.prototype.id = "<anchor>";
                function AnchorToken(value, start_mark, end_mark) {
                    this.value = value;
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                }
                return AnchorToken;
            }(this.Token);
            this.TagToken = function(_super) {
                __extends(TagToken, _super);
                TagToken.prototype.id = "<tag>";
                function TagToken(value, start_mark, end_mark) {
                    this.value = value;
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                }
                return TagToken;
            }(this.Token);
            this.ScalarToken = function(_super) {
                __extends(ScalarToken, _super);
                ScalarToken.prototype.id = "<scalar>";
                function ScalarToken(value, plain, start_mark, end_mark, style) {
                    this.value = value;
                    this.plain = plain;
                    this.start_mark = start_mark;
                    this.end_mark = end_mark;
                    this.style = style;
                }
                return ScalarToken;
            }(this.Token);
        }).call(this);
    });
    register({
        "0": [ "./scanner" ]
    }, 0, function(global, module, exports, require, window) {
        (function() {
            var MarkedYAMLError, SimpleKey, tokens, util, _ref, __hasProp = {}.hasOwnProperty, __extends = function(child, parent) {
                for (var key in parent) {
                    if (__hasProp.call(parent, key)) child[key] = parent[key];
                }
                function ctor() {
                    this.constructor = child;
                }
                ctor.prototype = parent.prototype;
                child.prototype = new ctor;
                child.__super__ = parent.prototype;
                return child;
            }, __slice = [].slice, __indexOf = [].indexOf || function(item) {
                for (var i = 0, l = this.length; i < l; i++) {
                    if (i in this && this[i] === item) return i;
                }
                return -1;
            };
            MarkedYAMLError = require("./errors").MarkedYAMLError;
            tokens = require("./tokens");
            util = require("./util");
            this.ScannerError = function(_super) {
                __extends(ScannerError, _super);
                function ScannerError() {
                    _ref = ScannerError.__super__.constructor.apply(this, arguments);
                    return _ref;
                }
                return ScannerError;
            }(MarkedYAMLError);
            SimpleKey = function() {
                function SimpleKey(token_number, required, index, line, column, mark) {
                    this.token_number = token_number;
                    this.required = required;
                    this.index = index;
                    this.line = line;
                    this.column = column;
                    this.mark = mark;
                }
                return SimpleKey;
            }();
            this.Scanner = function() {
                var C_LB, C_NUMBERS, C_WS, ESCAPE_CODES, ESCAPE_REPLACEMENTS;
                C_LB = "\r\n\u2028\u2029";
                C_WS = "	 ";
                C_NUMBERS = "0123456789";
                ESCAPE_REPLACEMENTS = {
                    "0": "\0",
                    a: "",
                    b: "\b",
                    t: "	",
                    "	": "	",
                    n: "\n",
                    v: "",
                    f: "\f",
                    r: "\r",
                    e: "",
                    " ": " ",
                    '"': '"',
                    "\\": "\\",
                    N: "",
                    _: " ",
                    L: "\u2028",
                    P: "\u2029"
                };
                ESCAPE_CODES = {
                    x: 2,
                    u: 4,
                    U: 8
                };
                function Scanner() {
                    this.done = false;
                    this.flow_level = 0;
                    this.tokens = [];
                    this.fetch_stream_start();
                    this.tokens_taken = 0;
                    this.indent = -1;
                    this.indents = [];
                    this.allow_simple_key = true;
                    this.possible_simple_keys = {};
                }
                Scanner.prototype.check_token = function() {
                    var choice, choices, _i, _len;
                    choices = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                    while (this.need_more_tokens()) {
                        this.fetch_more_tokens();
                    }
                    if (this.tokens.length !== 0) {
                        if (choices.length === 0) {
                            return true;
                        }
                        for (_i = 0, _len = choices.length; _i < _len; _i++) {
                            choice = choices[_i];
                            if (this.tokens[0] instanceof choice) {
                                return true;
                            }
                        }
                    }
                    return false;
                };
                Scanner.prototype.peek_token = function() {
                    while (this.need_more_tokens()) {
                        this.fetch_more_tokens();
                    }
                    if (this.tokens.length !== 0) {
                        return this.tokens[0];
                    }
                };
                Scanner.prototype.get_token = function() {
                    while (this.need_more_tokens()) {
                        this.fetch_more_tokens();
                    }
                    if (this.tokens.length !== 0) {
                        this.tokens_taken++;
                        return this.tokens.shift();
                    }
                };
                Scanner.prototype.need_more_tokens = function() {
                    if (this.done) {
                        return false;
                    }
                    if (this.tokens.length === 0) {
                        return true;
                    }
                    this.stale_possible_simple_keys();
                    if (this.next_possible_simple_key() === this.tokens_taken) {
                        return true;
                    }
                    return false;
                };
                Scanner.prototype.fetch_more_tokens = function() {
                    var char;
                    this.scan_to_next_token();
                    this.stale_possible_simple_keys();
                    this.unwind_indent(this.column);
                    char = this.peek();
                    if (char === "\0") {
                        return this.fetch_stream_end();
                    }
                    if (char === "%" && this.check_directive()) {
                        return this.fetch_directive();
                    }
                    if (char === "-" && this.check_document_start()) {
                        return this.fetch_document_start();
                    }
                    if (char === "." && this.check_document_end()) {
                        return this.fetch_document_end();
                    }
                    if (char === "[") {
                        return this.fetch_flow_sequence_start();
                    }
                    if (char === "{") {
                        return this.fetch_flow_mapping_start();
                    }
                    if (char === "]") {
                        return this.fetch_flow_sequence_end();
                    }
                    if (char === "}") {
                        return this.fetch_flow_mapping_end();
                    }
                    if (char === ",") {
                        return this.fetch_flow_entry();
                    }
                    if (char === "-" && this.check_block_entry()) {
                        return this.fetch_block_entry();
                    }
                    if (char === "?" && this.check_key()) {
                        return this.fetch_key();
                    }
                    if (char === ":" && this.check_value()) {
                        return this.fetch_value();
                    }
                    if (char === "*") {
                        return this.fetch_alias();
                    }
                    if (char === "&") {
                        return this.fetch_anchor();
                    }
                    if (char === "!") {
                        return this.fetch_tag();
                    }
                    if (char === "|" && this.flow_level === 0) {
                        return this.fetch_literal();
                    }
                    if (char === ">" && this.flow_level === 0) {
                        return this.fetch_folded();
                    }
                    if (char === "'") {
                        return this.fetch_single();
                    }
                    if (char === '"') {
                        return this.fetch_double();
                    }
                    if (this.check_plain()) {
                        return this.fetch_plain();
                    }
                    throw new exports.ScannerError("while scanning for the next token", null, "found character " + char + " that cannot start any token", this.get_mark());
                };
                Scanner.prototype.next_possible_simple_key = function() {
                    var key, level, min_token_number, _ref1;
                    min_token_number = null;
                    _ref1 = this.possible_simple_keys;
                    for (level in _ref1) {
                        if (!__hasProp.call(_ref1, level)) continue;
                        key = _ref1[level];
                        if (min_token_number === null || key.token_number < min_token_number) {
                            min_token_number = key.token_number;
                        }
                    }
                    return min_token_number;
                };
                Scanner.prototype.stale_possible_simple_keys = function() {
                    var key, level, _ref1, _results;
                    _ref1 = this.possible_simple_keys;
                    _results = [];
                    for (level in _ref1) {
                        if (!__hasProp.call(_ref1, level)) continue;
                        key = _ref1[level];
                        if (key.line === this.line && this.index - key.index <= 1024) {
                            continue;
                        }
                        if (!key.required) {
                            _results.push(delete this.possible_simple_keys[level]);
                        } else {
                            throw new exports.ScannerError("while scanning a simple key", key.mark, "could not find expected ':'", this.get_mark());
                        }
                    }
                    return _results;
                };
                Scanner.prototype.save_possible_simple_key = function() {
                    var required, token_number;
                    required = this.flow_level === 0 && this.indent === this.column;
                    if (required && !this.allow_simple_key) {
                        throw new Error("logic failure");
                    }
                    if (!this.allow_simple_key) {
                        return;
                    }
                    this.remove_possible_simple_key();
                    token_number = this.tokens_taken + this.tokens.length;
                    return this.possible_simple_keys[this.flow_level] = new SimpleKey(token_number, required, this.index, this.line, this.column, this.get_mark());
                };
                Scanner.prototype.remove_possible_simple_key = function() {
                    var key;
                    if (!(key = this.possible_simple_keys[this.flow_level])) {
                        return;
                    }
                    if (!key.required) {
                        return delete this.possible_simple_keys[this.flow_level];
                    } else {
                        throw new exports.ScannerError("while scanning a simple key", key.mark, "could not find expected ':'", this.get_mark());
                    }
                };
                Scanner.prototype.unwind_indent = function(column) {
                    var mark, _results;
                    if (this.flow_level !== 0) {
                        return;
                    }
                    _results = [];
                    while (this.indent > column) {
                        mark = this.get_mark();
                        this.indent = this.indents.pop();
                        _results.push(this.tokens.push(new tokens.BlockEndToken(mark, mark)));
                    }
                    return _results;
                };
                Scanner.prototype.add_indent = function(column) {
                    if (!(column > this.indent)) {
                        return false;
                    }
                    this.indents.push(this.indent);
                    this.indent = column;
                    return true;
                };
                Scanner.prototype.fetch_stream_start = function() {
                    var mark;
                    mark = this.get_mark();
                    return this.tokens.push(new tokens.StreamStartToken(mark, mark, this.encoding));
                };
                Scanner.prototype.fetch_stream_end = function() {
                    var mark;
                    this.unwind_indent(-1);
                    this.remove_possible_simple_key();
                    this.allow_possible_simple_key = false;
                    this.possible_simple_keys = {};
                    mark = this.get_mark();
                    this.tokens.push(new tokens.StreamEndToken(mark, mark));
                    return this.done = true;
                };
                Scanner.prototype.fetch_directive = function() {
                    this.unwind_indent(-1);
                    this.remove_possible_simple_key();
                    this.allow_simple_key = false;
                    return this.tokens.push(this.scan_directive());
                };
                Scanner.prototype.fetch_document_start = function() {
                    return this.fetch_document_indicator(tokens.DocumentStartToken);
                };
                Scanner.prototype.fetch_document_end = function() {
                    return this.fetch_document_indicator(tokens.DocumentEndToken);
                };
                Scanner.prototype.fetch_document_indicator = function(TokenClass) {
                    var start_mark;
                    this.unwind_indent(-1);
                    this.remove_possible_simple_key();
                    this.allow_simple_key = false;
                    start_mark = this.get_mark();
                    this.forward(3);
                    return this.tokens.push(new TokenClass(start_mark, this.get_mark()));
                };
                Scanner.prototype.fetch_flow_sequence_start = function() {
                    return this.fetch_flow_collection_start(tokens.FlowSequenceStartToken);
                };
                Scanner.prototype.fetch_flow_mapping_start = function() {
                    return this.fetch_flow_collection_start(tokens.FlowMappingStartToken);
                };
                Scanner.prototype.fetch_flow_collection_start = function(TokenClass) {
                    var start_mark;
                    this.save_possible_simple_key();
                    this.flow_level++;
                    this.allow_simple_key = true;
                    start_mark = this.get_mark();
                    this.forward();
                    return this.tokens.push(new TokenClass(start_mark, this.get_mark()));
                };
                Scanner.prototype.fetch_flow_sequence_end = function() {
                    return this.fetch_flow_collection_end(tokens.FlowSequenceEndToken);
                };
                Scanner.prototype.fetch_flow_mapping_end = function() {
                    return this.fetch_flow_collection_end(tokens.FlowMappingEndToken);
                };
                Scanner.prototype.fetch_flow_collection_end = function(TokenClass) {
                    var start_mark;
                    this.remove_possible_simple_key();
                    this.flow_level--;
                    this.allow_simple_key = false;
                    start_mark = this.get_mark();
                    this.forward();
                    return this.tokens.push(new TokenClass(start_mark, this.get_mark()));
                };
                Scanner.prototype.fetch_flow_entry = function() {
                    var start_mark;
                    this.allow_simple_key = true;
                    this.remove_possible_simple_key();
                    start_mark = this.get_mark();
                    this.forward();
                    return this.tokens.push(new tokens.FlowEntryToken(start_mark, this.get_mark()));
                };
                Scanner.prototype.fetch_block_entry = function() {
                    var mark, start_mark;
                    if (this.flow_level === 0) {
                        if (!this.allow_simple_key) {
                            throw new exports.ScannerError(null, null, "sequence entries are not allowed here", this.get_mark());
                        }
                        if (this.add_indent(this.column)) {
                            mark = this.get_mark();
                            this.tokens.push(new tokens.BlockSequenceStartToken(mark, mark));
                        }
                    }
                    this.allow_simple_key = true;
                    this.remove_possible_simple_key();
                    start_mark = this.get_mark();
                    this.forward();
                    return this.tokens.push(new tokens.BlockEntryToken(start_mark, this.get_mark()));
                };
                Scanner.prototype.fetch_key = function() {
                    var mark, start_mark;
                    if (this.flow_level === 0) {
                        if (!this.allow_simple_key) {
                            throw new exports.ScannerError(null, null, "mapping keys are not allowed here", this.get_mark());
                        }
                        if (this.add_indent(this.column)) {
                            mark = this.get_mark();
                            this.tokens.push(new tokens.BlockMappingStartToken(mark, mark));
                        }
                    }
                    this.allow_simple_key = !this.flow_level;
                    this.remove_possible_simple_key();
                    start_mark = this.get_mark();
                    this.forward();
                    return this.tokens.push(new tokens.KeyToken(start_mark, this.get_mark()));
                };
                Scanner.prototype.fetch_value = function() {
                    var key, mark, start_mark;
                    if (key = this.possible_simple_keys[this.flow_level]) {
                        delete this.possible_simple_keys[this.flow_level];
                        this.tokens.splice(key.token_number - this.tokens_taken, 0, new tokens.KeyToken(key.mark, key.mark));
                        if (this.flow_level === 0) {
                            if (this.add_indent(key.column)) {
                                this.tokens.splice(key.token_number - this.tokens_taken, 0, new tokens.BlockMappingStartToken(key.mark, key.mark));
                            }
                        }
                        this.allow_simple_key = false;
                    } else {
                        if (this.flow_level === 0) {
                            if (!this.allow_simple_key) {
                                throw new exports.ScannerError(null, null, "mapping values are not allowed here", this.get_mark());
                            }
                            if (this.add_indent(this.column)) {
                                mark = this.get_mark();
                                this.tokens.push(new tokens.BlockMappingStartToken(mark, mark));
                            }
                        }
                        this.allow_simple_key = !this.flow_level;
                        this.remove_possible_simple_key();
                    }
                    start_mark = this.get_mark();
                    this.forward();
                    return this.tokens.push(new tokens.ValueToken(start_mark, this.get_mark()));
                };
                Scanner.prototype.fetch_alias = function() {
                    this.save_possible_simple_key();
                    this.allow_simple_key = false;
                    return this.tokens.push(this.scan_anchor(tokens.AliasToken));
                };
                Scanner.prototype.fetch_anchor = function() {
                    this.save_possible_simple_key();
                    this.allow_simple_key = false;
                    return this.tokens.push(this.scan_anchor(tokens.AnchorToken));
                };
                Scanner.prototype.fetch_tag = function() {
                    this.save_possible_simple_key();
                    this.allow_simple_key = false;
                    return this.tokens.push(this.scan_tag());
                };
                Scanner.prototype.fetch_literal = function() {
                    return this.fetch_block_scalar("|");
                };
                Scanner.prototype.fetch_folded = function() {
                    return this.fetch_block_scalar(">");
                };
                Scanner.prototype.fetch_block_scalar = function(style) {
                    this.allow_simple_key = true;
                    this.remove_possible_simple_key();
                    return this.tokens.push(this.scan_block_scalar(style));
                };
                Scanner.prototype.fetch_single = function() {
                    return this.fetch_flow_scalar("'");
                };
                Scanner.prototype.fetch_double = function() {
                    return this.fetch_flow_scalar('"');
                };
                Scanner.prototype.fetch_flow_scalar = function(style) {
                    this.save_possible_simple_key();
                    this.allow_simple_key = false;
                    return this.tokens.push(this.scan_flow_scalar(style));
                };
                Scanner.prototype.fetch_plain = function() {
                    this.save_possible_simple_key();
                    this.allow_simple_key = false;
                    return this.tokens.push(this.scan_plain());
                };
                Scanner.prototype.check_directive = function() {
                    if (this.column === 0) {
                        return true;
                    }
                    return false;
                };
                Scanner.prototype.check_document_start = function() {
                    var _ref1;
                    if (this.column === 0 && this.prefix(3) === "---" && (_ref1 = this.peek(3), __indexOf.call(C_LB + C_WS + "\0", _ref1) >= 0)) {
                        return true;
                    }
                    return false;
                };
                Scanner.prototype.check_document_end = function() {
                    var _ref1;
                    if (this.column === 0 && this.prefix(3) === "..." && (_ref1 = this.peek(3), __indexOf.call(C_LB + C_WS + "\0", _ref1) >= 0)) {
                        return true;
                    }
                    return false;
                };
                Scanner.prototype.check_block_entry = function() {
                    var _ref1;
                    return _ref1 = this.peek(1), __indexOf.call(C_LB + C_WS + "\0", _ref1) >= 0;
                };
                Scanner.prototype.check_key = function() {
                    var _ref1;
                    if (this.flow_level !== 0) {
                        return true;
                    }
                    return _ref1 = this.peek(1), __indexOf.call(C_LB + C_WS + "\0", _ref1) >= 0;
                };
                Scanner.prototype.check_value = function() {
                    var _ref1;
                    if (this.flow_level !== 0) {
                        return true;
                    }
                    return _ref1 = this.peek(1), __indexOf.call(C_LB + C_WS + "\0", _ref1) >= 0;
                };
                Scanner.prototype.check_plain = function() {
                    var char, _ref1;
                    char = this.peek();
                    return __indexOf.call(C_LB + C_WS + "\0-?:,[]{}#&*!|>'\"%@`", char) < 0 || (_ref1 = this.peek(1), __indexOf.call(C_LB + C_WS + "\0", _ref1) < 0) && (char === "-" || this.flow_level === 0 && __indexOf.call("?:", char) >= 0);
                };
                Scanner.prototype.scan_to_next_token = function() {
                    var found, _ref1, _results;
                    if (this.index === 0 && this.peek() === "﻿") {
                        this.forward();
                    }
                    found = false;
                    _results = [];
                    while (!found) {
                        while (this.peek() === " ") {
                            this.forward();
                        }
                        if (this.peek() === "#") {
                            while (_ref1 = this.peek(), __indexOf.call(C_LB + "\0", _ref1) < 0) {
                                this.forward();
                            }
                        }
                        if (this.scan_line_break()) {
                            if (this.flow_level === 0) {
                                _results.push(this.allow_simple_key = true);
                            } else {
                                _results.push(void 0);
                            }
                        } else {
                            _results.push(found = true);
                        }
                    }
                    return _results;
                };
                Scanner.prototype.scan_directive = function() {
                    var end_mark, name, start_mark, value, _ref1;
                    start_mark = this.get_mark();
                    this.forward();
                    name = this.scan_directive_name(start_mark);
                    value = null;
                    if (name === "YAML") {
                        value = this.scan_yaml_directive_value(start_mark);
                        end_mark = this.get_mark();
                    } else if (name === "TAG") {
                        value = this.scan_tag_directive_value(start_mark);
                        end_mark = this.get_mark();
                    } else {
                        end_mark = this.get_mark();
                        while (_ref1 = this.peek(), __indexOf.call(C_LB + "\0", _ref1) < 0) {
                            this.forward();
                        }
                    }
                    this.scan_directive_ignored_line(start_mark);
                    return new tokens.DirectiveToken(name, value, start_mark, end_mark);
                };
                Scanner.prototype.scan_directive_name = function(start_mark) {
                    var char, length, value;
                    length = 0;
                    char = this.peek(length);
                    while ("0" <= char && char <= "9" || "A" <= char && char <= "Z" || "a" <= char && char <= "z" || __indexOf.call("-_", char) >= 0) {
                        length++;
                        char = peek(length);
                    }
                    throw new exports.ScannerError("while scanning a directive", start_mark, "expected alphanumeric or numeric character but found " + char, length === 0 ? this.get_mark() : void 0);
                    value = this.prefix(length);
                    this.forward(length);
                    char = this.peek();
                    throw new exports.ScannerError("while scanning a directive", start_mark, "expected alphanumeric or numeric character but found " + char, __indexOf.call(C_LB + "\0 ", char) < 0 ? this.get_mark() : void 0);
                    return value;
                };
                Scanner.prototype.scan_yaml_directive_value = function(start_mark) {
                    var major, minor, _ref1;
                    while (this.peek() === " ") {
                        this.forward();
                    }
                    major = this.scan_yaml_directive_number(start_mark);
                    throw new exports.ScannerError("while scanning a directive", start_mark, "expected a digit or '.' but found " + this.peek(), this.peek() !== "." ? this.get_mark() : void 0);
                    this.forward();
                    minor = this.scan_yaml_directive_number(start_mark);
                    throw new exports.ScannerError("while scanning a directive", start_mark, "expected a digit or ' ' but found " + this.peek(), (_ref1 = this.peek(), __indexOf.call(C_LB + "\0 ", _ref1) < 0) ? this.get_mark() : void 0);
                    return [ major, minor ];
                };
                Scanner.prototype.scan_yaml_directive_number = function(start_mark) {
                    var char, length, value, _ref1;
                    char = this.peek();
                    throw new exports.ScannerError("while scanning a directive", start_mark, "expected a digit but found " + char, !("0" <= char && char <= "9") ? this.get_mark() : void 0);
                    length = 0;
                    while ("0" <= (_ref1 = this.peek(length)) && _ref1 <= "9") {
                        length++;
                    }
                    value = parseInt(this.prefix(length));
                    this.forward(length);
                    return value;
                };
                Scanner.prototype.scan_tag_directive_value = function(start_mark) {
                    var handle, prefix;
                    while (this.peek() === " ") {
                        this.forward();
                    }
                    handle = this.scan_tag_directive_handle(start_mark);
                    while (this.peek() === " ") {
                        this.forward();
                    }
                    prefix = this.scan_tag_directive_prefix(start_mark);
                    return [ handle, prefix ];
                };
                Scanner.prototype.scan_tag_directive_handle = function(start_mark) {
                    var char, value;
                    value = this.scan_tag_handle("directive", start_mark);
                    char = this.peek();
                    throw new exports.ScannerError("while scanning a directive", start_mark, "expected ' ' but found " + char, char !== " " ? this.get_mark() : void 0);
                    return value;
                };
                Scanner.prototype.scan_tag_directive_prefix = function(start_mark) {
                    var char, value;
                    value = this.scan_tag_uri("directive", start_mark);
                    char = this.peek();
                    throw new exports.ScannerError("while scanning a directive", start_mark, "expected ' ' but found " + char, __indexOf.call(C_LB + "\0 ", char) < 0 ? this.get_mark() : void 0);
                    return value;
                };
                Scanner.prototype.scan_directive_ignored_line = function(start_mark) {
                    var char, _ref1;
                    while (this.peek() === " ") {
                        this.forward();
                    }
                    if (this.peek() === "#") {
                        while (_ref1 = this.peek(), __indexOf.call(C_LB + "\0", _ref1) < 0) {
                            this.forward();
                        }
                    }
                    char = this.peek();
                    throw new exports.ScannerError("while scanning a directive", start_mark, "expected a comment or a line break but found " + char, __indexOf.call(C_LB + "\0", char) < 0 ? this.get_mark() : void 0);
                    return this.scan_line_break();
                };
                Scanner.prototype.scan_anchor = function(TokenClass) {
                    var char, indicator, length, name, start_mark, value;
                    start_mark = this.get_mark();
                    indicator = this.peek();
                    if (indicator === "*") {
                        name = "alias";
                    } else {
                        name = "anchor";
                    }
                    this.forward();
                    length = 0;
                    char = this.peek(length);
                    while ("0" <= char && char <= "9" || "A" <= char && char <= "Z" || "a" <= char && char <= "z" || __indexOf.call("-_", char) >= 0) {
                        length++;
                        char = this.peek(length);
                    }
                    if (length === 0) {
                        throw new exports.ScannerError("while scanning an " + name, start_mark, "expected alphabetic or numeric character but found '" + char + "'", this.get_mark());
                    }
                    value = this.prefix(length);
                    this.forward(length);
                    char = this.peek();
                    if (__indexOf.call(C_LB + C_WS + "\0" + "?:,]}%@`", char) < 0) {
                        throw new exports.ScannerError("while scanning an " + name, start_mark, "expected alphabetic or numeric character but found '" + char + "'", this.get_mark());
                    }
                    return new TokenClass(value, start_mark, this.get_mark());
                };
                Scanner.prototype.scan_tag = function() {
                    var char, handle, length, start_mark, suffix, use_handle;
                    start_mark = this.get_mark();
                    char = this.peek(1);
                    if (char === "<") {
                        handle = null;
                        this.forward(2);
                        suffix = this.scan_tag_uri("tag", start_mark);
                        if (this.peek() !== ">") {
                            throw new exports.ScannerError("while parsing a tag", start_mark, "expected '>' but found " + this.peek(), this.get_mark());
                        }
                        this.forward();
                    } else if (__indexOf.call(C_LB + C_WS + "\0", char) >= 0) {
                        handle = null;
                        suffix = "!";
                        this.forward();
                    } else {
                        length = 1;
                        use_handle = false;
                        while (__indexOf.call(C_LB + "\0 ", char) < 0) {
                            if (char === "!") {
                                use_handle = true;
                                break;
                            }
                            length++;
                            char = this.peek(length);
                        }
                        if (use_handle) {
                            handle = this.scan_tag_handle("tag", start_mark);
                        } else {
                            handle = "!";
                            this.forward();
                        }
                        suffix = this.scan_tag_uri("tag", start_mark);
                    }
                    char = this.peek();
                    if (__indexOf.call(C_LB + "\0 ", char) < 0) {
                        throw new exports.ScannerError("while scanning a tag", start_mark, "expected ' ' but found " + char, this.get_mark());
                    }
                    return new tokens.TagToken([ handle, suffix ], start_mark, this.get_mark());
                };
                Scanner.prototype.scan_block_scalar = function(style) {
                    var breaks, chomping, chunks, end_mark, folded, increment, indent, leading_non_space, length, line_break, max_indent, min_indent, start_mark, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;
                    folded = style === ">";
                    chunks = [];
                    start_mark = this.get_mark();
                    this.forward();
                    _ref1 = this.scan_block_scalar_indicators(start_mark), chomping = _ref1[0], increment = _ref1[1];
                    this.scan_block_scalar_ignored_line(start_mark);
                    min_indent = this.indent + 1;
                    if (min_indent < 1) {
                        min_indent = 1;
                    }
                    if (increment == null) {
                        _ref2 = this.scan_block_scalar_indentation(), breaks = _ref2[0], max_indent = _ref2[1], end_mark = _ref2[2];
                        indent = Math.max(min_indent, max_indent);
                    } else {
                        indent = min_indent + increment - 1;
                        _ref3 = this.scan_block_scalar_breaks(indent), breaks = _ref3[0], end_mark = _ref3[1];
                    }
                    line_break = "";
                    while (this.column === indent && this.peek() !== "\0") {
                        chunks = chunks.concat(breaks);
                        leading_non_space = (_ref4 = this.peek(), __indexOf.call(" 	", _ref4) < 0);
                        length = 0;
                        while (_ref5 = this.peek(length), __indexOf.call(C_LB + "\0", _ref5) < 0) {
                            length++;
                        }
                        chunks.push(this.prefix(length));
                        this.forward(length);
                        line_break = this.scan_line_break();
                        _ref6 = this.scan_block_scalar_breaks(indent), breaks = _ref6[0], end_mark = _ref6[1];
                        if (this.column === indent && this.peek() !== "\0") {
                            if (folded && line_break === "\n" && leading_non_space && (_ref7 = this.peek(), __indexOf.call(" 	", _ref7) < 0)) {
                                if (util.is_empty(breaks)) {
                                    chunks.push(" ");
                                }
                            } else {
                                chunks.push(line_break);
                            }
                        } else {
                            break;
                        }
                    }
                    if (chomping !== false) {
                        chunks.push(line_break);
                    }
                    if (chomping === true) {
                        chunks = chunks.concat(breaks);
                    }
                    return new tokens.ScalarToken(chunks.join(""), false, start_mark, end_mark, style);
                };
                Scanner.prototype.scan_block_scalar_indicators = function(start_mark) {
                    var char, chomping, increment;
                    chomping = null;
                    increment = null;
                    char = this.peek();
                    if (__indexOf.call("+-", char) >= 0) {
                        chomping = char === "+";
                        this.forward();
                        char = this.peek();
                        if (__indexOf.call(C_NUMBERS, char) >= 0) {
                            increment = parseInt(char);
                            if (increment === 0) {
                                throw new exports.ScannerError("while scanning a block scalar", start_mark, "expected indentation indicator in the range 1-9 but found 0", this.get_mark());
                            }
                            this.forward();
                        }
                    } else if (__indexOf.call(C_NUMBERS, char) >= 0) {
                        increment = parseInt(char);
                        if (increment === 0) {
                            throw new exports.ScannerError("while scanning a block scalar", start_mark, "expected indentation indicator in the range 1-9 but found 0", this.get_mark());
                        }
                        this.forward();
                        char = this.peek();
                        if (__indexOf.call("+-", char) >= 0) {
                            chomping = char === "+";
                            this.forward();
                        }
                    }
                    char = this.peek();
                    if (__indexOf.call(C_LB + "\0 ", char) < 0) {
                        throw new exports.ScannerError("while scanning a block scalar", start_mark, "expected chomping or indentation indicators, but found " + char, this.get_mark());
                    }
                    return [ chomping, increment ];
                };
                Scanner.prototype.scan_block_scalar_ignored_line = function(start_mark) {
                    var char, _ref1;
                    while (this.peek() === " ") {
                        this.forward();
                    }
                    if (this.peek() === "#") {
                        while (_ref1 = this.peek(), __indexOf.call(C_LB + "\0", _ref1) < 0) {
                            this.forward();
                        }
                    }
                    char = this.peek();
                    if (__indexOf.call(C_LB + "\0", char) < 0) {
                        throw new exports.ScannerError("while scanning a block scalar", start_mark, "expected a comment or a line break but found " + char, this.get_mark());
                    }
                    return this.scan_line_break();
                };
                Scanner.prototype.scan_block_scalar_indentation = function() {
                    var chunks, end_mark, max_indent, _ref1;
                    chunks = [];
                    max_indent = 0;
                    end_mark = this.get_mark();
                    while (_ref1 = this.peek(), __indexOf.call(C_LB + " ", _ref1) >= 0) {
                        if (this.peek() !== " ") {
                            chunks.push(this.scan_line_break());
                            end_mark = this.get_mark();
                        } else {
                            this.forward();
                            if (this.column > max_indent) {
                                max_indent = this.column;
                            }
                        }
                    }
                    return [ chunks, max_indent, end_mark ];
                };
                Scanner.prototype.scan_block_scalar_breaks = function(indent) {
                    var chunks, end_mark, _ref1;
                    chunks = [];
                    end_mark = this.get_mark();
                    while (this.column < indent && this.peek() === " ") {
                        this.forward();
                    }
                    while (_ref1 = this.peek(), __indexOf.call(C_LB, _ref1) >= 0) {
                        chunks.push(this.scan_line_break());
                        end_mark = this.get_mark();
                        while (this.column < indent && this.peek() === " ") {
                            this.forward();
                        }
                    }
                    return [ chunks, end_mark ];
                };
                Scanner.prototype.scan_flow_scalar = function(style) {
                    var chunks, double, quote, start_mark;
                    double = style === '"';
                    chunks = [];
                    start_mark = this.get_mark();
                    quote = this.peek();
                    this.forward();
                    chunks = chunks.concat(this.scan_flow_scalar_non_spaces(double, start_mark));
                    while (this.peek() !== quote) {
                        chunks = chunks.concat(this.scan_flow_scalar_spaces(double, start_mark));
                        chunks = chunks.concat(this.scan_flow_scalar_non_spaces(double, start_mark));
                    }
                    this.forward();
                    return new tokens.ScalarToken(chunks.join(""), false, start_mark, this.get_mark(), style);
                };
                Scanner.prototype.scan_flow_scalar_non_spaces = function(double, start_mark) {
                    var char, chunks, code, k, length, _i, _ref1, _ref2;
                    chunks = [];
                    while (true) {
                        length = 0;
                        while (_ref1 = this.peek(length), __indexOf.call(C_LB + C_WS + "'\"\\\0", _ref1) < 0) {
                            length++;
                        }
                        if (length !== 0) {
                            chunks.push(this.prefix(length));
                            this.forward(length);
                        }
                        char = this.peek();
                        if (!double && char === "'" && this.peek(1) === "'") {
                            chunks.push("'");
                            this.forward(2);
                        } else if (double && char === "'" || !double && __indexOf.call('"\\', char) >= 0) {
                            chunks.push(char);
                            this.forward();
                        } else if (double && char === "\\") {
                            this.forward();
                            char = this.peek();
                            if (char in ESCAPE_REPLACEMENTS) {
                                chunks.push(ESCAPE_REPLACEMENTS[char]);
                                this.forward();
                            } else if (char in ESCAPE_CODES) {
                                length = ESCAPE_CODES[char];
                                this.forward();
                                for (k = _i = 0; 0 <= length ? _i < length : _i > length; k = 0 <= length ? ++_i : --_i) {
                                    if (_ref2 = this.peek(k), __indexOf.call(C_NUMBERS + "ABCDEFabcdef", _ref2) < 0) {
                                        throw new exports.ScannerError("while scanning a double-quoted scalar", start_mark, "expected escape sequence of " + length + " hexadecimal numbers, but " + "found " + this.peek(k), this.get_mark());
                                    }
                                }
                                code = parseInt(this.prefix(length), 16);
                                chunks.push(String.fromCharCode(code));
                                this.forward(length);
                            } else if (__indexOf.call(C_LB, char) >= 0) {
                                this.scan_line_break();
                                chunks = chunks.concat(this.scan_flow_scalar_breaks(double, start_mark));
                            } else {
                                throw new exports.ScannerError("while scanning a double-quoted scalar", start_mark, "found unknown escape character " + char, this.get_mark());
                            }
                        } else {
                            return chunks;
                        }
                    }
                };
                Scanner.prototype.scan_flow_scalar_spaces = function(double, start_mark) {
                    var breaks, char, chunks, length, line_break, whitespaces, _ref1;
                    chunks = [];
                    length = 0;
                    while (_ref1 = this.peek(length), __indexOf.call(C_WS, _ref1) >= 0) {
                        length++;
                    }
                    whitespaces = this.prefix(length);
                    this.forward(length);
                    char = this.peek();
                    if (char === "\0") {
                        throw new exports.ScannerError("while scanning a quoted scalar", start_mark, "found unexpected end of stream", this.get_mark());
                    }
                    if (__indexOf.call(C_LB, char) >= 0) {
                        line_break = this.scan_line_break();
                        breaks = this.scan_flow_scalar_breaks(double, start_mark);
                        if (line_break !== "\n") {
                            chunks.push(line_break);
                        } else if (!breaks) {
                            chunks.push(" ");
                        }
                        chunks = chunks.concat(breaks);
                    } else {
                        chunks.push(whitespaces);
                    }
                    return chunks;
                };
                Scanner.prototype.scan_flow_scalar_breaks = function(double, start_mark) {
                    var chunks, prefix, _ref1, _ref2, _ref3;
                    chunks = [];
                    while (true) {
                        prefix = this.prefix(3);
                        if (prefix === "---" || prefix === "..." && (_ref1 = this.peek(3), __indexOf.call(C_LB + C_WS + "\0", _ref1) >= 0)) {
                            throw new exports.ScannerError("while scanning a quoted scalar", start_mark, "found unexpected document separator", this.get_mark());
                        }
                        while (_ref2 = this.peek(), __indexOf.call(C_WS, _ref2) >= 0) {
                            this.forward();
                        }
                        if (_ref3 = this.peek(), __indexOf.call(C_LB, _ref3) >= 0) {
                            chunks.push(this.scan_line_break());
                        } else {
                            return chunks;
                        }
                    }
                };
                Scanner.prototype.scan_plain = function() {
                    var char, chunks, end_mark, indent, length, spaces, start_mark, _ref1, _ref2;
                    chunks = [];
                    start_mark = end_mark = this.get_mark();
                    indent = this.indent + 1;
                    spaces = [];
                    while (true) {
                        length = 0;
                        if (this.peek() === "#") {
                            break;
                        }
                        while (true) {
                            char = this.peek(length);
                            if (__indexOf.call(C_LB + C_WS + "\0", char) >= 0 || this.flow_level === 0 && char === ":" && (_ref1 = this.peek(length + 1), __indexOf.call(C_LB + C_WS + "\0", _ref1) >= 0) || this.flow_level !== 0 && __indexOf.call(",:?[]{}", char) >= 0) {
                                break;
                            }
                            length++;
                        }
                        if (this.flow_level !== 0 && char === ":" && (_ref2 = this.peek(length + 1), __indexOf.call(C_LB + C_WS + "\0,[]{}", _ref2) < 0)) {
                            this.forward(length);
                            throw new exports.ScannerError("while scanning a plain scalar", start_mark, "found unexpected ':'", this.get_mark(), "Please check http://pyyaml.org/wiki/YAMLColonInFlowContext");
                        }
                        if (length === 0) {
                            break;
                        }
                        this.allow_simple_key = false;
                        chunks = chunks.concat(spaces);
                        chunks.push(this.prefix(length));
                        this.forward(length);
                        end_mark = this.get_mark();
                        spaces = this.scan_plain_spaces(indent, start_mark);
                        if (spaces == null || spaces.length === 0 || this.peek() === "#" || this.flow_level === 0 && this.column < indent) {
                            break;
                        }
                    }
                    return new tokens.ScalarToken(chunks.join(""), true, start_mark, end_mark);
                };
                Scanner.prototype.scan_plain_spaces = function(indent, start_mark) {
                    var breaks, char, chunks, length, line_break, prefix, whitespaces, _ref1, _ref2, _ref3, _ref4;
                    chunks = [];
                    length = 0;
                    while (_ref1 = this.peek(length), __indexOf.call(" ", _ref1) >= 0) {
                        length++;
                    }
                    whitespaces = this.prefix(length);
                    this.forward(length);
                    char = this.peek();
                    if (__indexOf.call(C_LB, char) >= 0) {
                        line_break = this.scan_line_break();
                        this.allow_simple_key = true;
                        prefix = this.prefix(3);
                        if (prefix === "---" || prefix === "..." && (_ref2 = this.peek(3), __indexOf.call(C_LB + C_WS + "\0", _ref2) >= 0)) {
                            return;
                        }
                        breaks = [];
                        while (_ref4 = this.peek(), __indexOf.call(C_LB + " ", _ref4) >= 0) {
                            if (this.peek() === " ") {
                                this.forward();
                            } else {
                                breaks.push(this.scan_line_break());
                                prefix = this.prefix(3);
                                if (prefix === "---" || prefix === "..." && (_ref3 = this.peek(3), __indexOf.call(C_LB + C_WS + "\0", _ref3) >= 0)) {
                                    return;
                                }
                            }
                        }
                        if (line_break !== "\n") {
                            chunks.push(line_break);
                        } else if (breaks.length === 0) {
                            chunks.push(" ");
                        }
                        chunks = chunks.concat(breaks);
                    } else if (whitespaces) {
                        chunks.push(whitespaces);
                    }
                    return chunks;
                };
                Scanner.prototype.scan_tag_handle = function(name, start_mark) {
                    var char, length, value;
                    char = this.peek();
                    if (char !== "!") {
                        throw new exports.ScannerError("while scanning a " + name, start_mark, "expected '!' but found " + char, this.get_mark());
                    }
                    length = 1;
                    char = this.peek(length);
                    if (char !== " ") {
                        while ("0" <= char && char <= "9" || "A" <= char && char <= "Z" || "a" <= char && char <= "z" || __indexOf.call("-_", char) >= 0) {
                            length++;
                            char = this.peek(length);
                        }
                        if (char !== "!") {
                            this.forward(length);
                            throw new exports.ScannerError("while scanning a " + name, start_mark, "expected '!' but found " + char, this.get_mark());
                        }
                        length++;
                    }
                    value = this.prefix(length);
                    this.forward(length);
                    return value;
                };
                Scanner.prototype.scan_tag_uri = function(name, start_mark) {
                    var char, chunks, length;
                    chunks = [];
                    length = 0;
                    char = this.peek(length);
                    while ("0" <= char && char <= "9" || "A" <= char && char <= "Z" || "a" <= char && char <= "z" || __indexOf.call("-;/?:@&=+$,_.!~*'()[]%", char) >= 0) {
                        if (char === "%") {
                            chunks.push(this.prefix(length));
                            this.forward(length);
                            length = 0;
                            chunks.push(this.scan_uri_escapes(name, start_mark));
                        } else {
                            length++;
                        }
                        char = this.peek(length);
                    }
                    if (length !== 0) {
                        chunks.push(this.prefix(length));
                        this.forward(length);
                        length = 0;
                    }
                    if (chunks.length === 0) {
                        throw new exports.ScannerError("while parsing a " + name, start_mark, "expected URI but found " + char, this.get_mark());
                    }
                    return chunks.join("");
                };
                Scanner.prototype.scan_uri_escapes = function(name, start_mark) {
                    var bytes, k, mark, _i;
                    bytes = [];
                    mark = this.get_mark();
                    while (this.peek() === "%") {
                        this.forward();
                        for (k = _i = 0; _i <= 2; k = ++_i) {
                            throw new exports.ScannerError("while scanning a " + name, start_mark, "expected URI escape sequence of 2 hexadecimal numbers but found          " + this.peek(k), this.get_mark());
                        }
                        bytes.push(String.fromCharCode(parseInt(this.prefix(2), 16)));
                        this.forward(2);
                    }
                    return bytes.join("");
                };
                Scanner.prototype.scan_line_break = function() {
                    var char;
                    char = this.peek();
                    if (__indexOf.call("\r\n", char) >= 0) {
                        if (this.prefix(2) === "\r\n") {
                            this.forward(2);
                        } else {
                            this.forward();
                        }
                        return "\n";
                    } else if (__indexOf.call("\u2028\u2029", char) >= 0) {
                        this.forward();
                        return char;
                    }
                    return "";
                };
                return Scanner;
            }();
        }).call(this);
    });
    register({
        "0": [ "./parser" ]
    }, 0, function(global, module, exports, require, window) {
        (function() {
            var MarkedYAMLError, events, tokens, _ref, __hasProp = {}.hasOwnProperty, __extends = function(child, parent) {
                for (var key in parent) {
                    if (__hasProp.call(parent, key)) child[key] = parent[key];
                }
                function ctor() {
                    this.constructor = child;
                }
                ctor.prototype = parent.prototype;
                child.prototype = new ctor;
                child.__super__ = parent.prototype;
                return child;
            }, __slice = [].slice;
            events = require("./events");
            MarkedYAMLError = require("./errors").MarkedYAMLError;
            tokens = require("./tokens");
            this.ParserError = function(_super) {
                __extends(ParserError, _super);
                function ParserError() {
                    _ref = ParserError.__super__.constructor.apply(this, arguments);
                    return _ref;
                }
                return ParserError;
            }(MarkedYAMLError);
            this.Parser = function() {
                var DEFAULT_TAGS;
                DEFAULT_TAGS = {
                    "!": "!",
                    "!!": "tag:yaml.org,2002:"
                };
                function Parser() {
                    this.current_event = null;
                    this.yaml_version = null;
                    this.tag_handles = {};
                    this.states = [];
                    this.marks = [];
                    this.state = "parse_stream_start";
                }
                Parser.prototype.dispose = function() {
                    this.states = [];
                    return this.state = null;
                };
                Parser.prototype.check_event = function() {
                    var choice, choices, _i, _len;
                    choices = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                    if (this.current_event === null) {
                        if (this.state != null) {
                            this.current_event = this[this.state]();
                        }
                    }
                    if (this.current_event !== null) {
                        if (choices.length === 0) {
                            return true;
                        }
                        for (_i = 0, _len = choices.length; _i < _len; _i++) {
                            choice = choices[_i];
                            if (this.current_event instanceof choice) {
                                return true;
                            }
                        }
                    }
                    return false;
                };
                Parser.prototype.peek_event = function() {
                    if (this.current_event === null && this.state != null) {
                        this.current_event = this[this.state]();
                    }
                    return this.current_event;
                };
                Parser.prototype.get_event = function() {
                    var event;
                    if (this.current_event === null && this.state != null) {
                        this.current_event = this[this.state]();
                    }
                    event = this.current_event;
                    this.current_event = null;
                    return event;
                };
                Parser.prototype.parse_stream_start = function() {
                    var event, token;
                    token = this.get_token();
                    event = new events.StreamStartEvent(token.start_mark, token.end_mark);
                    this.state = "parse_implicit_document_start";
                    return event;
                };
                Parser.prototype.parse_implicit_document_start = function() {
                    var end_mark, event, start_mark, token;
                    if (!this.check_token(tokens.DirectiveToken, tokens.DocumentStartToken, tokens.StreamEndToken)) {
                        this.tag_handles = DEFAULT_TAGS;
                        token = this.peek_token();
                        start_mark = end_mark = token.start_mark;
                        event = new events.DocumentStartEvent(start_mark, end_mark, false);
                        this.states.push("parse_document_end");
                        this.state = "parse_block_node";
                        return event;
                    } else {
                        return this.parse_document_start();
                    }
                };
                Parser.prototype.parse_document_start = function() {
                    var end_mark, event, start_mark, tags, token, version, _ref1;
                    while (this.check_token(tokens.DocumentEndToken)) {
                        this.get_token();
                    }
                    if (!this.check_token(tokens.StreamEndToken)) {
                        start_mark = this.peek_token().start_mark;
                        _ref1 = this.process_directives(), version = _ref1[0], tags = _ref1[1];
                        if (!this.check_token(tokens.DocumentStartToken)) {
                            throw new exports.ParserError("expected '<document start>', but found " + this.peek_token().id, this.peek_token().start_mark);
                        }
                        token = this.get_token();
                        end_mark = token.end_mark;
                        event = new events.DocumentStartEvent(start_mark, end_mark, true, version, tags);
                        this.states.push("parse_document_end");
                        this.state = "parse_document_content";
                    } else {
                        token = this.get_token();
                        event = new events.StreamEndEvent(token.start_mark, token.end_mark);
                        if (this.states.length !== 0) {
                            throw new Error("assertion error, states should be empty");
                        }
                        if (this.marks.length !== 0) {
                            throw new Error("assertion error, marks should be empty");
                        }
                        this.state = null;
                    }
                    return event;
                };
                Parser.prototype.parse_document_end = function() {
                    var end_mark, event, explicit, start_mark, token;
                    token = this.peek_token();
                    start_mark = end_mark = token.start_mark;
                    explicit = false;
                    if (this.check_token(tokens.DocumentEndToken)) {
                        token = this.get_token();
                        end_mark = token.end_mark;
                        explicit = true;
                    }
                    event = new events.DocumentEndEvent(start_mark, end_mark, explicit);
                    this.state = "parse_document_start";
                    return event;
                };
                Parser.prototype.parse_document_content = function() {
                    var event;
                    if (this.check_token(tokens.DirectiveToken, tokens.DocumentStartToken, tokens.DocumentEndToken, tokens.StreamEndToken)) {
                        event = this.process_empty_scalar(this.peek_token().start_mark);
                        this.state = this.states.pop();
                        return event;
                    } else {
                        return this.parse_block_node();
                    }
                };
                Parser.prototype.process_directives = function() {
                    var handle, major, minor, prefix, tag_handles_copy, token, value, _ref1, _ref2, _ref3;
                    this.yaml_version = null;
                    this.tag_handles = {};
                    while (this.check_token(tokens.DirectiveToken)) {
                        token = this.get_token();
                        if (token.name === "YAML") {
                            if (this.yaml_version !== null) {
                                throw new exports.ParserError(null, null, "found duplicate YAML directive", token.start_mark);
                            }
                            _ref1 = token.value, major = _ref1[0], minor = _ref1[1];
                            if (major !== 1) {
                                throw new exports.ParserError(null, null, "found incompatible YAML document (version 1.* is required)", token.start_mark);
                            }
                            this.yaml_version = token.value;
                        } else if (token.name === "TAG") {
                            _ref2 = this.tag_handles, handle = _ref2[0], prefix = _ref2[1];
                            if (handle in this.tag_handles) {
                                throw new exports.ParserError(null, null, "duplicate tag handle " + handle, token.start_mark);
                            }
                            this.tag_handles[handle] = prefix;
                        }
                    }
                    tag_handles_copy = null;
                    _ref3 = this.tag_handles;
                    for (handle in _ref3) {
                        if (!__hasProp.call(_ref3, handle)) continue;
                        prefix = _ref3[handle];
                        if (tag_handles_copy == null) {
                            tag_handles_copy = {};
                        }
                        tag_handles_copy[handle] = prefix;
                    }
                    value = [ this.yaml_version, tag_handles_copy ];
                    for (handle in DEFAULT_TAGS) {
                        if (!__hasProp.call(DEFAULT_TAGS, handle)) continue;
                        prefix = DEFAULT_TAGS[handle];
                        if (!(prefix in this.tag_handles)) {
                            this.tag_handles[handle] = prefix;
                        }
                    }
                    return value;
                };
                Parser.prototype.parse_block_node = function() {
                    return this.parse_node(true);
                };
                Parser.prototype.parse_flow_node = function() {
                    return this.parse_node();
                };
                Parser.prototype.parse_block_node_or_indentless_sequence = function() {
                    return this.parse_node(true, true);
                };
                Parser.prototype.parse_node = function(block, indentless_sequence) {
                    var anchor, end_mark, event, handle, implicit, node, start_mark, suffix, tag, tag_mark, token;
                    if (block == null) {
                        block = false;
                    }
                    if (indentless_sequence == null) {
                        indentless_sequence = false;
                    }
                    if (this.check_token(tokens.AliasToken)) {
                        token = this.get_token();
                        event = new events.AliasEvent(token.value, token.start_mark, token.end_mark);
                        this.state = this.states.pop();
                    } else {
                        anchor = null;
                        tag = null;
                        start_mark = end_mark = tag_mark = null;
                        if (this.check_token(tokens.AnchorToken)) {
                            token = this.get_token();
                            start_mark = token.start_mark;
                            end_mark = token.end_mark;
                            anchor = token.value;
                            if (this.check_token(tokens.TagToken)) {
                                token = this.get_token();
                                tag_mark = token.start_mark;
                                end_mark = token.end_mark;
                                tag = token.value;
                            }
                        } else if (this.check_token(tokens.TagToken)) {
                            token = this.get_token();
                            start_mark = tag_mark = token.start_mark;
                            end_mark = token.end_mark;
                            tag = token.value;
                            if (this.check_token(tokens.AnchorToken)) {
                                token = this.get_token();
                                end_mark = token.end_mark;
                                anchor = token.value;
                            }
                        }
                        if (tag !== null) {
                            handle = tag[0], suffix = tag[1];
                            if (handle !== null) {
                                if (!(handle in this.tag_handles)) {
                                    throw new exports.ParserError("while parsing a node", start_mark, "found undefined tag handle " + handle, tag_mark);
                                }
                                tag = this.tag_handles[handle] + suffix;
                            } else {
                                tag = suffix;
                            }
                        }
                        if (start_mark === null) {
                            start_mark = end_mark = this.peek_token().start_mark;
                        }
                        event = null;
                        implicit = tag === null || tag === "!";
                        if (indentless_sequence && this.check_token(tokens.BlockEntryToken)) {
                            end_mark = this.peek_token().end_mark;
                            event = new events.SequenceStartEvent(anchor, tag, implicit, start_mark, end_mark);
                            this.state = "parse_indentless_sequence_entry";
                        } else {
                            if (this.check_token(tokens.ScalarToken)) {
                                token = this.get_token();
                                end_mark = token.end_mark;
                                if (token.plain && tag === null || tag === "!") {
                                    implicit = [ true, false ];
                                } else if (tag === null) {
                                    implicit = [ false, true ];
                                } else {
                                    implicit = [ false, false ];
                                }
                                event = new events.ScalarEvent(anchor, tag, implicit, token.value, start_mark, end_mark, token.style);
                                this.state = this.states.pop();
                            } else if (this.check_token(tokens.FlowSequenceStartToken)) {
                                end_mark = this.peek_token().end_mark;
                                event = new events.SequenceStartEvent(anchor, tag, implicit, start_mark, end_mark, true);
                                this.state = "parse_flow_sequence_first_entry";
                            } else if (this.check_token(tokens.FlowMappingStartToken)) {
                                end_mark = this.peek_token().end_mark;
                                event = new events.MappingStartEvent(anchor, tag, implicit, start_mark, end_mark, true);
                                this.state = "parse_flow_mapping_first_key";
                            } else if (block && this.check_token(tokens.BlockSequenceStartToken)) {
                                end_mark = this.peek_token().end_mark;
                                event = new events.SequenceStartEvent(anchor, tag, implicit, start_mark, end_mark, false);
                                this.state = "parse_block_sequence_first_entry";
                            } else if (block && this.check_token(tokens.BlockMappingStartToken)) {
                                end_mark = this.peek_token().end_mark;
                                event = new events.MappingStartEvent(anchor, tag, implicit, start_mark, end_mark, false);
                                this.state = "parse_block_mapping_first_key";
                            } else if (anchor !== null || tag !== null) {
                                event = new events.ScalarEvent(anchor, tag, [ implicit, false ], "", start_mark, end_mark);
                                this.state = this.states.pop();
                            } else {
                                if (block) {
                                    node = "block";
                                } else {
                                    node = "flow";
                                }
                                token = this.peek_token();
                                throw new exports.ParserError("while parsing a " + node + " node", start_mark, "expected the node content, but found " + token.id, token.start_mark);
                            }
                        }
                    }
                    return event;
                };
                Parser.prototype.parse_block_sequence_first_entry = function() {
                    var token;
                    token = this.get_token();
                    this.marks.push(token.start_mark);
                    return this.parse_block_sequence_entry();
                };
                Parser.prototype.parse_block_sequence_entry = function() {
                    var event, token;
                    if (this.check_token(tokens.BlockEntryToken)) {
                        token = this.get_token();
                        if (!this.check_token(tokens.BlockEntryToken, tokens.BlockEndToken)) {
                            this.states.push("parse_block_sequence_entry");
                            return this.parse_block_node();
                        } else {
                            this.state = "parse_block_sequence_entry";
                            return this.process_empty_scalar(token.end_mark);
                        }
                    }
                    if (!this.check_token(tokens.BlockEndToken)) {
                        token = this.peek_token();
                        throw new exports.ParserError("while parsing a block collection", this.marks.slice(-1)[0], "expected <block end>, but found " + token.id, token.start_mark);
                    }
                    token = this.get_token();
                    event = new events.SequenceEndEvent(token.start_mark, token.end_mark);
                    this.state = this.states.pop();
                    this.marks.pop();
                    return event;
                };
                Parser.prototype.parse_indentless_sequence_entry = function() {
                    var event, token;
                    if (this.check_token(tokens.BlockEntryToken)) {
                        token = this.get_token();
                        if (!this.check_token(tokens.BlockEntryToken, tokens.KeyToken, tokens.ValueToken, tokens.BlockEndToken)) {
                            this.states.push("parse_indentless_sequence_entry");
                            return this.parse_block_node();
                        } else {
                            this.state = "parse_indentless_sequence_entry";
                            return this.process_empty_scalar(token.end_mark);
                        }
                    }
                    token = this.peek_token();
                    event = new events.SequenceEndEvent(token.start_mark, token.start_mark);
                    this.state = this.states.pop();
                    return event;
                };
                Parser.prototype.parse_block_mapping_first_key = function() {
                    var token;
                    token = this.get_token();
                    this.marks.push(token.start_mark);
                    return this.parse_block_mapping_key();
                };
                Parser.prototype.parse_block_mapping_key = function() {
                    var event, token;
                    if (this.check_token(tokens.KeyToken)) {
                        token = this.get_token();
                        if (!this.check_token(tokens.KeyToken, tokens.ValueToken, tokens.BlockEndToken)) {
                            this.states.push("parse_block_mapping_value");
                            return this.parse_block_node_or_indentless_sequence();
                        } else {
                            this.state = "parse_block_mapping_value";
                            return this.process_empty_scalar(token.end_mark);
                        }
                    }
                    if (!this.check_token(tokens.BlockEndToken)) {
                        token = this.peek_token();
                        throw new exports.ParserError("while parsing a block mapping", this.marks.slice(-1)[0], "expected <block end>, but found " + token.id, token.start_mark);
                    }
                    token = this.get_token();
                    event = new events.MappingEndEvent(token.start_mark, token.end_mark);
                    this.state = this.states.pop();
                    this.marks.pop();
                    return event;
                };
                Parser.prototype.parse_block_mapping_value = function() {
                    var token;
                    if (this.check_token(tokens.ValueToken)) {
                        token = this.get_token();
                        if (!this.check_token(tokens.KeyToken, tokens.ValueToken, tokens.BlockEndToken)) {
                            this.states.push("parse_block_mapping_key");
                            return this.parse_block_node_or_indentless_sequence();
                        } else {
                            this.state = "parse_block_mapping_key";
                            return this.process_empty_scalar(token.end_mark);
                        }
                    } else {
                        this.state = "parse_block_mapping_key";
                        token = this.peek_token();
                        return this.process_empty_scalar(token.start_mark);
                    }
                };
                Parser.prototype.parse_flow_sequence_first_entry = function() {
                    var token;
                    token = this.get_token();
                    this.marks.push(token.start_mark);
                    return this.parse_flow_sequence_entry(true);
                };
                Parser.prototype.parse_flow_sequence_entry = function(first) {
                    var event, token;
                    if (first == null) {
                        first = false;
                    }
                    if (!this.check_token(tokens.FlowSequenceEndToken)) {
                        if (!first) {
                            if (this.check_token(tokens.FlowEntryToken)) {
                                this.get_token();
                            } else {
                                token = this.peek_token();
                                throw new exports.ParserError("while parsing a flow sequence", this.marks.slice(-1)[0], "expected ',' or ']', but got " + token.id, token.start_mark);
                            }
                        }
                        if (this.check_token(tokens.KeyToken)) {
                            token = this.peek_token();
                            event = new events.MappingStartEvent(null, null, true, token.start_mark, token.end_mark, true);
                            this.state = "parse_flow_sequence_entry_mapping_key";
                            return event;
                        } else if (!this.check_token(tokens.FlowSequenceEndToken)) {
                            this.states.push("parse_flow_sequence_entry");
                            return this.parse_flow_node();
                        }
                    }
                    token = this.get_token();
                    event = new events.SequenceEndEvent(token.start_mark, token.end_mark);
                    this.state = this.states.pop();
                    this.marks.pop();
                    return event;
                };
                Parser.prototype.parse_flow_sequence_entry_mapping_key = function() {
                    var token;
                    token = this.get_token();
                    if (!this.check_token(tokens.ValueToken, tokens.FlowEntryToken, tokens.FlowSequenceEndToken)) {
                        this.states.push("parse_flow_sequence_entry_mapping_value");
                        return this.parse_flow_node();
                    } else {
                        this.state = "parse_flow_sequence_entry_mapping_value";
                        return this.process_empty_scalar(token.end_mark);
                    }
                };
                Parser.prototype.parse_flow_sequence_entry_mapping_value = function() {
                    var token;
                    if (this.check_token(tokens.ValueToken)) {
                        token = this.get_token();
                        if (!this.check_token(tokens.FlowEntryToken, tokens.FlowSequenceEndToken)) {
                            this.states.push("parse_flow_sequence_entry_mapping_end");
                            return this.parse_flow_node();
                        } else {
                            this.state = "parse_flow_sequence_entry_mapping_end";
                            return this.process_empty_scalar(token.end_mark);
                        }
                    } else {
                        this.state = "parse_flow_sequence_entry_mapping_end";
                        token = this.peek_token();
                        return this.process_empty_scalar(token.start_mark);
                    }
                };
                Parser.prototype.parse_flow_sequence_entry_mapping_end = function() {
                    var token;
                    this.state = "parse_flow_sequence_entry";
                    token = this.peek_token();
                    return new events.MappingEndEvent(token.start_mark, token.start_mark);
                };
                Parser.prototype.parse_flow_mapping_first_key = function() {
                    var token;
                    token = this.get_token();
                    this.marks.push(token.start_mark);
                    return this.parse_flow_mapping_key(true);
                };
                Parser.prototype.parse_flow_mapping_key = function(first) {
                    var event, token;
                    if (first == null) {
                        first = false;
                    }
                    if (!this.check_token(tokens.FlowMappingEndToken)) {
                        if (!first) {
                            if (this.check_token(tokens.FlowEntryToken)) {
                                this.get_token();
                            } else {
                                token = this.peek_token();
                                throw new exports.ParserError("while parsing a flow mapping", this.marks.slice(-1)[0], "expected ',' or '}', but got " + token.id, token.start_mark);
                            }
                        }
                        if (this.check_token(tokens.KeyToken)) {
                            token = this.get_token();
                            if (!this.check_token(tokens.ValueToken, tokens.FlowEntryToken, tokens.FlowMappingEndToken)) {
                                this.states.push("parse_flow_mapping_value");
                                return this.parse_flow_node();
                            } else {
                                this.state = "parse_flow_mapping_value";
                                return this.process_empty_scalar(token.end_mark);
                            }
                        } else if (!this.check_token(tokens.FlowMappingEndToken)) {
                            this.states.push("parse_flow_mapping_empty_value");
                            return this.parse_flow_node();
                        }
                    }
                    token = this.get_token();
                    event = new events.MappingEndEvent(token.start_mark, token.end_mark);
                    this.state = this.states.pop();
                    this.marks.pop();
                    return event;
                };
                Parser.prototype.parse_flow_mapping_value = function() {
                    var token;
                    if (this.check_token(tokens.ValueToken)) {
                        token = this.get_token();
                        if (!this.check_token(tokens.FlowEntryToken, tokens.FlowMappingEndToken)) {
                            this.states.push("parse_flow_mapping_key");
                            return this.parse_flow_node();
                        } else {
                            this.state = "parse_flow_mapping_key";
                            return this.process_empty_scalar(token.end_mark);
                        }
                    } else {
                        this.state = "parse_flow_mapping_key";
                        token = this.peek_token();
                        return this.process_empty_scalar(token.start_mark);
                    }
                };
                Parser.prototype.parse_flow_mapping_empty_value = function() {
                    this.state = "parse_flow_mapping_key";
                    return this.process_empty_scalar(this.peek_token().start_mark);
                };
                Parser.prototype.process_empty_scalar = function(mark) {
                    return new events.ScalarEvent(null, null, [ true, false ], "", mark, mark);
                };
                return Parser;
            }();
        }).call(this);
    });
    register({
        "0": [ "./resolver" ]
    }, 0, function(global, module, exports, require, window) {
        (function() {
            var YAMLError, nodes, util, _ref, _ref1, __hasProp = {}.hasOwnProperty, __extends = function(child, parent) {
                for (var key in parent) {
                    if (__hasProp.call(parent, key)) child[key] = parent[key];
                }
                function ctor() {
                    this.constructor = child;
                }
                ctor.prototype = parent.prototype;
                child.prototype = new ctor;
                child.__super__ = parent.prototype;
                return child;
            }, __indexOf = [].indexOf || function(item) {
                for (var i = 0, l = this.length; i < l; i++) {
                    if (i in this && this[i] === item) return i;
                }
                return -1;
            };
            nodes = require("./nodes");
            util = require("./util");
            YAMLError = require("./errors").YAMLError;
            this.ResolverError = function(_super) {
                __extends(ResolverError, _super);
                function ResolverError() {
                    _ref = ResolverError.__super__.constructor.apply(this, arguments);
                    return _ref;
                }
                return ResolverError;
            }(YAMLError);
            this.BaseResolver = function() {
                var DEFAULT_MAPPING_TAG, DEFAULT_SCALAR_TAG, DEFAULT_SEQUENCE_TAG;
                DEFAULT_SCALAR_TAG = "tag:yaml.org,2002:str";
                DEFAULT_SEQUENCE_TAG = "tag:yaml.org,2002:seq";
                DEFAULT_MAPPING_TAG = "tag:yaml.org,2002:map";
                BaseResolver.prototype.yaml_implicit_resolvers = {};
                BaseResolver.prototype.yaml_path_resolvers = {};
                BaseResolver.add_implicit_resolver = function(tag, regexp, first) {
                    var char, _base, _i, _len, _ref1, _results;
                    if (first == null) {
                        first = [ null ];
                    }
                    if (!this.prototype.hasOwnProperty("yaml_implicit_resolvers")) {
                        this.prototype.yaml_implicit_resolvers = util.extend({}, this.prototype.yaml_implicit_resolvers);
                    }
                    _results = [];
                    for (_i = 0, _len = first.length; _i < _len; _i++) {
                        char = first[_i];
                        _results.push(((_ref1 = (_base = this.prototype.yaml_implicit_resolvers)[char]) != null ? _ref1 : _base[char] = []).push([ tag, regexp ]));
                    }
                    return _results;
                };
                function BaseResolver() {
                    this.resolver_exact_paths = [];
                    this.resolver_prefix_paths = [];
                }
                BaseResolver.prototype.descend_resolver = function(current_node, current_index) {
                    var depth, exact_paths, kind, path, prefix_paths, _i, _j, _len, _len1, _ref1, _ref2, _ref3, _ref4;
                    if (util.is_empty(this.yaml_path_resolvers)) {
                        return;
                    }
                    exact_paths = {};
                    prefix_paths = [];
                    if (current_node) {
                        depth = this.resolver_prefix_paths.length;
                        _ref1 = this.resolver_prefix_paths.slice(-1)[0];
                        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                            _ref2 = _ref1[_i], path = _ref2[0], kind = _ref2[1];
                            if (this.check_resolver_prefix(depth, path, kind, current_node, current_index)) {
                                if (path.length > depth) {
                                    prefix_paths.push([ path, kind ]);
                                } else {
                                    exact_paths[kind] = this.yaml_path_resolvers[path][kind];
                                }
                            }
                        }
                    } else {
                        _ref3 = this.yaml_path_resolvers;
                        for (_j = 0, _len1 = _ref3.length; _j < _len1; _j++) {
                            _ref4 = _ref3[_j], path = _ref4[0], kind = _ref4[1];
                            if (!path) {
                                exact_paths[kind] = this.yaml_path_resolvers[path][kind];
                            } else {
                                prefix_paths.push([ path, kind ]);
                            }
                        }
                    }
                    this.resolver_exact_paths.push(exact_paths);
                    return this.resolver_prefix_paths.push(prefix_paths);
                };
                BaseResolver.prototype.ascend_resolver = function() {
                    if (util.is_empty(this.yaml_path_resolvers)) {
                        return;
                    }
                    this.resolver_exact_paths.pop();
                    return this.resolver_prefix_paths.pop();
                };
                BaseResolver.prototype.check_resolver_prefix = function(depth, path, kind, current_node, current_index) {
                    var index_check, node_check, _ref1;
                    _ref1 = path[depth - 1], node_check = _ref1[0], index_check = _ref1[1];
                    if (typeof node_check === "string") {
                        if (current_node.tag !== node_check) {
                            return;
                        }
                    } else if (node_check !== null) {
                        if (!(current_node instanceof node_check)) {
                            return;
                        }
                    }
                    if (index_check === true && current_index !== null) {
                        return;
                    }
                    if ((index_check === false || index_check === null) && current_index === null) {
                        return;
                    }
                    if (typeof index_check === "string") {
                        if (!(current_index instanceof nodes.ScalarNode) && index_check === current_index.value) {
                            return;
                        }
                    } else if (typeof index_check === "number") {
                        if (index_check !== current_index) {
                            return;
                        }
                    }
                    return true;
                };
                BaseResolver.prototype.resolve = function(kind, value, implicit) {
                    var empty, exact_paths, k, regexp, resolvers, tag, _i, _len, _ref1, _ref2, _ref3, _ref4;
                    if (kind === nodes.ScalarNode && implicit[0]) {
                        if (value === "") {
                            resolvers = (_ref1 = this.yaml_implicit_resolvers[""]) != null ? _ref1 : [];
                        } else {
                            resolvers = (_ref2 = this.yaml_implicit_resolvers[value[0]]) != null ? _ref2 : [];
                        }
                        resolvers = resolvers.concat((_ref3 = this.yaml_implicit_resolvers[null]) != null ? _ref3 : []);
                        for (_i = 0, _len = resolvers.length; _i < _len; _i++) {
                            _ref4 = resolvers[_i], tag = _ref4[0], regexp = _ref4[1];
                            if (value.match(regexp)) {
                                return tag;
                            }
                        }
                        implicit = implicit[1];
                    }
                    empty = true;
                    for (k in this.yaml_path_resolvers) {
                        if ({}[k] == null) {
                            empty = false;
                        }
                    }
                    if (!empty) {
                        exact_paths = this.resolver_exact_paths.slice(-1)[0];
                        if (__indexOf.call(exact_paths, kind) >= 0) {
                            return exact_paths[kind];
                        }
                        if (__indexOf.call(exact_paths, null) >= 0) {
                            return exact_paths[null];
                        }
                    }
                    if (kind === nodes.ScalarNode) {
                        return DEFAULT_SCALAR_TAG;
                    }
                    if (kind === nodes.SequenceNode) {
                        return DEFAULT_SEQUENCE_TAG;
                    }
                    if (kind === nodes.MappingNode) {
                        return DEFAULT_MAPPING_TAG;
                    }
                };
                return BaseResolver;
            }();
            this.Resolver = function(_super) {
                __extends(Resolver, _super);
                function Resolver() {
                    _ref1 = Resolver.__super__.constructor.apply(this, arguments);
                    return _ref1;
                }
                return Resolver;
            }(this.BaseResolver);
            this.Resolver.add_implicit_resolver("tag:yaml.org,2002:bool", /^(?:yes|Yes|YES|true|True|TRUE|on|On|ON|no|No|NO|false|False|FALSE|off|Off|OFF)$/, "yYnNtTfFoO");
            this.Resolver.add_implicit_resolver("tag:yaml.org,2002:float", /^(?:[-+]?(?:[0-9][0-9_]*)\.[0-9_]*(?:[eE][-+][0-9]+)?|\.[0-9_]+(?:[eE][-+][0-9]+)?|[-+]?[0-9][0-9_]*(?::[0-5]?[0-9])+\.[0-9_]*|[-+]?\.(?:inf|Inf|INF)|\.(?:nan|NaN|NAN))$/, "-+0123456789.");
            this.Resolver.add_implicit_resolver("tag:yaml.org,2002:int", /^(?:[-+]?0b[01_]+|[-+]?0[0-7_]+|[-+]?(?:0|[1-9][0-9_]*)|[-+]?0x[0-9a-fA-F_]+|[-+]?0o[0-7_]+|[-+]?[1-9][0-9_]*(?::[0-5]?[0-9])+)$/, "-+0123456789");
            this.Resolver.add_implicit_resolver("tag:yaml.org,2002:merge", /^(?:<<)$/, "<");
            this.Resolver.add_implicit_resolver("tag:yaml.org,2002:null", /^(?:~|null|Null|NULL|)$/, [ "~", "n", "N", "" ]);
            this.Resolver.add_implicit_resolver("tag:yaml.org,2002:timestamp", /^(?:[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]|[0-9][0-9][0-9][0-9]-[0-9][0-9]?-[0-9][0-9]?(?:[Tt]|[\x20\t]+)[0-9][0-9]?:[0-9][0-9]:[0-9][0-9](?:\.[0-9]*)?(?:[\x20\t]*(?:Z|[-+][0-9][0-9]?(?::[0-9][0-9])?))?)$/, "0123456789");
            this.Resolver.add_implicit_resolver("tag:yaml.org,2002:value", /^(?:=)$/, "=");
            this.Resolver.add_implicit_resolver("tag:yaml.org,2002:yaml", /^(?:!|&|\*)$/, "!&*");
        }).call(this);
    });
    register({
        "0": [ "./loader" ]
    }, 0, function(global, module, exports, require, window) {
        (function() {
            var composer, constructor, parser, reader, resolver, scanner, util;
            util = require("./util");
            reader = require("./reader");
            scanner = require("./scanner");
            parser = require("./parser");
            composer = require("./composer");
            resolver = require("./resolver");
            constructor = require("./constructor");
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
                return function() {
                    var component, components;
                    components = [ Reader, Scanner, Parser, Composer, Resolver, Constructor ];
                    util.extend.apply(util, [ _Class.prototype ].concat(function() {
                        var _i, _len, _results;
                        _results = [];
                        for (_i = 0, _len = components.length; _i < _len; _i++) {
                            component = components[_i];
                            _results.push(component.prototype);
                        }
                        return _results;
                    }()));
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
                }();
            };
            this.Loader = this.make_loader();
        }).call(this);
    });
    register({
        "": [ "yaml" ]
    }, 0, function(global, module, exports, require, window) {
        (function() {
            var fs;
            this.composer = require("./composer");
            this.constructor = require("./constructor");
            this.errors = require("./errors");
            this.events = require("./events");
            this.loader = require("./loader");
            this.nodes = require("./nodes");
            this.parser = require("./parser");
            this.reader = require("./reader");
            this.resolver = require("./resolver");
            this.scanner = require("./scanner");
            this.tokens = require("./tokens");
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
            this.compose = function(stream, Loader) {
                var loader;
                if (Loader == null) {
                    Loader = exports.loader.Loader;
                }
                loader = new Loader(stream);
                return loader.get_single_node();
            };
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
            this.load = function(stream, Loader) {
                var loader;
                if (Loader == null) {
                    Loader = exports.loader.Loader;
                }
                loader = new Loader(stream);
                return loader.get_single_data();
            };
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
            if (typeof require !== "undefined" && require !== null && require.extensions) {
                fs = require("fs");
                require.extensions[".yml"] = require.extensions[".yaml"] = function(module, filename) {
                    return module.exports = exports.load_all(fs.readFileSync(filename, "utf8"));
                };
            }
        }).call(this);
    });
    root["yaml"] = require_from(null, "")("yaml");
}).call(this);