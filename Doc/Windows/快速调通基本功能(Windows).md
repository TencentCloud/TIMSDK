本文主要介绍腾讯云 Im SDK 的几个最基本功能的使用方法，阅读此文档有助于您对 IM 的基本使用流程有一个简单的认识。

## 初始化

- 在使用 SDK 进行云通信操作之前，需要初始 SDK。

**示例：**
```c
int sdk_app_id = 12345678;
std::string json_init_cfg;
Json::Value json_value_dev;
json_value_dev[kTIMDeviceInfoDevId] = "12345678";
json_value_dev[kTIMDeviceInfoPlatform] = TIMPlatform::kTIMPlatform_Windows;
json_value_dev[kTIMDeviceInfoDevType] = "";

Json::Value json_value_init;
json_value_init[kTIMSdkConfigLogFilePath] = path;
json_value_init[kTIMSdkConfigConfigFilePath] = path;
json_value_init[kTIMSdkConfigAccountType] = "107";
json_value_init[kTIMSdkConfigDeviceInfo] = json_value_dev;

TIMInit(sdk_app_id, json_value_init.toStyledString().c_str());
```
- sdkAppId 可以在云通讯 [控制台](https://console.cloud.tencent.com/avc) 创建应用后获取到。


**更多初始化操作请参考 [初始化](https://cloud.tencent.com/document/product/269/1581)**

## 登录/登出
### 登录
- 用户登录腾讯后台服务器后才能正常收发消息，登录需要用户提供`identifier`、`userSig`。详细请参阅 [帐号登录集成说明](https://cloud.tencent.com/document/product/269/1507)。
- 登录为异步过程，通过回调函数返回是否成功，成功后方能进行后续操作。登录成功或者失败会主动调用提供的回调。

**示例：**

```c
const void* user_data = nullptr; // 回调函数回传
const char* id = "WIN01"; 
const char* user_sig = "WIN01UserSig";
TIMLogin(id, user_sig, [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
    if (code != ERR_SUCC) {
        // 登入失败
        return;
    }
    //登入成功
    
}, user_data);
```

> code表示错误码，具体可参阅 [错误码](https://cloud.tencent.com/document/product/269/1671)，desc表示错误描述。

**onForceOffline**

如果此用户在其他终端被踢，登录将会失败，返回错误码（`ERR_IMSDK_KICKED_BY_OTHERS：6208`），如果用户被踢了，请务必用 Alert 等提示窗提示用户，关于被踢的详细描述，参见 [用户状态变更](https://cloud.tencent.com/document/product/269/1581#.E7.94.A8.E6.88.B7.E7.8A.B6.E6.80.81.E5.8F.98.E6.9B.B4)。


**onUserSigExpired**
每一个 userSig 都有一个过期时间，如果 userSig 过期，`login` 将会返回 `70001` 错误码，如果您收到这个错误码，可以向您的业务服务器重新请求新的 userSig，参见 [用户状态变更](https://cloud.tencent.com/document/product/269/1581#.E7.94.A8.E6.88.B7.E7.8A.B6.E6.80.81.E5.8F.98.E6.9B.B4)。


### 登出
如用户主动注销或需要进行用户的切换，则需要调用注销操作。

**示例：**

```c
const void* user_data = nullptr; // 回调函数回传
TIMLogout([](int32_t code, const char* desc, const char* json_param, const void* user_data) { 
    if (code != ERR_SUCC) { 
        // 登出失败
        return;
    }
    // 登出成功
    
}, user_data);
```

> !在需要切换帐号时，需要 `Logout` 回调成功或者失败后才能再次 `Login`，否则 `Login` 可能会失败。


**更多登录/登出操作请参考 [登录](https://cloud.tencent.com/document/product/269/1590)**

## 消息发送

### 通用消息发送

#### 会话获取

会话是指面向一个人或者一个群组的对话，通过与单个人或群组之间会话收发消息，发消息时首先需要先获取会话，获取会话需要指定会话类型（群组或者单聊），以及会话对方标志（对方帐号或者群号）。


**获取对方 `identifier` 为『Windows-02』的单聊会话示例： **

```c
const void* user_data = nullptr; // 回调函数回传
const char* userid = "Windows-02";
int ret = TIMConvCreate(userid, kTIMConv_C2C, [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
    // 回调返回会话的具体信息
}, user_data);
if (ret != TIM_SUCC) {
    // 调用 TIMConvCreate 接口失败
}
```

**获取群组 ID 为『Windows-Group-01』的群聊会话示例：** 
```c
const void* user_data = nullptr; // 回调函数回传
const char* groupid = "Windows-Group-01";
int ret = TIMConvCreate(groupid, kTIMConv_Group, [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
    // 回调返回会话的具体信息
}, user_data);
if (ret != TIM_SUCC) {
    // 调用 TIMConvCreate 接口失败
}
```


#### 消息发送

 ImSDK 中的消息由 `TIMMessage` 表示， 每个 `TIMMessage` 由多个 `TIMElem` 组成，每个 `TIMElem` 单元可以是文本，也可以是图片，也就是说每一条消息可包含多个文本、多张图片、以及其他类型的单元。

![](https://main.qcloudimg.com/raw/2841a6842e0f46d2ac71eae1e5a13e05.png)

**示例：**

```c
const void* user_data = nullptr; // 回调函数回传
Json::Value json_value_text;
json_value_text[kTIMElemType] = kTIMElem_Text;
json_value_text[kTIMTextElemContent] = "Message Send to Windows-02";
Json::Value json_value_msg;
json_value_msg[kTIMMsgElemArray].append(json_value_text);

const char* userid = "Windows-02";
int ret = TIMMsgSendNewMsg(userid, kTIMConv_C2C, json_value_msg.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
    if (code != ERR_SUCC) { 
        // 发送消息成功失败
        return;
    }
    // 发送消息成功成功
    
}, user_data);
if (ret != TIM_SUCC) {
    // 调用 TIMMsgSendNewMsg 接口失败
}
```

## 消息接收
在多数情况下，用户需要感知新消息的通知，这时只需注册新消息监听回调 `TIMSetRecvNewMsgCallback`，在用户登录状态下，会拉取离线消息，为了不漏掉消息通知，需要在登录之前注册新消息监听回调。

**设置消息监听示例：**
```c
// 设置新消息监听器，收到新消息时，通过此监听器回调
const void *user_data = nullptr;
TIMSetRecvNewMsgCallback([](const char* json_msg_array, const void* user_data) {
    Json::Value json_value_msgs; // 解析消息
    Json::Reader reader;
    if (!reader.parse(json_msg_array, json_value_msgs)) {
        printf("reader parse failure!%s", reader.getFormattedErrorMessages().c_str());
        return;
    }
    for (Json::ArrayIndex i = 0; i < json_value_msgs.size(); i++) {  // 遍历Message
        Json::Value& json_value_msg = json_value_msgs[i];
        Json::Value& elems = json_value_msg[kTIMMsgElemArray];
        for (Json::ArrayIndex m = 0; m < elems.size(); m++) {   // 遍历Elem
            Json::Value& elem = elems[i];

            uint32_t elem_type = elem[kTIMElemType].asUInt();
            if (elem_type == TIMElemType::kTIMElem_Text) {  // 文本
                
            }else if (elem_type == TIMElemType::kTIMElem_Sound) {  // 声音
                
            } else if (elem_type == TIMElemType::kTIMElem_File) {  // 文件
                
            } else if (elem_type == TIMElemType::kTIMElem_Image) { // 图片
                
            }
        }
    }
    
}, user_data);
```

**更多消息收发操作请参考 [消息收发](https://cloud.tencent.com/document/product/269/1587)**

## 群组管理

IM 云通讯有多种群组类型，其特点以及限制因素可参考 [群组系统](https://cloud.tencent.com/document/product/269/1502#.E7.BE.A4.E7.BB.84.E5.BD.A2.E6.80.81.E4.BB.8B.E7.BB.8D)，群组使用唯一 ID 标识，通过群组 ID 可以进行不同操作，其中群组相关操作都由 `TIMGroupManager` 实现，需要用户登录成功后操作。

|             类型              | 说明                                                         |
| :---------------------------: | :----------------------------------------------------------- |
|       私有群（Private）       | 适用于较为私密的聊天场景，群组资料不公开，只能通过邀请的方式加入，类似于微信群。 |
|       公开群（Public）        | 适用于公开群组，具有较为严格的管理机制、准入机制，类似于 QQ 群。 |
|      聊天室（ChatRoom）       | 群成员可以随意进出。                                         |
|   直播聊天室（AVChatRoom）    | 与聊天室相似，但群成员人数无上限；支持以游客身份（不登录）接收消息。 |
| 在线成员广播大群（BChatRoom） | 适用于需要向全体在线用户推送消息的场景。                     |


### 创建群组

以下示例创建一个叫做"Windows-Group-01"公开群组，并且把用户『Windows_002』拉入群组。 
**示例：**

```c
Json::Value json_group_member_array(Json::arrayValue);
// 初始群成员
Json::Value json_group_member;
json_group_member[kTIMGroupMemberInfoIdentifier] = "Windows_002";
json_group_member[kTIMGroupMemberInfoMemberRole] = kTIMGroupMemberRoleFlag_Member;
json_group_member_array.append(json_group_member);

Json::Value json_value_createparam;
json_value_createparam[kTIMCreateGroupParamGroupId] = "Windows-Group-01";
json_value_createparam[kTIMCreateGroupParamGroupType] = kTIMGroup_Public;
json_value_createparam[kTIMCreateGroupParamGroupName] = "Windows-Group-Name";
json_value_createparam[kTIMCreateGroupParamGroupMemberArray] = json_group_member_array;

json_value_createparam[kTIMCreateGroupParamNotification] = "group notification";
json_value_createparam[kTIMCreateGroupParamIntroduction] = "group introduction";
json_value_createparam[kTIMCreateGroupParamFaceUrl] = "group face url";
json_value_createparam[kTIMCreateGroupParamMaxMemberCount] = 2000;
json_value_createparam[kTIMCreateGroupParamAddOption] = kTIMGroupAddOpt_Any;

const void* user_data = nullptr;
int ret = TIMGroupCreate(json_param.c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
    if (code != ERR_SUCC) { 
        // 创建群组失败
        return;
    }
    
    // 创建群组成功 解析Json获取创建后的GroupID
    
}, user_data))
```

**更多群组操作请参考 SDK 文档 [群组管理](https://cloud.tencent.com/document/product/269/1592)**

### 群组消息
群组消息与 C2C （单聊）消息相同，仅在发送时填写群组的ID和类型`kTIMConv_Group`，可参阅 SDK 文档 [消息发送](https://cloud.tencent.com/document/product/269/1587#.E6.B6.88.E6.81.AF.E5.8F.91.E9.80.81) 部分。
