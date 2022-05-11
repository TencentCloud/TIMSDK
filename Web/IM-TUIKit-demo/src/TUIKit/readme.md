## TUIKit 接入文档

1. 复制TUIKit文件到项目中；

2. 引用TUIKit 文件；
   
   ```
   import { TUICore } from './TUIKit';
   ```

3. 初始化TUICore；
   
   ```
   let options = {
    SDKAppID: 0, // 接入时需要将0替换为您的云通信应用的 SDKAppID
    tim: tim // tim 参数适用于业务中已存在 TIM 实例，为保证 TIM 实例唯一性
   };
   
   TUIKit = TUICore.init(config);
   ```

4. 将TUIComponents 挂载至 TUICore 上；
   
   ```
   方法一：按需加载
   import { TUIChat } from './TUIKit/TUIComponents';
   TUIKit.component(TUIChat.name, TUIChat.server);
   
   方法二：全量加载
   import { TUIComponents } from './TUIKit';
   TUIKit.use(TUIComponents);
   ```

5. 登录TUICore；
   
   ```
   let options = {
    userID: 'xxx', // 当前用户ID
    userSig:'xxx' // 当前用户签名
   };
   TUIKit.login();
   ```

6. 使用组件；
   
   ```
   <template>
       <TUIChat />
   </template>
   ```

## TUICore API 文档

### init({sdkAppId, tim})

TUICore 初始化；

```
import { TUICore } from './TUIKit';

let options = {
  SDKAppID: 0, // 接入时需要将0替换为您的云通信应用的 SDKAppID
  tim: tim // tim 参数适用于业务中已存在 TIM 实例，为保证 TIM 实例唯一性
};

TUIKit = TUICore.init(config);
```

| 参数       | 类型     | 含义                                             |
| -------- | ------ | ---------------------------------------------- |
| sdkAppId | number | 云通信应用的 SDKAppID                                |
| tim      | TIM    | TIM 实例（选填）tim 参数适用于业务中已存在 TIM 实例，为保证 TIM 实例唯一性 |

### login({userID,userSig})

登录TUICore；

```
let options = {
  userID: 'xxx', // 当前用户ID
  userSig:'xxx' // 当前用户签名
};
TUIKit.login();
```

| 参数      | 类型     | 含义                                                         |
| ------- | ------ | ---------------------------------------------------------- |
| userID  | string | 当前用户的 ID，字符串类型，只允许包含英文字母（a-z 和 A-Z）、数字（0-9）、连词符（-）和下划线（_）。 |
| userSig | string | 腾讯云设计的一种安全保护签名，获取方式请参见 如何计算及使用 UserSig。                    |

### getInstance()

获取TUICore实例；

```
TUIKit.getInstance()
```

### destroyed()

销毁TUICore实例；

```
TUIKit.destroyed()
```

### component(TUIName, TUIComponent)

组件挂载；

```
import { TUIChat } from './TUIKit/TUIComponents';

TUIKit.component(TUIChat.name, TUIChat.server);
```

| 参数           | 类型           | 含义     |
| ------------ | ------------ | ------ |
| TUIName      | string       | 挂载的组件名 |
| TUIComponent | TUIComponent | 挂载的组件  |

### use(TUIPlugin, options)

插件注入；

```
import { TUIComponents } from './TUIKit';

TUICore.use(TUIComponents);
```

| 参数        | 类型     | 含义        |
| --------- | ------ | --------- |
| TUIPlugin | string | 需要挂载模块的服务 |
| options   | any    | 其他参数（选填）  |

### setCommonStore

设置公共数据；

```
TUICore.setCommonStore(data);
```

| 参数   | 类型     | 含义      |
| ---- | ------ | ------- |
| data | object | 需要设置的数据 |

### setComponentStore

设置组件数据；

```
TUICore.setComponentStore(TUIName，data，updateCallback);
```

| 参数             | 类型       | 含义      |
| -------------- | -------- | ------- |
| TUIName        | sting    | 组件名称    |
| data           | object   | 需要设置的数据 |
| updateCallback | function | 数据更新回调  |

### storeCommonListener

监听公共数据

```
TUICore.setComponentStore(key，callback);
```

| 参数       | 类型       | 含义           |
| -------- | -------- | ------------ |
| key      | sting    | 需要监听的公共数据的名称 |
| callback | function | 数据更新回调       |
