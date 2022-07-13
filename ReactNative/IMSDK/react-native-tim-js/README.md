# Tencent IM SDK for React native
腾讯云官方`IM React Native SDK`, 可轻松集成聊天、会话、群组、资料管理能力，帮助您实现文字、图片、短语音、短视频等富媒体消息收发，全面满足通信需要。
## 安装
### NPM
```bash
npm install react-native-tim-js
```
### Yarn
```bash
yarn add react-native-tim-js
```
## 使用方法
### 前提条件
1. 您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 帐号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。
2. 参照 [创建并升级应用](https://cloud.tencent.com/document/product/269/32577) 创建应用，并记录好`SDKAppID`。

### 如何使用
```javascript
import { TencentImSDKPlugin } from 'react-native-tim-js';

// 获取IM实例
const timManger = TencentImSDKPlugin.v2TIMManager;

// 群组高级接口，包含了群组的高级功能，例如群成员邀请、非群成员申请进群等操作接口。
const groupManager = timManager.getGroupManager();

// 高级消息接口, 包含了创建消息，发送消息，获取历史消息等接口
const messageManager = timManager.getMessageManager();

// 关系链接口，包含了好友的添加和删除，黑名单的添加和删除等逻辑。
const friendshipManager = timManager.getFriendshipManager();

// 会话接口，包含了会话的获取，删除和更新的逻辑。
const conversationManager = timManager.getConversationManager();

// 离线推送接口
const offlinePushManager = timManager.getOfflinePushManager(); 

// 信令接口，包含
const signalingManager = timManager.getSignalingManager();

// 初始化SDK
const sdkAppID = 0; // 前提条件第二部申请的sdkAppID
const logLevel = LogLevelEnum.V2TIM_LOG_DEBUG;
await timManger.initSDK(sdkAppID, logLeve);

// 登录
const userID = 123456; // 用户登录ID
const userSig = "xxx"; // userSig 生成请参考 [UserSig 后台 API](https://cloud.tencent.com/document/product/269/32688)
timManger.login(userID, userSig);

// 发送第一条消息
const friendID = 456789; // 接收消息用户ID
const text = "Hello, Tencent IM";
timManger.sendC2CTextMessage(friendID, text);

// 登出
timManager.logout();

```
更多接口使用请参考[example]();

### 参考链接
- [腾讯云IM](https://cloud.tencent.com/product/im)
- [SDK for React Native Docs]()
