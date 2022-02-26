# TUIKit（Android）

## 最新增强版 6.0.1992 @2022.02.09 主题设置

> 自`6.0.1992 @2022.02.09`版本开始，支持自定义主题设置。
> 目前已内置主题风格有`TUIBaseLightTheme(轻量版)`、`TUIBaseLivelyTheme(活泼版)`、`TUIBaseSeriousTheme(严肃版)`

### 配置说明

1. 在内部组件通信模块`tuicore `(必要模块)，找到`src -> main -> (res-light、res-lively、res-serious) -> values -> xxx_styles.xml`目录中的三个样式文件并打开。

2. 分别为`TUIBaseLightTheme`、`TUIBaseLivelyTheme`、`TUIBaseSeriousTheme`添加父主题。

   ```xml
   <style name="TUIBaseLightTheme" parent="Theme.AppCompat.xxx">
   </style>
   <style name="TUIBaseLivelyTheme" parent="Theme.AppCompat.xxx">
   </style>
   <style name="TUIBaseSeriousTheme" parent="Theme.AppCompat.xxx">
   </style>
   ```

3. 在会话列表、聊天窗口、好友列表、音视频通话等几个基本的界面，为Activity设置Theme。

   ```xml
   <activity
   	android:theme="@style/TUIChatLightTheme"
   	android:name=".XXXActivity" />
   ```

## 下载地址

[最新 TUIChat 下载](https://im.sdk.cloud.tencent.cn/download/tuikit/6.0.1992/android/TUIChat.zip)

[最新 TUIConversation 下载](https://im.sdk.cloud.tencent.cn/download/tuikit/6.0.1992/android/TUIConversation.zip)

[最新 TUIContact 下载](https://im.sdk.cloud.tencent.cn/download/tuikit/6.0.1992/android/TUIContact.zip)

[最新 TUIGroup 下载](https://im.sdk.cloud.tencent.cn/download/tuikit/6.0.1992/android/TUIGroup.zip)

[最新 TUISearch 下载](https://im.sdk.cloud.tencent.cn/download/tuikit/6.0.1992/android/TUISearch.zip)

[最新 TUICalling 下载](https://im.sdk.cloud.tencent.cn/download/tuikit/6.0.1992/android/TUICalling.zip)

[最新 TUICore 下载](https://im.sdk.cloud.tencent.cn/download/tuikit/6.0.1992/android/TUICore.zip)

如果您遇到 TUIKit 的 Bug，欢迎提交  Pull Request，Merge 成功后我们会及时更新 TUIKit 库 。
