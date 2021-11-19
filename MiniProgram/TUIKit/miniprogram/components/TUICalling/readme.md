### TUICalling 组件接入说明

本文档主要介绍如何快速集成TUICalling，实现实时视频/语音通话。
    

## 目录结构

```
TUICalling
├─ component        // UI 组件
    ├─ calling      // 呼叫中 UI 组件
    └─ connected    // 通话中 UI 组件
├─ static         // UI icon 图片
├─ TRTCCalling    // TRTCCalling 逻辑文件
```

1. ##### 复制 TUICalling 到 components 文件

2. ##### 添加组件到对应page

```
{
  "usingComponents": {
    "TUICalling": "../../components/TUICalling/TUICalling",
}
```

1. ##### 使用组件

js文件

```
Page({
  /**
   * 页面的初始数据
   */
  data: {
    config: {
      sdkAppID: 0,
      userID: 0,
      userSig: '',
      type: 1,
      tim: null, // 参数适用于业务中已存在 TIM 实例，为保证 TIM 实例唯一性
    },
    userId: 1，//被呼叫的用户ID
  },


  /**
   * 生命周期函数--监听页面加载
   */
  onLoad: function (options) {
    	// 将初始化后到TUICalling实例注册到this.TUICalling中，this.TUICalling 可使用TUICalling所以方法功能。
   		this.TUICalling = this.selectComponent('#TUICalling-component');
   		//初始化TUICalling
   		this.TUICalling.init()
  },
   /**
   * 生命周期函数--监听页面卸载
   */
  onUnload() {
    this.TUICalling.destroyed()
  },
  
  call: function() {
   // 注：初始化完成后调用call方法
    this.TUICalling.call({ userID: this.data.userId, type:2})
  },
})
```

wxml文件

```
		<TUICalling 
      id="TUICalling-component"
      config="{{config}}"
    ></TUICalling>
```

TUICalling 属性

| 属性   | 类型   | 默认值 | 必填 | 说明                                                         |
| :----- | :----- | :----- | :--- | :----------------------------------------------------------- |
| id     | String |        | 是   | 绑定TRTCCalling的dom ID，可通过this.selectComponent(ID)获取实例 |
| config | Object |        | 是   | TRTCCalling初始化配置                                        |

config 参数

| 参数     | 类型   | 必填 | 说明                                                         |
| :------- | :----- | :--- | :----------------------------------------------------------- |
| sdkAppID | Number | 是   | 开通实时音视频服务创建应用后分配的 [SDKAppID](https://console.cloud.tencent.com/trtc/app)。 |
| userID   | String | 是   | 用户 ID，可以由您的帐号体系指定。                            |
| userSig  | String | 是   | 身份签名（即相当于登录密码），由 userID 计算得出，具体计算方法请参见 [如何计算 UserSig](https://cloud.tencent.com/document/product/647/17275)。 |
| type     | Number | 是   | 指定通话类型。1：语音通话，2：视频通话。                     |
| tim      | object | 否   | tim 参数适用于业务中已存在 TIM 实例，为保证 TIM 实例唯一性   |

### 组件方法

#### selectComponent()

您可以通过小程序提供的 `this.selectComponent()` 方法获取组件实例。

```
const TUICallingContext = this.selectComponent(ID)
```

#### call({userID, type})

进行某个 user 进行呼叫。

| 参数   | 含义                                              |
| :----- | :------------------------------------------------ |
| userID | 希望呼叫用户的 userID。                           |
| type   | 通话类型，type = 1：语音通话，type =2：视频通话。 |

```
let userID = 'test'
let type = 2
TUICallingContext.call({userID, type})
```

