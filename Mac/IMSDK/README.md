## (English Click [here](#readme_en))
<a name="readme_cn"></a>

# TIM SDK （Mac）

## 下载地址

### 基础版
[最新 ImSDKForMac.framework 下载](https://im.sdk.qcloud.com/download/standard/5.1.62/TIM_SDK_Mac_latest_framework.zip)

### 增强版
[最新 ImSDKForMac_Plus.framework 下载](https://sdk-im-1252463788.cos.ap-hongkong.myqcloud.com/download/plus/6.0.1992/ImSDKForMac_Plus_6.0.1992.framework.zip)

### C接口版
[最新C接口下载](https://im.sdk.cloud.tencent.cn/download/plus/6.0.1992/cross_platform/ImSDK_Mac_C_6.0.1992.framework.zip)

### C++接口版
[最新C++接口下载](https://im.sdk.cloud.tencent.cn/download/plus/6.0.1992/cross_platform/ImSDK_Mac_CPP_6.0.1992.framework.zip)

## cocoaPods 集成
如果使用基础版 SDK，请您按照如下方式设置 Podfile 文件

```
source 'https://github.com/CocoaPods/Specs.git'
platform :macos, '10.10'

target 'TUIKitDemo' do
   pod 'TXIMSDK_Mac'

end

```

如果使用增强版 SDK，请您按照如下方式设置 Podfile 文件

```
source 'https://github.com/CocoaPods/Specs.git'
platform :macos, '10.10'

target 'TUIKitDemo' do
   pod 'TXIMSDK_Plus_Mac'

end

```

------------------------------
## (中文版本请参看[这里](#readme_cn))
<a name="readme_en"></a>


# TIM SDK (Mac)

## Download Links

### Basic Edition
[Latest ImSDKForMac.framework download](https://im.sdk.qcloud.com/download/standard/5.1.62/TIM_SDK_Mac_latest_framework.zip)

### Enhanced Edition
[Latest ImSDKForMac_Plus.framework download](https://sdk-im-1252463788.cos.ap-hongkong.myqcloud.com/download/plus/6.0.1992/ImSDKForMac_Plus_6.0.1992.framework.zip)

### C API edition
[Latest C API download](https://im.sdk.cloud.tencent.cn/download/plus/6.0.1992/cross_platform/ImSDK_Mac_C_6.0.1992.framework.zip)

### C++ API edition
[Latest C++ API download](https://im.sdk.cloud.tencent.cn/download/plus/6.0.1992/cross_platform/ImSDK_Mac_CPP_6.0.1992.framework.zip)

## CocoaPods Integration
If you are using the SDK basic edition, edit the Podfile as follows:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :macos, '10.10'

target 'TUIKitDemo' do
   pod 'TXIMSDK_Mac'

end

```

If you are using the SDK enhanced edition, edit the Podfile as follows:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :macos, '10.10'

target 'TUIKitDemo' do
   pod 'TXIMSDK_Plus_Mac'

end

```
