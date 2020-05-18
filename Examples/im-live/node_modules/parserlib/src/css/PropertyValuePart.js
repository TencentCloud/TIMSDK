"use strict";

module.exports = PropertyValuePart;

var SyntaxUnit = require("../util/SyntaxUnit");

var Colors = require("./Colors");
var Parser = require("./Parser");
var Tokens = require("./Tokens");

/**
 * Represents a single part of a CSS property value, meaning that it represents
 * just one part of the data between ":" and ";".
 * @param {String} text The text representation of the unit.
 * @param {int} line The line of text on which the unit resides.
 * @param {int} col The column of text on which the unit resides.
 * @namespace parserlib.css
 * @class PropertyValuePart
 * @extends parserlib.util.SyntaxUnit
 * @constructor
 */
function PropertyValuePart(text, line, col, optionalHint) {
    var hint = optionalHint || {};

    SyntaxUnit.call(this, text, line, col, Parser.PROPERTY_VALUE_PART_TYPE);

    /**
     * Indicates the type of value unit.
     * @type String
     * @property type
     */
    this.type = "unknown";

    //figure out what type of data it is

    var temp;

    //it is a measurement?
    if (/^([+\-]?[\d\.]+)([a-z]+)$/i.test(text)) {  //dimension
        this.type = "dimension";
        this.value = +RegExp.$1;
        this.units = RegExp.$2;

        //try to narrow down
        switch (this.units.toLowerCase()) {

            case "em":
            case "rem":
            case "ex":
            case "px":
            case "cm":
            case "mm":
            case "in":
            case "pt":
            case "pc":
            case "ch":
            case "vh":
            case "vw":
            case "vmax":
            case "vmin":
                this.type = "length";
                break;

            case "fr":
                this.type = "grid";
                break;

            case "deg":
            case "rad":
            case "grad":
            case "turn":
                this.type = "angle";
                break;

            case "ms":
            case "s":
                this.type = "time";
                break;

            case "hz":
            case "khz":
                this.type = "frequency";
                break;

            case "dpi":
            case "dpcm":
                this.type = "resolution";
                break;

            //default

        }

    } else if (/^([+\-]?[\d\.]+)%$/i.test(text)) {  //percentage
        this.type = "percentage";
        this.value = +RegExp.$1;
    } else if (/^([+\-]?\d+)$/i.test(text)) {  //integer
        this.type = "integer";
        this.value = +RegExp.$1;
    } else if (/^([+\-]?[\d\.]+)$/i.test(text)) {  //number
        this.type = "number";
        this.value = +RegExp.$1;

    } else if (/^#([a-f0-9]{3,6})/i.test(text)) {  //hexcolor
        this.type = "color";
        temp = RegExp.$1;
        if (temp.length === 3) {
            this.red    = parseInt(temp.charAt(0)+temp.charAt(0), 16);
            this.green  = parseInt(temp.charAt(1)+temp.charAt(1), 16);
            this.blue   = parseInt(temp.charAt(2)+temp.charAt(2), 16);
        } else {
            this.red    = parseInt(temp.substring(0, 2), 16);
            this.green  = parseInt(temp.substring(2, 4), 16);
            this.blue   = parseInt(temp.substring(4, 6), 16);
        }
    } else if (/^rgb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)/i.test(text)) { //rgb() color with absolute numbers
        this.type   = "color";
        this.red    = +RegExp.$1;
        this.green  = +RegExp.$2;
        this.blue   = +RegExp.$3;
    } else if (/^rgb\(\s*(\d+)%\s*,\s*(\d+)%\s*,\s*(\d+)%\s*\)/i.test(text)) { //rgb() color with percentages
        this.type   = "color";
        this.red    = +RegExp.$1 * 255 / 100;
        this.green  = +RegExp.$2 * 255 / 100;
        this.blue   = +RegExp.$3 * 255 / 100;
    } else if (/^rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([\d\.]+)\s*\)/i.test(text)) { //rgba() color with absolute numbers
        this.type   = "color";
        this.red    = +RegExp.$1;
        this.green  = +RegExp.$2;
        this.blue   = +RegExp.$3;
        this.alpha  = +RegExp.$4;
    } else if (/^rgba\(\s*(\d+)%\s*,\s*(\d+)%\s*,\s*(\d+)%\s*,\s*([\d\.]+)\s*\)/i.test(text)) { //rgba() color with percentages
        this.type   = "color";
        this.red    = +RegExp.$1 * 255 / 100;
        this.green  = +RegExp.$2 * 255 / 100;
        this.blue   = +RegExp.$3 * 255 / 100;
        this.alpha  = +RegExp.$4;
    } else if (/^hsl\(\s*(\d+)\s*,\s*(\d+)%\s*,\s*(\d+)%\s*\)/i.test(text)) { //hsl()
        this.type   = "color";
        this.hue    = +RegExp.$1;
        this.saturation = +RegExp.$2 / 100;
        this.lightness  = +RegExp.$3 / 100;
    } else if (/^hsla\(\s*(\d+)\s*,\s*(\d+)%\s*,\s*(\d+)%\s*,\s*([\d\.]+)\s*\)/i.test(text)) { //hsla() color with percentages
        this.type   = "color";
        this.hue    = +RegExp.$1;
        this.saturation = +RegExp.$2 / 100;
        this.lightness  = +RegExp.$3 / 100;
        this.alpha  = +RegExp.$4;
    } else if (/^url\(("([^\\"]|\\.)*")\)/i.test(text)) { //URI
        // generated by TokenStream.readURI, so always double-quoted.
        this.type   = "uri";
        this.uri    = PropertyValuePart.parseString(RegExp.$1);
    } else if (/^([^\(]+)\(/i.test(text)) {
        this.type   = "function";
        this.name   = RegExp.$1;
        this.value  = text;
    } else if (/^"([^\n\r\f\\"]|\\\r\n|\\[^\r0-9a-f]|\\[0-9a-f]{1,6}(\r\n|[ \n\r\t\f])?)*"/i.test(text)) {    //double-quoted string
        this.type   = "string";
        this.value  = PropertyValuePart.parseString(text);
    } else if (/^'([^\n\r\f\\']|\\\r\n|\\[^\r0-9a-f]|\\[0-9a-f]{1,6}(\r\n|[ \n\r\t\f])?)*'/i.test(text)) {    //single-quoted string
        this.type   = "string";
        this.value  = PropertyValuePart.parseString(text);
    } else if (Colors[text.toLowerCase()]) {  //named color
        this.type   = "color";
        temp        = Colors[text.toLowerCase()].substring(1);
        this.red    = parseInt(temp.substring(0, 2), 16);
        this.green  = parseInt(temp.substring(2, 4), 16);
        this.blue   = parseInt(temp.substring(4, 6), 16);
    } else if (/^[,\/]$/.test(text)) {
        this.type   = "operator";
        this.value  = text;
    } else if (/^-?[a-z_\u00A0-\uFFFF][a-z0-9\-_\u00A0-\uFFFF]*$/i.test(text)) {
        this.type   = "identifier";
        this.value  = text;
    }

    // There can be ambiguity with escape sequences in identifiers, as
    // well as with "color" parts which are also "identifiers", so record
    // an explicit hint when the token generating this PropertyValuePart
    // was an identifier.
    this.wasIdent = Boolean(hint.ident);

}

