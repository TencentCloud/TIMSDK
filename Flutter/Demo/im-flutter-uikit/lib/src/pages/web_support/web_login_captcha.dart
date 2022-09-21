

import 'package:flutter/material.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/src/pages/web_support/webview/tim_webview.dart'
  if(dart.library.html) 'package:timuikit/src/pages/web_support/webview/tim_webview_web_implement.dart';
import 'package:timuikit/utils/toast.dart';

enum CaptchaStatus { unReady, loading, ready }

class WebLoginCaptcha extends StatefulWidget {
  const WebLoginCaptcha({Key? key, required this.onSuccess, required this.onClose})
      : super(key: key);
  final void Function(dynamic obj) onSuccess;
  final void Function() onClose;

  @override
  _WebLoginCaptchaState createState() => _WebLoginCaptchaState();
}

class _WebLoginCaptchaState extends State<WebLoginCaptcha> {
  CaptchaStatus captchaStatus = CaptchaStatus.unReady;
  bool isClose = false;

  double getSize() {
    switch (captchaStatus) {
      case CaptchaStatus.unReady:
        return 0;
      case CaptchaStatus.loading:
        return 130;
      case CaptchaStatus.ready:
        return 260;
    }
  }

  @override
  build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        child: Center(
          child: SizedBox(
            width: getSize(),
            height: getSize(),
            child: TIMWebView(
              initialUrl: IMDemoConfig.webCaptchaUrl,
              width: getSize(),
              height: getSize(),
              webEventHandler: (name, body){
                switch (name){
                  case 'onLoading':
                    setState(() {
                      captchaStatus = CaptchaStatus.loading;
                    });
                    break;
                  case "onCaptchaReady":
                    setState(() {
                      captchaStatus = CaptchaStatus.ready;
                    });
                    break;
                  case "messageHandler":
                    try {
                      widget.onSuccess(body);
                    } catch (e) {
                      Utils.toast(imt("图片验证码校验失败"));
                    }
                    setState(() {
                      captchaStatus = CaptchaStatus.unReady;
                    });
                    if(!isClose){
                      isClose = true;
                      widget.onClose();
                    }
                    break;
                  case "capClose":
                    setState(() {
                      captchaStatus = CaptchaStatus.unReady;
                    });
                    if(!isClose){
                      isClose = true;
                      widget.onClose();
                    }
                    break;
                }
              },
            ),
          ),
        ));
  }
}
