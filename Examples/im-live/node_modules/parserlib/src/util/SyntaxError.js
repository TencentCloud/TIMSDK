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
