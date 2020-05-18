"use strict";

module.exports = TokenStream;

var TokenStreamBase = require("../util/TokenStreamBase");

var PropertyValuePart = require("./PropertyValuePart");
var Tokens = require("./Tokens");

var h = /^[0-9a-fA-F]$/,
    nonascii = /^[\u00A0-\uFFFF]$/,
    nl = /\n|\r\n|\r|\f/,
    whitespace = /\u0009|\u000a|\u000c|\u000d|\u0020/;

//-----------------------------------------------------------------------------
// Helper functions
//-----------------------------------------------------------------------------


function isHexDigit(c) {
    return c !== null && h.test(c);
}

function isDigit(c) {
    return c !== null && /\d/.test(c);
}

function isWhitespace(c) {
    return c !== null && whitespace.test(c);
}

function isNewLine(c) {
    return c !== null && nl.test(c);
}

function isNameStart(c) {
    return c !== null && /[a-z_\u00A0-\uFFFF\\]/i.test(c);
}

function isNameChar(c) {
    return c !== null && (isNameStart(c) || /[0-9\-\\]/.test(c));
}

function isIdentStart(c) {
    return c !== null && (isNameStart(c) || /\-\\/.test(c));
}

function mix(receiver, supplier) {
    for (var prop in supplier) {
        if (Object.prototype.hasOwnProperty.call(supplier, prop)) {
            receiver[prop] = supplier[prop];
        }
    }
    return receiver;
}

//-----------------------------------------------------------------------------
// CSS Token Stream
//-----------------------------------------------------------------------------


/**
 * A token stream that produces CSS tokens.
 * @param {String|Reader} input The source of text to tokenize.
 * @constructor
 * @class TokenStream
 * @namespace parserlib.css
 */
function TokenStream(input) {
    TokenStreamBase.call(this, input, Tokens);
}

