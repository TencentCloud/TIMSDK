English|[简体中文](./README_ZH.md)

## Introduction to TUIKit

Flutter TUIKit is a set of TUI components based on Flutter IM SDKs. It provides features such as the conversation, chat, relationship chain, and group features. You can use these TUI components to quickly build your own business logic. The architecture of Flutter TUIKit is as follows.
![img](https://qcloudimg.tencent-cloud.cn/raw/b336c1a482129254682d405e008fec01.png)

Currently, Flutter TUIKit contains the following components:

- [TIMUIKitCore](https://www.tencentcloud.com/document/product/1047/46297#timuikitcore) (core)
- [TIMUIKitConversation](https://www.tencentcloud.com/document/product/1047/46297#timuikitconversation) (conversations)
- [TIMUIKitChat](https://www.tencentcloud.com/document/product/1047/46297#timuikitchat) (chats)
- [TIMUIKitContact](https://www.tencentcloud.com/document/product/1047/46297#timuikitcontact) (contacts)
- [TIMUIKitProfile](https://www.tencentcloud.com/document/product/1047/46297#timuikitprofile) (friend management)
- [TIMUIKitGroupProfile](https://www.tencentcloud.com/document/product/1047/46297#timuikitgroupprofile) (group management)
- [TIMUIKitGroup](https://www.tencentcloud.com/document/product/1047/46297#timuikitgroup) (my group chats)
- [TIMUIKitBlackList](https://www.tencentcloud.com/document/product/1047/46297#timuikitblacklist) (blocklist)
- [TIMUIKitNewContact](https://www.tencentcloud.com/document/product/1047/46297#timuikitnewcontact) (new contacts)

![img](https://qcloudimg.tencent-cloud.cn/raw/8a59b20de79c7dc670f64ff0a6de8ecc.png)
For the source code of the project in the figure above, see [im-flutter-uikit](https://github.com/tencentyun/TIMSDK/tree/master/Flutter/Demo/im-flutter-uikit). The project is open source and can be used directly.

## Supported Platforms

- Android
- iOS

## Directions

The following describes how to use Flutter TUIKit to quickly build a simple IM app.

### Step 1. Create a Flutter app

Quickly create a Flutter app by referring to [Flutter documentation](https://flutter.cn/docs/get-started/test-drive?tab=terminal).

### Step 2. Install dependencies

Add `tim_ui_kit` under `dependencies` in the `pubspec.yaml` file, or run the following command:

```
// Step 1:
flutter pub add tim_ui_kit
// Step 2:
flutter pub get
```

### Step 3. Initialize TUIKit

Initialize `TIMUIKit` in `initState`. You only need to perform the initialization once for the project to start.

```dart
/// main.dart
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
void main() {
 runApp(MyApp());
}
class MyApp extends StatelessWidget {
 // This widget is the root of your application.
 @override
 Widget build(BuildContext context) {
   return MaterialApp(
     title: 'TIMUIKit Demo',
     theme: ThemeData(
       primarySwatch: Colors.blue,
     ),
     home: MyHomePage(title: 'TIMUIKit Demo'),
   );
 }
}
class MyHomePage extends StatefulWidget {
 MyHomePage({Key? key, required this.title}) : super(key: key);
 final String title;
  @override
 _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
 final CoreServicesImpl _coreInstance = TIMUIKitCore.getInstance();
  @override
 void initState() {
   _coreInstance.init(
     sdkAppID: 0, // SDKAppID obtained from the console
     loglevel: LogLevelEnum.V2TIM_LOG_DEBUG,
     listener: V2TimSDKListener());    
   super.initState();
 }
  @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text(widget.title),
     ),
     body: Container(),
   );
 }
}
```

### Step 4. Get the signature and log in

> Note：
>
> The correct `UserSig` distribution method is to integrate the calculation code of `UserSig` into your server and provide an application-oriented API. When `UserSig` is needed, your application can send a request to the business server for a dynamic `UserSig`. For more information, see [How do I calculate UserSig on the server?](https://www.tencentcloud.com/document/product/1047/34385).

Add two `TextField` fields to pass in `UserID` and `UserSig`. Click **Login** to call the login API.

```dart
/// main.dart
/// Omitted
class _MyHomePageState extends State<MyHomePage> {
 /// Get the TIMUIKitCore instance
 final CoreServicesImpl _coreInstance = TIMUIKitCore.getInstance();
 String userID = "";
 String userSig = "";
  /// Omitted
  void _login() {
   // Login
   _coreInstance.login(userID: userID, userSig: userSig);
 }
  @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text(widget.title),
     ),
     body: Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: <Widget>[
           TextField(
             onChanged: ((value) {
               setState(() {
                 userID = value;
               });
             }),
             decoration: InputDecoration(hintText: "userID"),
           ),
           TextField(
             onChanged: ((value) {
               setState(() {
                 userSig = value;
               });
             }),
             decoration: InputDecoration(hintText: "userSig"),
           ),
           ElevatedButton(
               onPressed: (() {
                 _login();
               }),
               child: const Text("Login"))
         ],
       ),
     ),
   );
 }
}
```

### Step 5. Integrate desired components

- Create the `message.dart` file to integrate `TIMUIKitConversation`, `TIMUIKitChat`, and more components as needed.

- Modify the code in

   

  ```
  main.dart
  ```

   

  to enable redirection to the specified page upon successful login.

  ```dart
  /// message.dart
  import 'package:flutter/material.dart';
  import 'package:tim_ui_kit/tim_ui_kit.dart';
  class Conversation extends StatelessWidget {
  const Conversation({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        "Message",
        style: TextStyle(color: Colors.black),
      ),
    ),
    body: TIMUIKitConversation(
      onTapItem: (selectedConv) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Chat(
                selectedConversation: selectedConv,
              ),
            ));
      },
    ),
  );
  }
  }
  class Chat extends StatelessWidget {
  final V2TimConversation selectedConversation;
  const Chat({Key? key, required this.selectedConversation}) : super(key: key);
  String? _getConvID() {
  return selectedConversation.type == 1
      ? selectedConversation.userID
      : selectedConversation.groupID;
  }
  @override
  Widget build(BuildContext context) {
  return TIMUIKitChat(
    conversationID: _getConvID() ?? '', // groupID or UserID
    conversationType: selectedConversation.type ?? 0, // Conversation type
    conversationShowName: selectedConversation.showName ?? "", // Conversation display name
    onTapAvatar: (_) {}, // Callback for the clicking of the message sender profile photo. This callback can be used with `TIMUIKitProfile`.
    appBarActions: [
      IconButton(
          onPressed: () {}, icon: const Icon(Icons.more_horiz_outlined))
    ],
  );
  }
  }
  /// main.dart
  /// Some code is omitted
  void _login() async {
  final res = await _coreInstance.login(userID: userID, userSig: userSig);
  if (res.code == 0) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (BuildContext context) => const Conversation()),
      (route) => false,
    );
  }
  }
  ```

### FAQs

#### 1. Do I need to integrate IM SDK after integrating TUIKit?

No. You don't need to integrate IM SDK again. If you want to use IM SDK related APIs, you can get them via `TIMUIKitCore.getSDKInstance()`. This method is recommended to ensure IM SDK version consistency.

#### 2. Why did force quit occur when I sent voice, image, file or other messages?

Check whether you have enabled the **camera**, **mic**, **album**, or other related permissions.