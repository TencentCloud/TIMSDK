# TIMSDK
腾讯云通信IM服务

## 最新版本 4.2.10 @2019.03.29

### iOS & Mac：
**新增：**

   新增好友增/删/查逻辑

  **bugfix：**

  1. 优化超时问题
  2. 优化自动登录逻辑
  3. 优化crash问题
  4. 优化偶现网络连接异常bug
  
### Android：

**bugfix：**

 1. 优化超时问题
 2. 优化自动登录逻辑
 3. 优化JNI泄漏问题
 4. 优化crash问题
 5. 优化偶现网络连接异常bug

### Windows：

**bugfix：**

  1. 优化超时问题
  4. 优化crash问题
  5. 优化偶现网络连接异常bug
  
### 跨平台C接口：
发布macOS、iOS、Android三个平台跨平台C接口库，目前跨平台C接口支持Windows、macOS、iOS、Android四个平台

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
