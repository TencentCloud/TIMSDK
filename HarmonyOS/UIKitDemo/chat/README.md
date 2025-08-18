# UIKit-Next HarmonyOS

基于 HarmonyOS ArkTS 开发的下一代 UI 套件，提供完整的即时通讯界面解决方案。

## 项目架构

本项目采用模块化组件架构，将页面容器与业务组件分离：

```
uikit-next/harmony/
├── entry/                          # 主应用入口
│   ├── src/main/ets/pages/         # 页面容器层
│   │   ├── MainPage.ets           # 主页面（Tab导航）
│   │   ├── ContactPage.ets        # 联系人页面
│   │   ├── ConversationPage.ets   # 会话列表页面
│   │   └── ProfilePage.ets        # 个人资料页面
│   └── ...
└── components/                     # 业务组件库（外部引用）
    ├── ConversationList/           # 会话列表组件
    ├── ContactList/               # 联系人列表组件
    ├── MessageList/               # 消息列表组件
    └── ...
```

## 设计原则

### 1. 分层架构

- **页面层（Page）**：负责导航栏、搜索框等页面级UI元素
- **组件层（Component）**：专注具体业务逻辑和数据处理
- **状态层（State）**：统一管理IM数据和网络操作

### 2. 数据流

```
Page（用户交互）→ @State → @Prop → Component（业务处理）→ State（IM SDK）
```

### 3. 响应式设计

- 使用 `@Prop @Watch` 实现父子组件间的响应式数据传递
- 支持主题切换和多屏幕尺寸适配
- 基于 Figma 设计规范的现代化UI

## 主要功能

### 📱 主页面（MainPage）

- Tab 导航栏：消息、联系人、我的
- 底部角标显示未读消息数
- 主题管理集成

### 💬 会话列表（ConversationPage + ConversationListPage）

- **ConversationPage**：大标题、搜索框、编辑按钮
- **ConversationListPage**：会话列表、滑动操作、未读消息
- 支持搜索、删除、置顶等操作

### 👥 联系人列表（ContactPage + ContactListPage）

- **ContactPage**：标题栏"Contacts"、集成搜索框
- **ContactListPage**：
    - 管理选项：新联系人、群聊通知、我的群组、黑名单
    - 字母索引快速定位
    - 滑动操作：更多选项、发消息
    - 支持搜索、删除、设置备注等

### 👤 个人中心（ProfilePage）

- 用户信息展示
- 设置选项
- 主题切换

## 快速开始

### 1. 环境要求

- HarmonyOS DevEco Studio 4.0+
- API Level 9+
- ArkTS 开发环境

### 2. 项目配置

```json5
// oh-package.json5
{
  "dependencies": {
    "basecomponent": "file:../../components/Harmony/BaseComponent",
    "conversationlist": "file:../../components/Harmony/ConversationList",
    "contactlist": "file:../../components/Harmony/ContactList",
    "chatengine": "file:../../components/Harmony/State/ChatEngine"
  }
}
```

### 3. 使用示例

```typescript
// MainPage.ets - 主页面
@
Entry
@
Component
struct
MainPage
{
  @
  State
  currentTabIndex: number = 0;
  @
  State
  messageTabBadge: number = 0;

  build()
  {
    Tabs
    ({ barPosition: BarPosition.End })
    {
      TabContent()
      {
        ConversationPage({
          onBadgeUpdate: (count: number) => {
            this.messageTabBadge = count;
          }
        })
      }
      .
      tabBar(this.TabBarBuilder('消息', 0, this.messageTabBadge))

      TabContent()
      {
        ContactPage()
      }
      .
      tabBar(this.TabBarBuilder('联系人', 1))

      TabContent()
      {
        ProfilePage()
      }
      .
      tabBar(this.TabBarBuilder('我的', 2))
    }
  }
}
```

## 核心组件

### ContactPage 架构

```typescript
// 页面容器 - 负责UI框架
@
Component
export struct
ContactPage
{
  @
  State
  searchKeyword: string = '';

  @
  Builder
  NavigationBarBuilder()
  {
    // 标题栏 + 搜索框
  }

  build()
  {
    Column()
    {
      this.NavigationBarBuilder()
      ContactListPage({
        searchKeyword: this.searchKeyword, // 数据传递
        onSelectContact: this.handleContactSelect
      })
    }
  }
}

// 业务组件 - 负责数据处理
@
Component
export struct
ContactListPage
{
  @
  Prop @
  Watch('onSearchKeywordChanged')
  searchKeyword: string = '';

  onSearchKeywordChanged()
  {
    this.performSearch(); // 响应式搜索
  }
}
```

