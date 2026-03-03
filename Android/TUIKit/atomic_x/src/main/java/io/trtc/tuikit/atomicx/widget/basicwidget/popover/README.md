# AtomicPopover 弹窗容器

`AtomicPopover` 是 AtomicX Android UIKit 的统一弹窗容器，内部整合了 **底部弹出面板** 与 **居中弹出对话框** 两种形态。开发者只需指定位置（`PanelGravity.BOTTOM` / `PanelGravity.CENTER`）即可获得一致的蒙层、主题与动画体验。

## 文件结构

```
basicwidget/popover/
├── AtomicPopover.kt        # 弹窗容器实现（本文档对应文件）
└── ...                     # 相关工具类
```

## 快速开始

### 1. 底部弹出（Bottom Sheet）

```kotlin
val bottomPopover = AtomicPopover(
    context = context,
    panelGravity = AtomicPopover.PanelGravity.BOTTOM
)

bottomPopover.setContent(AudioEffectView(context).apply { init(roomId = "12345") })
bottomPopover.setPanelHeight(AtomicPopover.PanelHeight.Ratio(0.5f))

bottomPopover.show()
```

### 2. 居中弹出（Center Dialog）

```kotlin
val centerPopover = AtomicPopover(
    context = context,
    panelGravity = AtomicPopover.PanelGravity.CENTER
)

val dialogLayout = LayoutInflater.from(context).inflate(R.layout.dialog_logout, null)
centerPopover.setContent(dialogLayout)

centerPopover.show()
```

> 两种模式均支持 `setContent` 注入任意自定义 View，`AtomicPopover` 仅负责容器、蒙层、圆角和动画。

## 主要特性

1. **双布局模式**：
   - `PanelGravity.BOTTOM`：底部滑入，支持高度比设置，常用于操作面板、功能列表。
   - `PanelGravity.CENTER`：居中弹出，宽度默认占屏幕 80%，适合提示类对话框。
2. **灵活高度**：
   - `PanelHeight.WrapContent`：内容自适应，最高不超过屏幕 90%。
   - `PanelHeight.Ratio(value)`：以屏幕高度比例显示（0~1）。
3. **主题联动**：自动监听 `ThemeStore`，背景、蒙层、圆角在主题切换时实时更新。
4. **点击蒙层关闭**：默认点击外层区域即 `dismiss()`。
5. **动画区分**：底部模式具备滑入/滑出动画，居中模式无位移动画，直接渐变呈现。

## API 概览

| 方法 | 说明 |
| --- | --- |
| `setContent(view: View)` | 设置弹窗内部显示的内容 View（会自动移除原父容器） |
| `setPanelHeight(height: PanelHeight)` | 设置高度策略（仅当 `panelGravity = BOTTOM` 时有效） |
| `show()` | 展示弹窗，自动应用对应动画与蒙层 |
| `dismiss()` | 关闭弹窗；底部模式会播放下滑动画 |

### PanelGravity

```kotlin
enum class PanelGravity {
    BOTTOM,   // 底部弹出
    CENTER    // 居中弹出
}
```

### PanelHeight

```kotlin
sealed class PanelHeight {
    object WrapContent : PanelHeight()               // 自适应内容高度
    data class Ratio(val value: Float) : PanelHeight() // 按屏幕高度比例 (0.0 ~ 1.0)
}
```

## 使用建议

1. **内容布局**：`setContent` 会将子 View 宽度强制为容器宽度；居中模式下宽度为 80% 屏宽，可在子布局中自行设置内边距与圆角。
2. **高度策略**：
   - 表单、键盘场景建议 `WrapContent`。
   - 功能面板/音效面板等强调展示区域可使用 `Ratio(0.5f)` 等固定比例。
3. **复用 View**：若内容 View 需要复用，请确保在传入前与旧父容器解绑（`setContent` 会自动移除父容器，但仍建议避免状态冲突）。
4. **主题切换**：无需手动刷新，`AtomicPopover` 会响应 `ThemeStore` 的变更自动更新背景与蒙层。

---
如需更复杂的按钮 DSL、列表项等能力，可将自定义布局交由 `AtomicPopover` 承载，或结合 `AtomicAlertDialog` 等上层封装一起使用。
