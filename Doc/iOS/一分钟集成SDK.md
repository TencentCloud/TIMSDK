
本文主要介绍如何快速地将腾讯云 IM SDK(iOS) 集成到您的项目中，只要按照如下步骤进行配置，就可以完成 SDK 的集成工作。

## 开发环境要求
- Xcode 9.0+。
- iOS 8.0 以上的 iPhone 或者 iPad 真机。
- 项目已配置有效的开发者签名。

## 集成 IM SDK
您可以选择使用 CocoaPods 自动加载的方式，或者先 [下载](https://github.com/tencentyun/TIMSDK) SDK 再将其导入到您当前的工程项目中。

### CocoaPods 自动加载
#### 1. 安装 CocoaPods
在终端窗口中输入如下命令（需要提前在 Mac 中安装 Ruby 环境）：
```
sudo gem install cocoapods
```

#### 2. 创建 Podfile 文件
进入项目所在路径输入以下命令行，之后项目路径下会出现一个 Podfile 文件。
```
pod init
```

#### 3. 编辑 Podfile 文件
编辑 Podfile 文件，按如下方式设置：

```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_iOS'
end
```

#### 4. 更新并安装 SDK
在终端窗口中输入如下命令以更新本地库文件，并安装 TXIMSDK：
```
pod install
```
或使用以下命令更新本地库版本：
```
pod update
```

pod 命令执行完后，会生成集成了 SDK 的 .xcworkspace 后缀的工程文件，双击打开即可。
>?若 pod 搜索失败，建议尝试更新 pod 的本地 repo 缓存。更新命令如下：
```
pod setup
pod repo update
rm ~/Library/Caches/CocoaPods/search_index.json
```

### 手动集成
#### 1. 从 [Github](https://github.com/tencentyun/TIMSDK) 下载 IM SDK 开发包，其中 SDK 所在的位置如下：
![](https://main.qcloudimg.com/raw/fcef4a413f6ed3a183f5f60947df1c6f.png)

- IMSDK.framework 为 IM SDK 的核心动态库文件。

| 包名 | 介绍 | 
| --- | --- |
| ImSDK.framework | IM 功能包 |

- TXLiteAVSDK_UGC.framework 是腾讯云短视频（UGC）SDK，用于实现云通信 IM 中的短视频收发能力，为可选组件。

| 包名 | 介绍 | 功能 |
| --- | --- | --- |
| TXLiteAVSDK_UGC.framework | 小视频录制、编辑能力扩展包 | 包含小视频录制功能、小视频编辑功能，详情请参阅 [短视频 SDK 文档](https://cloud.tencent.com/product/ugsv) |

#### 2. 创建工程
**创建一个新工程**：
![](//avc.qcloud.com/wiki2.0/im/imgs/20150928013356_56054.jpg)

**填入工程名**（例如：IMDemo）：

![](//avc.qcloud.com/wiki2.0/im/imgs/20150928013638_56711.jpg)

#### 3. 集成 IM SDK

**添加依赖库：**选中 IMDemo 的【Target】，在【General】面板中的 【Embedded Binaries】和【Linked Frameworks and Libraries】添加依赖库。

![](https://main.qcloudimg.com/raw/3a1cc30c280362be2d99058dde347d4f.png)

**添加依赖库：**
```
ImSDK.framework
```
>!需要在【Build Setting】-【Other Linker Flags】添加 `-ObjC`。

## 引用 IM SDK
项目代码中使用 SDK 有两种方式：
- 方式一： 在Xcode -> Build Setting -> Herader Search Paths 设置 ImSDK.framework/Headers 路径，在项目需要使用 SDK API 的文件里，直接引用头文件"ImSDK.h":
```
#import "ImSDK.h"
```

- 方式二：在项目需要使用 SDK API 的文件里，引入具体的头文件 < ImSDK/ImSDK.h >:
```
#import <ImSDK/ImSDK.h>
```
