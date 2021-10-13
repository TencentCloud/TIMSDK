# Android Support 迁移 AndroidX 指南

## 第一步
1. 将 build tools 更新到 3.2.0 或更高版本；
2. gradle 更新到 4.6 或更高版本；
3. `compileSdkVersion` 更新到 28 或更高版本；

**请确保各工具版本满足要求，否则可能无法进行迁移**

## 第二步
修改当前项目的 gradle.properties。

```
android.useAndroidX=true
android.enableJetifier=true
```

- android.useAndroidX=true 表示当前项目启用 AndroidX；
- android.enableJetifier=true 表示将依赖包也迁移到AndroidX 。如果取值为 false ,表示不迁移依赖包到AndroidX，但在使用依赖包中的内容时可能会出现问题，当然了，如果你的项目中没有使用任何三方依赖，那么，此项可以设置为 false；

## 第三步

点击 Refactor -> Migrate to AndroidX，如下图：

<img src="https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/migrate_to_androidx.png" width="400" height="418"/>

之后会出现提示，勾选是否需要备份zip，建议勾选，然后点击 Migrate 即可，如下图：

<img src="https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/migrate_comfirm.png" width="550" height="189"/>

studio会自动搜索项目需要修改的地方，只需跟修改项目名称一样，搜索完成后点击Do Refactor即可，如下图：

<img src="https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/do_refactor.png" width="550" height="218"/>

## 第四步
建议重启Android Studio，直接运行的话studio的缓存会报很多异常，如下图：

<img src="https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/invalidate_caches_restart.png" width="400" height="857"/>

## 第五步
重启之后我们发现所有依赖的地方都变成了 AndroidX 的依赖，布局文件也都变成了 AndroidX 的依赖。<font color='red'>但是遗憾的是 Java 文件中 import 导入类可能还没有变过来，需要手动将 import 也更改过来。这可能是 Android Studio 的 bug。</font>
