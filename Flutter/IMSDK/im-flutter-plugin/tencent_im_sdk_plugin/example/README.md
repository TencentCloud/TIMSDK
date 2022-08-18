# IM SDK Flutter API Example

为帮助您更好的理解IM SDK的各API，[我们提供了API Example](https://github.com/TencentCloud/TIMSDK/tree/master/Flutter/IMSDK/im-flutter-plugin/tencent_im_sdk_plugin/example)，演示各个API的调用及监听的触发。

如下命令进入API Example:

```shell
#clone 代码
git clone https://github.com/TencentCloud/TIMSDK.git

#进入flutter的demo目录
cd TIMSDK/Flutter/IMSDK/im-flutter-plugin/tencent_im_sdk_plugin/example

#安装依赖
flutter pub get
```

运行项目后，先在右上角录入App信息及测试用户信息。并在首页第一个卡片点击初始化和登录按钮，完成登录。

完成初始化和登录后，可在首页测试各项API及监听回调。

![wecom-temp-430533-d291e58410e1b8b8bfe355cc816abc43](https://tuikit-1251787278.cos.ap-guangzhou.myqcloud.com/wecom-temp-430533-d291e58410e1b8b8bfe355cc816abc43.jpg)

具体每个API的调用代码，可在 `lib/im` 文件夹内找到，您可参考其实现您的业务需求。

![20220705201305](https://tuikit-1251787278.cos.ap-guangzhou.myqcloud.com/20220705201305.png)