import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

class PrivacyAgreementPage extends StatefulWidget {
  const PrivacyAgreementPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PrivacyAgreementPageState();
}

class PrivacyAgreementPageState extends State {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        shadowColor: theme.weakDividerColor,
        elevation: 1,
        title: Text(
          imt("腾讯云即时通信IM"),
          style: TextStyle(fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: Colors.white,
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
                'https://web.sdk.qcloud.com/document/Tencent-IM-Privacy-Protection-Guidelines.html',
            javascriptMode: JavascriptMode.unrestricted),
      ),
    );
  }
}
