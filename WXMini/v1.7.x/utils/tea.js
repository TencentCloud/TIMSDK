var base64 = require("base64.js");
var	__key = '',
	__pos = 0,
	__plain = [],
	__prePlain = [],
	__cryptPos = 0, // 当前密文块位置
	__preCryptPos = 0, // 上一个密文块位置
	__out = [], // 保存加密/解密的输出
	__cipher = [], // 输出的密文
	/*用于加密时，表示当前是否是第一个8字节块，因为加密算法是反馈的,
	但是最开始的8个字节没有反馈可用，所有需要标明这种情况*/
	__header = true;
function __rand() {
	return Math.round(Math.random()*0xffffffff);
}
/**
 * 将数据转化为无符号整形
 */
function __getUInt(data, offset, len) {
	if (!len || len > 4)
		len = 4;
	var ret = 0;
	for (var i=offset; i<offset+len; i++) {
		ret <<= 8;
		ret |= data[i];
	}
	return (ret & 0xffffffff) >>> 0; // 无符号化
}
/**
 把整形数据填充到数组里，要注意端序
 */
function __intToBytes(data, offset, value) {
	data[offset+3] = (value >> 0) & 0xff;
	data[offset+2] = (value >> 8) & 0xff;
	data[offset+1] = (value >> 16) & 0xff;
	data[offset+0] = (value >> 24) & 0xff;
}
function __bytesInStr(data) {
	if (!data) return "";
	var outInHex = "";
	for (var i=0; i<data.length; i++) {
		var hex = Number(data[i]).toString(16);
		if (hex.length == 1)
			hex = "0" + hex;
		outInHex += hex;
	}
	return outInHex;
}
function __bytesToStr(data) {
	var str = "";
	for (var i=0; i<data.length; i+=2) // 输入的16进制字符串
			str += String.fromCharCode(parseInt(data.substr(i, 2), 16));
	return str;
}
function __strToBytes(str, unicode) {
	if (!str) return "";
	if (unicode) str = utf16ToUtf8(str);

	var data = [];
	for (var i=0; i<str.length; i++)
		data[i] = str.charCodeAt(i);
	return __bytesInStr(data);
}

//UTF-16转UTF-8
function utf16ToUtf8(s){
	var i, code, ret = [], len = s.length;
	for(i = 0; i < len; i++){
		code = s.charCodeAt(i);
		if(code > 0x0 && code <= 0x7f){
			//单字节
			//UTF-16 0000 - 007F
			//UTF-8  0xxxxxxx
			ret.push(s.charAt(i));
		}else if(code >= 0x80 && code <= 0x7ff){
			//双字节
			//UTF-16 0080 - 07FF
			//UTF-8  110xxxxx 10xxxxxx
			ret.push(
				//110xxxxx
				String.fromCharCode(0xc0 | ((code >> 6) & 0x1f)),
				//10xxxxxx
				String.fromCharCode(0x80 | (code & 0x3f))
			);
		}else if(code >= 0x800 && code <= 0xffff){
			//三字节
			//UTF-16 0800 - FFFF
			//UTF-8  1110xxxx 10xxxxxx 10xxxxxx
			ret.push(
				//1110xxxx
				String.fromCharCode(0xe0 | ((code >> 12) & 0xf)),
				//10xxxxxx
				String.fromCharCode(0x80 | ((code >> 6) & 0x3f)),
				//10xxxxxx
				String.fromCharCode(0x80 | (code & 0x3f))
			);
		}
	}

	return ret.join('');
}

