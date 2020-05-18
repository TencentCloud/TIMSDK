"use strict";

var Pseudos = module.exports = {
    __proto__:       null,
    ":first-letter": 1,
    ":first-line":   1,
    ":before":       1,
    ":after":        1
};

Pseudos.ELEMENT = 1;
Pseudos.CLASS = 2;

Pseudos.isElement = function(pseudo) {
    return pseudo.indexOf("::") === 0 || Pseudos[pseudo.toLowerCase()] === Pseudos.ELEMENT;
};
