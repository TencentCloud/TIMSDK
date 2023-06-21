本文档主要介绍如何在别的工程中集成TUIVideoSeat组件

## 目录结构
```
TUIVideoSeat
├─ Resources               // 多人视频会议的视频UI所需的图片、国际化字符串资源文件夹
├─ Source                  // 多人视频会议的视频UI主要界面代码
└─ TUIVideoSeat.podspec   // TUIVideoSeat 组件 pod 接入文件
```

## 环境准备
iOS 12.0及更高。

## 运行示例

### 前提条件
您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。

### 申请 SDKAPPID 和 SECRETKEY
1. 登录实时音视频控制台，选择【开发辅助】>【[快速跑通Demo](https://console.cloud.tencent.com/trtc/quickstart)】。
2. 单击【立即开始】，输入您的应用名称，例如`TestTRTC`，单击【创建应用】。
<img src="https://main.qcloudimg.com/raw/169391f6711857dca6ed8cfce7b391bd.png" width="650" height="295"/>
3. 创建应用完成后，单击【我已下载，下一步】，可以查看 SDKAppID 和密钥信息。

### 开通移动直播服务
1. [开通直播服务并绑定域名](https://console.cloud.tencent.com/live/livestat) 如果还没开通，点击申请开通，之后在域名管理中配置推流域名和拉流域名
2. [获取SDK的测试License](https://console.cloud.tencent.com/live/license) 
3. [配置推拉流域名](https://console.cloud.tencent.com/live/domainmanage)

## 集成TUIVideoSeat
如果需要将 TUIVideoSeat 组件集成到自己的项目中，可按如下步骤接入

### 工程配置
1. 将 `TUIVideoSeat/Resources`、`TUIVideoSeat/Source`、`TUIVideoSeat/TUIVideoSeat.podspec` 模块导入到自己的工程中
2. 在项目的 `Podfile` 文件中添加我们的 TUIVideoSeat 模块

```
   pod 'TUIVideoSeat', :path => "../TUIVideoSeat/"
```

3. 打开Terminal（终端）进入到工程目录下执行`pod install`指令，等待完成。

### TUIVideoSeat使用
1. 直接创建 `TUIVideoSeatView`

```
  let videoSeatView = TUIVideoSeatView(frame: UIScreen.main.bounds, roomEngine: roomEngine, roomId: roomId)
```

2. 添加 `TUIVideoSeatView` 

```
  view.addSubview(videoSeatView)
```
[](id:ui.step4)

>?如果TUIRoomKit想要进行多人视频，必须导入TUIVideoSeat组件，否则无法使用视频功能。

## 问题答疑
1、我们官网文档[常见问题](https://cloud.tencent.com/document/product/454/7998)中整理了一些常见的问题，如果遇到相同的问题，可以参考上面的解决方案
2、可以加入我们的 TUIKIT 答疑群，在群里我们有专人进行答疑
