import 'package:discuss/common/hextocolor.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyAgreementPage extends StatefulWidget {
  const PrivacyAgreementPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PrivacyAgreementPageState();
}

class PrivacyAgreementPageState extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        shadowColor: hexToColor("ececec"),
        elevation: 1,
        title: const Text(
          '腾讯云即时通信IM',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(14, 25, 44, 1),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const WebView(
            initialUrl:
                'https://web.sdk.qcloud.com/document/Tencent-IM-Privacy-Protection-Guidelines.html',
            javascriptMode: JavascriptMode.unrestricted),
      ),
    );
  }
}
