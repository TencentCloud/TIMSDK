import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyAgreementPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PrivacyAgreementPageState();
}

class PrivacyAgreementPageState extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('腾讯云即时通信IM'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromRGBO(14, 25, 44, 1),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: WebView(
            initialUrl:
                'https://web.sdk.qcloud.com/document/Tencent-IM-Privacy-Protection-Guidelines.html',
            javascriptMode: JavascriptMode.unrestricted),
      ),
    );
  }
}
