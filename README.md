# TIMSDK
腾讯云通信IM服务

## 最新版本 4.3.135 @2019.05.24

**iOS平台**

- 增加校验好友接口 checkFriends
- 增加 queryGroupInfo 接口获取本地数据
- 废弃 getGroupPublicInfo 接口，统一用 getGroupInfo 接口
- 修复消息列表包含已删除消息的问题
- 修复未登陆获取不了本地消息问题
- 修复最近联系人拉取数量及排序问题
- 修复群消息断网重连后的消息同步问题
- 修复短时间内接收大量消息时判重失效问题
- 修复重启程序后有概率再次收到同一条消息的问题
- 修复初始化和同步消息偶现异常问题
- 修复会话的 lastMsg 被删除引发的偶现异常问题
- 修复登录后 onRefreshConversation 回调两次且数据相同问题
- 修复 chatroom 获取不了入群前的历史消息问题
- 修复 TIMMessage 的 copyFrom 接口不生效的问题
- 修复 TIMGroupEventListener 监听收不到回调的问题
- 修复线上反馈的 Crash 问题
- 优化重连时连接请求
- 优化在不同网络下首次连接和海外接入点的质量
- 优化iOS切换WIFI时网络重连慢的问题


**Android平台**

- 增加校验好友接口 checkFriends
- 增加 queryGroupInfo 接口获取本地数据
- 废弃 getGroupDetailInfo 和 getGroupPublicInfo 接口，统一用 getGroupInfo 接口
- 修复消息列表包含已删除消息的问题
- 优化 modifyGroupOwner 和 getGroupMembersByFilter 回调问题
- 修复未登陆获取不了本地消息问题
- 修复最近联系人拉取数量及排序问题
- 修复群消息断网重连后的消息同步问题
- 修复短时间内接收大量消息时判重失效问题
- 修复重启程序后有概率再次收到同一条消息的问题
- 修复初始化和同步消息偶现异常问题
- 修复会话的 lastMsg 被删除引发的偶现异常问题
- 修复登录后 onRefreshConversation 回调两次且数据相同问题
- 修复 chatroom 获取不了入群前的历史消息问题
- 修复线上反馈的 Crash 问题
- 优化重连时连接请求
- 优化在不同网络下首次连接和海外接入点的质量



**Windows平台**

- 新增自定义字段数据上报
- 新增阅后即焚消息
- 新增消息撤回使用用例
- 修复设置上传文件偶现失败问题
- 修复消息列表包含已删除消息的问题
- 修复最近联系人拉取数量及排序问题
- 修复群消息断网重连后的消息同步问题
- 修复短时间内接收大量消息时判重失效问题
- 修复重启程序后有概率再次收到同一条消息的问题
- 修复会话的 lastMsg 被删除引发的偶现异常问题
- 修复初始化和同步消息偶现异常问题
- 发送消息，在发送成功的回调里面返回消息的json字符串
- TIMSetRecvNewMsgCallback 接口改为 TIMAddRecvNewMsgCallback 和 TIMRemoveRecvNewMsgCallback 接口
- 新增socks5代理服务器配置
- 优化重连时连接请求
- 优化在不同网络下首次连接和海外接入点的质量



## 如何只检出指定平台的代码？

- 检出 Android
```
git init TIM_Android
cd TIM_Android
git remote add origin https://github.com/tencentyun/TIMSDK.git
git config core.sparsecheckout true
echo "Android/*" >> .git/info/sparse-checkout
git pull origin master
```

- 检出 iOS
```
git init TIM_iOS
cd TIM_iOS
git remote add origin https://github.com/tencentyun/TIMSDK.git
git config core.sparsecheckout true
echo "iOS/*" >> .git/info/sparse-checkout
git pull origin master
```

- 检出 Mac
```
git init TIM_Mac
cd TIM_Mac
git remote add origin https://github.com/tencentyun/TIMSDK.git
git config core.sparsecheckout true
echo "Mac/*" >> .git/info/sparse-checkout
git pull origin master
```

- 检出 Windows
```
git init TIM_Windows
cd TIM_Windows
git remote add origin https://github.com/tencentyun/TIMSDK.git
git config core.sparsecheckout true
echo "Windows/*" >> .git/info/sparse-checkout
git pull origin master
```
