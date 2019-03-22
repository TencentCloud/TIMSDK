# TIMSDK
腾讯云通信IM服务

## 最新版本 4.2.2 @2019.03.22

### iOS：
**新增功能：**

1. SDK 新增用户资料逻辑
2. SDK 新增自动登录逻辑
3. SDK 新增错误码枚举类 TIMErrorCode.h
4. DEMO 新增推送设置示例代码

**bugfix：**

1. 修复OfflinePushInfo设置和获取无效的问题
2. 修复本地消息没有保存pushinfo中的descr和ext字段的问题
3. 修复调用setAPNS crash的问题
4. 修复TUIKit 偶现 crash的问题
5. 修复切换账号longloop偶现异常的问题
6. 修复消息重复检测偶现异常的问题

### Android：
**新增功能：**

1. SDK 新增用户资料逻辑
2. SDK 新增自动登录逻辑

**bugfix：**

1. 修复本地消息没有保存pushinfo中的descr和ext字段的问题
2. 修复切换账号longloop偶现异常的问题
3. 修复消息重复检测偶现异常的问题
4.  修复内存泄漏问题

### Windows:
修复切换账号longloop偶现异常的问题

## 检出 Android
```
git init TIM_Android
cd TIM_Android
git remote add origin https://github.com/tencentyun/TIMSDK.git
git config core.sparsecheckout true
echo "Android/*" >> .git/info/sparse-checkout
git pull origin master
```

## 检出 iOS
```
git init TIM_iOS
cd TIM_iOS
git remote add origin https://github.com/tencentyun/TIMSDK.git
git config core.sparsecheckout true
echo "iOS/*" >> .git/info/sparse-checkout
git pull origin master
```

## 检出 Mac
```
git init TIM_Mac
cd TIM_Mac
git remote add origin https://github.com/tencentyun/TIMSDK.git
git config core.sparsecheckout true
echo "Mac/*" >> .git/info/sparse-checkout
git pull origin master
```

## 检出 Windows
```
git init TIM_Windows
cd TIM_Windows
git remote add origin https://github.com/tencentyun/TIMSDK.git
git config core.sparsecheckout true
echo "Windows/*" >> .git/info/sparse-checkout
git pull origin master
```
