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

