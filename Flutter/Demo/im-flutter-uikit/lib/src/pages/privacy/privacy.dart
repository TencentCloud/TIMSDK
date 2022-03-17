import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

class UserAgreementPage extends StatefulWidget {
  const UserAgreementPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => UserAgreementPateState();
}

class UserAgreementPateState extends State {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        shadowColor: theme.weakDividerColor,
        elevation: 1,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          imt("腾讯云即时通信IM"),
          style: const TextStyle(fontSize: 17),
        ),
        leading: IconButton(
          padding: const EdgeInsets.only(left: 16),
          icon: Image.asset(
            'images/arrow_back.png',
            package: 'tim_ui_kit',
            height: 34,
            width: 34,
          ),
          // 返回Home事件
          onPressed: () => {Navigator.pop(context)},
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
              theme.primaryColor ?? CommonColor.primaryColor
            ]),
          ),
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const WebView(
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
//         title: const Text(imt("腾讯云TRTC")),
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
