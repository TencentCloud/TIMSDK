# BaseComponent

HarmonyOS ArkTS 基础组件库，提供统一的 UI 组件和主题系统。

## 安装

在你的 HarmonyOS 项目中引入此组件库。

## 主题系统

### Colors

提供统一的颜色系统，包含品牌色、灰度色、错误色等。

### Fonts

提供统一的字体系统，包含不同尺寸和权重的字体定义。

### Radius

提供统一的圆角系统。

### Spacing

提供统一的间距系统。

## 组件（Components）

### Button 组件

按钮组件提供多种类型和样式，支持文本、图标以及组合显示。

#### 基本用法

```typescript
import { ButtonControl, ButtonContent, ButtonControlType, ButtonColorType, ButtonSize, ButtonIconPosition } from 'atomic_x';

// 基础按钮
ButtonControl({
  content: {
    type: ButtonContent.textOnly,
    text: "确定"
  },
  ButtonControlType: ButtonControlType.filled,
  colorType: ButtonColorType.primary,
  buttonSize: ButtonSize.m,
  onButtonClick: () => {
    console.log("按钮被点击");
  }
})

// 带图标的按钮
ButtonControl({
  content: {
    type: ButtonContent.iconWithText,
  text: "发送",
  icon: $r("app.media.icon_send"),
    iconPosition: ButtonIconPosition.start
  },
  ButtonControlType: ButtonControlType.filled,
  colorType: ButtonColorType.primary,
  buttonSize: ButtonSize.m,
  onButtonClick: () => {
    console.log("发送按钮被点击");
  }
})

// 纯图标按钮
ButtonControl({
  content: {
    type: ButtonContent.iconOnly,
    icon: $r("app.media.icon_settings")
  },
  ButtonControlType: ButtonControlType.outlined,
  colorType: ButtonColorType.secondary,
  buttonSize: ButtonSize.m,
  onButtonClick: () => {
    console.log("设置按钮被点击");
  }
})
```

#### Button 组件 API

| 参数                | 类型                  | 默认值     | 说明       |
|-------------------|---------------------|---------|----------|
| content           | ButtonContentParams | -       | 按钮内容配置   |
| isEnabled         | boolean             | true    | 是否启用     |
| ButtonControlType | ButtonControlType   | filled  | 按钮类型     |
| colorType         | ButtonColorType     | primary | 颜色类型     |
| buttonSize        | ButtonSize          | l       | 按钮尺寸     |
| onButtonClick     | () => void          | -       | 点击回调     |

#### 枚举类型

**ButtonControlType（按钮类型）**

- `filled`: 填充按钮
- `outlined`: 描边按钮
- `text`: 文本按钮

**ButtonColorType（颜色类型）**

- `primary`: 主要颜色（品牌色）
- `secondary`: 次要颜色（灰色）
- `danger`: 危险颜色（红色）

**ButtonSize（按钮尺寸）**

- `xs`: 超小尺寸
- `s`: 小尺寸
- `m`: 中等尺寸
- `l`: 大尺寸

**ButtonContent（按钮内容类型）**

- `textOnly`: 纯文本按钮
- `iconOnly`: 纯图标按钮
- `iconWithText`: 图标+文本按钮

**ButtonIconPosition（图标位置）**

- `start`: 图标在文本左侧
- `end`: 图标在文本右侧

### Label 组件

标签组件提供多种样式和颜色。

#### 基本用法

```typescript
import { TagLabel, TagLabelColor, LabelSize } from 'atomic_x';

// 彩色标签
TagLabel({
  text: '成功标签',
  colorType: TagLabelColor.green,
  size: LabelSize.m
})

TagLabel({
  text: '警告标签',
  colorType: TagLabelColor.orange,
  size: LabelSize.m
})

TagLabel({
  text: '错误标签',
  colorType: TagLabelColor.red,
  size: LabelSize.m
})

TagLabel({
  text: '信息标签',
  colorType: TagLabelColor.blue,
  size: LabelSize.m
})
```

#### Label 组件 API

| 参数        | 类型             | 默认值 | 说明   |
|-----------|----------------|-----|------|
| text      | string         | -   | 标签文本 |
| colorType | TagLabelColor  | -   | 颜色类型 |
| size      | LabelSize      | m   | 标签尺寸 |

#### 枚举类型

**TagLabelColor（标签颜色）**

- `green`: 绿色（成功）
- `orange`: 橙色（警告）
- `red`: 红色（错误）
- `blue`: 蓝色（信息）

