
本文主要介绍如何快速地将腾讯云 IMSDK 集成到您的项目中，只要按照如下步骤进行配置，就可以完成 SDK 的集成工作。

## 开发环境要求
- Xcode 9.0+
- OS X 10.10+ 的Mac真机
- 项目已配置有效的开发者签名

## 集成 IMSDK
您可以选择使用 CocoaPods 自动加载的方式，或者先下载 SDK 再将其导入到您当前的工程项目中。

### CocoaPods
#### 1. 安装 CocoaPods
在终端窗口中输入如下命令（需要提前在 Mac 中安装 Ruby 环境）
```
sudo gem install cocoapods
```

#### 2. 创建 Podfile 文件
进入项目所在路径，然后输入以下命令行，之后项目路径下会出现一个 Podfile 文件。
```
pod init
```

#### 3. 编辑 Podfile 文件
编辑 Podfile 文件，按如下方式设置：  

```
platform :macos, '10.10'
source 'https://github.com/CocoaPods/Specs.git'

target 'mac_test' do
pod 'TXIMSDK_Mac'
end
```

#### 4. 更新并安装 SDK
在终端窗口中输入如下命令以更新本地库文件，并安装 TXIMSDK_Mac：
```
pod install
```
或使用以下命令更新本地库版本:
```
pod update
```

pod命令执行完后，会生成集成了SDK的 .xcworkspace 后缀的工程文件，双击打开即可。

### 手动集成
#### 1. 从 [Git](https://github.com/tencentyun/TIMSDK) 下载 ImSDK 开发包，其中SDK所在的位置如下：
![](https://main.qcloudimg.com/raw/25a0fdc636ace72dc3cc22ce6531ee9b.png)

- ImSDKForMac.framework 为 IMSDK 的核心动态库文件。

| 包名 | 介绍 |  ipa增量 |
| --- | --- | --- |
| ImSDKForMac.framework | IM 功能包 | 1.4M|

#### 2. 创建一个新工程

![](https://main.qcloudimg.com/raw/7dd7a0f99893f52c63fd3144794a12cd.png)

**填入工程名：**

![](https://main.qcloudimg.com/raw/39f16307b69c8f0d766349e5ed201ef4.png)

#### 2. 集成 ImSDK

**添加依赖库：**选中 Demo 的【Target】，在【General】面板中的 【Embedded Binaries】和【Linked Frameworks and Libraries】添加依赖库。

![](https://main.qcloudimg.com/raw/440dd55e50d2fe52e1d83ed0aa4284be.png)

**添加依赖库：**
```
ImSDKForMac.framework
```
> **注意：**
>- 需要在【Build Setting】-【Other Linker Flags】添加 `-ObjC`。

## 引用 ImSDK
项目代码中使用 SDK 有两种方式：
- 方式一： 在Xcode -> Build Setting -> Herader Search Paths 设置ImSDKForMac.framework/Headers 路径，在项目需要使用SDK API的文件里，直接引用头文件"ImSDK.h"
```
#import "ImSDK.h"
```

- 方式二：在项目需要使用SDK API的文件里，引入具体的头文件 < ImSDKForMac/ImSDK.h >
```
#import <ImSDKForMac/ImSDK.h>
```