### 数据流示例

```typescript
// 1. 用户在搜索框输入
SearchBar.onChange((value: string) => {
  this.searchKeyword = value; // 更新 Page 状态
})

// 2. 通过 @Prop 传递给组件
ContactListPage({ searchKeyword: this.searchKeyword })

// 3. 组件响应数据变化
@
Prop @
Watch('onSearchKeywordChanged')
searchKeyword: string = '';

// 4. 自动执行业务逻辑
onSearchKeywordChanged()
{
  const results = this.contactListStore.searchContacts(this.searchKeyword);
}
```

## 主题系统

### 主题管理

```typescript
@
StorageLink('ThemeState')
ThemeState: ThemeState = ThemeState.getInstance();

// 主题颜色
ThemeState.currentTheme.textColorPrimary // 主要文字
ThemeState.currentTheme.textColorSecondary // 次要文字
ThemeState.currentTheme.bgColorOperate // 背景色
```

### 主题切换

```typescript
// 切换主题
ThemeState.switchTheme('dark'); // 或 'light'
```

## 国际化

项目支持多语言：

```typescript
// 字符串资源
Text($r('app.string.contacts_title')) // "联系人"
Text($r('app.string.search_placeholder')) // "搜索"
```

## 性能优化

### 1. 虚拟化列表

```typescript
// 使用 LazyForEach 实现大数据列表
LazyForEach(this.contactDataSource, (item: ContactInfo) => {
  ContactItemComponent({ contact: item })
})
```

### 2. 响应式更新

```typescript
// 精确的状态更新，避免全量刷新
@
Watch('onDataChanged')
contactList: ContactInfo[] = [];
```

### 3. 资源管理

```typescript
// 组件销毁时清理资源
aboutToDisappear()
{
  this.contactListStore.destroy();
}
```

## 开发指南

### 1. 添加新页面

1. 在 `entry/src/main/ets/pages/` 创建页面容器
2. 实现导航栏、搜索等页面级UI
3. 集成对应的业务组件
4. 在 MainPage 中添加导航

### 2. 创建业务组件

1. 在 `components/` 创建组件模块
2. 实现状态管理类（继承自 ChatEngine）
3. 设计响应式数据接口
4. 提供完整的错误处理

### 3. 调试建议

```typescript
// 启用日志,
console.info('[ComponentName] 状态信息');
console.error('[ComponentName] 错误信息:', error.message);
```

## 依赖管理

### 核心依赖

- `@tencentcloud/imsdk` - 腾讯云IM SDK
- `@kit.ArkUI` - HarmonyOS UI框架
- `basecomponent` - 基础组件库
- `chatengine` - 聊天引擎状态管理

### 组件依赖

```typescript
// 组件间依赖关系
MainPage →
ContactPage →
ContactListPage →
contactListStore
```

## 错误处理

### 统一错误格式

```typescript
interface ErrorResult {
code: number;
message: string; // 注意：使用 message 而不是 errorMessage
}
```

### 错误处理模式

```typescript
someOperation()
  .then(() => {
    // 成功处理
  })
  .catch((error: ErrorResult) => {
    console.error(`操作失败: ${error.message}`);
    // 显示用户友好的错误提示
  });
```

## 版本历史

### v2.0.0 (最新)

- 🏗️ **架构重构**：Page-Component 分层架构
- 🔍 **搜索优化**：响应式搜索系统
- 🎨 **UI 升级**：基于 Figma 设计规范
- 📱 **组件化**：移除页面入口，提升复用性
- 🛠️ **API 统一**：错误处理接口标准化

### v1.0.0

- 基础功能实现
- 单体页面架构

## 贡献指南

1. Fork 项目
2. 创建功能分支：`git checkout -b feature/AmazingFeature`
3. 提交更改：`git commit -m 'Add some AmazingFeature'`
4. 推送分支：`git push origin feature/AmazingFeature`
5. 开启 Pull Request

## 许可证

本项目基于 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 联系方式

- 项目地址：[https://github.com/tencentcloud/imsdk](https://github.com/tencentcloud/imsdk)
- 问题反馈：[Issues](https://github.com/tencentcloud/imsdk/issues)
- 文档中心：[腾讯云IM文档](https://cloud.tencent.com/document/product/269)
