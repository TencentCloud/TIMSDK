# TIMSDK
腾讯云通信IM服务

## 最新版本 4.2.52 @2019.04.17

**新功能**

- 补齐老版本 SDK 的好友黑名单功能，好友分组功能，以及加好友请求处理等关系链功能。

**iOS平台**

- 优化 API 接口注释
- 修复群自定义字段和群成员自定义字段不生效的问题
- 优化 TIMMessage 获取 senderProfile 拿不到用户资料信息的问题
- 修复已读回执回调及状态问题
- 修复同步未读消息最新一条消息不回调问题
- 修复群消息偶尔收不到问题
- 修复login回包无法解密问题
- 增加ip连接和login信息统计上报
- 修复消息seq错误

**Android平台**
- 修复android的jni泄漏
- 修复群组成员角色错误问题
- 修复退群在加群后，群组消息撤回崩溃问题
- 修复TUIKit Demo表情不显示问题
- 修复群聊会话获取消息，第二页大概率获取重复消息问题
- 修复TUIKit Demo中的部分crash问题
- 优化 TIMMessage 获取 senderProfile 拿不到用户资料信息的问题
- 修复已读回执回调及状态问题
- 修复同步未读消息最新一条消息不回调问题
- 修复群消息偶尔收不到问题
- 修复login回包无法解密问题
- 增加ip连接和login信息统计上报
- 修复消息seq错误

**Windows平台**
- 优化 TIMMessage 获取 senderProfile 拿不到用户资料信息的问题
- 修复已读回执回调及状态问题
- 修复同步未读消息最新一条消息不回调问题
- 修复群消息偶尔收不到问题
- 修复login回包无法解密问题
- 增加ip连接和login信息统计上报
- 修复消息seq错误

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
