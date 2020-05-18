"use strict";

module.exports = Specificity;

var Pseudos = require("./Pseudos");
var SelectorPart = require("./SelectorPart");

/**
 * Represents a selector's specificity.
 * @namespace parserlib.css
 * @class Specificity
 * @constructor
 * @param {int} a Should be 1 for inline styles, zero for stylesheet styles
 * @param {int} b Number of ID selectors
 * @param {int} c Number of classes and pseudo classes
 * @param {int} d Number of element names and pseudo elements
 */
function Specificity(a, b, c, d) {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
}

Specificity.prototype = {
    constructor: Specificity,

    /**
     * Compare this specificity to another.
     * @param {Specificity} other The other specificity to compare to.
     * @return {int} -1 if the other specificity is larger, 1 if smaller, 0 if equal.
     * @method compare
     */
    compare: function(other) {
        var comps = ["a", "b", "c", "d"],
            i, len;

        for (i=0, len=comps.length; i < len; i++) {
            if (this[comps[i]] < other[comps[i]]) {
                return -1;
            } else if (this[comps[i]] > other[comps[i]]) {
                return 1;
            }
        }

        return 0;
    },

    /**
     * Creates a numeric value for the specificity.
     * @return {int} The numeric value for the specificity.
     * @method valueOf
     */
    valueOf: function() {
        return (this.a * 1000) + (this.b * 100) + (this.c * 10) + this.d;
    },

    /**
     * Returns a string representation for specificity.
     * @return {String} The string representation of specificity.
     * @method toString
     */
    toString: function() {
        return this.a + "," + this.b + "," + this.c + "," + this.d;
    }

};

/**
 * Calculates the specificity of the given selector.
 * @param {parserlib.css.Selector} The selector to calculate specificity for.
 * @return {parserlib.css.Specificity} The specificity of the selector.
 * @static
 * @method calculate
 */
Specificity.calculate = function(selector) {

    var i, len,
        part,
        b=0, c=0, d=0;

    function updateValues(part) {

        var i, j, len, num,
            elementName = part.elementName ? part.elementName.text : "",
            modifier;

        if (elementName && elementName.charAt(elementName.length-1) !== "*") {
            d++;
        }

        for (i=0, len=part.modifiers.length; i < len; i++) {
            modifier = part.modifiers[i];
            switch (modifier.type) {
                case "class":
                case "attribute":
                    c++;
                    break;

                case "id":
                    b++;
                    break;

                case "pseudo":
                    if (Pseudos.isElement(modifier.text)) {
                        d++;
                    } else {
                        c++;
                    }
                    break;

                case "not":
                    for (j=0, num=modifier.args.length; j < num; j++) {
                        updateValues(modifier.args[j]);
                    }
            }
        }
    }

    for (i=0, len=selector.parts.length; i < len; i++) {
        part = selector.parts[i];

        if (part instanceof SelectorPart) {
            updateValues(part);
        }
    }

    return new Specificity(0, b, c, d);
};