function __encrypt(data) {
	__plain = new Array(8);
	__prePlain = new Array(8);
	__cryptPos = __preCryptPos = 0;
	__header = true;
	__pos = 0;
	var len = data.length;
	var padding = 0;

	__pos = (len + 0x0A) % 8;
	if (__pos != 0)
		__pos = 8 - __pos;
	__out = new Array(len + __pos + 10);
	__plain[0] = ((__rand() & 0xF8) | __pos ) & 0xFF;

	for (var i=1; i<=__pos; i++)
		__plain[i] = __rand() & 0xFF;
	__pos++;

	for (var i=0; i<8; i++)
		__prePlain[i] = 0;

	padding = 1;
	while (padding <= 2) {
		if (__pos < 8) {
			__plain[__pos++] = __rand() & 0xFF;
			padding++;
		}
		if (__pos == 8)
			__encrypt8bytes();
	}

	var i = 0;
	while (len > 0) {
		if (__pos < 8) {
			__plain[__pos++] = data[i++];
			len--;
		}
		if (__pos == 8)
			__encrypt8bytes();
	}

	padding = 1;
	while (padding <= 7) {
		if (__pos < 8) {
			__plain[__pos++] = 0;
			padding++;
		}
		if (__pos == 8)
			__encrypt8bytes();
	}

	return __out;
}
function __decrypt(data) {
	var count = 0;
	var m = new Array(8);
	var len = data.length;
	__cipher = data;

	if (len % 8 != 0 || len < 16)
		return null;
	/* 第一个8字节，加密的时候因为prePlain是全0，所以可以直接解密，得到消息的头部，
	关键是可以得到真正明文开始的位置
	*/
	__prePlain = __decipher(data);
	__pos = __prePlain[0] & 0x7;
	count = len - __pos - 10; // 真正的明文长度
	if (count < 0)
		return null;

	// 临时的preCrypt, 与加密时对应，全0的prePlain 对应 全0的preCrypt
	for (var i=0; i<m.length; i++)
		m[i] = 0;
	__out = new Array(count);
	__preCryptPos = 0;
	__cryptPos = 8; // 头部已经解密过，所以是8
	__pos++; // 与解密过程对应，+1

/*	开始跳过头部，如果在这个过程中满了8字节，则解密下一块
	因为是解密下一块，所以我们有一个语句 m = data，下一块当然有preCrypt了，我们不再用m了
	但是如果不满8，这说明了什么？说明了头8个字节的密文是包含了明文信息的，当然还是要用m把明文弄出来
	所以，很显然，满了8的话，说明了头8个字节的密文除了一个长度信息有用之外，其他都是无用的填充*/
	var padding = 1;
	while (padding <= 2) {
		if (__pos < 8) {
			__pos++;
			padding++;
		}
		if (__pos == 8) {
			m = data;
			if (!__decrypt8Bytes())
				return null;
		}
	}

/*	这里是解密的重要阶段，这个时候头部的填充都已经跳过了，开始解密
	注意如果上面一个while没有满8，这里第一个if里面用的就是原始的m，否则这个m就是data了*/
	var i=0;
	while (count != 0) {
		if (__pos < 8) {
			__out[i] = (m[__preCryptPos + __pos] ^ __prePlain[__pos]) & 0xff;
			i++;
			count--;
			__pos++;
		}
		if (__pos == 8) {
			m = data;
			__preCryptPos = __cryptPos - 8;
			if (!__decrypt8Bytes())
				return null;
		}
	}

	/*
		明文已经解密完毕了，到这里剩下的只有尾部的填充，应该全是0，如果解密后非0，即出错了，返回null
	*/
	for (padding=1; padding<8; padding++) {
		if (__pos < 8) {
			if ((m[__preCryptPos + __pos] ^ __prePlain[__pos]) != 0)
				return null;
			__pos++;
		}
		if (__pos == 8) {
			m = data;
			__preCryptPos = __cryptPos;
			if (!__decrypt8Bytes())
				return null;
		}
	}

	return __out;
}
function __encrypt8bytes() {
	for (var i=0; i<8; i++) {
		if (__header)
			__plain[i] ^= __prePlain[i];
		else
			__plain[i] ^= __out[__preCryptPos + i];
	}
	var crypted = __encipher(__plain);
	for (var i=0; i<8; i++) {
		__out[__cryptPos+i] = crypted[i] ^ __prePlain[i];
		__prePlain[i] = __plain[i];
	}

	__preCryptPos = __cryptPos;
	__cryptPos += 8;
	__pos = 0;
	__header = false;
}
function __encipher(data) {
	var loop = 16;
	var y = __getUInt(data, 0, 4);
	var z = __getUInt(data, 4, 4);
	var a = __getUInt(__key, 0, 4);
	var b = __getUInt(__key, 4, 4);
	var c = __getUInt(__key, 8, 4);
	var d = __getUInt(__key, 12, 4);
	var sum = 0;
	var delta = 0x9E3779B9 >>> 0;

	while (loop-- > 0) {
		sum += delta;
		sum = (sum & 0xFFFFFFFF) >>> 0;
		y += ((z << 4) + a) ^ (z + sum) ^ ((z >>> 5) + b);
		y = (y & 0xFFFFFFFF) >>> 0;
		z += ((y << 4) + c) ^ (y + sum) ^ ((y >>> 5) + d);
		z = (z & 0xFFFFFFFF) >>> 0;
	}
	var bytes = new Array(8);
	__intToBytes(bytes, 0, y);
	__intToBytes(bytes, 4, z);
	return bytes;
}
function __decipher(data) {
	var loop = 16;
	var y = __getUInt(data, 0, 4);
	var z = __getUInt(data, 4, 4);
	var a = __getUInt(__key, 0, 4);
	var b = __getUInt(__key, 4, 4);
	var c = __getUInt(__key, 8, 4);
	var d = __getUInt(__key, 12, 4);
	var sum = 0xE3779B90 >>> 0;
	var delta = 0x9E3779B9 >>> 0;

	while (loop-- > 0) {
		z -= ((y << 4) + c) ^ (y + sum) ^ ((y >>> 5) + d);
		z = (z & 0xFFFFFFFF) >>> 0;
		y -= ((z << 4) + a) ^ (z + sum) ^ ((z >>> 5) + b);
		y = (y & 0xFFFFFFFF) >>> 0;
		sum -= delta;
		sum = (sum & 0xFFFFFFFF) >>> 0;
	}

	var bytes = new Array(8);
	__intToBytes(bytes, 0, y);
	__intToBytes(bytes, 4, z);
	return bytes;
}
function __decrypt8Bytes() {
	var len = __cipher.length;
	for (var i=0; i<8; i++) {
		__prePlain[i] ^= __cipher[__cryptPos + i];
	}

	__prePlain = __decipher(__prePlain);

	__cryptPos += 8;
	__pos = 0;
	return true;
}
/**
 * 把输入字符串转换为javascript array
 */
