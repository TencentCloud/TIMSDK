[English](./README_EN.md) | 简体中文

# Flutter TUIKit Demo

TUIKit Demo 是基于 `TIMUIKit` 快速搭建的一套及时通信系统。

- ## 运行demo

```
flutter run --dart-define=SDK_APPID=xxxx（xxxx是你自己申请的sdkappID，记得删掉这个括号） --dart-define=ISPRODUCT_ENV=false
--dart-define=KEY=xxxx
```

- ### 若要使用vs的调试工具
请在launch.json中添加环境参数
```
"args": [
            "--dart-define=SDK_APPID=xxxx（xxxx是你自己申请的sdkappID）",
            "--dart-define=KEY=xxxx(xxx你自己的key)"
            "--dart-define=ISPRODUCT_ENV=false"
            
        ]
```

- ### 若要体验位置消息能力
请根据本文档申请AK并填入，即可在DEMO中体验LBS位置消息能力。

https://docs.qq.com/doc/DSVliWE9acURta2dL

若需接入LBS消息插件，请查看 https://pub.dev/packages/tim_ui_kit_lbs_plugin

