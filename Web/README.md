# TIMSDK Web Demo

## 一分钟跑通Demo

1. 下载源码到本地

3. 配置 `SDKAppID` 和 `SECRETKEY`，参考：[密钥获取方法](https://cloud.tencent.com/document/product/269/36838#.E6.AD.A5.E9.AA.A42.EF.BC.9A.E8.8E.B7.E5.8F.96.E5.AF.86.E9.92.A5.E4.BF.A1.E6.81.AF)

   2.1 打开 `/dist/debug/GenerateTestUserSig.js` 文件

   2.2 按图示填写相应配置后，保存文件

   ![配置SDKAppID和SECRETKEY](_doc/image/demo-init-1.png)

4. 建议使用 `Chrome` 浏览器打开 `/dist/index.html` 文件，即可预览。

## 开发运行

Web Demo 使用 `Vue` + `Vuex` + `Element-UI` 开发，你可以参考该 Demo 进行业务开发，也可以直接基于本Demo 进行二次开发。 

> 参考文档：
>
> - [TIMSDK 官方文档](https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/index.html)

### 目录结构

```
├───sdk/
│   ├───tim-js.js - tim sdk 文件，demo 中未使用，仅供自行集成使用
├───dist/  - 打包编译后的目录
├───public/ - 公共入口
│   ├───debug/ - 用于配置SDKAppID 和 SECRETKEY
│   └───index.html
├───src/ - 源码目录
│   ├───assets/ - 静态资源目录
│   ├───components/ - 组件目录
│   ├───store/ - Vuex Store 目录
│   ├───utils/ - 工具函数目录
│   ├───index.vue - 入口文件
│   ├───main.js - Vue 全局配置
│   └───tim.js - TIM SDK相关
├───_doc/ - 文档相关
├───.eslintignore - eslint 忽略配置
├───babel.config.js - babel 配置
├───package.json
├───README.md
└───vue.config.js - vue-cli@3 配置文件
```

### 准备工作

1. 准备好您的 `SDKAPPID` 和 `SECRETKEY`，获取方式参考：[密钥获取方法](https://cloud.tencent.com/document/product/269/36838#.E6.AD.A5.E9.AA.A41.EF.BC.9A.E5.88.9B.E5.BB.BA.E5.BA.94.E7.94.A8)

2. 搭建 [nodejs 环境](https://nodejs.org/zh-cn/) （建议安装 8.0 版本以上的 nodejs），选择官网推荐的安装包，安装即可

   安装完成后，打开命令行，输入以下命令：

   ```shell
   node -v
   ```

   如果上述命令输出相应的版本号，说明环境搭建完成。

### 启动流程

1. 克隆本仓库到本地

   ```shell
   # 命令行执行
   git clone https://github.com/tencentyun/TIMSDK.git

   # 进入 Web Demo 项目
   cd TIMSDK/H5
   ```

2. 配置 `SDKAppID` 和 `SECRETKEY`，参考：[密钥获取方法](https://cloud.tencent.com/document/product/269/36838#.E6.AD.A5.E9.AA.A42.EF.BC.9A.E8.8E.B7.E5.8F.96.E5.AF.86.E9.92.A5.E4.BF.A1.E6.81.AF)

   2.1 打开 `/public/debug/GenerateTestUserSig.js` 文件

   2.2 按图示填写相应配置后，保存文件

   ![配置SDKAppID和SECRETKEY](_doc/image/demo-init-1.png)

3. 启动项目

   ```shell
   # 同步依赖
   npm install
   # 启动项目
   npm start
   ```

   > 若同步依赖过程中出现问题，尝试切换 npm 源后重试。
   >
   > ```shell
   > # 切换 cnpm 源
   > npm config set registry http://r.cnpmjs.org/
   > ```

4. 浏览器中打开链接：http://localhost:8080/

### 注意事项

1. 避免在前端进行签名计算

   本 Demo 为了用户体验的便利，将 `userSig` 签发放到前端执行。若直接部署上线，会面临 `SECRETKEY` 泄露的风险。

   正确的 `userSig` 签发方式是将 `userSig` 的计算代码集成到您的服务端，并提供相应接口。在需要 `userSig` 时，发起请求获取动态 `userSig`。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig)。

### WebIM Demo Change Log

#### 2020/09/27

**Features**

- Web Demo 支持关系链
- SDK 版本更新至 2.14.0

#### 2020/04/06

**Features**

- Web Demo 支持消息合并转发
- SDK 版本更新至 2.10.1

#### 2020/03/11

**Features**

- Web Demo 支持自研 upload 插件

- Web Demo 群 @ 功能

#### 2020/12/04

**Features**

- Web Demo增加群直播功能

- Web Demo新增 1v1 和群语音视频通话,和native互通

#### 2020/10/22

**Features**

- SDK 版本更新，支持查询直播群在线人数，发送图片消息接入图片压缩

**BUG Fixes**

- 修复C2C 消息发送失败显示未读标示问题

#### 2020/7/3

**Features**

- SDK 版本更新至 2.7.6

#### 2020/7/3

**Features**

- SDK 版本更新至 2.7.5

**Changes**

- Web demo 更新群名称：好友工作群（Work）、陌生人社交群（Public）、临时会议群（Meeting）和直播群（AVChatRoom）

#### 2020/6/10

**Features**

- SDK 版本更新至 2.7.0，支持C2C已读回执功能
- Web demo C2C支持已读回执功能上报显示

**Changes**

- Web demo  登录页面增加直播电商解决方案入口

#### 2020/4/28

**Features**

- SDK 版本更新至 2.6.3，支持群组全体禁言和取消禁言
- Web demo 群组支持全体禁言和取消全体禁言的功能入口

**Changes**

- 监听 TIM.EVENT.NET_STATE_CHANGE ，添加网络状态变更提醒
- 废弃 TIM.EVENT.GROUP_SYSTEM_NOTICE_RECEIVED事件
- 用户入群、退群、发消息，优先展示其 nick 没有 nick 才用 userID

#### 2020/3/30

**Features**

- SDK 版本更新至 2.6.0, 支持收发视频消息
- Web demo 支持收发视频消息，可拖拽发送框发送或选取文件发送

**Change**

- 修改视频通话界面UI

**BUG Fixes**

- 修复撤回 C2C 消息通知在 web 多实例登录时的同步问题
- 修复大文件或空文件发送失败后无法第二次发送的问题

#### 2020/1/14

**Features**

- 支持 C2C 视频通话

**Change**

- 消息发送两分钟后，不展示撤回菜单

#### 2020/1/6

**Features**

- SDK 版本更新，支持消息撤回
- Web Demo增加消息撤回与重新编辑功能
- 账号被踢出时，给出原因提醒

#### 2019/12/13

**Features**

- 支持粘贴发送截图

**Change**

- 完善收到新消息时的通知处理
- 处理完【加群申请】后，将相应的通知删除

#### 2019/11/22

**Features**

- 支持地理位置消息的渲染
- 支持点击群消息头像查看详细资料
- 支持我的名片的展示和修改

**Change**

- 优化几处体验问题

#### 2019/11/01

**Change**

- 优化几处体验问题

**BUG Fixes**

- 修复删除群组会话后，会话又出现的问题
- 修复退出群组时，Demo 出现空白区域的问题

#### 2019/10/17

**Features**

- Web Demo 样式调整
- SDK 版本更新，支持接收视频消息
- 移除掷骰子功能，替换为使用评分

#### 2019/10/12

**Bug Fixes**

- 修复 React 框架下发图片消息失败的问题

#### 2019/09/21

**Bug Fixes**

- 修复收到新群系统通知事件名不正确的问题

#### 2019/09/06

**Bug Fixes**

- 修复 IE 下超长文本消息的显示超出会话框的问题
- 修复重发消息失败时无错误提示的问题


#### 2019/09/05

**Bug Fixes**

- 修复预览图片时，图片显示不正确的问题
- 修复点击群组列表时，群成员列表不更新的问题
- 解决修改个人资料时，报错的问题

#### 2019/12/19

**Feat**

- 添加trtc视频通话，基础流程跑通
