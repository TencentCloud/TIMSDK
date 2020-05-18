"use strict";

module.exports = PropertyValue;

var SyntaxUnit = require("../util/SyntaxUnit");

var Parser = require("./Parser");

/**
 * Represents a single part of a CSS property value, meaning that it represents
 * just everything single part between ":" and ";". If there are multiple values
 * separated by commas, this type represents just one of the values.
 * @param {String[]} parts An array of value parts making up this value.
 * @param {int} line The line of text on which the unit resides.
 * @param {int} col The column of text on which the unit resides.
 * @namespace parserlib.css
 * @class PropertyValue
 * @extends parserlib.util.SyntaxUnit
 * @constructor
 */
function PropertyValue(parts, line, col) {

    SyntaxUnit.call(this, parts.join(" "), line, col, Parser.PROPERTY_VALUE_TYPE);

    /**
     * The parts that make up the selector.
     * @type Array
     * @property parts
     */
    this.parts = parts;

}

PropertyValue.prototype = new SyntaxUnit();
PropertyValue.prototype.constructor = PropertyValue;