**LabelSize（标签尺寸）**

- `s`: 小尺寸
- `m`: 中等尺寸
- `l`: 大尺寸

### Slider 滑块组件

Slider组件提供了一个可拖拽的滑块控件，支持水平和垂直方向。

#### 基本用法

```typescript
import { SliderControl, SliderOrientation } from 'atomic_x';

@State sliderValue: number = 50;
@State verticalSliderValue: number = 30;

// 水平滑块
SliderControl({
  value: this.sliderValue,
  orientation: SliderOrientation.Horizontal,
  valueRange: [0, 100],
  onValueChange: (value: number) => {
    this.sliderValue = Math.round(value);
  }
})

// 垂直滑块
SliderControl({
  value: this.verticalSliderValue,
  orientation: SliderOrientation.Vertical,
  valueRange: [0, 100],
  onValueChange: (value: number) => {
    this.verticalSliderValue = Math.round(value);
  }
})
  .height(120)
  .width(48)
```

#### Slider 组件 API

| 参数名           | 类型                      | 默认值        | 说明       |
|---------------|-------------------------|------------|----------|
| value         | number                  | 0          | 当前滑块值    |
| orientation   | SliderOrientation       | Horizontal | 滑块方向     |
| enabled       | boolean                 | true       | 是否启用滑块   |
| valueRange    | [number, number]        | [0, 100]   | 滑块值范围    |
| showTooltip   | boolean                 | false      | 是否显示工具提示 |
| onValueChange | (value: number) => void | -          | 值变化回调    |

#### 枚举类型

**SliderOrientation（滑块方向）**

- `Horizontal`: 水平方向
- `Vertical`: 垂直方向

### Switch 开关组件

开关组件提供多种类型和尺寸。

#### 基本用法

```typescript
import { SwitchView, SwitchType } from 'atomic_x';

SwitchView({
  checked: true,
  type: SwitchType.Basic,
  onCheckedChange: (checked: boolean) => {
    console.log("开关状态:", checked);
  }
})
```

### Badge 徽章组件

徽章组件用于显示数字或圆点标记。

#### 基本用法

```typescript
import { BadgeControl, BadgeType } from 'atomic_x';

// 文本徽章
BadgeControl({
  type: BadgeType.Text,
  text: "99+"
})

// 圆点徽章
BadgeControl({
  type: BadgeType.Dot
})
```

#### Badge 组件 API

| 参数   | 类型        | 默认值 | 说明   |
|------|-----------|-----|------|
| type | BadgeType | -   | 徽章类型 |
| text | string    | -   | 徽章文本 |

#### 枚举类型

**BadgeType（徽章类型）**

- `Text`: 文本徽章
- `Dot`: 圆点徽章

### Avatar 头像组件

头像组件支持图片头像和首字母头像。

#### 基本用法

```typescript
import { Avatar } from 'atomic_x';

// 图片头像
Avatar({
  avatarUrl: "https://example.com/avatar.jpg",
  displayName: "用户名",
  avatarSize: 40
})

// 首字母头像
Avatar({
  displayName: "张三",
  avatarSize: 40,
  avatarBackgroundColor: "#1C66E5",
  textColor: "#FFFFFF"
})
```

#### Avatar 组件 API

| 参数                    | 类型     | 默认值      | 说明       |
|-----------------------|--------|----------|----------|
| avatarUrl             | string | -        | 头像URL    |
| displayName           | string | -        | 显示名称     |
| avatarSize            | number | 34       | 头像尺寸     |
| avatarBorderRadius    | number | -        | 头像圆角     |
| avatarBackgroundColor | string | #1C66E5  | 背景颜色     |
| textColor             | string | #FFFFFF  | 文字颜色     |
| fontSize              | number | -        | 字体大小     |

### ActionSheet 操作表单组件

ActionSheet 提供底部弹出的操作选择界面。

#### 基本用法

```typescript
import { ActionSheet, ActionItem } from 'atomic_x';

const options: ActionItem[] = [
  { text: "编辑", value: "edit" },
  { text: "分享", value: "share" },
  { text: "删除", value: "delete", isDestructive: true }
];

ActionSheet({
  title: "选择操作",
  options: options,
  showCancel: true,
  cancelText: "取消",
  onActionSelected: (item: ActionItem) => {
    console.log("选择了:", item.text);
  },
  onDismiss: () => {
    console.log("取消了操作");
  }
})
```

