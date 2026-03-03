# AtomicAvatar 头像组件

AtomicAvatar 是一个高度可定制的 Android 头像组件，基于 Kotlin 设计，支持 **XML 布局配置**和**代码动态设置**两种使用方式。它遵循 AtomicX 设计系统，提供了多种尺寸、形状和徽章样式，适用于用户头像、群组头像、图标展示等多种场景。

## 文件结构

```
avatar/
├── AtomicAvatar.kt              # 头像组件核心实现
└── README.md                    # 本文件
```

## 快速开始

### 方式一：XML 布局配置（推荐）

直接在 XML 中配置所有属性，无需代码设置：

```xml
<!-- 用户头像：URL + 圆形 + 中等尺寸 + 红点徽章 -->
<io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar
    android:id="@+id/user_avatar"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    app:avatarSize="m"
    app:avatarShape="round"
    app:avatarUrl="https://example.com/avatar.jpg"
    app:avatarPlaceholder="@drawable/ic_default_avatar"
    app:badgeType="dot" />
```

### 方式二：代码动态设置

```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar
    android:id="@+id/avatar"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content" />
```

在代码中配置：

```kotlin
val avatar = findViewById<AtomicAvatar>(R.id.avatar)

// 设置头像内容（图片URL）
avatar.setContent(
    AtomicAvatar.AvatarContent.URL(
        url = "https://example.com/avatar.jpg",
        placeImage = R.drawable.default_avatar
    )
)

// 设置尺寸
avatar.setSize(AtomicAvatar.AvatarSize.L)

// 设置形状
avatar.setShape(AtomicAvatar.AvatarShape.Round)

// 设置徽章
avatar.setBadge(AtomicAvatar.AvatarBadge.Dot)
```

## XML 属性说明

### 可用的 XML 属性

| 属性名 | 类型 | 说明 | 可选值 |
|--------|------|------|--------|
| `app:avatarSize` | enum | 头像尺寸 | xxs/xs/s/m(默认)/l/xl/xxl |
| `app:avatarShape` | enum | 头像形状 | round(默认)/roundRectangle/rectangle |
| `app:avatarUrl` | string | 图片URL | 任意URL字符串 |
| `app:avatarPlaceholder` | reference | 占位图 | @drawable/xxx |
| `app:avatarText` | string | 文本内容 | 任意文本 |
| `app:avatarIcon` | reference | 图标资源 | @drawable/xxx |
| `app:badgeType` | enum | 徽章类型 | none(默认)/dot/text |
| `app:badgeText` | string | 徽章文本 | 任意文本（配合badgeType="text"使用）|

### 内容优先级

当同时设置多个内容属性时，优先级为：**avatarUrl > avatarIcon > avatarText**

### 完整 XML 示例

#### 示例 1：用户头像（URL + 圆形 + 中等尺寸 + 红点）
```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar
    android:id="@+id/user_avatar"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    app:avatarSize="m"
    app:avatarShape="round"
    app:avatarUrl="https://example.com/user_avatar.jpg"
    app:avatarPlaceholder="@drawable/ic_default_avatar"
    app:badgeType="dot" />
```

#### 示例 2：群组头像（文本 + 圆角矩形 + 大尺寸 + 数字徽章）
```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar
    android:id="@+id/group_avatar"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    app:avatarSize="l"
    app:avatarShape="roundRectangle"
    app:avatarText="开发组"
    app:badgeType="text"
    app:badgeText="5" />
```

#### 示例 3：系统图标（图标 + 矩形 + 小尺寸）
```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar
    android:id="@+id/system_icon"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    app:avatarSize="s"
    app:avatarShape="rectangle"
    app:avatarIcon="@drawable/ic_notification" />
```

#### 示例 4：XXS 超小头像（带数字徽章）
```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar
    android:id="@+id/mini_avatar"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    app:avatarSize="xxs"
    app:avatarShape="round"
    app:avatarText="A"
    app:badgeType="text"
    app:badgeText="99+" />
```

## 代码使用示例

如果需要动态修改头像属性，可以使用代码方式：

### 1. 基础图片头像

```kotlin
val avatar = findViewById<AtomicAvatar>(R.id.avatar)

avatar.setContent(
    AtomicAvatar.AvatarContent.URL(
        url = "https://example.com/avatar.jpg",
        placeImage = R.drawable.default_avatar
    )
)
avatar.setSize(AtomicAvatar.AvatarSize.L)
avatar.setShape(AtomicAvatar.AvatarShape.Round)
```

