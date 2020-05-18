- 项目说明

> 本项目为直播带货场景化demo，其中包含了腾讯云即时通信IM SDK以及直播带货场景化SDK [im-live-sells](https://www.npmjs.com/package/im-live-sells)的使用例子。

- 线上体验地址

<img src="https://main.qcloudimg.com/raw/17a62d60c914556479f2c188641fb2f0.png" alt="img" style="zoom:25%;" />

- 腾讯云官网文档
  - https://cloud.tencent.com/document/product/269/44527

- 项目启动

```javascript
//安装依赖
npm i
//开发环境启动
npm run dev
//生产环境启动
npm run build
```

- 项目配置

  - 修改小程序appid

  - 找到src/common/const.js目录，修改后台接口地址、以及腾讯云即时通信IM应用ID

  - 业务接口实现

    - getRoomList

    - getUser
    - wxRegister
    - getUserSig

> 注意：由于接口并未开源，所以开发者在运行项目时可能会报错，如遇到这种情况，着重留意项目中src/pages/room文件中的实现即可。里面包含了，直播带货场业务流程的实现以及sdk方法的调用。