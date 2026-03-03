# AtomicAlertDialog 通用弹窗组件

`AtomicAlertDialog` 是 AtomicX Android UIKit 中的标准弹窗组件，基于 Kotlin DSL 设计，支持链式配置，默认提供确认/取消按钮、列表项等多种呈现方式。内部复用 `AtomicPopover` 的容器能力，可选择居中或底部弹出（通过构造参数传入 `AtomicPopover.PanelGravity`）。

## 文件结构

```
basicwidget/alertdialog/
├── AtomicAlertDialog.kt   # 组件实现（DSL + 渲染逻辑）
└── README.md              # 本文档
```

## 快速开始

使用方式：**先创建实例并在 `init {}` 中配置内容，再调用 `show()` 展示**。

### 1. 基础确认/取消弹窗

```kotlin
val dialog = AtomicAlertDialog(context)
dialog.init {
    init(
        title = "退出登录",
        content = "确定要退出当前账号吗？",
        autoDismiss = true
    )

    cancelButton(text = "取消")

    confirmButton(
        text = "确定",
        type = AtomicAlertDialog.TextColorPreset.RED
    ) { dlg ->
        logout()
    }
}
dialog.show()
```

### 2. 列表选择弹窗

```kotlin
val dialog = AtomicAlertDialog(context)
dialog.init {
    init(title = "设置头像")

    val options = listOf(
        "拍摄" to AtomicAlertDialog.TextColorPreset.PRIMARY,
        "从相册选择" to AtomicAlertDialog.TextColorPreset.PRIMARY,
        "删除头像" to AtomicAlertDialog.TextColorPreset.RED
    )

    items(options) { dlg, index, text ->
        when (index) {
            0 -> takePhoto()
            1 -> pickImage()
            2 -> deleteAvatar()
        }
    }
}
dialog.show()
```

### 3. 带自定义图标 View 的弹窗

```kotlin
val dialog = AtomicAlertDialog(context)
val avatarView = AvatarView(context).apply { loadUrl("https://example.com/avatar.png") }

dialog.init {
    init(
        title = "账号风险",
        content = "检测到异常登录行为，请及时处理",
        iconView = avatarView
    )

    confirmButton(text = "去处理")
    cancelButton(text = "忽略", type = AtomicAlertDialog.TextColorPreset.GREY)
}
dialog.show()
```

## 核心 API（DialogConfig DSL）

`init {}` 闭包中的 `DialogConfig` 支持以下配置：

### 基础配置 `init(...)`

| 参数 | 类型 | 说明 | 默认值 |
| :--- | :--- | :--- | :--- |
| `title` | `String` | 弹窗标题 | 必填 |
| `content` | `String?` | 正文内容 | `null` |
| `iconView` | `View?` | 自定义图标/头像 | `null` |
| `autoDismiss` | `Boolean` | 点击按钮或列表项后是否自动关闭 | `true` |

### 按钮配置

- `confirmButton(text, type, isBold, onClick)`：主操作按钮（默认蓝色、加粗）
- `cancelButton(text, type, isBold, onClick)`：次操作按钮（默认灰色）

### 列表项

- `addItem(text, type, isBold, onClick)`：添加单个列表项
- `items(list, isBold, onClick)`：批量添加列表项，回调提供 `(dialog, index, text)`

### 颜色预设 `TextColorPreset`

- `PRIMARY`：主文本色
- `GREY`：次级文本色
- `BLUE`：强调/链接色
- `RED`：危险/警示操作

## 动态主题与布局

- 内建监听 `ThemeStore`，当主题发生变化时自动刷新背景、文字、分割线等样式。
- 通过构造参数 `AtomicAlertDialog(context, gravity = AtomicPopover.PanelGravity.CENTER)` 可切换弹窗出现的位置（例如居中、底部）。
- 与 `AtomicPopover` 共享容器能力，确保圆角、遮罩、动画等表现一致。

## 注意事项

1. **Context**：建议传入 `Activity` Context；如需在 `Fragment` 中使用请确保生命周期安全。
2. **Icon View**：传入的 `iconView` 不能同时挂在其他父容器下，内部会自动移除再添加。
3. **自动关闭**：`autoDismiss = true` 时，`confirmButton`、`cancelButton`、`itemList` 的点击都会在回调后自动关闭；若需要手动控制请设置为 `false` 并在回调中自行 `dismiss()`。
4. **重复 show**：再次 `show()` 前会自动销毁上一次的 `AtomicPopover`，无需手动清理。