function __dataFromStr(str, isASCII) {
	var data = [];
	if (isASCII) {
		for (var i=0; i<str.length; i++)
			data[i] = str.charCodeAt(i) & 0xff;
	} else {
		var k = 0;
		for (var i=0; i<str.length; i+=2) // 输入的16进制字符串
			data[k++] = parseInt(str.substr(i, 2), 16);
	}
	return data;
}

var TEA = {
	encrypt: function(str, isASCII) {
		var data = __dataFromStr(str, isASCII);
		var encrypted = __encrypt(data);
		return __bytesInStr(encrypted);
	},
	enAsBase64: function(str, isASCII) { // output base64 encoded
		var data = __dataFromStr(str, isASCII);
		var encrypted = __encrypt(data);
		var bytes = "";
		for (var i=0; i<encrypted.length; i++)
			bytes += String.fromCharCode(encrypted[i]);
		return base64.encode(bytes);
	},
	decrypt: function(str) {
		var data = __dataFromStr(str, false);
		var decrypted = __decrypt(data);
		return __bytesInStr(decrypted);
	},
	initkey: function(key, isASCII) {
		__key = __dataFromStr(key, isASCII);
	},
	bytesToStr: __bytesToStr,
	strToBytes: __strToBytes,
	bytesInStr: __bytesInStr,
	dataFromStr: __dataFromStr
};

