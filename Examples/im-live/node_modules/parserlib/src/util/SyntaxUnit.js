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
