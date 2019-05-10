# TIMSDK
腾讯云通信IM服务

## 最新版本 4.3.118 @2019.05.10

iOS平台

- 增加 TIMFriendshipManager 类中的 querySelfProfile 和 queryUserProfile 接口（读取本地数据）
- 修复获取登录 getLoginUser 返回登录用户异常的问题
- 修复线上反馈的用户资料获取失败问题
- 修复重启 APP 后部分本地字段失效问题
- 修复消息删除后调用已读上报偶现异常的问题
- 修复线上反馈的 IM 群组问题
- 修复会话未读数问题
- 修复在线消息问题
- 修复消息重发偶现失效问题
- 修复本地票据过期导致持续重连问题
- 修复线上反馈的 Crash 问题
- 优化服务器连接策略
- 优化断网重连策略
- 优化服务器过载策略
- 优化心跳，减少不必要发包
- TUIKit 新增支持 CocoaPods 导入
- TUIKit 新增联系人界面
- TUIKit 新增好友添加界面
- TUIKit 新增黑名单界面
- TUIKit 新增好友搜索界面
- TUIKit 新增新朋友界面
- TUIKit 优化好友资料页：增加备注、黑名单、删除好友功能
- TUIKit 优化个人资料页：增加昵称、个人签名、生日、性别、所在地修改功能
- TUIKit 优化群列表置顶功能

Android平台

- 增加 TIMFriendshipManager 类中的 querySelfProfile 和 queryUserProfile 接口（读取本地数据）
- 增加获取好友信息中 addTime 字段
- 增加 x86 及 x86_64 架构支持
- 修复获取登录 getLoginUser 返回登录用户异常的问题
- 修复线上反馈的用户资料获取失败问题
- 修复重启 APP 后部分本地字段失效问题
- 修复消息删除后调用已读上报偶现异常的问题
- 修复线上反馈的 IM 群组问题
- 修复会话未读数问题
- 修复在线消息问题
- 修复消息重发偶现失效问题
- 修复本地票据过期导致持续重连问题
- 修复线上反馈的 Crash 问题
- 优化服务器连接策略
- 优化断网重连策略
- 优化服务器过载策略
- 优化心跳，减少不必要发包
- TUIKit 加入聊天置顶功能
- TUIKit 修改昵称和个性签名，资料页面显示昵称
- TUIKit 修复 Android 端接收到 iOS 端发送的表情包后无法显示出来问题
- TUIKit 修复未读消息红点数问题
- TUIKit 修复美图 M8 设备点击加号后显示操作界面有 UI 问题
- TUIKit 修复设置头像后，头像会被缩小，不能铺满 UI 问题
- TUIKit 修复登录，自动登录逻辑
- TUIKit 修复超过输入内容最大限制后导致的 ANR 问题 
- TUIKit 修复发送图片, 当在相册选择图片并预览模式的时候，点击【确定】，发送会没有反应问题
- TUIKit 修复聊天界面长按图片消息没有弹出删除和撤销的操作按钮
- TUIKit 优化和修复线上反馈的 crash 问题

Windows平台

- 修复获取登录 getLoginUser 返回登录用户异常的问题
- 修复线上反馈的用户资料获取失败问题
- 修复重启 APP 后部分本地字段失效问题
- 修复消息删除后调用已读上报偶现异常的问题
- 修复线上反馈的 IM 群组问题
- 修复会话未读数问题
- 修复在线消息问题
- 修复消息重发偶现失效问题
- 修复本地票据过期导致持续重连问题
- 修复线上反馈的 Crash 问题
- 优化服务器连接策略
- 优化断网重连策略
- 优化服务器过载策略
- 优化心跳，减少不必要发包



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
