import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UserAgreementPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UserAgreementPateState();
}

class UserAgreementPateState extends State {
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
                'https://web.sdk.qcloud.com/document/Tencent-IM-User-Agreement.html',
            javascriptMode: JavascriptMode.unrestricted),
      ),
    );
  }
}

// class Test extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('腾讯云TRTC'),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Color.fromRGBO(14, 25, 44, 1),
//       ),
//       body: Container(
//         child: Text("akaksjks"),
//       ),
//     );
//   }
// }