#### ActionSheet 组件 API

| 参数               | 类型                          | 默认值  | 说明       |
|------------------|-----------------------------|----- |----------|
| title            | string \| Resource          | -    | 标题       |
| options          | ActionItem[]                | []   | 操作项列表    |
| showCancel       | boolean                     | true | 是否显示取消按钮 |
| cancelText       | string \| Resource          | 取消   | 取消按钮文本   |
| onActionSelected | (item: ActionItem) => void  | -    | 选择回调     |
| onDismiss        | () => void                  | -    | 取消回调     |

#### ActionItem 接口

| 属性            | 类型                                      | 默认值   | 说明       |
|---------------|----------------------------------------|-------|----------|
| text          | string \| Resource                     | -     | 操作项文本    |
| isDestructive | boolean                                | false | 是否为危险操作  |
| isEnabled     | boolean                                | true  | 是否启用     |
| value         | string \| number \| boolean \| object | -     | 附加数据     |
| isSelected    | boolean                                | false | 是否为选中项   |

### AlertDialog 警告对话框组件

AlertDialog 提供警告和确认对话框。

#### 基本用法

```typescript
import { AlertDialog } from 'atomic_x';

// 单按钮对话框
AlertDialog.show({
  title: "提示",
  message: "这是一个提示信息",
  confirmText: "确定",
  onConfirm: () => {
    console.log("确认操作");
  }
}, context);

// 双按钮对话框
AlertDialog.show({
  title: "确认删除",
  message: "确定要删除这个项目吗？",
  confirmText: "删除",
  cancelText: "取消",
  onConfirm: () => {
    console.log("确认删除");
  },
  onCancel: () => {
    console.log("取消删除");
  }
}, context);
```

## 工具类（Utils）

### Toast 弹窗提示

Toast 组件支持多种类型的全局消息提示。

#### 基本用法

```typescript
import { Toast, ToastType } from 'atomic_x';

// 不同类型的 Toast
Toast.info('这是信息提示', context)
Toast.success('操作成功', context)
Toast.warning('警告信息', context)
Toast.error('发生错误', context)
Toast.loading('加载中...', context)

// 自定义类型和时长
Toast.show('自定义内容', ToastType.Help, context, 4000)

// 简单原生 Toast
Toast.shortToast('短提示')
Toast.longToast('长提示')
```

#### Toast API

| 方法                                              | 说明                    |
|-------------------------------------------------|-----------------------|
| `Toast.info(message, context, duration?)`       | 信息提示                  |
| `Toast.success(message, context, duration?)`    | 成功提示                  |
| `Toast.warning(message, context, duration?)`    | 警告提示                  |
| `Toast.error(message, context, duration?)`      | 错误提示                  |
| `Toast.loading(message, context, duration?)`    | 加载提示                  |
| `Toast.show(message, type, context, duration?)` | 自定义类型和时长              |
| `Toast.shortToast(message, bottom?)`            | 原生短 Toast（无需 context） |
| `Toast.longToast(message, bottom?)`             | 原生长 Toast（无需 context） |
| `Toast.closeDialog()`                           | 主动关闭弹窗                |

### TextUtils 文本工具

文本处理相关的工具函数。

#### 基本用法

```typescript
import { TextUtils } from 'atomic_x';

// 获取首字母
const firstLetter = TextUtils.getFirstLetter("张三"); // "张"

// 判断是否为空
const isEmpty = TextUtils.isEmpty(""); // true
const isNotEmpty = TextUtils.isNotEmpty("hello"); // true
```

### TimeUtil 时间工具

时间处理相关的工具函数。

#### 基本用法

```typescript
import { TimeUtil } from 'atomic_x';

// 格式化时间
const formattedTime = TimeUtil.formatTime(Date.now());

// 获取相对时间
const relativeTime = TimeUtil.getRelativeTime(Date.now() - 3600000); // "1小时前"
```

### ImageSizeUtil 图片尺寸工具

图片尺寸计算相关的工具函数。

#### 基本用法

```typescript
import { ImageSizeUtil } from 'atomic_x';

// 计算图片显示尺寸
const size = ImageSizeUtil.calculateImageSize(800, 600, 200);
```

### Log 日志工具

日志输出工具。

#### 基本用法

```typescript
import { Log } from 'atomic_x';

Log.d("Tag", "Debug message");
Log.i("Tag", "Info message");
Log.w("Tag", "Warning message");
Log.e("Tag", "Error message");
```

