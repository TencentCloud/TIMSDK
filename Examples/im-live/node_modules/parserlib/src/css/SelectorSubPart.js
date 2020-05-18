"use strict";

module.exports = SelectorSubPart;

var SyntaxUnit = require("../util/SyntaxUnit");

var Parser = require("./Parser");

/**
 * Represents a selector modifier string, meaning a class name, element name,
 * element ID, pseudo rule, etc.
 * @namespace parserlib.css
 * @class SelectorSubPart
 * @extends parserlib.util.SyntaxUnit
 * @constructor
 * @param {String} text The text representation of the unit.
 * @param {String} type The type of selector modifier.
 * @param {int} line The line of text on which the unit resides.
 * @param {int} col The column of text on which the unit resides.
 */
function SelectorSubPart(text, type, line, col) {

    SyntaxUnit.call(this, text, line, col, Parser.SELECTOR_SUB_PART_TYPE);

    /**
     * The type of modifier.
     * @type String
     * @property type
     */
    this.type = type;

    /**
     * Some subparts have arguments, this represents them.
     * @type Array
     * @property args
     */
    this.args = [];

}

SelectorSubPart.prototype = new SyntaxUnit();
SelectorSubPart.prototype.constructor = SelectorSubPart;

