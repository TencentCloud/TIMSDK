English | [简体中文](./README.md)

The web demo is implemented based on the IM TUIKit. TUIKit provides features such as management of conversations, chats, groups, and profiles. With TUIkit, you can quickly build your own business logic.

## Demo UI

### Conversation management

| Initiate a Conversation | Conversation List | Manage the Conversation List |
| --- | --- | --- |
| [![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/search.png)](https://camo.githubusercontent.com/abb48b90448d4ec1c6ec449ad47697821d5d7f6c246caf6ae284c0bcb09e6f29/68747470733a2f2f71636c6f7564696d672e74656e63656e742d636c6f75642e636e2f7261772f30313831653232316264393936663935396139643530313637366130373539612e706e67) | ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/conversationList.png) | [![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/conversationManage.png)](https://camo.githubusercontent.com/08a3ba2375ca499388552089a882e541a3330b8ad63a639ebcb4ff9282bdec56/68747470733a2f2f71636c6f7564696d672e74656e63656e742d636c6f75642e636e2f7261772f61663634353263313166613563653537343162636262316461323138333564652e706e67) |

### Chat management

| Message List | Send Messages | Manage Group Chats |
| --- | --- | --- |
| ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/chat.png) | ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/chat-send.png) | ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/group-manage.png) |

### Group management

| Group Notifications | My Group Chats | Search for and Join a Group Chat |
| --- | --- | --- |
| ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/group-system.png) | ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/group-list.png) | ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/group-search.png) |

### Profile management

| Manage the Profile |
| --- |
| ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/profile.png) |

| Feature | Description |
| --- | --- |
| Conversation management | 1. Initiate a one-to-one or group chat. <br/>2. Display the conversation list. <br/>3. Manage the conversation list. |
| Chat management | 1. Display the message list. <br/>2. Send messages. <br/>3. Manage group chats. |
| Group management | 1. Display group notifications. <br/>2. Display and manage group chats that a user belongs to or owns. <br/>3. Search for and join a group chat. |
| Profile management | Display and update the profile. |

## Running the demo

### Step 1. Download the source code

Download the SDK and matching [demo source code](https://cloud.tencent.com/document/product/269/36887).

``` shell
# Run the code in CLI
git clone https://github.com/tencentyun/TIMSDK.git

# Go to the web project

cd TIMSDK/Web/Demo

# Install dependencies of the demo
yarn install

cd TIMSDK/Web/Demo/src/TUIKit

# Install dependencies of the TUIKit
yarn install
```

### Step 2. Initialize the demo

1. Open the project in the web directory, and find the `GenerateTestUserSig` file via the path /debug/GenerateTestUserSig.js.
2. Set required parameters in the `GenerateTestUserSig` file, where `SDKAppID` and `Key` can be obtained in the [IM console](https://console.cloud.tencent.com/im). Click the card of the target app to go to its basic configuration page. [![](https://qcloudimg.tencent-cloud.cn/raw/e435332cda8d9ec7fea21bd95f7a0cba.png)](https://camo.githubusercontent.com/20575292024f27b76db87d6688e57f16d38b579b249054466668b596975dd30e/68747470733a2f2f71636c6f7564696d672e74656e63656e742d636c6f75642e636e2f7261772f65343335333332636461386439656337666561323162643935663761306362612e706e67)
  
3. In the **Basic Information** area, click **Display key**, and copy and save the key information to the `GenerateTestUserSig` file. [![](https://main.qcloudimg.com/raw/e7f6270bcbc68c51595371bd48c40af7.png)](https://camo.githubusercontent.com/d3e2ecc55db7a3c14ba0ba84c7cb92e18618028006c6f7fa304ba5ef01f0b6be/68747470733a2f2f6d61696e2e71636c6f7564696d672e636f6d2f7261772f65376636323730626362633638633531353935333731626434386334306166372e706e67)
  

> ! In this document, the method to obtain `UserSig` is to configure a `SECRETKEY` in the client code. In this method, the `SECRETKEY` is vulnerable to decompilation and reverse engineering. Once your `SECRETKEY` is disclosed, attackers can steal your Tencent Cloud traffic. Therefore, **this method is only suitable for locally running a demo project and feature debugging**. The correct `UserSig` distribution method is to integrate the calculation code of `UserSig` into your server and provide an application-oriented API. When `UserSig` is needed, your application can send a request to the business server for a dynamic `UserSig`. For more information, see the "Calculating UserSig on the Server" section of [Generating UserSig](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig).

### Step 3. Launch the project

``` shell
# Launch the project
cd TIMSDK/Web/Demo
yarn serve
```

- [SDK API Documentation](https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html)
- [SDK Update Log](https://cloud.tencent.com/document/product/269/38492)
- [Demo Source Code](https://github.com/tencentyun/TIMSDK/tree/master/Web/Demo)