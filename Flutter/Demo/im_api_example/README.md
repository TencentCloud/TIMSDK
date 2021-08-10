# im_api_example
该项目用于构建Flutter api demo, 包含相关api 的使用方式，便于用户使用及测试。

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 如何使用
- 根据Flutter [官方文档](https://flutter.dev/docs/get-started/install)配置对应的环境.
- 运行该项目， 如何运行Flutter项目可参考[文档](https://flutter.dev/docs/get-started/codelab).
- 调用相关Api前请先配置`sdkappid`,`secret`,需到[腾讯云控制台](https://cloud.tencent.com/product/im)注册账号，并创建应用.
- 在基础模块中，初始化SDK(initSDK), 并且登录(login)。

## QA
- **如何设置自定义字段**

自定义字段为满足于用户更多的使用场景。IM提供了 `用户自定义字段`， `好友自定义字段`， `群自定义字段` 和 `群成员自定义字段`， 首先需要到控制台配置对应的自定义字段名，后可调用对应的API(`setSelfInfo`, `setGourpInfo`, `setGroupMemberInfo`, `setFriendInfo`)去设置该字段值.

由于创建用户自定义字段和好友自定义字段时，控制台会自动加上 `Tag_Profile_Custom_` 和 `Tag_SNS_Custom_` 前缀，当我们调用API 设置该值时，不需要加上该前缀。 例如在控制台好友自定义字段为`Tag_SNS_Custom_test`, 当我们调用API 时字段名只需要设置为`test` 即可。