/**
 * base64 兼容window.btoa window.atob
 * if (!window.btoa) window.btoa = base64.encode
 * if (!window.atob) window.atob = base64.decode
 */
var base64 = {};
base64.PADCHAR = '=';
base64.ALPHA = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
/*
base64.getbyte64 = function(s,i) {
	// This is oddly fast, except on Chrome/V8.
	//  Minimal or no improvement in performance by using a
	//   object with properties mapping chars to value (eg. 'A': 0)
	var idx = base64.ALPHA.indexOf(s.charAt(i));
	if (idx == -1) {
		throw "Cannot decode base64";
	}
	return idx;
}

base64.decode = function(s) {
	// convert to string
	s = "" + s;
	var getbyte64 = base64.getbyte64;
	var pads, i, b10;
	var imax = s.length
	if (imax == 0) {
		return s;
	}

	if (imax % 4 != 0) {
		throw "Cannot decode base64";
	}

	pads = 0
	if (s.charAt(imax -1) == base64.PADCHAR) {
		pads = 1;
		if (s.charAt(imax -2) == base64.PADCHAR) {
			pads = 2;
		}
		// either way, we want to ignore this last block
		imax -= 4;
	}

	var x = [];
	for (i = 0; i < imax; i += 4) {
		b10 = (getbyte64(s,i) << 18) | (getbyte64(s,i+1) << 12) |
		(getbyte64(s,i+2) << 6) | getbyte64(s,i+3);
		x.push(String.fromCharCode(b10 >> 16, (b10 >> 8) & 0xff, b10 & 0xff));
	}

	switch (pads) {
		case 1:
			b10 = (getbyte64(s,i) << 18) | (getbyte64(s,i+1) << 12) | (getbyte64(s,i+2) << 6)
			x.push(String.fromCharCode(b10 >> 16, (b10 >> 8) & 0xff));
			break;
		case 2:
			b10 = (getbyte64(s,i) << 18) | (getbyte64(s,i+1) << 12);
			x.push(String.fromCharCode(b10 >> 16));
			break;
	}
	return x.join('');
}
*/

base64.getbyte = function(s,i) {
	var x = s.charCodeAt(i);
	if (x > 255) {
		throw "INVALID_CHARACTER_ERR: DOM Exception 5";
	}
	return x;
}

base64.encode = function(s) {
	if (arguments.length != 1) {
		throw "SyntaxError: Not enough arguments";
	}
	var padchar = base64.PADCHAR;
	var alpha   = base64.ALPHA;
	var getbyte = base64.getbyte;

	var i, b10;
	var x = [];

	// convert to string
	s = "" + s;

	var imax = s.length - s.length % 3;

	if (s.length == 0) {
		return s;
	}
	for (i = 0; i < imax; i += 3) {
		b10 = (getbyte(s,i) << 16) | (getbyte(s,i+1) << 8) | getbyte(s,i+2);
		x.push(alpha.charAt(b10 >> 18));
		x.push(alpha.charAt((b10 >> 12) & 0x3F));
		x.push(alpha.charAt((b10 >> 6) & 0x3f));
		x.push(alpha.charAt(b10 & 0x3f));
	}
	switch (s.length - imax) {
		case 1:
			b10 = getbyte(s,i) << 16;
			x.push(alpha.charAt(b10 >> 18) + alpha.charAt((b10 >> 12) & 0x3F) +
			padchar + padchar);
			break;
		case 2:
			b10 = (getbyte(s,i) << 16) | (getbyte(s,i+1) << 8);
			x.push(alpha.charAt(b10 >> 18) + alpha.charAt((b10 >> 12) & 0x3F) +
			alpha.charAt((b10 >> 6) & 0x3f) + padchar);
			break;
	}
	return x.join('');
}

module.exports = TEA;