### 2. 文字头像

适用于没有头像图片时，显示文本内容。

```kotlin
val avatar = findViewById<AtomicAvatar>(R.id.avatar)

avatar.setContent(
    AtomicAvatar.AvatarContent.Text(name = "张")
)
avatar.setSize(AtomicAvatar.AvatarSize.M)
avatar.setShape(AtomicAvatar.AvatarShape.Round)
```

### 3. 图标头像

使用 Drawable 资源作为头像内容。

```kotlin
val avatar = findViewById<AtomicAvatar>(R.id.avatar)

val drawable = ContextCompat.getDrawable(context, R.drawable.ic_group)
avatar.setContent(
    AtomicAvatar.AvatarContent.Icon(drawable = drawable!!)
)
avatar.setSize(AtomicAvatar.AvatarSize.XL)
avatar.setShape(AtomicAvatar.AvatarShape.RoundRectangle)
```

### 4. 带徽章的头像

显示在线状态、未读消息数等信息。

```kotlin
val avatar = findViewById<AtomicAvatar>(R.id.avatar)

// 设置头像内容
avatar.setContent(
    AtomicAvatar.AvatarContent.URL(
        url = userAvatarUrl,
        placeImage = R.drawable.default_avatar
    )
)

// 添加红点徽章（在线状态）
avatar.setBadge(AtomicAvatar.AvatarBadge.Dot)

// 或添加数字徽章（未读消息数）
avatar.setBadge(AtomicAvatar.AvatarBadge.Text("99+"))

avatar.setSize(AtomicAvatar.AvatarSize.L)
avatar.setShape(AtomicAvatar.AvatarShape.Round)
```

### 5. 带点击事件的头像

```kotlin
val avatar = findViewById<AtomicAvatar>(R.id.avatar)

avatar.setContent(
    AtomicAvatar.AvatarContent.URL(url = userAvatarUrl, placeImage = R.drawable.default_avatar)
)

// 设置点击监听器
avatar.setOnAvatarClickListener {
    // 跳转到用户详情页
    navigateToUserProfile(userId)
}
```

## 核心 API

### AtomicAvatar.AvatarContent（头像内容）

头像组件支持三种内容类型：

#### 1. URL - 图片头像
```kotlin
AtomicAvatar.AvatarContent.URL(
    url: String,              // 图片URL
    placeImage: Int           // 占位图资源ID（@DrawableRes）
)
```

#### 2. Text - 文字头像
```kotlin
AtomicAvatar.AvatarContent.Text(
    name: String              // 显示的文本内容
)
```

#### 3. Icon - 图标头像
```kotlin
AtomicAvatar.AvatarContent.Icon(
    drawable: Drawable        // Drawable 资源
)
```

### AtomicAvatar.AvatarSize（头像尺寸）

提供 7 种预定义尺寸规格：

| 尺寸 | 大小 (dp) | 文字大小 (sp) | 圆角半径 (dp) | 使用场景 |
| :--- | :--- | :--- | :--- | :--- |
| `XXS` | 16 | 10 | 4 | 超小标签、迷你图标 |
| `XS` | 24 | 12 | 4 | 小型头像列表、标签 |
| `S` | 32 | 14 | 4 | 评论区、聊天气泡 |
| `M` | 40 | 16 | 4 | 会话列表（默认） |
| `L` | 48 | 18 | 8 | 联系人列表 |
| `XL` | 64 | 28 | 12 | 个人中心、用户卡片 |
| `XXL` | 96 | 36 | 12 | 个人主页头部 |

**XML 使用：**
```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar
    app:avatarSize="l" />
```

**代码使用：**
```kotlin
avatar.setSize(AtomicAvatar.AvatarSize.XL)
```

### AtomicAvatar.AvatarShape（头像形状）

支持 3 种形状样式：

| 形状 | 说明 | 使用场景 |
| :--- | :--- | :--- |
| `Round` | 圆形 | 个人头像（最常用） |
| `RoundRectangle` | 圆角矩形 | 群组头像、品牌Logo |
| `Rectangle` | 直角矩形 | 封面图、卡片图 |

**XML 使用：**
```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar
    app:avatarShape="roundRectangle" />
```

**代码使用：**
```kotlin
avatar.setShape(AtomicAvatar.AvatarShape.Round)
```

### AtomicAvatar.AvatarBadge（徽章）

支持 3 种徽章类型：

#### 1. None - 无徽章

