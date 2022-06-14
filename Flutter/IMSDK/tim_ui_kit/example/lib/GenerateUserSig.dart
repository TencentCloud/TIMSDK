// ignore_for_file: file_names

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

/// 生成腾讯云即时通信测试用userSig
/// Generate userSig for Tencent Cloud instant messaging test
///
class GenerateTestUserSig {
  GenerateTestUserSig({required this.sdkappid, required this.key});
  int sdkappid;
  String key;

  /// 生成UserSig
  /// Generate UserSig
  ///
  String genSig({
    required String identifier,
    required int expire,
  }) {
    int currTime = _getCurrentTime();
    String sig = '';
    Map<String, dynamic> sigDoc = <String, dynamic>{};
    sigDoc.addAll({
      "TLS.ver": "2.0",
      "TLS.identifier": identifier,
      // ignore: unnecessary_this
      "TLS.sdkappid": this.sdkappid,
      "TLS.expire": expire,
      "TLS.time": currTime,
    });

    sig = _hmacsha256(
      identifier: identifier,
      currTime: currTime,
      expire: expire,
    );
    sigDoc['TLS.sig'] = sig;
    String jsonStr = json.encode(sigDoc);
    List<int>? compress = const ZLibEncoder().encode(utf8.encode(jsonStr));
    return _escape(content: base64.encode(compress));
  }

  int _getCurrentTime() {
    return (DateTime.now().millisecondsSinceEpoch / 1000).floor();
  }

  String _hmacsha256({
    required String identifier,
    required int currTime,
    int expire = 30 * 24 * 60 * 60,
  }) {
    int sdkappid = this.sdkappid;
    String contentToBeSigned =
        "TLS.identifier:$identifier\nTLS.sdkappid:$sdkappid\nTLS.time:$currTime\nTLS.expire:$expire\n";
    Hmac hmacSha256 = Hmac(sha256, utf8.encode(key));
    Digest hmacSha256Digest =
        hmacSha256.convert(utf8.encode(contentToBeSigned));
    return base64.encode(hmacSha256Digest.bytes);
  }

  String _escape({
    required String content,
  }) {
    return content
        .replaceAll('+', '*')
        .replaceAll('/', '-')
        .replaceAll('=', '_');
  }
}