PropertyValuePart.prototype = new SyntaxUnit();
PropertyValuePart.prototype.constructor = PropertyValuePart;

/**
 * Helper method to parse a CSS string.
 */
PropertyValuePart.parseString = function(str) {
    str = str.slice(1, -1); // Strip surrounding single/double quotes
    var replacer = function(match, esc) {
        if (/^(\n|\r\n|\r|\f)$/.test(esc)) {
            return "";
        }
        var m = /^[0-9a-f]{1,6}/i.exec(esc);
        if (m) {
            var codePoint = parseInt(m[0], 16);
            if (String.fromCodePoint) {
                return String.fromCodePoint(codePoint);
            } else {
                // XXX No support for surrogates on old JavaScript engines.
                return String.fromCharCode(codePoint);
            }
        }
        return esc;
    };
    return str.replace(/\\(\r\n|[^\r0-9a-f]|[0-9a-f]{1,6}(\r\n|[ \n\r\t\f])?)/ig,
                       replacer);
};

/**
 * Helper method to serialize a CSS string.
 */
PropertyValuePart.serializeString = function(value) {
    var replacer = function(match, c) {
        if (c === "\"") {
            return "\\" + c;
        }
        var cp = String.codePointAt ? String.codePointAt(0) :
            // We only escape non-surrogate chars, so using charCodeAt
            // is harmless here.
            String.charCodeAt(0);
        return "\\" + cp.toString(16) + " ";
    };
    return "\"" + value.replace(/["\r\n\f]/g, replacer) + "\"";
};

/**
 * Create a new syntax unit based solely on the given token.
 * Convenience method for creating a new syntax unit when
 * it represents a single token instead of multiple.
 * @param {Object} token The token object to represent.
 * @return {parserlib.css.PropertyValuePart} The object representing the token.
 * @static
 * @method fromToken
 */
PropertyValuePart.fromToken = function(token) {
    var part = new PropertyValuePart(token.value, token.startLine, token.startCol, {
        // Tokens can have escaped characters that would fool the type
        // identification in the PropertyValuePart constructor, so pass
        // in a hint if this was an identifier.
        ident: token.type === Tokens.IDENT
    });
    return part;
};