**XML 使用：**
```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar
    app:badgeType="none" />
```

**代码使用：**
```kotlin
avatar.setBadge(AtomicAvatar.AvatarBadge.None)
```

#### 2. Dot - 红点徽章

适用于在线状态、新消息提示。

**XML 使用：**
```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar
    app:badgeType="dot" />
```

**代码使用：**
```kotlin
avatar.setBadge(AtomicAvatar.AvatarBadge.Dot)
```

#### 3. Text - 文本徽章

适用于未读消息数、等级标识等。

**XML 使用：**
```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar
    app:badgeType="text"
    app:badgeText="99+" />
```

**代码使用：**
```kotlin
avatar.setBadge(AtomicAvatar.AvatarBadge.Text("99+"))
```

### 徽章位置规则

徽章会根据头像形状自动计算最佳位置：

- **圆形头像**：徽章位于右上角 45° 位置（对角线方向）
- **圆角矩形**：
  - Dot 徽章：位于圆角内切位置
  - Text 徽章：位于右上角顶点
- **矩形**：徽章位于右上角顶点


## 动态主题 (Dynamic Theming)

`AtomicAvatar` 内置了对 `ThemeStore` 的支持。头像的背景色、文字颜色等会自动响应主题变化（例如切换深色模式），无需手动刷新。

## 布局尺寸规则

`AtomicAvatar` 支持灵活的尺寸设置方式，遵循 Android 标准的测量规范：

### 1. 使用 `wrap_content`（推荐）

由 `avatarSize` 属性决定实际尺寸：

```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    app:avatarSize="l" />
<!-- 实际显示: 48dp × 48dp -->
```

### 2. 明确指定尺寸

直接控制头像大小，忽略 `avatarSize` 属性：

```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar
    android:layout_width="60dp"
    android:layout_height="60dp"
    app:avatarSize="m" />
<!-- 实际显示: 60dp × 60dp，avatarSize 被覆盖 -->
```

### 3. 自适应父布局

支持 `match_parent` 和 ConstraintLayout 约束：

```xml
<!-- 填充父布局 -->
<io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar
    android:layout_width="match_parent"
    android:layout_height="match_parent" />

<!-- ConstraintLayout 约束 -->
<io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar
    android:layout_width="0dp"
    android:layout_height="0dp"
    app:layout_constraintWidth_percent="0.2"
    app:layout_constraintDimensionRatio="1:1" />
```

### 4. 宽高不一致时

组件会取宽高中的较小值，确保头像保持正方形：

```xml
<io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar
    android:layout_width="80dp"
    android:layout_height="60dp" />
<!-- 实际显示: 60dp × 60dp（取较小值）-->
```

### 优先级规则

1. **明确指定的尺寸** (`layout_width`/`layout_height` 为具体数值) > **avatarSize 属性**
2. **wrap_content** 时使用 **avatarSize 属性**
3. 宽高不一致时，取**较小值**保持正方形

## 注意事项

1. **内容优先级**: 当在 XML 中同时设置多个内容属性时，优先级为：`avatarUrl` > `avatarIcon` > `avatarText`。

2. **占位图**: 使用 `avatarUrl` 时，建议设置 `avatarPlaceholder` 作为加载失败时的占位图。

3. **文字内容**: `AtomicAvatar.AvatarContent.Text` 直接显示传入的文本内容，请在外部处理后传入。

4. **徽章文本长度**: 建议徽章文本不超过 3 个字符（如 "99+"），过长文本会影响美观。

5. **Drawable 资源**: 使用 `AtomicAvatar.AvatarContent.Icon` 时，传入的 Drawable 不应为 null。

6. **主题支持**: 头像的背景色和文本颜色会自动适配当前主题（`ThemeStore`）。

7. **保持正方形**: 组件会自动保持正方形比例，如果宽高设置不一致，会取较小值。

## 设计规范

### 尺寸选择建议

- **超小图标**：使用 XXS (16dp)
- **列表场景**：优先使用 M (40dp) 或 S (32dp)
- **详情场景**：优先使用 L (48dp) 或 XL (64dp)
- **个人主页**：使用 XXL (96dp)
- **小型标签**：使用 XS (24dp)

### 形状选择建议

- **个人用户**：Round（圆形）
- **群组/品牌**：RoundRectangle（圆角矩形）
- **封面图**：Rectangle（矩形）

### 徽章使用建议

- **在线状态**：使用 Dot
- **未读消息**：使用 Text（显示数字）
- **无提示**：使用 None