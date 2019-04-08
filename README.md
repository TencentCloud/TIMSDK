# TIMSDK
腾讯云通信IM服务

## 最新版本 4.2.28 @2019.04.08

### iOS：

  **bugfix：**

1，优化未读计数相关的问题
2，优化消息已读状态的问题
3，优化RESTAPI发的C2C消息排序异常的问题
4，优化获取漫游消息偶现重复的问题
5，优化uniqueId空实现的问题
  
### Android：

**新增：**

   新增好友增/删/查逻辑

**bugfix：**

1，优化未读计数相关的问题
2，优化消息已读状态的问题
3，优化RESTAPI发的C2C消息排序异常的问题
4，优化获取漫游消息偶现重复的问题
5，优化uniqueId空实现的问题

### Windows：

**bugfix：**

1，优化未读计数相关的问题
2，优化消息已读状态的问题
3，优化RESTAPI发的C2C消息排序异常的问题
4，优化获取漫游消息偶现重复的问题
  
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
