// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/src/cancel_account.dart';
import 'package:timuikit/src/provider/theme.dart';
import '../i18n/i18n_utils.dart';
import 'config.dart';
import 'package:provider/provider.dart';
import 'contactPage.dart';
import 'pages/privacy/privacy_webview.dart';

class About extends StatefulWidget{

  const About({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AboutState();


}

class AboutState extends State<About>{
  final V2TIMManager sdkInstance = TIMUIKitCore.getSDKInstance();
  String sdkVersion = "null";

  Widget aboutItem(String text, Function onClick, [String? rightText]){
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
            Color(int.parse('ededed', radix: 16)).withAlpha(255),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          onClick();
        },
        child: TIMUIKitOperationItem(
          operationName: imt(text),
          isRightIcon: !(rightText != null && rightText.isNotEmpty),
          operationRightWidget: Text(rightText ?? ""),
        ),
      ),
    );
  }

  void getSDKVersion() async {
    final versionValue = await sdkInstance.getVersion();
    setState(() {
      sdkVersion = versionValue.data ?? "null";
    });
  }

  @override
  void initState() {
    getSDKVersion();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        shadowColor: theme.weakDividerColor,
        elevation: 1,
        title: Text(
            imt("关于腾讯云 · IM"),
          style: const TextStyle(fontSize: IMDemoConfig.appBarTitleFontSize),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
              theme.primaryColor ?? CommonColor.primaryColor
            ]),
          ),
        ),
      ),
      body: Column(
        children: [
          aboutItem( "SDK版本号", (){}, sdkVersion),
          aboutItem( "应用版本号", (){}, IMDemoConfig.appVersion),
          const SizedBox(
            height: 12,
          ),
          aboutItem( "隐私政策", (){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PrivacyDocument(
                        title: imt("隐私政策"),
                        url:
                        "https://privacy.qq.com/document/preview/1cfe904fb7004b8ab1193a55857f7272")));
          }),
          aboutItem( "用户协议", (){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PrivacyDocument(
                        title: imt("用户协议"),
                        url:
                        "https://web.sdk.qcloud.com/document/Tencent-IM-User-Agreement.html")));
          }),
          aboutItem( "免责声明", (){
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(imt("免责声明")),
                  content: Text(imt(
                      "IM即时通信（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。")),
                  actions: <Widget>[
                    TextButton(
                      child: Text(imt("取消")),
                      onPressed: () => Navigator.of(context).pop(), // 关闭对话框
                    ),
                    TextButton(
                      child: Text(imt("确定")),
                      onPressed: () {
                        //关闭对话框并返回true
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                );
              },
            );
          }),
          const SizedBox(
            height: 12,
          ),
          aboutItem( "信息收集清单", (){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PrivacyDocument(
                        title: imt("信息收集清单"),
                        url:
                        "https://privacy.qq.com/document/preview/45ba982a1ce6493597a00f8c86b52a1e")));
          }),
          aboutItem( "信息共享清单", (){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PrivacyDocument(
                        title: imt("信息共享清单"),
                        url:
                        "https://privacy.qq.com/document/preview/dea84ac4bb88454794928b77126e9246")));
          }),
          const SizedBox(
            height: 12,
          ),
          aboutItem( "注销账户", (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  CancelAccount(),
              ),
            );
          }),
          aboutItem( "联系我们", (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ContactPage(),
              ),
            );
          }),
        ],
      ),
    );
  }
}