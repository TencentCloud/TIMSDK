# discuss

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


- #### 运行demo

```
flutter run --dart-define=SDK_APPID=xxxx（xxxx是你自己申请的sdkappID，记得删掉这个括号） --dart-define=ISPRODUCT_ENV=false
--dart-define=PROJECT_TYPE=demo
```

PS:如您打算使用Xcode或者Android Studio直接执行项目，请直接修改环境变量，具体参考修改配置

- ### 若要使用vs的调试工具
请在launch.json中添加环境参数
```
"args": [
            "--dart-define=SDK_APPID=xxxx（xxxx是你自己申请的sdkappID）",
            "--dart-define=ISPRODUCT_ENV=false"
            "--dart-define=PROJECT_TYPE=demo"
        ]
```

PROJECT_TYPE：有两种
（1）demo 以demo的形式运行打包（多了通讯录bar）,不填写情况下默认为discord运行
（2）discord 以discord形式运行（无通讯录bar,个人设置略有不同）