var b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
var cb_encode = function(ccc) {
    var padlen = [0, 2, 1][ccc.length % 3],
    ord = ccc.charCodeAt(0) << 16
        | ((ccc.length > 1 ? ccc.charCodeAt(1) : 0) << 8)
        | ((ccc.length > 2 ? ccc.charCodeAt(2) : 0)),
    chars = [
        b64chars.charAt( ord >>> 18),
        b64chars.charAt((ord >>> 12) & 63),
        padlen >= 2 ? '=' : b64chars.charAt((ord >>> 6) & 63),
        padlen >= 1 ? '=' : b64chars.charAt(ord & 63)
    ];
    return chars.join('');
};
// @ts-ignore
var btoa = global.btoa ? function(b) {
    // @ts-ignore
    return global.btoa(b);
} : function(b) {
    return b.replace(/[\s\S]{1,3}/g, cb_encode);
};
var fromCharCode = String.fromCharCode;
var cb_utob = function(c) {
    var cc
    if (c.length < 2) {
        cc = c.charCodeAt(0);
        return cc < 0x80 ? c
            : cc < 0x800 ? (fromCharCode(0xc0 | (cc >>> 6))
                            + fromCharCode(0x80 | (cc & 0x3f)))
            : (fromCharCode(0xe0 | ((cc >>> 12) & 0x0f))
                + fromCharCode(0x80 | ((cc >>>  6) & 0x3f))
                + fromCharCode(0x80 | ( cc         & 0x3f)));
    } else {
        cc = 0x10000
            + (c.charCodeAt(0) - 0xD800) * 0x400
            + (c.charCodeAt(1) - 0xDC00);
        return (fromCharCode(0xf0 | ((cc >>> 18) & 0x07))
                + fromCharCode(0x80 | ((cc >>> 12) & 0x3f))
                + fromCharCode(0x80 | ((cc >>>  6) & 0x3f))
                + fromCharCode(0x80 | ( cc         & 0x3f)));
    }
};
var re_utob = /[\uD800-\uDBFF][\uDC00-\uDFFFF]|[^\x00-\x7F]/g;
var utob = function(u) {
    return u.replace(re_utob, cb_utob);
};
var _encode = function(u) {
    const isUint8Array = Object.prototype.toString.call(u) === '[object Uint8Array]';
    return isUint8Array ? u.toString('base64')
        : btoa(utob(String(u)));
}
var encode = function(u, urisafe = false) {
    return !urisafe
        ? _encode(u)
        : _encode(String(u)).replace(/[+\/]/g, function(m0) {
            return m0 == '+' ? '-' : '_';
        }).replace(/=/g, '');
};
export default {
    encode
}