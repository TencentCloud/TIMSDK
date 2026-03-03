# AtomicToast 轻量级提示组件

AtomicToast 是一个轻量级的 Android Toast 提示组件，基于系统 Toast 封装，提供了丰富的语义化样式和自定义选项。它遵循 AtomicX 设计系统，支持多种位置、样式和图标配置。

## 文件结构

```
toast/
├── AtomicToast.kt          # Toast 组件核心实现
└── README.md               # 本文件
```

## 快速开始

AtomicToast 采用单例模式设计，通过静态方法直接调用，无需创建实例。

### 1. 基础文本提示

最简单的文本提示，无图标。

```kotlin
AtomicToast.show(
    context = this,
    text = "这是一条提示信息"
)
```

### 2. 成功提示

带有成功图标的提示，适用于操作完成场景。

```kotlin
AtomicToast.show(
    context = this,
    text = "操作成功！",
    style = AtomicToast.Style.SUCCESS
)
```

### 3. 警告和错误提示

用于警告或错误场景，提供视觉上的区分。

```kotlin
// 警告
AtomicToast.show(
    context = this,
    text = "请注意：这是警告信息",
    style = AtomicToast.Style.WARNING
)

// 错误
AtomicToast.show(
    context = this,
    text = "操作失败，请重试",
    style = AtomicToast.Style.ERROR
)
```

### 4. 加载提示

用于异步操作时显示加载状态。

```kotlin
// 显示加载
AtomicToast.show(
    context = this,
    text = "正在加载...",
    style = AtomicToast.Style.LOADING,
    position = AtomicToast.Position.CENTER,
    duration = AtomicToast.Duration.LONG
)
```

### 5. 不同位置显示

支持顶部、居中、底部三种位置。

```kotlin
// 顶部
AtomicToast.show(
    context = this,
    text = "顶部显示的 Toast",
    position = AtomicToast.Position.TOP
)

// 居中
AtomicToast.show(
    context = this,
    text = "居中显示的 Toast",
    position = AtomicToast.Position.CENTER
)

// 底部
AtomicToast.show(
    context = this,
    text = "底部显示的 Toast",
    position = AtomicToast.Position.BOTTOM
)
```

### 6. 自定义图标

支持传入自定义图标资源。

```kotlin
AtomicToast.show(
    context = this,
    text = "自定义图标示例",
    style = AtomicToast.Style.TEXT,
    customIcon = R.drawable.ic_custom_icon
)
```

## 核心 API

### `show()` 方法参数

| 参数名 | 类型 | 说明 | 默认值 |
| :--- | :--- | :--- | :--- |
| `context` | Context | 上下文（建议使用 Application Context） | (必填) |
| `text` | String | 显示的文本内容 | (必填) |
| `style` | Style | 语义化样式（见下方枚举） | Style.TEXT |
| `position` | Position | 显示位置（见下方枚举） | Position.CENTER |
| `customIcon` | Int? | 自定义图标资源 ID | null |
| `duration` | Duration | 显示时长（见下方枚举） | Duration.SHORT |

### 样式枚举 (Style)

| 枚举值 | 说明 | 默认图标 |
| :--- | :--- | :--- |
| `TEXT` | 纯文本，无图标 | 无 |
| `INFO` | 信息提示 | 信息图标 |
| `HELP` | 帮助提示 | 帮助图标 |
| `LOADING` | 加载中 | 加载动画图标 |
| `SUCCESS` | 成功提示 | 成功图标 |
| `WARNING` | 警告提示 | 警告图标 |
| `ERROR` | 错误提示 | 错误图标 |

### 位置枚举 (Position)

| 枚举值 | 说明 | 适用场景 |
| :--- | :--- | :--- |
| `TOP` | 顶部显示 | 通知类消息 |
| `CENTER` | 居中显示 | 加载、重要提示 |
| `BOTTOM` | 底部显示 | 常规反馈 |

> **注意**：Android 11 (API 30+) 对自定义 Toast 的位置做了限制，在部分设备上可能强制显示在底部。

### 时长枚举 (Duration)

| 枚举值 | 说明 | 对应系统值 |
| :--- | :--- | :--- |
| `SHORT` | 短时显示 | Toast.LENGTH_SHORT (约 2 秒) |
| `LONG` | 长时显示 | Toast.LENGTH_LONG (约 3.5 秒) |


## 动态主题 (Dynamic Theming)

`AtomicToast` 内置了对 `ThemeStore` 的支持，会自动应用当前主题的配置：

- **背景颜色**：使用 `tokens.color.bgColorOperate`
- **文本颜色**：使用 `tokens.color.textColorPrimary`
- **字体样式**：使用 `tokens.font.regular14`
- **圆角大小**：使用 `@dimen/radius_6`

当应用主题切换时，新创建的 Toast 会自动应用新主题样式。

## 使用场景

### 1. 表单提交反馈

```kotlin
viewModel.submitForm().observe(this) { result ->
    when (result) {
        is Success -> AtomicToast.show(this, "提交成功！", AtomicToast.Style.SUCCESS)
        is Error -> AtomicToast.show(this, result.message, AtomicToast.Style.ERROR)
    }
}
```

### 2. 网络请求状态

```kotlin
// 开始请求
AtomicToast.show(
    context = this,
    text = "正在加载数据...",
    style = AtomicToast.Style.LOADING,
    duration = AtomicToast.Duration.LONG
)

// 请求完成
api.fetchData().onComplete {
    AtomicToast.show(this, "加载完成", AtomicToast.Style.SUCCESS)
}
```

### 3. 复制到剪贴板

```kotlin
button.setOnClickListener {
    copyToClipboard(text)
    AtomicToast.show(this, "已复制到剪贴板", AtomicToast.Style.SUCCESS)
}
```

## 注意事项

1. **Context 选择**：建议传入 `Application Context` 以避免内存泄漏，特别是在长时间显示的场景。

2. **自动去重**：组件内部会自动取消上一个 Toast，避免 Toast 队列堆积。

3. **文本验证**：如果传入的文本为空（`isBlank()`），Toast 不会显示。

4. **API 30+ 限制**：Android 11 及以上版本对自定义 Toast 的 `setView()` 方法标记为 deprecated，但对前台应用目前仍然有效。组件内部已添加 `@Suppress("DEPRECATION")` 注解处理。

5. **线程安全**：Toast 必须在主线程调用，如果在子线程使用，需要切换到主线程：

```kotlin
withContext(Dispatchers.Main) {
    AtomicToast.show(context, "提示信息")
}
```

## 设计规范

AtomicToast 遵循以下设计规范：

- **最大宽度**：340dp
- **最大行数**：2 行，超出部分显示省略号
- **内边距**：水平 16dp，垂直 8dp
- **最小高度**：40dp
- **图标尺寸**：16dp × 16dp
- **图标间距**：图标与文字间距 4dp
- **圆角大小**：6dp
- **字体大小**：14sp
