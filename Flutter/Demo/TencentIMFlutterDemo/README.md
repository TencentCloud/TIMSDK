# 腾讯云即时通信IM flutter demo

- #### 在腾讯云即时通信IM控制台创建应用
 使用Demo前请先配置`sdkappid`,`secret`,需到[腾讯云控制台](https://cloud.tencent.com/product/im)注册账号，创建应用.拿到所需的sdkappid和secret

- #### 运行demo

```
flutter run --dart-define=SDK_APPID=xxxx（xxxx是你自己申请的sdkappID，记得删掉这个括号） --dart-define=KEY=xxxx（xxxx是你自己申请的密钥,记得删掉这个括号）
```
如需使用手机验证码登陆请再添加：--dart-define=ISPRODUCT_ENV=true

PS:如您打算使用Xcode或者Android Studio直接执行项目，请直接修改环境变量，具体参考修改配置

- #### 修改配置（可选）

目录：/example/lib/utils/config
这里配置了环境变量，您也可以在这里把SDKAPPID和KEY写死（修改例子如下）这样就不用每次运行时增加环境变量参数，但若您的仓库是对公网的，还是建议通过添加变量的方式添加appid和key以保证安全性
  static const int sdkappid = int.fromEnvironment('SDK_APPID', defaultValue: 你的SDKAPPID(int));
  static const String key = String.fromEnvironment('KEY',defaultValue:"xxxxx（你的KEY）");
- ### 若要使用vs的调试工具
请在launch.json中添加环境参数
```
"args": [
            "--dart-define=SDK_APPID=xxxx（xxxx是你自己申请的sdkappID）",
            "--dart-define=KEY=xxxx（xxxx是你自己申请的密钥）"
        ]
```


- ### 常见问题
若出现白屏无法启动的情况，可能是SDK_APPID填写错误 请检查

PS: 因为现在人力不足，Demo这块一直没有时间优化实在不好意思啦（＞人＜；）～ 底层SDK是没什么问题的，我们一直在努力更新，改bug！ 现在主力在进行MAC端和windows端还有electron的工作，争取年底前IM实现全平台，还希望各位大佬理解支持呀(^人^)～
 

