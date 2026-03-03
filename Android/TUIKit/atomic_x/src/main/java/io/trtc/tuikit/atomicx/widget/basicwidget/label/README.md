# AtomicLabel 文本标签组件

AtomicLabel 是一个功能丰富的 Android 文本标签组件，基于 AppCompatTextView 封装，提供了图文混排、主题化、颜色 Token 和自定义外观等特性。它遵循 AtomicX 设计系统，支持动态主题切换和多种样式配置。

## 文件结构

```
label/
├── AtomicLabel.kt          # Label 组件核心实现
└── README.md               # 本文件
```

## 快速开始

AtomicLabel 支持代码创建和 XML 布局两种使用方式。

### 1. 纯文本标签

最简单的文本标签，无图标，使用默认样式。

```kotlin
val label = AtomicLabel(context)
label.text = "这是一个文本标签"
```

### 2. 带图标的标签

支持在文本左侧或右侧添加图标。

```kotlin
val label = AtomicLabel(context)
label.text = "带图标的标签"
label.iconConfiguration = AtomicLabel.IconConfiguration(
    drawable = ContextCompat.getDrawable(context, R.drawable.ic_star),
    position = AtomicLabel.IconConfiguration.Position.LEFT,
    spacing = 8f,
    size = Size(20, 20)
)
```

### 3. 图标在右侧

适用于导航、展开/收起等场景。

```kotlin
label.iconConfiguration = AtomicLabel.IconConfiguration(
    drawable = ContextCompat.getDrawable(context, R.drawable.ic_arrow_right),
    position = AtomicLabel.IconConfiguration.Position.RIGHT,
    spacing = 4f
)
```

### 4. 自定义外观

通过 AppearanceProvider 自定义颜色、字体、圆角等样式。

```kotlin
val label = AtomicLabel(context)
label.text = "自定义样式"
label.setAppearanceProvider { theme ->
    AtomicLabel.LabelAppearance(
        textColor = theme.tokens.color.textColorSecondary,
        backgroundColor = theme.tokens.color.buttonColorPrimaryDefault,
        textSize = theme.tokens.font.bold16.size,
        textWeight = Typeface.BOLD,
        cornerRadius = 8f
    )
}
```

### 5. 圆角背景

支持设置圆角背景，适用于标签、徽章等场景。

```kotlin
val label = AtomicLabel(context)
label.text = "圆角标签"
label.setAppearanceProvider { theme ->
    AtomicLabel.LabelAppearance(
        textColor = Color.WHITE,
        backgroundColor = theme.tokens.color.buttonColorPrimaryDefault,
        textSize = 14f,
        textWeight = Typeface.NORMAL,
        cornerRadius = 12f
    )
}
label.setPadding(16, 8, 16, 8)
```

### 6. XML 布局使用（支持颜色 Token）

在 XML 中直接使用 AtomicLabel，支持 `android:textColor` 和自定义属性。

```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.label.AtomicLabel
    android:id="@+id/myLabel"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="XML 中的标签"
    android:textColor="@color/text_color_primary"
    app:labelBackgroundColor="@color/bg_color_function"
    app:labelCornerRadius="8dp"
    android:padding="12dp" />
```

然后在代码中配置：

```kotlin
val label = findViewById<AtomicLabel>(R.id.myLabel)
label.iconConfiguration = AtomicLabel.IconConfiguration(
    drawable = ContextCompat.getDrawable(this, R.drawable.ic_star),
    position = AtomicLabel.IconConfiguration.Position.LEFT
)
```

## 核心 API

### `AtomicLabel` 类

#### 构造函数

```kotlin
AtomicLabel(context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0)
```

| 参数名 | 类型 | 说明 | 默认值 |
| :--- | :--- | :--- | :--- |
| `context` | Context | 上下文对象 | (必填) |
| `attrs` | AttributeSet? | XML 属性集 | null |
| `defStyleAttr` | Int | 默认样式属性 | 0 |

#### 属性

| 属性名 | 类型 | 说明 |
| :--- | :--- | :--- |
| `text` | CharSequence? | 文本内容（继承自 TextView） |
| `iconConfiguration` | IconConfiguration? | 图标配置，设置后自动更新 |

