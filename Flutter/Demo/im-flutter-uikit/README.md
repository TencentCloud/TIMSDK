# Flutter TUIKit Demo

TUIKit Demo 是基于 `TIMUIKit` 快速搭建的一套即使通信系统。

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
