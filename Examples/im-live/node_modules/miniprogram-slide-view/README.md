# slide-view

小程序自定义组件

> 使用此组件需要依赖小程序基础库 2.2.1 以上版本，同时依赖开发者工具的 npm 构建。具体详情可查阅[官方 npm 文档](https://developers.weixin.qq.com/miniprogram/dev/devtools/npm.html)。

## 使用效果
![slide-view](./docs/slide-view.gif)
## 使用方法

1. 安装 slide-view

```
npm install --save miniprogram-slide-view
```

2. 在需要使用 slide-view 的页面 page.json 中添加 slide-view 自定义组件配置

```json
{
  "usingComponents": {
    "slide-view": "miniprogram-slide-view"
  }
}
```
3. WXML 文件中引用 slide-view

每一个 slide-view 提供两个`<slot>`节点，用于承载组件引用时提供的子节点。left 节点用于承载静止时 slide-view 所展示的节点，此节点的宽高应与传入 slide-view 的宽高相同。right 节点用于承载滑动时所展示的节点，其宽度应于传入 slide-view 的 slideWidth 相同。

``` xml
<slide-view class="slide" width="320" height="100" slideWidth="200">
  <view slot="left">这里是插入到组内容</view>
  <view slot="right">
    <view>标为已读</view>
    <view>删除</view>
  </view>
</slide-view>
```

**slide-view的属性介绍如下：**

| 属性名                   | 类型         | 默认值                    | 是否必须    | 说明                                        |
|-------------------------|--------------|---------------------------|------------|---------------------------------------------|
| width                   | Number       | 显示屏幕的宽度             | 是          | slide-view组件的宽度                        |
| height                  | Number       | 0                         | 是          | slide-view组件的高度                        |
| slide-width              | Number       | 0                         | 是          | 滑动展示区域的宽度（默认高度于slide-view相同）|


