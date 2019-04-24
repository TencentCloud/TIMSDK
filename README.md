# TIMSDK
腾讯云通信IM服务

## 最新版本 4.3.81 @2019.04.24

**新功能**
- Android平台 补齐老版本 SDK 的好友黑名单功能，好友分组功能，以及加好友请求处理等关系链功能。

**iOS平台**
- 修复草稿箱添加消息元素crash的问题
- 修复某些账户在app卸载重装后拉取不到会话列表的问题
- 修复在登录的状态下usersig过期，不重启app的情况下会一直登录失败的问题
- 修复在登录的状态下usersig过期，发消息失败，收不到 usersig 过期回调的问题
- 修复修复群成员获取数量问题
- 优化请求超时（错误码6012）问题

**Android平台**
- 修复一处app主进程被杀后的报错问题
- 修复修复群成员获取数量问题
- 修复群自定义字段和群成员自定义字段的设置和获取问题
- 修复获取群信息超时后，没有onError回调出去的问题
- 修复某些账户在app卸载重装后拉取不到会话列表的问题
- 修复在登录的状态下usersig过期，不重启app的情况下会一直登录失败的问题
- 修复在登录的状态下usersig过期，发消息失败，收不到 usersig 过期回调的问题
- 修复消息乱序问题
- 优化请求超时（错误码6012）问题
- 更新关系链错误码
- TUIKit修复日期工具类出错的严重bug(github issue#75)
- TUIKit修改一处崩溃(github issue#86)
- TUIKit修复无权限时，使用SDK的一些问题
- TUIKit修复删除会话，删除消息，然后长按后的一些崩溃问题
- TUIKit修复popupwindow长驻不消失问题
- TUIKit修复消息重复问题
- TUIKit拦截发送空格空消息问题
- TUIKit修复删除会话后，未读消息未更新问题
- TUIKit修复发送消息最大字符限制问题
- TUIKit体验优化和修复若干数组越界问题

**Windows平台**
- 修复部分崩溃问题
- 优化请求超时（错误码6012）问题
- 修复某些账户在app卸载重装后拉取不到会话列表的问题
- 修复在登录的状态下usersig过期，不重启app的情况下会一直登录失败的问题
- 修复在登录的状态下usersig过期，发消息失败，收不到 usersig 过期回调的问题

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
