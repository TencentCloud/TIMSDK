# AtomicButton 基础组件

AtomicX Android UIKit 通用按钮组件 `AtomicButton`，支持多种语义变体、尺寸档位和灵活的图文布局，并与主题系统深度集成。

## 文件结构

```
button/
├── AtomicButton.kt           # 按钮组件实现（变体、尺寸、布局、主题响应）
└── README.md                 # 本文件
```

## 快速开始

### 在 XML 布局中使用

```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.button.AtomicButton
    android:id="@+id/btnSubmit"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="提交"
    app:buttonVariant="filled"
    app:buttonColorType="primary"
    app:customButtonSize="m" />
```

### XML 属性一览

| 属性名 | 类型 | 可选值 | 说明 |
| :--- | :--- | :--- | :--- |
| `android:text` | string | - | 按钮文本 |
| `buttonVariant` | enum | `filled` / `outlined` / `text` | 按钮变体样式 |
| `buttonColorType` | enum | `primary` / `secondary` / `danger` | 按钮语义颜色 |
| `customButtonSize` | enum | `xs` / `s` / `m` / `l` | 按钮尺寸档位 |
| `buttonIconPosition` | enum | `start` / `end` / `none` | 图标位置 |
| `buttonIcon` | reference | drawable 资源 | 按钮图标 |
| `textStyle` | boolean | `true` / `false` | 是否加粗 |
| `buttonTextSize` | dimension | 如 `14sp` | 自定义文字大小 |

### 在代码中配置

```kotlin
// 1. 创建主操作按钮（默认：FILLED + PRIMARY + S）
val btnSubmit = findViewById<AtomicButton>(R.id.btnSubmit).apply {
    variant = ButtonVariant.FILLED
    colorType = ButtonColorType.PRIMARY
    size = ButtonSize.M
}

// 2. 创建次级按钮（描边样式）
val btnCancel = AtomicButton(context).apply {
    text = "取消"
    variant = ButtonVariant.OUTLINED
    colorType = ButtonColorType.SECONDARY
    size = ButtonSize.M
}

// 3. 创建危险操作按钮（带图标）
val btnDelete = AtomicButton(context).apply {
    text = "删除"
    variant = ButtonVariant.FILLED
    colorType = ButtonColorType.DANGER
    size = ButtonSize.S

    iconDrawable = ContextCompat.getDrawable(context, R.drawable.ic_delete)
    iconPosition = ButtonIconPosition.START
}

// 4. 注册点击事件
btnSubmit.setOnClickListener {
    // 处理点击逻辑
}
```

## 尺寸优先级说明

`AtomicButton` 支持两种方式控制尺寸，优先级如下：

1. **XML 布局属性优先**：如果在 XML 中显式设置了 `layout_height` 或 `layout_width`（非 `wrap_content`），则以 XML 设置的值为准。
2. **customButtonSize 属性次之**：当 `layout_height="wrap_content"` 时，组件会根据 `customButtonSize`（`xs` / `s` / `m` / `l`）自动计算高度与最小宽度。

> **建议**：一般情况下将 `layout_height` 设为 `wrap_content`，通过 `customButtonSize` 控制尺寸；如有特殊需求可直接指定固定高度覆盖。

## 主要特性

### 1. 语义变体与视觉样式 (`ButtonVariant`)

- `FILLED` (默认): 实心背景，适合主要操作
- `OUTLINED`: 描边样式，背景透明，适合次级操作
- `TEXT`: 纯文本样式，无边框无背景，适合轻量级操作

### 2. 颜色语义 (`ButtonColorType`)

- `PRIMARY` (默认): 主题主色，强调操作
- `SECONDARY`: 中性配色，用于默认/次要操作
- `DANGER`: 危险/警示操作（通常为红色）

### 3. 四种尺寸档位 (`ButtonSize` / `customButtonSize`)

自动适配高度、最小宽度、图标大小和字体大小。

| 尺寸 | XML 值 | 高度 (dp) | 最小宽度 (dp) | 图标大小 (dp) | 字体大小 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `XS` | `xs` | 24 | 48 | 14 | 12sp |
| `S` | `s` | 32 | 64 | 16 | 14sp |
| `M` | `m` | 40 | 80 | 20 | 16sp |
| `L` | `l` | 48 | 96 | 20 | 16sp |

### 4. 灵活的图文布局

通过 `buttonIcon` 和 `buttonIconPosition` 属性控制：

- `start`: 左图右文
- `end`: 左文右图
- `none`: 仅文本（默认）

> 图标会自动进行着色（`tint`）以匹配当前按钮的文本颜色。

### 5. 主题系统集成

- **自动响应**：`AtomicButton` 内部监听 `ThemeStore` 的状态变化。当应用切换主题（如深色模式）时，按钮会自动更新背景色、边框色、文字颜色和水波纹效果，无需手动刷新。
- **生命周期管理**：组件自动处理协程作用域，在 View `onDetachedFromWindow` 时取消监听，防止内存泄漏。

### 6. 自动状态管理

组件根据 `isEnabled` 和 `isPressed` 状态自动切换样式：

- **Normal**: 默认状态，使用标准色。
- **Pressed**: 按下状态，背景变深或显示 Ripple 水波纹。
- **Disabled**: 禁用状态，自动置灰背景、边框和文字，且不响应点击。

## 样式规范细节

组件内部根据 `ButtonVariant` 和 `ButtonColorType` 组合计算最终样式：

- **FILLED 模式**:
    - 背景色：填充对应 ColorType 的颜色
    - 边框：无
    - 文字：通常为反白 (White)
- **OUTLINED 模式**:
    - 背景色：透明
    - 边框：1dp 实线，颜色跟随 ColorType
    - 文字：颜色跟随 ColorType
- **TEXT 模式**:
    - 背景色：透明
    - 边框：无
    - 文字：颜色跟随 ColorType

> 圆角默认根据高度自适应为全圆角（Capsule 样式）。

## API 参考

### 核心属性

| 属性 | 类型 | 说明 |
| :--- | :--- | :--- |
| `variant` | `ButtonVariant` | 按钮变体样式 |
| `colorType` | `ButtonColorType` | 按钮语义颜色 |
| `size` | `ButtonSize` | 按钮尺寸 |
| `iconDrawable` | `Drawable?` | 图标资源 |
| `iconPosition` | `ButtonIconPosition` | 图标位置 |
| `text` | `CharSequence` | 按钮文本 |
| `isBold` | `Boolean` | 是否加粗 |
| `customTextSizeSp` | `Float?` | 自定义文字大小（sp） |

### 继承属性

继承自 `FrameLayout`，支持所有标准属性：
- `isEnabled`
- `setOnClickListener`
- ...

## 注意事项

1. **EditMode 支持**：在 Android Studio 预览布局中，组件会尝试加载默认主题以展示大致效果。
2. **布局参数**：设置 `customButtonSize` 属性会自动调整高度和最小宽度，通常建议将 XML 中的高度设为 `wrap_content`。
3. **图标着色**：组件会强制接管图标的 `tint` 颜色。如果需要显示图标原色，请确保 `iconDrawable` 为 `null` 并自行处理（或扩展组件）。
