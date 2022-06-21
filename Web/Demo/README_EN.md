English | [简体中文](./README.md)

The web demo is implemented based on the IM TUIKit. TUIKit provides features such as management of conversations, chats, groups, and profiles. With TUIkit, you can quickly build your own business logic.

## Demo UI

### Conversation management

| Initiate a Conversation | Conversation List                                                                  | Manage the Conversation List                                                         |
| ----------------------- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/intl/search.png)       | ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/intl/conversationList.png) | ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/intl/conversationManage.png) |

### Chat management

| Message List                                                           | Send Messages                                                               | Manage Group Chats                                                             |
| ---------------------------------------------------------------------- | --------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/intl/chat.png) | ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/intl/chat-send.png) | ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/intl/group-manage.png) |

### Group management

| Group Notifications                                                            | My Group Chats                                                               | Search for and Join a Group Chat                                               |
| ------------------------------------------------------------------------------ | ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/intl/group-system.png) | ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/intl/group-list.png) | ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/intl/group-search.png) |

### Profile management

| Manage the Profile                                                        |
| ------------------------------------------------------------------------- |
| ![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/intl/profile.png) |

| Feature                 | Description                                                                                                                                      |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Conversation management | 1. Initiate a one-to-one or group chat. <br/>2. Display the conversation list. <br/>3. Manage the conversation list.                             |
| Chat management         | 1. Display the message list. <br/>2. Send messages. <br/>3. Manage group chats.                                                                  |
| Group management        | 1. Display group notifications. <br/>2. Display and manage group chats that a user belongs to or owns. <br/>3. Search for and join a group chat. |
| Profile management      | Display and update the profile.                                                                                                                  |

## Running the demo

### Step 1. Download the source code

Download the SDK and matching [demo source code](https://cloud.tencent.com/document/product/269/36887).

```shell
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

2. Set required parameters in the `GenerateTestUserSig` file, where `SDKAppID` and `Key` can be obtained in the [IM console](https://console.cloud.tencent.com/im). Click the card of the target app to go to its basic configuration page. 
![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/intl/control.png)

3. In the **Basic Information** area, click **Display key**, and copy and save the key information to the `GenerateTestUserSig` file. 
![](https://web.sdk.qcloud.com/im/demo/TUIkit/document-image/intl/useSig.png)

> ! In this document, the method to obtain `UserSig` is to configure a `SECRETKEY` in the client code. In this method, the `SECRETKEY` is vulnerable to decompilation and reverse engineering. Once your `SECRETKEY` is disclosed, attackers can steal your Tencent Cloud traffic. Therefore, **this method is only suitable for locally running a demo project and feature debugging**. The correct `UserSig` distribution method is to integrate the calculation code of `UserSig` into your server and provide an application-oriented API. When `UserSig` is needed, your application can send a request to the business server for a dynamic `UserSig`. For more information, see the "Calculating UserSig on the Server" section of [Generating UserSig](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig).

### Step 3. Launch the project

```shell
# Launch the project
cd TIMSDK/Web/Demo
yarn serve
```

- [SDK API Documentation](https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html)
- [SDK Update Log](https://cloud.tencent.com/document/product/269/38492)
- [Demo Source Code](https://github.com/tencentyun/TIMSDK/tree/master/Web/Demo)
