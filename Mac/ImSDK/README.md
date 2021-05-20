# TIM SDK （Mac）

## 下载地址

### 标准版
[最新 ImSDKForMac.framework 下载](https://im.sdk.qcloud.com/download/standard/5.1.62/TIM_SDK_Mac_latest_framework.zip)

### 精简版
[最新 ImSDKForMac_Smart.framework 下载](https://im.sdk.qcloud.com/download/smart/5.3.435/ImSDKForMac_Smart_5.3.435.framework.zip)

## cocoaPods 集成
如果使用标准版 SDK，请您按照如下方式设置 Podfile 文件

```
source 'https://github.com/CocoaPods/Specs.git'
platform :macos, '10.10'

target 'TUIKitDemo' do
   pod 'TXIMSDK_Mac'

end

```

如果使用精简版 SDK，请您按照如下方式设置 Podfile 文件

```
source 'https://github.com/CocoaPods/Specs.git'
platform :macos, '10.10'

target 'TUIKitDemo' do
   pod 'TXIMSDK_Smart_Mac'

end

```