## 页面（Pages）

### BaseComponent 基础组件页面

提供基础的样式和资源常量。

#### 基本用法

```typescript
import { BaseComponent } from 'atomic_x';

// 获取通用样式
const imageRadius = BaseComponent.imageRadius();
const titleFontColor = BaseComponent.titleFontColor();
const paddingStartEnd = BaseComponent.paddingStartEnd();

// 获取通用图标
const backIcon = BaseComponent.backIcon();
const forwardIcon = BaseComponent.forwardIcon();
const defaultUserIcon = BaseComponent.defaultUserIcon();
```

#### BaseComponent API

| 方法                      | 返回类型     | 说明       |
|-------------------------|----------|----------|
| `imageRadius()`         | Resource | 图片圆角     |
| `titleFontColor()`      | Resource | 标题字体颜色   |
| `contentFontColor()`    | Resource | 内容字体颜色   |
| `paddingStartEnd()`     | Resource | 左右内边距    |
| `lightPrimaryColor()`   | Resource | 浅色主题色    |
| `backIcon()`            | Resource | 返回图标     |
| `forwardIcon()`         | Resource | 前进图标     |
| `defaultUserIcon()`     | Resource | 默认用户图标   |
| `defaultReplaceImage()` | Resource | 默认替换图片   |

## 完整示例

以下是一个完整的组件测试示例，展示了如何使用各种组件：

```typescript
import {
  ButtonControl,
  ButtonContent,
  ButtonControlType,
  ButtonColorType,
  ButtonSize,
  ButtonIconPosition,
  TagLabel,
  TagLabelColor,
  LabelSize,
  SliderControl,
  SliderOrientation,
  Toast,
  ToastType,
  ThemeState
} from 'atomic_x';

@Component
struct ComponentTestView {
  @State sliderValue: number = 50;
  @State verticalSliderValue: number = 30;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();

  build() {
    Column() {
      Text('组件测试')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.currentTheme.textColorPrimary)
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 16 })

      // Button 测试
      Column() {
        Text('Button 组件测试')
          .fontSize(16)
          .fontColor(this.themeState.currentTheme.textColorPrimary)
          .margin({ bottom: 8 })

        Column({ space: 8 }) {
          // textOnly 按钮
          Row({ space: 8 }) {
            ButtonControl({
              content: {
                type: ButtonContent.textOnly,
                text: '主要按钮'
              },
              ButtonControlType: ButtonControlType.filled,
              colorType: ButtonColorType.primary,
              buttonSize: ButtonSize.m,
              onButtonClick: () => {
                Toast.show('主要按钮点击', ToastType.Info, this.getUIContext())
              }
            })

            ButtonControl({
              content: {
                type: ButtonContent.textOnly,
                text: '次要按钮'
              },
              ButtonControlType: ButtonControlType.filled,
              colorType: ButtonColorType.secondary,
              buttonSize: ButtonSize.m,
              onButtonClick: () => {
                Toast.show('次要按钮点击', ToastType.Info, this.getUIContext())
              }
            })
          }

          // iconOnly 按钮
          Row({ space: 8 }) {
            ButtonControl({
              content: {
                type: ButtonContent.iconOnly,
                icon: $r('sys.media.ohos_ic_public_device_phone')
              },
              ButtonControlType: ButtonControlType.filled,
              colorType: ButtonColorType.primary,
              buttonSize: ButtonSize.m,
              onButtonClick: () => {
                Toast.show('图标按钮点击', ToastType.Info, this.getUIContext())
              }
            })

            ButtonControl({
              content: {
                type: ButtonContent.iconOnly,
                icon: $r('sys.media.ohos_ic_public_device_phone')
              },
              ButtonControlType: ButtonControlType.outlined,
              colorType: ButtonColorType.secondary,
              buttonSize: ButtonSize.m,
              onButtonClick: () => {
                Toast.show('设置按钮点击', ToastType.Info, this.getUIContext())
              }
            })
          }

          // iconWithText 按钮
          Row({ space: 8 }) {
            ButtonControl({
              content: {
                type: ButtonContent.iconWithText,
                text: '添加好友',
                icon: $r('sys.media.ohos_ic_public_device_phone'),
                iconPosition: ButtonIconPosition.start
              },
              ButtonControlType: ButtonControlType.filled,
              colorType: ButtonColorType.primary,
              buttonSize: ButtonSize.m,
              onButtonClick: () => {
                Toast.show('添加好友点击', ToastType.Info, this.getUIContext())
              }
            })

            ButtonControl({
              content: {
                type: ButtonContent.iconWithText,
                text: '设置',
                icon: $r('sys.media.ohos_ic_public_device_phone'),
                iconPosition: ButtonIconPosition.end
              },
              ButtonControlType: ButtonControlType.outlined,
              colorType: ButtonColorType.secondary,
              buttonSize: ButtonSize.m,
              onButtonClick: () => {
                Toast.show('设置点击', ToastType.Info, this.getUIContext())
              }
            })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 20 })

      // Label 测试
      Column() {
        Text('Label 组件测试')
          .fontSize(16)
          .fontColor(this.themeState.currentTheme.textColorPrimary)
          .margin({ bottom: 8 })

        Row() {
          TagLabel({
            text: '成功标签',
            colorType: TagLabelColor.green,
            size: LabelSize.m
          })

          Row() {
            TagLabel({
              text: '警告标签',
              colorType: TagLabelColor.orange,
              size: LabelSize.m
            })
          }
          .margin({ left: 8 })

          Row() {
            TagLabel({
              text: '错误标签',
              colorType: TagLabelColor.red,
              size: LabelSize.m
            })
          }
          .margin({ left: 8 })

          Row() {
            TagLabel({
              text: '信息标签',
              colorType: TagLabelColor.blue,
              size: LabelSize.m
            })
          }
          .margin({ left: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 20 })

      // Slider 测试
      Column() {
        Text('Slider 组件测试')
          .fontSize(16)
          .fontColor(this.themeState.currentTheme.textColorPrimary)
          .margin({ bottom: 8 })

        // 水平滑块
        Column() {
          Text(`水平滑块值: ${this.sliderValue}`)
            .fontSize(14)
            .fontColor(this.themeState.currentTheme.textColorSecondary)
            .margin({ bottom: 8 })

          SliderControl({
            value: this.sliderValue,
            orientation: SliderOrientation.Horizontal,
            valueRange: [0, 100],
            onValueChange: (value: number) => {
              this.sliderValue = Math.round(value);
            }
          })
            .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 16 })

        // 垂直滑块
        Row() {
          Column() {
            Text(`垂直滑块值: ${this.verticalSliderValue}`)
              .fontSize(14)
              .fontColor(this.themeState.currentTheme.textColorSecondary)
              .margin({ bottom: 8 })
          }
          .layoutWeight(1)

          SliderControl({
            value: this.verticalSliderValue,
            orientation: SliderOrientation.Vertical,
            valueRange: [0, 100],
            onValueChange: (value: number) => {
              this.verticalSliderValue = Math.round(value);
            }
          })
            .height(120)
            .width(48)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(this.themeState.currentTheme.bgColorBubbleReciprocal)
    .borderRadius(12)
    .padding(16)
    .margin({ top: 16, left: 16, right: 16 })
  }
}
```

