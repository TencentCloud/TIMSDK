module.exports = function(){
	/********************************************
	 *
	 *  加密及算法相关
	 *
	 *******************************************/
	var hexcase = 1;
	var b64pad = "";
	var chrsz = 8;
	var mode = 32;
    var TEA = require("tea.js");
    var RSA = require("rsa.js");
		var base64 = require("base64.js");
	function md5(s){
		return hex_md5(s);
	}
	function hex_md5(s){
		return binl2hex(core_md5(str2binl(s), s.length * chrsz));
	}

	function str_md5(s){
		return binl2str(core_md5(str2binl(s), s.length * chrsz));
	}
	function hex_hmac_md5(key, data){
		return binl2hex(core_hmac_md5(key, data));
	}
	function b64_hmac_md5(key, data){
		return binl2b64(core_hmac_md5(key, data));
	}
	function str_hmac_md5(key, data){
		return binl2str(core_hmac_md5(key, data));
	}
	function core_md5(x, len){
		x[len >> 5] |= 0x80 << ((len) % 32);
		x[(((len + 64) >>> 9) << 4) + 14] = len;

		var a = 1732584193;
		var b =  - 271733879;
		var c =  - 1732584194;
		var d = 271733878;

		for (var i = 0; i < x.length; i += 16)  {
			var olda = a;
			var oldb = b;
			var oldc = c;
			var oldd = d;

			a = md5_ff(a, b, c, d, x[i + 0], 7,  - 680876936);
			d = md5_ff(d, a, b, c, x[i + 1], 12,  - 389564586);
			c = md5_ff(c, d, a, b, x[i + 2], 17, 606105819);
			b = md5_ff(b, c, d, a, x[i + 3], 22,  - 1044525330);
			a = md5_ff(a, b, c, d, x[i + 4], 7,  - 176418897);
			d = md5_ff(d, a, b, c, x[i + 5], 12, 1200080426);
			c = md5_ff(c, d, a, b, x[i + 6], 17,  - 1473231341);
			b = md5_ff(b, c, d, a, x[i + 7], 22,  - 45705983);
			a = md5_ff(a, b, c, d, x[i + 8], 7, 1770035416);
			d = md5_ff(d, a, b, c, x[i + 9], 12,  - 1958414417);
			c = md5_ff(c, d, a, b, x[i + 10], 17,  - 42063);
			b = md5_ff(b, c, d, a, x[i + 11], 22,  - 1990404162);
			a = md5_ff(a, b, c, d, x[i + 12], 7, 1804603682);
			d = md5_ff(d, a, b, c, x[i + 13], 12,  - 40341101);
			c = md5_ff(c, d, a, b, x[i + 14], 17,  - 1502002290);
			b = md5_ff(b, c, d, a, x[i + 15], 22, 1236535329);

			a = md5_gg(a, b, c, d, x[i + 1], 5,  - 165796510);
			d = md5_gg(d, a, b, c, x[i + 6], 9,  - 1069501632);
			c = md5_gg(c, d, a, b, x[i + 11], 14, 643717713);
			b = md5_gg(b, c, d, a, x[i + 0], 20,  - 373897302);
			a = md5_gg(a, b, c, d, x[i + 5], 5,  - 701558691);
			d = md5_gg(d, a, b, c, x[i + 10], 9, 38016083);
			c = md5_gg(c, d, a, b, x[i + 15], 14,  - 660478335);
			b = md5_gg(b, c, d, a, x[i + 4], 20,  - 405537848);
			a = md5_gg(a, b, c, d, x[i + 9], 5, 568446438);
			d = md5_gg(d, a, b, c, x[i + 14], 9,  - 1019803690);
			c = md5_gg(c, d, a, b, x[i + 3], 14,  - 187363961);
			b = md5_gg(b, c, d, a, x[i + 8], 20, 1163531501);
			a = md5_gg(a, b, c, d, x[i + 13], 5,  - 1444681467);
			d = md5_gg(d, a, b, c, x[i + 2], 9,  - 51403784);
			c = md5_gg(c, d, a, b, x[i + 7], 14, 1735328473);
			b = md5_gg(b, c, d, a, x[i + 12], 20,  - 1926607734);

			a = md5_hh(a, b, c, d, x[i + 5], 4,  - 378558);
			d = md5_hh(d, a, b, c, x[i + 8], 11,  - 2022574463);
			c = md5_hh(c, d, a, b, x[i + 11], 16, 1839030562);
			b = md5_hh(b, c, d, a, x[i + 14], 23,  - 35309556);
			a = md5_hh(a, b, c, d, x[i + 1], 4,  - 1530992060);
			d = md5_hh(d, a, b, c, x[i + 4], 11, 1272893353);
			c = md5_hh(c, d, a, b, x[i + 7], 16,  - 155497632);
			b = md5_hh(b, c, d, a, x[i + 10], 23,  - 1094730640);
			a = md5_hh(a, b, c, d, x[i + 13], 4, 681279174);
			d = md5_hh(d, a, b, c, x[i + 0], 11,  - 358537222);
			c = md5_hh(c, d, a, b, x[i + 3], 16,  - 722521979);
			b = md5_hh(b, c, d, a, x[i + 6], 23, 76029189);
			a = md5_hh(a, b, c, d, x[i + 9], 4,  - 640364487);
			d = md5_hh(d, a, b, c, x[i + 12], 11,  - 421815835);
			c = md5_hh(c, d, a, b, x[i + 15], 16, 530742520);
			b = md5_hh(b, c, d, a, x[i + 2], 23,  - 995338651);

			a = md5_ii(a, b, c, d, x[i + 0], 6,  - 198630844);
			d = md5_ii(d, a, b, c, x[i + 7], 10, 1126891415);
			c = md5_ii(c, d, a, b, x[i + 14], 15,  - 1416354905);
			b = md5_ii(b, c, d, a, x[i + 5], 21,  - 57434055);
			a = md5_ii(a, b, c, d, x[i + 12], 6, 1700485571);
			d = md5_ii(d, a, b, c, x[i + 3], 10,  - 1894986606);
			c = md5_ii(c, d, a, b, x[i + 10], 15,  - 1051523);
			b = md5_ii(b, c, d, a, x[i + 1], 21,  - 2054922799);
			a = md5_ii(a, b, c, d, x[i + 8], 6, 1873313359);
			d = md5_ii(d, a, b, c, x[i + 15], 10,  - 30611744);
			c = md5_ii(c, d, a, b, x[i + 6], 15,  - 1560198380);
			b = md5_ii(b, c, d, a, x[i + 13], 21, 1309151649);
			a = md5_ii(a, b, c, d, x[i + 4], 6,  - 145523070);
			d = md5_ii(d, a, b, c, x[i + 11], 10,  - 1120210379);
			c = md5_ii(c, d, a, b, x[i + 2], 15, 718787259);
			b = md5_ii(b, c, d, a, x[i + 9], 21,  - 343485551);

			a = safe_add(a, olda);
			b = safe_add(b, oldb);
			c = safe_add(c, oldc);
			d = safe_add(d, oldd);
		}
		if (mode == 16) {
			return Array(b, c);
		}else{
			return Array(a, b, c, d);
		}
	}
	function md5_cmn(q, a, b, x, s, t){
		return safe_add(bit_rol(safe_add(safe_add(a, q), safe_add(x, t)), s), b);
	}
	function md5_ff(a, b, c, d, x, s, t){
		return md5_cmn((b & c) | ((~b) & d), a, b, x, s, t);
	}
	function md5_gg(a, b, c, d, x, s, t){
		return md5_cmn((b & d) | (c & (~d)), a, b, x, s, t);
	}
	function md5_hh(a, b, c, d, x, s, t){
		return md5_cmn(b ^ c ^ d, a, b, x, s, t);
	}
	function md5_ii(a, b, c, d, x, s, t){
		return md5_cmn(c ^ (b | (~d)), a, b, x, s, t);
	}
	function core_hmac_md5(key, data){
		var bkey = str2binl(key);
		if (bkey.length > 16)
			bkey = core_md5(bkey, key.length * chrsz);

		var ipad = Array(16), opad = Array(16);
		for (var i = 0; i < 16; i++){
			ipad[i] = bkey[i] ^ 0x36363636;
			opad[i] = bkey[i] ^ 0x5C5C5C5C;
		}

		var hash = core_md5(ipad.concat(str2binl(data)), 512+data.length * chrsz);
		return core_md5(opad.concat(hash), 512+128);
	}
	function safe_add(x, y){
		var lsw = (x & 0xFFFF) + (y & 0xFFFF);
		var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
		return (msw << 16) | (lsw & 0xFFFF);
	}
	function bit_rol(num, cnt){
		return (num << cnt) | (num  >>> (32-cnt));
	}
	function str2binl(str){
		var bin = Array();
		var mask = (1 << chrsz) - 1;
		for (var i = 0; i < str.length * chrsz; i += chrsz)
			bin[i >> 5] |= (str.charCodeAt(i / chrsz) & mask) << (i % 32);
		return bin;
	}
	function binl2str(bin){
		var str = "";
		var mask = (1 << chrsz) - 1;
		for (var i = 0; i < bin.length * 32; i += chrsz)
			str += String.fromCharCode((bin[i >> 5] >>> (i % 32)) & mask);
		return str;
	}
	function binl2hex(binarray){
		var hex_tab = hexcase ? "0123456789ABCDEF" : "0123456789abcdef";
		var str = "";

		for (var i = 0; i < binarray.length * 4; i++){
			str += hex_tab.charAt((binarray[i >> 2] >> ((i % 4) * 8+4)) & 0xF) +
				hex_tab.charAt((binarray[i >> 2] >> ((i % 4) * 8)) & 0xF);
		}
		return str;
	}
	function binl2b64(binarray){
		var tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
		var str = "";
		for (var i = 0; i < binarray.length * 4; i += 3){
			var triplet = (((binarray[i >> 2] >> 8 * (i % 4)) & 0xFF) << 16) | ((
				(binarray[i + 1 >> 2] >> 8 * ((i + 1) % 4)) & 0xFF) << 8) | ((binarray[i
				+ 2 >> 2] >> 8 * ((i + 2) % 4)) & 0xFF);
			for (var j = 0; j < 4; j++){
				if (i * 8+j * 6 > binarray.length * 32)
					str += b64pad;
				else
					str += tab.charAt((triplet >> 6 * (3-j)) & 0x3F);
			}
		}
		return str;
	}

	function hexchar2bin(str){
		var arr = [];
		for(var i=0;i<str.length;i=i+2){
			arr.push(String.fromCharCode(parseInt(str.substr(i,2),16)));
		}
		return arr.join('')
	}

	/**
	 * TEA(S2, H1 + SdkAppid +Accounttype + Identifier + VerifyCode)
	 * @param options = {pwd:xx, sdkAppid: xx, id: xx, vcode: xx, salt: xx}
	 * @param options.pwd 密码
	 * @param options.sdkAppid
	 * @param options.id identifier
	 * @param options.vcode verifycode
	 * @param options.salt
	 * @return {String} PtA1     返回的加密字符串
	 */
	function getEncPwd(options) {
		var vcode = options.vcode || "";
		var pwd = options.pwd || "";
		var h1 = md5(pwd),
			s2 = md5(hexchar2bin(h1) + options.salt),
			hexVcode = TEA.strToBytes(vcode.toUpperCase(), true),
			vcodeLen = Number(hexVcode.length/2).toString(16),
			hexId = TEA.strToBytes(options.id),
			idLen = Number(hexId.length/2).toString(16),
			hexAppid = Number(options.sdkAppid).toString(16),
			hexAcctype = Number(0).toString(16);

		while (vcodeLen.length < 2*2)
			vcodeLen = "0" + vcodeLen;
		while (idLen.length < 2*2)
			idLen = "0" + idLen;
		while (hexAppid.length < 4*2)
			hexAppid = "0" + hexAppid;
		while (hexAcctype.length < 4*2)
			hexAcctype = "0" + hexAcctype;

		TEA.initkey(s2);
		// 输入格式为十六进制字符串展示的二进制内容，如 "\x12\x34" => "1234"
		// 输出为十六进制字符串展示的二进制内容
		var saltPwd = TEA.encrypt(h1 + idLen + hexId + hexAppid + hexAcctype + vcodeLen + hexVcode);
		TEA.initkey(""); // reset key
		var pubKey = "00988f6fe99e3d7c72b8b8a1cc9563e9750f5815316de064b531a0bfaa4dd5c2a5ea1f0e9b6e87bbcd19f445a13afada991a8ef60b812c628019741e4337933fb68438d93b62a538da25884627d3d46e6c62a5a41d30a7167a3a1ce5f6ecc3353db98b14a04ce2f777f335223134a900caa74fa79d9ab2c20ce19aaac9c24a82c847fa2eed0704553f75e030d93aa721186576cf5c344015ddc384b6b37add7139531af060548be8060a4bb075cc842bb190343c7f5e0e0b03fe1ca46c29b0df0bec7345888028df47f71fe44a0bd9cb8aed6282c095a75c57b6a604600886744b2965138730b27cf7d173381f0e53523aa1ced6864c09f7cc4135d45c5d4cfcbd";
		return urlBase64(RSA.encrypt(hexchar2bin(saltPwd), pubKey, "10001"));
	}

	function getRSAH1(pwd) {
		pwd = pwd || randpwd();
		var h1 = md5(pwd);
		var pubKey = "00ccaa91239f0a10fae03522fe6fdc6194007809732b07cb89e04dee9b4fdb9186787659fdf308be6efbc8aa147ffd8b5e4d61aba8a7e40e08af759751e1acc207a3988ce381cca6dfac4c75af1acda8bb3c09dce7a3d43fc23c95eecf56ca0c0c7a7eaeb019c912877757fe23ab28ac7060ee5409da3f0b5f079901475b11ac7d6c5cea1e7bd26a324674878cc31094b62eb407247f3e7f2070bb76a919883eaa114b0a40ea1341bf99dfd131d77343fd113f3a294fc0e19d9cc06989b98a0c14677e589ac41dd414283a3cf7685089d92770e7fde43c6aa443f2822c52fdbba309ea819bea8e4c2f1fac03930081ffd5189de9f025e15c4a1c466b761ba8e7f3";
		return urlBase64(RSA.encrypt(hexchar2bin(h1), pubKey, "10001"));
	}

	function urlBase64(src) {
		src = base64.encode(hexchar2bin(src));
		return src.replace(/[\/\+=]/g, function(a) {return {'/':'-', '+':'*', '=':'_'}[a];});
	}

	function randpwd() {
		var base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		var pwd = "";
		for (var i=0; i<16; i++) {
			pwd += base[Math.round(Math.random() * 1000) % base.length]
		}

		return pwd;
	}
	return {
		getEncPwd: getEncPwd,
		getRSAH1: getRSAH1,
		md5: md5
	};
}();
