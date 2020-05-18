/*!
Parser-Lib
Copyright (c) 2009-2016 Nicholas C. Zakas. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
/* Version v1.1.0, Build time: 6-December-2016 10:31:29 */
var parserlib = (function () {
var require;
require=(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({"parserlib-core":[function(require,module,exports){
"use strict";

module.exports = {
    StringReader    : require("./StringReader"),
    SyntaxError     : require("./SyntaxError"),
    SyntaxUnit      : require("./SyntaxUnit"),
    EventTarget     : require("./EventTarget"),
    TokenStreamBase : require("./TokenStreamBase")
};

},{"./EventTarget":23,"./StringReader":24,"./SyntaxError":25,"./SyntaxUnit":26,"./TokenStreamBase":27}],23:[function(require,module,exports){
"use strict";

module.exports = EventTarget;

/**
 * A generic base to inherit from for any object
 * that needs event handling.
 * @class EventTarget
 * @constructor
 */
function EventTarget() {

    /**
     * The array of listeners for various events.
     * @type Object
     * @property _listeners
     * @private
     */
    this._listeners = Object.create(null);
}

EventTarget.prototype = {

    //restore constructor
    constructor: EventTarget,

    /**
     * Adds a listener for a given event type.
     * @param {String} type The type of event to add a listener for.
     * @param {Function} listener The function to call when the event occurs.
     * @return {void}
     * @method addListener
     */
    addListener: function(type, listener) {
        if (!this._listeners[type]) {
            this._listeners[type] = [];
        }

        this._listeners[type].push(listener);
    },

    /**
     * Fires an event based on the passed-in object.
     * @param {Object|String} event An object with at least a 'type' attribute
     *      or a string indicating the event name.
     * @return {void}
     * @method fire
     */
    fire: function(event) {
        if (typeof event === "string") {
            event = { type: event };
        }
        if (typeof event.target !== "undefined") {
            event.target = this;
        }

        if (typeof event.type === "undefined") {
            throw new Error("Event object missing 'type' property.");
        }

        if (this._listeners[event.type]) {

            //create a copy of the array and use that so listeners can't chane
            var listeners = this._listeners[event.type].concat();
            for (var i=0, len=listeners.length; i < len; i++) {
                listeners[i].call(this, event);
            }
        }
    },

    /**
     * Removes a listener for a given event type.
     * @param {String} type The type of event to remove a listener from.
     * @param {Function} listener The function to remove from the event.
     * @return {void}
     * @method removeListener
     */
    removeListener: function(type, listener) {
        if (this._listeners[type]) {
            var listeners = this._listeners[type];
            for (var i=0, len=listeners.length; i < len; i++) {
                if (listeners[i] === listener) {
                    listeners.splice(i, 1);
                    break;
                }
            }


        }
    }
};

},{}],27:[function(require,module,exports){
"use strict";

module.exports = TokenStreamBase;

var StringReader = require("./StringReader");
var SyntaxError = require("./SyntaxError");

/**
 * Generic TokenStream providing base functionality.
 * @class TokenStreamBase
 * @namespace parserlib.util
 * @constructor
 * @param {String|StringReader} input The text to tokenize or a reader from
 *      which to read the input.
 */
function TokenStreamBase(input, tokenData) {

    /**
     * The string reader for easy access to the text.
     * @type StringReader
     * @property _reader
     * @private
     */
    this._reader = new StringReader(input ? input.toString() : "");

    /**
     * Token object for the last consumed token.
     * @type Token
     * @property _token
     * @private
     */
    this._token = null;

    /**
     * The array of token information.
     * @type Array
     * @property _tokenData
     * @private
     */
    this._tokenData = tokenData;

    /**
     * Lookahead token buffer.
     * @type Array
     * @property _lt
     * @private
     */
    this._lt = [];

    /**
     * Lookahead token buffer index.
     * @type int
     * @property _ltIndex
     * @private
     */
    this._ltIndex = 0;

    this._ltIndexCache = [];
}

/**
 * Accepts an array of token information and outputs
 * an array of token data containing key-value mappings
 * and matching functions that the TokenStream needs.
 * @param {Array} tokens An array of token descriptors.
 * @return {Array} An array of processed token data.
 * @method createTokenData
 * @static
 */
TokenStreamBase.createTokenData = function(tokens) {

    var nameMap     = [],
        typeMap     = Object.create(null),
        tokenData     = tokens.concat([]),
        i            = 0,
        len            = tokenData.length+1;

    tokenData.UNKNOWN = -1;
    tokenData.unshift({ name:"EOF" });

    for (; i < len; i++) {
        nameMap.push(tokenData[i].name);
        tokenData[tokenData[i].name] = i;
        if (tokenData[i].text) {
            typeMap[tokenData[i].text] = i;
        }
    }

    tokenData.name = function(tt) {
        return nameMap[tt];
    };

    tokenData.type = function(c) {
        return typeMap[c];
    };

    return tokenData;
};

TokenStreamBase.prototype = {

    //restore constructor
    constructor: TokenStreamBase,

    //-------------------------------------------------------------------------
    // Matching methods
    //-------------------------------------------------------------------------

    /**
     * Determines if the next token matches the given token type.
     * If so, that token is consumed; if not, the token is placed
     * back onto the token stream. You can pass in any number of
     * token types and this will return true if any of the token
     * types is found.
     * @param {int|int[]} tokenTypes Either a single token type or an array of
     *      token types that the next token might be. If an array is passed,
     *      it's assumed that the token can be any of these.
     * @param {variant} channel (Optional) The channel to read from. If not
     *      provided, reads from the default (unnamed) channel.
     * @return {Boolean} True if the token type matches, false if not.
     * @method match
     */
    match: function(tokenTypes, channel) {

        //always convert to an array, makes things easier
        if (!(tokenTypes instanceof Array)) {
            tokenTypes = [tokenTypes];
        }

        var tt  = this.get(channel),
            i   = 0,
            len = tokenTypes.length;

        while (i < len) {
            if (tt === tokenTypes[i++]) {
                return true;
            }
        }

        //no match found, put the token back
        this.unget();
        return false;
    },

    /**
     * Determines if the next token matches the given token type.
     * If so, that token is consumed; if not, an error is thrown.
     * @param {int|int[]} tokenTypes Either a single token type or an array of
     *      token types that the next token should be. If an array is passed,
     *      it's assumed that the token must be one of these.
     * @return {void}
     * @method mustMatch
     */
    mustMatch: function(tokenTypes) {

        var token;

        //always convert to an array, makes things easier
        if (!(tokenTypes instanceof Array)) {
            tokenTypes = [tokenTypes];
        }

        if (!this.match.apply(this, arguments)) {
            token = this.LT(1);
            throw new SyntaxError("Expected " + this._tokenData[tokenTypes[0]].name +
                " at line " + token.startLine + ", col " + token.startCol + ".", token.startLine, token.startCol);
        }
    },

    //-------------------------------------------------------------------------
    // Consuming methods
    //-------------------------------------------------------------------------

    /**
     * Keeps reading from the token stream until either one of the specified
     * token types is found or until the end of the input is reached.
     * @param {int|int[]} tokenTypes Either a single token type or an array of
     *      token types that the next token should be. If an array is passed,
     *      it's assumed that the token must be one of these.
     * @param {variant} channel (Optional) The channel to read from. If not
     *      provided, reads from the default (unnamed) channel.
     * @return {void}
     * @method advance
     */
    advance: function(tokenTypes, channel) {

        while (this.LA(0) !== 0 && !this.match(tokenTypes, channel)) {
            this.get();
        }

        return this.LA(0);
    },

    /**
     * Consumes the next token from the token stream.
     * @return {int} The token type of the token that was just consumed.
     * @method get
     */
    get: function(channel) {

        var tokenInfo   = this._tokenData,
            i           =0,
            token,
            info;

        //check the lookahead buffer first
        if (this._lt.length && this._ltIndex >= 0 && this._ltIndex < this._lt.length) {

            i++;
            this._token = this._lt[this._ltIndex++];
            info = tokenInfo[this._token.type];

            //obey channels logic
            while ((info.channel !== undefined && channel !== info.channel) &&
                    this._ltIndex < this._lt.length) {
                this._token = this._lt[this._ltIndex++];
                info = tokenInfo[this._token.type];
                i++;
            }

            //here be dragons
            if ((info.channel === undefined || channel === info.channel) &&
                    this._ltIndex <= this._lt.length) {
                this._ltIndexCache.push(i);
                return this._token.type;
            }
        }

        //call token retriever method
        token = this._getToken();

        //if it should be hidden, don't save a token
        if (token.type > -1 && !tokenInfo[token.type].hide) {

            //apply token channel
            token.channel = tokenInfo[token.type].channel;

            //save for later
            this._token = token;
            this._lt.push(token);

            //save space that will be moved (must be done before array is truncated)
            this._ltIndexCache.push(this._lt.length - this._ltIndex + i);

            //keep the buffer under 5 items
            if (this._lt.length > 5) {
                this._lt.shift();
            }

            //also keep the shift buffer under 5 items
            if (this._ltIndexCache.length > 5) {
                this._ltIndexCache.shift();
            }

            //update lookahead index
            this._ltIndex = this._lt.length;
        }

        /*
         * Skip to the next token if:
         * 1. The token type is marked as hidden.
         * 2. The token type has a channel specified and it isn't the current channel.
         */
        info = tokenInfo[token.type];
        if (info &&
                (info.hide ||
                (info.channel !== undefined && channel !== info.channel))) {
            return this.get(channel);
        } else {
            //return just the type
            return token.type;
        }
    },

    /**
     * Looks ahead a certain number of tokens and returns the token type at
     * that position. This will throw an error if you lookahead past the
     * end of input, past the size of the lookahead buffer, or back past
     * the first token in the lookahead buffer.
     * @param {int} The index of the token type to retrieve. 0 for the
     *      current token, 1 for the next, -1 for the previous, etc.
     * @return {int} The token type of the token in the given position.
     * @method LA
     */
    LA: function(index) {
        var total = index,
            tt;
        if (index > 0) {
            //TODO: Store 5 somewhere
            if (index > 5) {
                throw new Error("Too much lookahead.");
            }

            //get all those tokens
            while (total) {
                tt = this.get();
                total--;
            }

            //unget all those tokens
            while (total < index) {
                this.unget();
                total++;
            }
        } else if (index < 0) {

            if (this._lt[this._ltIndex+index]) {
                tt = this._lt[this._ltIndex+index].type;
            } else {
                throw new Error("Too much lookbehind.");
            }

        } else {
            tt = this._token.type;
        }

        return tt;

    },

    /**
     * Looks ahead a certain number of tokens and returns the token at
     * that position. This will throw an error if you lookahead past the
     * end of input, past the size of the lookahead buffer, or back past
     * the first token in the lookahead buffer.
     * @param {int} The index of the token type to retrieve. 0 for the
     *      current token, 1 for the next, -1 for the previous, etc.
     * @return {Object} The token of the token in the given position.
     * @method LA
     */
    LT: function(index) {

        //lookahead first to prime the token buffer
        this.LA(index);

        //now find the token, subtract one because _ltIndex is already at the next index
        return this._lt[this._ltIndex+index-1];
    },

    /**
     * Returns the token type for the next token in the stream without
     * consuming it.
     * @return {int} The token type of the next token in the stream.
     * @method peek
     */
    peek: function() {
        return this.LA(1);
    },

    /**
     * Returns the actual token object for the last consumed token.
     * @return {Token} The token object for the last consumed token.
     * @method token
     */
    token: function() {
        return this._token;
    },

    /**
     * Returns the name of the token for the given token type.
     * @param {int} tokenType The type of token to get the name of.
     * @return {String} The name of the token or "UNKNOWN_TOKEN" for any
     *      invalid token type.
     * @method tokenName
     */
    tokenName: function(tokenType) {
        if (tokenType < 0 || tokenType > this._tokenData.length) {
            return "UNKNOWN_TOKEN";
        } else {
            return this._tokenData[tokenType].name;
        }
    },

    /**
     * Returns the token type value for the given token name.
     * @param {String} tokenName The name of the token whose value should be returned.
     * @return {int} The token type value for the given token name or -1
     *      for an unknown token.
     * @method tokenName
     */
    tokenType: function(tokenName) {
        return this._tokenData[tokenName] || -1;
    },

    /**
     * Returns the last consumed token to the token stream.
     * @method unget
     */
    unget: function() {
        //if (this._ltIndex > -1) {
        if (this._ltIndexCache.length) {
            this._ltIndex -= this._ltIndexCache.pop();//--;
            this._token = this._lt[this._ltIndex - 1];
        } else {
            throw new Error("Too much lookahead.");
        }
    }

};


},{"./StringReader":24,"./SyntaxError":25}],25:[function(require,module,exports){
"use strict";

module.exports = SyntaxError;

/**
 * Type to use when a syntax error occurs.
 * @class SyntaxError
 * @namespace parserlib.util
 * @constructor
 * @param {String} message The error message.
 * @param {int} line The line at which the error occurred.
 * @param {int} col The column at which the error occurred.
 */
function SyntaxError(message, line, col) {
    Error.call(this);
    this.name = this.constructor.name;

    /**
     * The column at which the error occurred.
     * @type int
     * @property col
     */
    this.col = col;

    /**
     * The line at which the error occurred.
     * @type int
     * @property line
     */
    this.line = line;

    /**
     * The text representation of the unit.
     * @type String
     * @property text
     */
    this.message = message;

}

//inherit from Error
SyntaxError.prototype = Object.create(Error.prototype); // jshint ignore:line
SyntaxError.prototype.constructor = SyntaxError; // jshint ignore:line

},{}],24:[function(require,module,exports){
"use strict";

module.exports = StringReader;

/**
 * Convenient way to read through strings.
 * @namespace parserlib.util
 * @class StringReader
 * @constructor
 * @param {String} text The text to read.
 */
function StringReader(text) {

    /**
     * The input text with line endings normalized.
     * @property _input
     * @type String
     * @private
     */
    this._input = text.replace(/(\r\n?|\n)/g, "\n");


    /**
     * The row for the character to be read next.
     * @property _line
     * @type int
     * @private
     */
    this._line = 1;


    /**
     * The column for the character to be read next.
     * @property _col
     * @type int
     * @private
     */
    this._col = 1;

    /**
     * The index of the character in the input to be read next.
     * @property _cursor
     * @type int
     * @private
     */
    this._cursor = 0;
}

StringReader.prototype = {

    // restore constructor
    constructor: StringReader,

    //-------------------------------------------------------------------------
    // Position info
    //-------------------------------------------------------------------------

    /**
     * Returns the column of the character to be read next.
     * @return {int} The column of the character to be read next.
     * @method getCol
     */
    getCol: function() {
        return this._col;
    },

    /**
     * Returns the row of the character to be read next.
     * @return {int} The row of the character to be read next.
     * @method getLine
     */
    getLine: function() {
        return this._line;
    },

    /**
     * Determines if you're at the end of the input.
     * @return {Boolean} True if there's no more input, false otherwise.
     * @method eof
     */
    eof: function() {
        return this._cursor === this._input.length;
    },

    //-------------------------------------------------------------------------
    // Basic reading
    //-------------------------------------------------------------------------

    /**
     * Reads the next character without advancing the cursor.
     * @param {int} count How many characters to look ahead (default is 1).
     * @return {String} The next character or null if there is no next character.
     * @method peek
     */
    peek: function(count) {
        var c = null;
        count = typeof count === "undefined" ? 1 : count;

        // if we're not at the end of the input...
        if (this._cursor < this._input.length) {

            // get character and increment cursor and column
            c = this._input.charAt(this._cursor + count - 1);
        }

        return c;
    },

    /**
     * Reads the next character from the input and adjusts the row and column
     * accordingly.
     * @return {String} The next character or null if there is no next character.
     * @method read
     */
    read: function() {
        var c = null;

        // if we're not at the end of the input...
        if (this._cursor < this._input.length) {

            // if the last character was a newline, increment row count
            // and reset column count
            if (this._input.charAt(this._cursor) === "\n") {
                this._line++;
                this._col=1;
            } else {
                this._col++;
            }

            // get character and increment cursor and column
            c = this._input.charAt(this._cursor++);
        }

        return c;
    },

    //-------------------------------------------------------------------------
    // Misc
    //-------------------------------------------------------------------------

    /**
     * Saves the current location so it can be returned to later.
     * @method mark
     * @return {void}
     */
    mark: function() {
        this._bookmark = {
            cursor: this._cursor,
            line:   this._line,
            col:    this._col
        };
    },

    reset: function() {
        if (this._bookmark) {
            this._cursor = this._bookmark.cursor;
            this._line = this._bookmark.line;
            this._col = this._bookmark.col;
            delete this._bookmark;
        }
    },

    //-------------------------------------------------------------------------
    // Advanced reading
    //-------------------------------------------------------------------------

    /**
     * Reads up to and including the given string. Throws an error if that
     * string is not found.
     * @param {String} pattern The string to read.
     * @return {String} The string when it is found.
     * @throws Error when the string pattern is not found.
     * @method readTo
     */
    readTo: function(pattern) {

        var buffer = "",
            c;

        /*
         * First, buffer must be the same length as the pattern.
         * Then, buffer must end with the pattern or else reach the
         * end of the input.
         */
        while (buffer.length < pattern.length || buffer.lastIndexOf(pattern) !== buffer.length - pattern.length) {
            c = this.read();
            if (c) {
                buffer += c;
            } else {
                throw new Error("Expected \"" + pattern + "\" at line " + this._line  + ", col " + this._col + ".");
            }
        }

        return buffer;

    },

    /**
     * Reads characters while each character causes the given
     * filter function to return true. The function is passed
     * in each character and either returns true to continue
     * reading or false to stop.
     * @param {Function} filter The function to read on each character.
     * @return {String} The string made up of all characters that passed the
     *      filter check.
     * @method readWhile
     */
    readWhile: function(filter) {

        var buffer = "",
            c = this.peek();

        while (c !== null && filter(c)) {
            buffer += this.read();
            c = this.peek();
        }

        return buffer;

    },

    /**
     * Reads characters that match either text or a regular expression and
     * returns those characters. If a match is found, the row and column
     * are adjusted; if no match is found, the reader's state is unchanged.
     * reading or false to stop.
     * @param {String|RegExp} matcher If a string, then the literal string
     *      value is searched for. If a regular expression, then any string
     *      matching the pattern is search for.
     * @return {String} The string made up of all characters that matched or
     *      null if there was no match.
     * @method readMatch
     */
    readMatch: function(matcher) {

        var source = this._input.substring(this._cursor),
            value = null;

        // if it's a string, just do a straight match
        if (typeof matcher === "string") {
            if (source.slice(0, matcher.length) === matcher) {
                value = this.readCount(matcher.length);
            }
        } else if (matcher instanceof RegExp) {
            if (matcher.test(source)) {
                value = this.readCount(RegExp.lastMatch.length);
            }
        }

        return value;
    },


    /**
     * Reads a given number of characters. If the end of the input is reached,
     * it reads only the remaining characters and does not throw an error.
     * @param {int} count The number of characters to read.
     * @return {String} The string made up the read characters.
     * @method readCount
     */
    readCount: function(count) {
        var buffer = "";

        while (count--) {
            buffer += this.read();
        }

        return buffer;
    }

};

},{}],26:[function(require,module,exports){
"use strict";

module.exports = SyntaxUnit;

/**
 * Base type to represent a single syntactic unit.
 * @class SyntaxUnit
 * @namespace parserlib.util
 * @constructor
 * @param {String} text The text of the unit.
 * @param {int} line The line of text on which the unit resides.
 * @param {int} col The column of text on which the unit resides.
 */
function SyntaxUnit(text, line, col, type) {


    /**
     * The column of text on which the unit resides.
     * @type int
     * @property col
     */
    this.col = col;

    /**
     * The line of text on which the unit resides.
     * @type int
     * @property line
     */
    this.line = line;

    /**
     * The text representation of the unit.
     * @type String
     * @property text
     */
    this.text = text;

    /**
     * The type of syntax unit.
     * @type int
     * @property type
     */
    this.type = type;
}

/**
 * Create a new syntax unit based solely on the given token.
 * Convenience method for creating a new syntax unit when
 * it represents a single token instead of multiple.
 * @param {Object} token The token object to represent.
 * @return {parserlib.util.SyntaxUnit} The object representing the token.
 * @static
 * @method fromToken
 */
SyntaxUnit.fromToken = function(token) {
    return new SyntaxUnit(token.value, token.startLine, token.startCol);
};

SyntaxUnit.prototype = {

    //restore constructor
    constructor: SyntaxUnit,

    /**
     * Returns the text representation of the unit.
     * @return {String} The text representation of the unit.
     * @method valueOf
     */
    valueOf: function() {
        return this.toString();
    },

    /**
     * Returns the text representation of the unit.
     * @return {String} The text representation of the unit.
     * @method toString
     */
    toString: function() {
        return this.text;
    }

};

},{}]},{},[]);

(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({},{},[]);

return { _require: require, util: require('parserlib-core') };
})();