## 开发指南

### 引入组件

```typescript
// 导入所需组件
import { 
  ButtonControl,
  TagLabel,
  SliderControl,
  Toast,
  AlertDialog,
  BadgeControl,
  Avatar,
  ActionSheet,
  SwitchView,
  ThemeState,
  TextUtils,
  TimeUtil,
  ImageSizeUtil,
  Log
} from 'atomic_x';
```

### 主题集成

所有组件都支持主题系统，通过 `ThemeState` 管理：

```typescript
@StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();

// 在组件中使用主题颜色
.fontColor(this.themeState.currentTheme.textColorPrimary)
.backgroundColor(this.themeState.currentTheme.bgColorOperate)
```

### 最佳实践

1. **一致性**：使用统一的组件库确保 UI 一致性
2. **主题适配**：所有组件都应支持主题切换
3. **响应式**：考虑不同屏幕尺寸的适配
4. **性能优化**：合理使用状态管理，避免不必要的重渲染
5. **用户体验**：提供适当的反馈和交互效果

## 注意事项

- 所有组件都需要在 HarmonyOS ArkTS 环境中使用
- Toast 等需要 UIContext 的组件，确保传入正确的上下文
- 使用主题系统时，确保 ThemeState 正确初始化
- 图标资源需要在项目中正确配置

## 更新日志

### v1.0.0
- 初始版本发布
- 包含基础组件：Button、Label、Slider、Switch、Badge、Avatar、ActionSheet、AlertDialog
- 集成主题系统
- 提供完整的工具类支持