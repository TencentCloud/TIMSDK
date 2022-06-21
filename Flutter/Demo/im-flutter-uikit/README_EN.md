# TUIKit Demo for Flutter

The TUIKit demo is a set of instant messaging system that can be quickly built based on `TIMUIKit`.

- ## Running the Demo

```
flutter run --dart-define=SDK_APPID=xxxx (xxxx is the sdkappID you have applied for; delete these parentheses and the content) --dart-define=ISPRODUCT_ENV=false
--dart-define=KEY=xxxx
```

- ### Using Visual Studio debugging tools
Add the following environment parameters in `launch.json`
```json
"args": [
            "--dart-define=SDK_APPID=xxxx (xxxx is the sdkappID you have applied for),
            "--dart-define=KEY=xxxx (xxxx is your key)"
            "--dart-define=ISPRODUCT_ENV=false"
            
        ]
```