TokenStream.prototype = mix(new TokenStreamBase(), {

    /**
     * Overrides the TokenStreamBase method of the same name
     * to produce CSS tokens.
     * @return {Object} A token object representing the next token.
     * @method _getToken
     * @private
     */
    _getToken: function() {

        var c,
            reader = this._reader,
            token   = null,
            startLine   = reader.getLine(),
            startCol    = reader.getCol();

        c = reader.read();


        while (c) {
            switch (c) {

                /*
                 * Potential tokens:
                 * - COMMENT
                 * - SLASH
                 * - CHAR
                 */
                case "/":

                    if (reader.peek() === "*") {
                        token = this.commentToken(c, startLine, startCol);
                    } else {
                        token = this.charToken(c, startLine, startCol);
                    }
                    break;

                /*
                 * Potential tokens:
                 * - DASHMATCH
                 * - INCLUDES
                 * - PREFIXMATCH
                 * - SUFFIXMATCH
                 * - SUBSTRINGMATCH
                 * - CHAR
                 */
                case "|":
                case "~":
                case "^":
                case "$":
                case "*":
                    if (reader.peek() === "=") {
                        token = this.comparisonToken(c, startLine, startCol);
                    } else {
                        token = this.charToken(c, startLine, startCol);
                    }
                    break;

                /*
                 * Potential tokens:
                 * - STRING
                 * - INVALID
                 */
                case "\"":
                case "'":
                    token = this.stringToken(c, startLine, startCol);
                    break;

                /*
                 * Potential tokens:
                 * - HASH
                 * - CHAR
                 */
                case "#":
                    if (isNameChar(reader.peek())) {
                        token = this.hashToken(c, startLine, startCol);
                    } else {
                        token = this.charToken(c, startLine, startCol);
                    }
                    break;

                /*
                 * Potential tokens:
                 * - DOT
                 * - NUMBER
                 * - DIMENSION
                 * - PERCENTAGE
                 */
                case ".":
                    if (isDigit(reader.peek())) {
                        token = this.numberToken(c, startLine, startCol);
                    } else {
                        token = this.charToken(c, startLine, startCol);
                    }
                    break;

                /*
                 * Potential tokens:
                 * - CDC
                 * - MINUS
                 * - NUMBER
                 * - DIMENSION
                 * - PERCENTAGE
                 */
                case "-":
                    if (reader.peek() === "-") {  //could be closing HTML-style comment
                        token = this.htmlCommentEndToken(c, startLine, startCol);
                    } else if (isNameStart(reader.peek())) {
                        token = this.identOrFunctionToken(c, startLine, startCol);
                    } else {
                        token = this.charToken(c, startLine, startCol);
                    }
                    break;

                /*
                 * Potential tokens:
                 * - IMPORTANT_SYM
                 * - CHAR
                 */
                case "!":
                    token = this.importantToken(c, startLine, startCol);
                    break;

                /*
                 * Any at-keyword or CHAR
                 */
                case "@":
                    token = this.atRuleToken(c, startLine, startCol);
                    break;

                /*
                 * Potential tokens:
                 * - NOT
                 * - CHAR
                 */
                case ":":
                    token = this.notToken(c, startLine, startCol);
                    break;

                /*
                 * Potential tokens:
                 * - CDO
                 * - CHAR
                 */
                case "<":
                    token = this.htmlCommentStartToken(c, startLine, startCol);
                    break;

                /*
                 * Potential tokens:
                 * - IDENT
                 * - CHAR
                 */
                case "\\":
                    if (/[^\r\n\f]/.test(reader.peek())) {
                        token = this.identOrFunctionToken(this.readEscape(c, true), startLine, startCol);
                    } else {
                        token = this.charToken(c, startLine, startCol);
                    }
                    break;

                /*
                 * Potential tokens:
                 * - UNICODE_RANGE
                 * - URL
                 * - CHAR
                 */
                case "U":
                case "u":
                    if (reader.peek() === "+") {
                        token = this.unicodeRangeToken(c, startLine, startCol);
                        break;
                    }
                    /* falls through */
                default:

                    /*
                     * Potential tokens:
                     * - NUMBER
                     * - DIMENSION
                     * - LENGTH
                     * - FREQ
                     * - TIME
                     * - EMS
                     * - EXS
                     * - ANGLE
                     */
                    if (isDigit(c)) {
                        token = this.numberToken(c, startLine, startCol);
                    } else

                    /*
                     * Potential tokens:
                     * - S
                     */
                    if (isWhitespace(c)) {
                        token = this.whitespaceToken(c, startLine, startCol);
                    } else

                    /*
                     * Potential tokens:
                     * - IDENT
                     */
                    if (isIdentStart(c)) {
                        token = this.identOrFunctionToken(c, startLine, startCol);
                    } else {
                       /*
                        * Potential tokens:
                        * - CHAR
                        * - PLUS
                        */
                        token = this.charToken(c, startLine, startCol);
                    }

            }

            //make sure this token is wanted
            //TODO: check channel
            break;
        }

        if (!token && c === null) {
            token = this.createToken(Tokens.EOF, null, startLine, startCol);
        }

        return token;
    },

    //-------------------------------------------------------------------------
    // Methods to create tokens
    //-------------------------------------------------------------------------

    /**
     * Produces a token based on available data and the current
     * reader position information. This method is called by other
     * private methods to create tokens and is never called directly.
     * @param {int} tt The token type.
     * @param {String} value The text value of the token.
     * @param {int} startLine The beginning line for the character.
     * @param {int} startCol The beginning column for the character.
     * @param {Object} options (Optional) Specifies a channel property
     *      to indicate that a different channel should be scanned
     *      and/or a hide property indicating that the token should
     *      be hidden.
     * @return {Object} A token object.
     * @method createToken
     */
    createToken: function(tt, value, startLine, startCol, options) {
        var reader = this._reader;
        options = options || {};

        return {
            value:      value,
            type:       tt,
            channel:    options.channel,
            endChar:    options.endChar,
            hide:       options.hide || false,
            startLine:  startLine,
            startCol:   startCol,
            endLine:    reader.getLine(),
            endCol:     reader.getCol()
        };
    },

    //-------------------------------------------------------------------------
    // Methods to create specific tokens
    //-------------------------------------------------------------------------

    /**
     * Produces a token for any at-rule. If the at-rule is unknown, then
     * the token is for a single "@" character.
     * @param {String} first The first character for the token.
     * @param {int} startLine The beginning line for the character.
     * @param {int} startCol The beginning column for the character.
     * @return {Object} A token object.
     * @method atRuleToken
     */
    atRuleToken: function(first, startLine, startCol) {
        var rule    = first,
            reader  = this._reader,
            tt      = Tokens.CHAR,
            ident;

        /*
         * First, mark where we are. There are only four @ rules,
         * so anything else is really just an invalid token.
         * Basically, if this doesn't match one of the known @
         * rules, just return '@' as an unknown token and allow
         * parsing to continue after that point.
         */
        reader.mark();

        //try to find the at-keyword
        ident = this.readName();
        rule = first + ident;
        tt = Tokens.type(rule.toLowerCase());

        //if it's not valid, use the first character only and reset the reader
        if (tt === Tokens.CHAR || tt === Tokens.UNKNOWN) {
            if (rule.length > 1) {
                tt = Tokens.UNKNOWN_SYM;
            } else {
                tt = Tokens.CHAR;
                rule = first;
                reader.reset();
            }
        }

        return this.createToken(tt, rule, startLine, startCol);
    },

    /**
     * Produces a character token based on the given character
     * and location in the stream. If there's a special (non-standard)
     * token name, this is used; otherwise CHAR is used.
     * @param {String} c The character for the token.
     * @param {int} startLine The beginning line for the character.
     * @param {int} startCol The beginning column for the character.
     * @return {Object} A token object.
     * @method charToken
     */
    charToken: function(c, startLine, startCol) {
        var tt = Tokens.type(c);
        var opts = {};

        if (tt === -1) {
            tt = Tokens.CHAR;
        } else {
            opts.endChar = Tokens[tt].endChar;
        }

        return this.createToken(tt, c, startLine, startCol, opts);
    },

    /**
     * Produces a character token based on the given character
     * and location in the stream. If there's a special (non-standard)
     * token name, this is used; otherwise CHAR is used.
     * @param {String} first The first character for the token.
     * @param {int} startLine The beginning line for the character.
     * @param {int} startCol The beginning column for the character.
     * @return {Object} A token object.
     * @method commentToken
     */
    commentToken: function(first, startLine, startCol) {
        var comment = this.readComment(first);

        return this.createToken(Tokens.COMMENT, comment, startLine, startCol);
    },

    /**
     * Produces a comparison token based on the given character
     * and location in the stream. The next character must be
     * read and is already known to be an equals sign.
     * @param {String} c The character for the token.
     * @param {int} startLine The beginning line for the character.
     * @param {int} startCol The beginning column for the character.
     * @return {Object} A token object.
     * @method comparisonToken
     */
    comparisonToken: function(c, startLine, startCol) {
        var reader  = this._reader,
            comparison  = c + reader.read(),
            tt      = Tokens.type(comparison) || Tokens.CHAR;

        return this.createToken(tt, comparison, startLine, startCol);
    },

    /**
     * Produces a hash token based on the specified information. The
     * first character provided is the pound sign (#) and then this
     * method reads a name afterward.
     * @param {String} first The first character (#) in the hash name.
     * @param {int} startLine The beginning line for the character.
     * @param {int} startCol The beginning column for the character.
     * @return {Object} A token object.
     * @method hashToken
     */
    hashToken: function(first, startLine, startCol) {
        var name    = this.readName(first);

        return this.createToken(Tokens.HASH, name, startLine, startCol);
    },

    /**
     * Produces a CDO or CHAR token based on the specified information. The
     * first character is provided and the rest is read by the function to determine
     * the correct token to create.
     * @param {String} first The first character in the token.
     * @param {int} startLine The beginning line for the character.
     * @param {int} startCol The beginning column for the character.
     * @return {Object} A token object.
     * @method htmlCommentStartToken
     */
    htmlCommentStartToken: function(first, startLine, startCol) {
        var reader      = this._reader,
            text        = first;

        reader.mark();
        text += reader.readCount(3);

        if (text === "<!--") {
            return this.createToken(Tokens.CDO, text, startLine, startCol);
        } else {
            reader.reset();
            return this.charToken(first, startLine, startCol);
        }
    },

    /**
     * Produces a CDC or CHAR token based on the specified information. The
     * first character is provided and the rest is read by the function to determine
     * the correct token to create.
     * @param {String} first The first character in the token.
     * @param {int} startLine The beginning line for the character.
     * @param {int} startCol The beginning column for the character.
     * @return {Object} A token object.
     * @method htmlCommentEndToken
     */
    htmlCommentEndToken: function(first, startLine, startCol) {
        var reader      = this._reader,
            text        = first;

        reader.mark();
        text += reader.readCount(2);

        if (text === "-->") {
            return this.createToken(Tokens.CDC, text, startLine, startCol);
        } else {
            reader.reset();
            return this.charToken(first, startLine, startCol);
        }
    },

    /**
     * Produces an IDENT or FUNCTION token based on the specified information. The
     * first character is provided and the rest is read by the function to determine
     * the correct token to create.
     * @param {String} first The first character in the identifier.
     * @param {int} startLine The beginning line for the character.
     * @param {int} startCol The beginning column for the character.
     * @return {Object} A token object.
     * @method identOrFunctionToken
     */
    identOrFunctionToken: function(first, startLine, startCol) {
        var reader  = this._reader,
            ident   = this.readName(first),
            tt      = Tokens.IDENT,
            uriFns  = ["url(", "url-prefix(", "domain("],
            uri;

        //if there's a left paren immediately after, it's a URI or function
        if (reader.peek() === "(") {
            ident += reader.read();
            if (uriFns.indexOf(ident.toLowerCase()) > -1) {
                reader.mark();
                uri = this.readURI(ident);
                if (uri === null) {
                    //didn't find a valid URL or there's no closing paren
                    reader.reset();
                    tt = Tokens.FUNCTION;
                } else {
                    tt = Tokens.URI;
                    ident = uri;
                }
            } else {
                tt = Tokens.FUNCTION;
            }
        } else if (reader.peek() === ":") {  //might be an IE function

            //IE-specific functions always being with progid:
            if (ident.toLowerCase() === "progid") {
                ident += reader.readTo("(");
                tt = Tokens.IE_FUNCTION;
            }
        }

        return this.createToken(tt, ident, startLine, startCol);
    },

    /**
     * Produces an IMPORTANT_SYM or CHAR token based on the specified information. The
     * first character is provided and the rest is read by the function to determine
     * the correct token to create.
     * @param {String} first The first character in the token.
     * @param {int} startLine The beginning line for the character.
     * @param {int} startCol The beginning column for the character.
     * @return {Object} A token object.
     * @method importantToken
     */
    importantToken: function(first, startLine, startCol) {
        var reader      = this._reader,
            important   = first,
            tt          = Tokens.CHAR,
            temp,
            c;

        reader.mark();
        c = reader.read();

        while (c) {

            //there can be a comment in here
            if (c === "/") {

                //if the next character isn't a star, then this isn't a valid !important token
                if (reader.peek() !== "*") {
                    break;
                } else {
                    temp = this.readComment(c);
                    if (temp === "") {    //broken!
                        break;
                    }
                }
            } else if (isWhitespace(c)) {
                important += c + this.readWhitespace();
            } else if (/i/i.test(c)) {
                temp = reader.readCount(8);
                if (/mportant/i.test(temp)) {
                    important += c + temp;
                    tt = Tokens.IMPORTANT_SYM;

                }
                break;  //we're done
            } else {
                break;
            }

            c = reader.read();
        }

        if (tt === Tokens.CHAR) {
            reader.reset();
            return this.charToken(first, startLine, startCol);
        } else {
            return this.createToken(tt, important, startLine, startCol);
        }


    },

    /**
     * Produces a NOT or CHAR token based on the specified information. The
     * first character is provided and the rest is read by the function to determine
     * the correct token to create.
     * @param {String} first The first character in the token.
     * @param {int} startLine The beginning line for the character.
     * @param {int} startCol The beginning column for the character.
     * @return {Object} A token object.
     * @method notToken
     */
    notToken: function(first, startLine, startCol) {
        var reader      = this._reader,
            text        = first;

        reader.mark();
        text += reader.readCount(4);

        if (text.toLowerCase() === ":not(") {
            return this.createToken(Tokens.NOT, text, startLine, startCol);
        } else {
            reader.reset();
            return this.charToken(first, startLine, startCol);
        }
    },

    /**
     * Produces a number token based on the given character
     * and location in the stream. This may return a token of
     * NUMBER, EMS, EXS, LENGTH, ANGLE, TIME, FREQ, DIMENSION,
     * or PERCENTAGE.
     * @param {String} first The first character for the token.
     * @param {int} startLine The beginning line for the character.
     * @param {int} startCol The beginning column for the character.
     * @return {Object} A token object.
     * @method numberToken
     */
    numberToken: function(first, startLine, startCol) {
        var reader  = this._reader,
            value   = this.readNumber(first),
            ident,
            tt      = Tokens.NUMBER,
            c       = reader.peek();

        if (isIdentStart(c)) {
            ident = this.readName(reader.read());
            value += ident;

            if (/^em$|^ex$|^px$|^gd$|^rem$|^vw$|^vh$|^vmax$|^vmin$|^ch$|^cm$|^mm$|^in$|^pt$|^pc$/i.test(ident)) {
                tt = Tokens.LENGTH;
            } else if (/^deg|^rad$|^grad$|^turn$/i.test(ident)) {
                tt = Tokens.ANGLE;
            } else if (/^ms$|^s$/i.test(ident)) {
                tt = Tokens.TIME;
            } else if (/^hz$|^khz$/i.test(ident)) {
                tt = Tokens.FREQ;
            } else if (/^dpi$|^dpcm$/i.test(ident)) {
                tt = Tokens.RESOLUTION;
            } else {
                tt = Tokens.DIMENSION;
            }

        } else if (c === "%") {
            value += reader.read();
            tt = Tokens.PERCENTAGE;
        }

        return this.createToken(tt, value, startLine, startCol);
    },

    /**
     * Produces a string token based on the given character
     * and location in the stream. Since strings may be indicated
     * by single or double quotes, a failure to match starting
     * and ending quotes results in an INVALID token being generated.
     * The first character in the string is passed in and then
     * the rest are read up to and including the final quotation mark.
     * @param {String} first The first character in the string.
     * @param {int} startLine The beginning line for the character.
     * @param {int} startCol The beginning column for the character.
     * @return {Object} A token object.
     * @method stringToken
     */
    stringToken: function(first, startLine, startCol) {
        var delim   = first,
            string  = first,
            reader  = this._reader,
            tt      = Tokens.STRING,
            c       = reader.read(),
            i;

        while (c) {
            string += c;

            if (c === "\\") {
                c = reader.read();
                if (c === null) {
                    break; // premature EOF after backslash
                } else if (/[^\r\n\f0-9a-f]/i.test(c)) {
                    // single-character escape
                    string += c;
                } else {
                    // read up to six hex digits
                    for (i=0; isHexDigit(c) && i<6; i++) {
                        string += c;
                        c = reader.read();
                    }
                    // swallow trailing newline or space
                    if (c === "\r" && reader.peek() === "\n") {
                        string += c;
                        c = reader.read();
                    }
                    if (isWhitespace(c)) {
                        string += c;
                    } else {
                        // This character is null or not part of the escape;
                        // jump back to the top to process it.
                        continue;
                    }
                }
            } else if (c === delim) {
                break; // delimiter found.
            } else if (isNewLine(reader.peek())) {
                // newline without an escapement: it's an invalid string
                tt = Tokens.INVALID;
                break;
            }
            c = reader.read();
        }

        //if c is null, that means we're out of input and the string was never closed
        if (c === null) {
            tt = Tokens.INVALID;
        }

        return this.createToken(tt, string, startLine, startCol);
    },

    unicodeRangeToken: function(first, startLine, startCol) {
        var reader  = this._reader,
            value   = first,
            temp,
            tt      = Tokens.CHAR;

        //then it should be a unicode range
        if (reader.peek() === "+") {
            reader.mark();
            value += reader.read();
            value += this.readUnicodeRangePart(true);

            //ensure there's an actual unicode range here
            if (value.length === 2) {
                reader.reset();
            } else {

                tt = Tokens.UNICODE_RANGE;

                //if there's a ? in the first part, there can't be a second part
                if (value.indexOf("?") === -1) {

                    if (reader.peek() === "-") {
                        reader.mark();
                        temp = reader.read();
                        temp += this.readUnicodeRangePart(false);

                        //if there's not another value, back up and just take the first
                        if (temp.length === 1) {
                            reader.reset();
                        } else {
                            value += temp;
                        }
                    }

                }
            }
        }

        return this.createToken(tt, value, startLine, startCol);
    },

    /**
     * Produces a S token based on the specified information. Since whitespace
     * may have multiple characters, this consumes all whitespace characters
     * into a single token.
     * @param {String} first The first character in the token.
     * @param {int} startLine The beginning line for the character.
     * @param {int} startCol The beginning column for the character.
     * @return {Object} A token object.
     * @method whitespaceToken
     */
    whitespaceToken: function(first, startLine, startCol) {
        var value   = first + this.readWhitespace();
        return this.createToken(Tokens.S, value, startLine, startCol);
    },


    //-------------------------------------------------------------------------
    // Methods to read values from the string stream
    //-------------------------------------------------------------------------

    readUnicodeRangePart: function(allowQuestionMark) {
        var reader  = this._reader,
            part = "",
            c       = reader.peek();

        //first read hex digits
        while (isHexDigit(c) && part.length < 6) {
            reader.read();
            part += c;
            c = reader.peek();
        }

        //then read question marks if allowed
        if (allowQuestionMark) {
            while (c === "?" && part.length < 6) {
                reader.read();
                part += c;
                c = reader.peek();
            }
        }

        //there can't be any other characters after this point

        return part;
    },

    readWhitespace: function() {
        var reader  = this._reader,
            whitespace = "",
            c       = reader.peek();

        while (isWhitespace(c)) {
            reader.read();
            whitespace += c;
            c = reader.peek();
        }

        return whitespace;
    },
    readNumber: function(first) {
        var reader  = this._reader,
            number  = first,
            hasDot  = (first === "."),
            c       = reader.peek();


        while (c) {
            if (isDigit(c)) {
                number += reader.read();
            } else if (c === ".") {
                if (hasDot) {
                    break;
                } else {
                    hasDot = true;
                    number += reader.read();
                }
            } else {
                break;
            }

            c = reader.peek();
        }

        return number;
    },

    // returns null w/o resetting reader if string is invalid.
    readString: function() {
        var token = this.stringToken(this._reader.read(), 0, 0);
        return token.type === Tokens.INVALID ? null : token.value;
    },

    // returns null w/o resetting reader if URI is invalid.
    readURI: function(first) {
        var reader  = this._reader,
            uri     = first,
            inner   = "",
            c       = reader.peek();

        //skip whitespace before
        while (c && isWhitespace(c)) {
            reader.read();
            c = reader.peek();
        }

        //it's a string
        if (c === "'" || c === "\"") {
            inner = this.readString();
            if (inner !== null) {
                inner = PropertyValuePart.parseString(inner);
            }
        } else {
            inner = this.readUnquotedURL();
        }

        c = reader.peek();

        //skip whitespace after
        while (c && isWhitespace(c)) {
            reader.read();
            c = reader.peek();
        }

        //if there was no inner value or the next character isn't closing paren, it's not a URI
        if (inner === null || c !== ")") {
            uri = null;
        } else {
            // Ensure argument to URL is always double-quoted
            // (This simplifies later processing in PropertyValuePart.)
            uri += PropertyValuePart.serializeString(inner) + reader.read();
        }

        return uri;
    },
    // This method never fails, although it may return an empty string.
    readUnquotedURL: function(first) {
        var reader  = this._reader,
            url     = first || "",
            c;

        for (c = reader.peek(); c; c = reader.peek()) {
            // Note that the grammar at
            // https://www.w3.org/TR/CSS2/grammar.html#scanner
            // incorrectly includes the backslash character in the
            // `url` production, although it is correctly omitted in
            // the `baduri1` production.
            if (nonascii.test(c) || /^[\-!#$%&*-\[\]-~]$/.test(c)) {
                url += c;
                reader.read();
            } else if (c === "\\") {
                if (/^[^\r\n\f]$/.test(reader.peek(2))) {
                    url += this.readEscape(reader.read(), true);
                } else {
                    break; // bad escape sequence.
                }
            } else {
                break; // bad character
            }
        }

        return url;
    },

    readName: function(first) {
        var reader  = this._reader,
            ident   = first || "",
            c;

        for (c = reader.peek(); c; c = reader.peek()) {
            if (c === "\\") {
                if (/^[^\r\n\f]$/.test(reader.peek(2))) {
                    ident += this.readEscape(reader.read(), true);
                } else {
                    // Bad escape sequence.
                    break;
                }
            } else if (isNameChar(c)) {
                ident += reader.read();
            } else {
                break;
            }
        }

        return ident;
    },

    readEscape: function(first, unescape) {
        var reader  = this._reader,
            cssEscape = first || "",
            i       = 0,
            c       = reader.peek();

        if (isHexDigit(c)) {
            do {
                cssEscape += reader.read();
                c = reader.peek();
            } while (c && isHexDigit(c) && ++i < 6);
        }

        if (cssEscape.length === 1) {
            if (/^[^\r\n\f0-9a-f]$/.test(c)) {
                reader.read();
                if (unescape) {
                    return c;
                }
            } else {
                // We should never get here (readName won't call readEscape
                // if the escape sequence is bad).
                throw new Error("Bad escape sequence.");
            }
        } else if (c === "\r") {
            reader.read();
            if (reader.peek() === "\n") {
                c += reader.read();
            }
        } else if (/^[ \t\n\f]$/.test(c)) {
            reader.read();
        } else {
            c = "";
        }

        if (unescape) {
            var cp = parseInt(cssEscape.slice(first.length), 16);
            return String.fromCodePoint ? String.fromCodePoint(cp) :
                String.fromCharCode(cp);
        }
        return cssEscape + c;
    },

    readComment: function(first) {
        var reader  = this._reader,
            comment = first || "",
            c       = reader.read();

        if (c === "*") {
            while (c) {
                comment += c;

                //look for end of comment
                if (comment.length > 2 && c === "*" && reader.peek() === "/") {
                    comment += reader.read();
                    break;
                }

                c = reader.read();
            }

            return comment;
        } else {
            return "";
        }

    }
});