#### 方法

| 方法名 | 说明 |
| :--- | :--- |
| `setAppearanceProvider(provider: AppearanceProvider)` | 设置外观提供者，会在 View attached 时立即刷新样式 |

#### XML 自定义属性

| 属性名 | 类型 | 说明 |
| :--- | :--- | :--- |
| `android:textColor` | reference\|color | 文本颜色，支持颜色 Token（如 `@color/text_color_primary`）或静态颜色 |
| `app:labelBackgroundColor` | reference\|color | 背景颜色，支持颜色 Token 或静态颜色 |
| `app:labelCornerRadius` | dimension | 圆角半径（如 `8dp`） |

### `LabelAppearance` 数据类

定义 Label 的视觉样式。

| 属性名 | 类型 | 说明 |
| :--- | :--- | :--- |
| `textColor` | Int | 文本颜色（Color Int） |
| `backgroundColor` | Int | 背景颜色（Color Int） |
| `textSize` | Float | 字体大小（单位：SP） |
| `textWeight` | Int | 字体粗细（Typeface.BOLD 或 Typeface.NORMAL） |
| `cornerRadius` | Float | 圆角半径（单位：DP） |

#### 默认外观

```kotlin
LabelAppearance.defaultAppearance(theme: Theme): LabelAppearance
```

返回基于当前主题的默认外观配置。

### `IconConfiguration` 数据类

定义图标的配置参数。

| 属性名 | 类型 | 说明 | 默认值 |
| :--- | :--- | :--- | :--- |
| `drawable` | Drawable? | 图标 Drawable 对象 | (必填) |
| `position` | Position | 图标位置（LEFT/RIGHT） | LEFT |
| `spacing` | Float | 图标与文本的间距（单位：px） | 4f |
| `size` | Size? | 图标尺寸，null 则使用原始尺寸 | null |

#### Position 枚举

| 枚举值 | 说明 |
| :--- | :--- |
| `LEFT` | 图标在文本左侧 |
| `RIGHT` | 图标在文本右侧 |

### `AppearanceProvider` 函数接口

用于根据主题动态提供外观配置。

```kotlin
fun interface AppearanceProvider {
    fun provide(theme: Theme): LabelAppearance
}
```

## 动态主题 (Dynamic Theming)

`AtomicLabel` 内置了对 `ThemeStore` 的支持，会自动监听主题变化并更新样式：

- **自动刷新**：主题切换时，所有 Label 会自动应用新主题
- **协程管理**：使用基于 View 的 CoroutineScope 监听主题状态，自动处理生命周期
- **性能优化**：仅在 View attach 时订阅，detach 时自动取消
- **颜色 Token**：支持在 XML 中使用颜色 Token，自动跟随主题切换

### 方式 1：使用 AppearanceProvider

```kotlin
val label = AtomicLabel(context)
label.text = "主题化标签"
label.setAppearanceProvider { theme ->
    AtomicLabel.LabelAppearance(
        textColor = theme.tokens.color.textColorPrimary,
        backgroundColor = theme.tokens.color.bgColorDefault,
        textSize = theme.tokens.font.regular14.size,
        textWeight = theme.tokens.font.regular14.weight,
        cornerRadius = 4f
    )
}
```

### 方式 2：使用 XML 颜色 Token

```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.label.AtomicLabel
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="主题化标签"
    android:textColor="@color/text_color_primary"
    app:labelBackgroundColor="@color/bg_color_function"
    app:labelCornerRadius="4dp" />
```

当用户切换主题时：

```kotlin
ThemeStore.shared(context).setTheme(Theme.darkTheme(context))
```

所有使用主题 Token 或 AppearanceProvider 的 Label 会自动更新样式。

## 使用场景

### 1. 状态标签

显示用户状态、订单状态等信息。

```kotlin
val statusLabel = AtomicLabel(context)
statusLabel.text = "已完成"
statusLabel.setAppearanceProvider { theme ->
    AtomicLabel.LabelAppearance(
        textColor = Color.WHITE,
        backgroundColor = theme.tokens.color.toastColorSuccess,
        textSize = 12f,
        textWeight = Typeface.NORMAL,
        cornerRadius = 4f
    )
}
statusLabel.setPadding(12, 4, 12, 4)
```

### 2. 导航菜单项

带箭头的导航项。

```kotlin
val menuItem = AtomicLabel(context)
menuItem.text = "个人设置"
menuItem.iconConfiguration = AtomicLabel.IconConfiguration(
    drawable = ContextCompat.getDrawable(context, R.drawable.ic_arrow_right),
    position = AtomicLabel.IconConfiguration.Position.RIGHT,
    spacing = 8f,
    size = Size(16, 16)
)
```

### 3. 标签组

多个标签组合展示。

```kotlin
val tags = listOf("Android", "Kotlin", "AtomicX")
val tagContainer = LinearLayout(context).apply {
    orientation = LinearLayout.HORIZONTAL
}

tags.forEach { tagText ->
    val tag = AtomicLabel(context)
    tag.text = tagText
    tag.setAppearanceProvider { theme ->
        AtomicLabel.LabelAppearance(
            textColor = theme.tokens.color.textColorLink,
            backgroundColor = theme.tokens.color.bgColorFunction,
            textSize = 12f,
            textWeight = Typeface.NORMAL,
            cornerRadius = 8f
        )
    }
    tag.setPadding(16, 6, 16, 6)
    tagContainer.addView(tag)
}
```

### 4. 信息提示

带图标的信息提示。

```kotlin
val infoLabel = AtomicLabel(context)
infoLabel.text = "点击查看详情"
infoLabel.iconConfiguration = AtomicLabel.IconConfiguration(
    drawable = ContextCompat.getDrawable(context, R.drawable.ic_info),
    position = AtomicLabel.IconConfiguration.Position.LEFT,
    spacing = 4f,
    size = Size(16, 16)
)
```

## 注意事项

1. **Context 选择**：建议传入 Activity Context，避免 Application Context 导致的主题问题。

2. **图标尺寸**：图标尺寸建议不超过字体行高的 1.5 倍，以保持视觉平衡。

3. **间距单位**：`IconConfiguration.spacing` 的单位是 **px（像素）**，不是 dp。如需使用 dp，请使用 `dp2px` 工具方法转换。

```kotlin
val spacingPx = dp2px(context, 8f)
```

4. **生命周期管理**：组件内部使用基于 View 的 CoroutineScope 自动处理主题监听的生命周期，无需手动取消订阅。

5. **性能优化**：使用 `CompoundDrawables` 实现图标，性能优于 ImageSpan 方案。

6. **背景绘制**：圆角背景通过 `GradientDrawable` 实现，支持硬件加速，使用 lazy 延迟初始化。

7. **文本更新**：修改 `text` 属性会立即刷新显示，无需手动调用 `invalidate()`。

8. **颜色 Token**：
   - XML 中引用的颜色资源（如 `@color/text_color_primary`）会自动识别为 Token 并跟随主题切换
   - 直接使用颜色值（如 `#FF000000`）则为静态颜色，不跟随主题
   - AppearanceProvider 优先级高于 XML 属性

9. **协程调度**：使用 `Dispatchers.Main.immediate` 确保主题更新在 UI 线程立即执行。

## 设计规范

AtomicLabel 遵循以下设计规范：

- **默认字体**：14sp，Regular（400）
- **图标间距**：4px（约 2dp）
- **圆角半径**：0-12dp（根据场景调整）
- **内边距**：建议 8-16dp（水平）、4-8dp（垂直）
- **图标尺寸**：12-24dp（根据字体大小调整）

## 常见问题

**Q: 如何动态修改文本内容？**  
A: 直接设置 `text` 属性即可：

```kotlin
label.text = "新的文本内容"
```

**Q: 如何移除图标？**  
A: 将 `iconConfiguration` 设置为 `null`：

```kotlin
label.iconConfiguration = null
```

**Q: 如何实现点击效果？**  
A: 添加点击监听器并使用不同的 Appearance：

```kotlin
label.setOnClickListener {
    label.setAppearanceProvider { theme ->
        AtomicLabel.LabelAppearance(
            textColor = Color.WHITE,
            backgroundColor = theme.tokens.color.buttonColorPrimaryActive,
            textSize = 14f,
            textWeight = Typeface.NORMAL,
            cornerRadius = 4f
        )
    }
}
```

**Q: 如何禁用主题自动更新？**  
A: 方式 1 - 使用固定的颜色值代替主题 tokens：

```kotlin
val label = AtomicLabel(context)
label.text = "固定样式"
label.setAppearanceProvider { _ ->
    AtomicLabel.LabelAppearance(
        textColor = Color.BLACK,
        backgroundColor = Color.LTGRAY,
        textSize = 14f,
        textWeight = Typeface.NORMAL,
        cornerRadius = 4f
    )
}
```

方式 2 - XML 中使用静态颜色：

```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.label.AtomicLabel
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="固定样式"
    android:textColor="#FF000000"
    app:labelBackgroundColor="#FFDDDDDD"
    app:labelCornerRadius="4dp" />
```

**Q: 图标模糊或变形怎么办？**  
A: 使用矢量图（SVG）或提供 @2x/@3x 的 PNG 资源，并确保设置了正确的 `size`。

**Q: XML 中设置的颜色没有跟随主题切换？**  
A: 检查是否使用了颜色 Token 资源（如 `@color/text_color_primary`）而非静态颜色值（如 `#FF000000`）。只有 Token 颜色会跟随主题切换。

**Q: 如何在 XML 中同时支持 Token 和静态颜色？**  
A: 组件会自动识别：
- `@color/text_color_primary` → 识别为 Token，跟随主题
- `#FF000000` 或 `@color/custom_static_color` → 识别为静态颜色，不跟随主题

## 完整示例

### 代码方式

```kotlin
class ExampleActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(24, 24, 24, 24)
        }
        
        // 1. 基础标签
        val basicLabel = AtomicLabel(this)
        basicLabel.text = "基础标签"
        container.addView(basicLabel)
        
        // 2. 带图标的标签
        val iconLabel = AtomicLabel(this)
        iconLabel.text = "带图标"
        iconLabel.iconConfiguration = AtomicLabel.IconConfiguration(
            drawable = ContextCompat.getDrawable(this, R.drawable.ic_star),
            position = AtomicLabel.IconConfiguration.Position.LEFT,
            spacing = 8f,
            size = Size(20, 20)
        )
        container.addView(iconLabel)
        
        // 3. 自定义样式标签
        val customLabel = AtomicLabel(this)
        customLabel.text = "自定义"
        customLabel.setAppearanceProvider { theme ->
            AtomicLabel.LabelAppearance(
                textColor = Color.WHITE,
                backgroundColor = theme.tokens.color.buttonColorPrimaryDefault,
                textSize = theme.tokens.font.bold16.size,
                textWeight = Typeface.BOLD,
                cornerRadius = 8f
            )
        }
        customLabel.setPadding(16, 8, 16, 8)
        container.addView(customLabel)
        
        setContentView(container)
    }
}
```

### XML 方式

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="24dp">

    <!-- 基础标签 -->
    <io.trtc.tuikit.atomicx.widget.basicwidget.label.AtomicLabel
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="基础标签" />

    <!-- 使用颜色 Token（跟随主题） -->
    <io.trtc.tuikit.atomicx.widget.basicwidget.label.AtomicLabel
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="主题化标签"
        android:textColor="@color/text_color_primary"
        app:labelBackgroundColor="@color/bg_color_function"
        app:labelCornerRadius="8dp"
        android:padding="12dp" />

    <!-- 使用静态颜色（不跟随主题） -->
    <io.trtc.tuikit.atomicx.widget.basicwidget.label.AtomicLabel
        android:id="@+id/staticLabel"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="静态样式标签"
        android:textColor="#FFFFFFFF"
        app:labelBackgroundColor="#FF4086FF"
        app:labelCornerRadius="12dp"
        android:padding="16dp" />

</LinearLayout>
```
