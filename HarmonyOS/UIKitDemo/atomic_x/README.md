# Atomic_X - Unified Component Library for HarmonyOS

A comprehensive UI component library for HarmonyOS applications, providing unified design system components, base
controls, and utilities for building modern instant messaging and communication applications.

## Overview

Atomic_X is a cross-platform unified component library that combines all UI components into a single module for
HarmonyOS applications. It provides a complete set of reusable components with consistent design patterns, theming
support, and seamless integration with ChatEngine SDK.

## Features

- **🎨 Unified Design System**: Consistent colors, fonts, spacing, and radius across all components
- **🧩 Base Components**: Essential UI controls including buttons, avatars, labels, badges, and more
- **🎭 Theme Support**: Built-in light/dark theme support with customizable color schemes
- **📱 Responsive Design**: Adaptive layouts for different screen sizes and orientations
- **🔧 Type Safety**: Full TypeScript/ArkTS support with comprehensive type definitions
- **⚡ Performance**: Optimized for HarmonyOS with efficient rendering and memory usage
- **🌐 Cross-Platform**: Consistent API and behavior across HarmonyOS, iOS, and Android

## Installation

### Prerequisites

- HarmonyOS SDK API 9 or higher
- DevEco Studio 4.0 or later
- ChatEngine dependency (included)

### Add Dependency

Add the following dependency to your `oh-package.json5`:

```json5
{
  "dependencies": {
    "atomic_x": "^1.0.0"
  }
}
```

## Quick Start

### 1. Import Components

```typescript
import { 
  ButtonControl, 
  ButtonContent, 
  ButtonControlType, 
  ButtonColorType, 
  ButtonSize,
  Avatar,
  Colors,
  Fonts,
  Spacing 
} from 'atomic_x'
```

### 2. Basic Usage

```typescript
@Entry
@Component
struct MainPage {
  build() {
    Column({ space: Spacing.m }) {
      // Button Component
      ButtonControl({
        content: {
          type: ButtonContent.textOnly,
          text: "Get Started"
        },
        ButtonControlType: ButtonControlType.filled,
        colorType: ButtonColorType.primary,
        buttonSize: ButtonSize.m,
        onButtonClick: () => {
          console.log("Button clicked");
        }
      })
      
      // Avatar Component
      Avatar({
        url: "https://example.com/avatar.jpg",
        name: "User Name",
        size: AvatarSize.m,
        shape: AvatarShape.round
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background.primary)
  }
}
```

## Core Components

### 🔘 Button Component

Versatile button component with multiple styles and configurations.

#### Basic Usage

```typescript
// Text Only Button
ButtonControl({
  content: {
    type: ButtonContent.textOnly,
    text: "Confirm"
  },
  ButtonControlType: ButtonControlType.filled,
  colorType: ButtonColorType.primary,
  buttonSize: ButtonSize.m,
  onButtonClick: () => {
    // Handle click
  }
})

// Icon with Text Button
ButtonControl({
  content: {
    type: ButtonContent.iconWithText,
    text: "Send",
    icon: $r("app.media.icon_send"),
    iconPosition: ButtonIconPosition.start
  },
  ButtonControlType: ButtonControlType.outlined,
  colorType: ButtonColorType.secondary,
  buttonSize: ButtonSize.l,
  onButtonClick: () => {
    // Handle send
  }
})

// Icon Only Button
ButtonControl({
  content: {
    type: ButtonContent.iconOnly,
    icon: $r("app.media.icon_settings")
  },
  ButtonControlType: ButtonControlType.noBorder,
  colorType: ButtonColorType.primary,
  buttonSize: ButtonSize.s,
  onButtonClick: () => {
    // Handle settings
  }
})
```

#### Button API

| Parameter         | Type                | Default | Description                  |
|-------------------|---------------------|---------|------------------------------|
| content           | ButtonContentParams | -       | Button content configuration |
| ButtonControlType | ButtonControlType   | filled  | Button style type            |
| colorType         | ButtonColorType     | primary | Color theme                  |
| buttonSize        | ButtonSize          | m       | Button size                  |
| isEnabled         | boolean             | true    | Enable/disable state         |
| onButtonClick     | () => void          | -       | Click callback               |

#### Button Types

- `ButtonControlType.filled` - Solid background button
- `ButtonControlType.outlined` - Border-only button
- `ButtonControlType.noBorder` - Text-only button

#### Button Colors

- `ButtonColorType.primary` - Primary theme color
- `ButtonColorType.secondary` - Secondary theme color
- `ButtonColorType.danger` - Error/danger color

#### Button Sizes

- `ButtonSize.xs` - Extra small (24dp height)
- `ButtonSize.s` - Small (32dp height)
- `ButtonSize.m` - Medium (40dp height)
- `ButtonSize.l` - Large (48dp height)

### 👤 Avatar Component

Flexible avatar component supporting images, text, and various shapes.

#### Basic Usage

```typescript
// Image Avatar
Avatar({
  url: "https://example.com/avatar.jpg",
  name: "John Doe",
  size: AvatarSize.m,
  shape: AvatarShape.round
})

// Text Avatar
Avatar({
  name: "Jane Smith",
  size: AvatarSize.l,
  shape: AvatarShape.roundedRectangle
})

// Avatar with Status
Avatar({
  url: "https://example.com/avatar.jpg",
  name: "User",
  size: AvatarSize.m,
  shape: AvatarShape.round,
  status: AvatarStatus.online
})

// Avatar with Badge
Avatar({
  url: "https://example.com/avatar.jpg",
  name: "User",
  size: AvatarSize.m,
  shape: AvatarShape.round,
  badge: {
    type: BadgeType.count,
    value: 5
  }
})
```

#### Avatar API

| Parameter | Type         | Default | Description               |
|-----------|--------------|---------|---------------------------|
| url       | string       | -       | Avatar image URL          |
| name      | string       | -       | User name (fallback text) |
| size      | AvatarSize   | m       | Avatar size               |
| shape     | AvatarShape  | round   | Avatar shape              |
| status    | AvatarStatus | none    | Online status indicator   |
| badge     | BadgeConfig  | -       | Badge configuration       |
| onClick   | () => void   | -       | Click callback            |

## Theme System

### 🎨 Colors

Comprehensive color system with semantic naming.

```typescript
// Brand Colors
Colors.brand.primary
Colors.brand.secondary
Colors.brand.accent

// Background Colors
Colors.background.primary
Colors.background.secondary
Colors.background.elevated

// Text Colors
Colors.text.primary
Colors.text.secondary
Colors.text.disabled

// State Colors
Colors.state.success
Colors.state.warning
Colors.state.error
Colors.state.info
```

### 📝 Fonts

Typography system with consistent font sizes and weights.

```typescript
// Font Sizes
Fonts.size.xs    // 12sp
Fonts.size.s     // 14sp
Fonts.size.m     // 16sp
Fonts.size.l     // 18sp
Fonts.size.xl    // 20sp
Fonts.size.xxl   // 24sp

// Font Weights
Fonts.weight.regular   // 400
Fonts.weight.medium    // 500
Fonts.weight.semibold  // 600
Fonts.weight.bold      // 700
```

### 📏 Spacing

Consistent spacing system for layouts.

```typescript
Spacing.xs   // 4vp
Spacing.s    // 8vp
Spacing.m    // 16vp
Spacing.l    // 24vp
Spacing.xl   // 32vp
Spacing.xxl  // 48vp
```

### 🔄 Radius

Border radius system for consistent rounded corners.

```typescript
Radius.xs   // 4vp
Radius.s    // 8vp
Radius.m    // 12vp
Radius.l    // 16vp
Radius.xl   // 24vp
Radius.full // 50%
```

## Advanced Usage

### Custom Theme Implementation

```typescript
// Define custom colors
const customColors = {
  brand: {
    primary: '#FF6B6B',
    secondary: '#4ECDC4',
    accent: '#45B7D1'
  },
  background: {
    primary: '#FFFFFF',
    secondary: '#F8F9FA'
  }
}

// Apply custom theme
@Component
struct CustomThemedComponent {
  build() {
    Column() {
      ButtonControl({
        content: {
          type: ButtonContent.textOnly,
          text: "Custom Button"
        },
        ButtonControlType: ButtonControlType.filled,
        colorType: ButtonColorType.primary,
        buttonSize: ButtonSize.m
      })
    }
    .backgroundColor(customColors.background.primary)
  }
}
```

### Component Composition

```typescript
@Component
struct UserCard {
  @Prop user: UserInfo

  build() {
    Row({ space: Spacing.m }) {
      Avatar({
        url: this.user.avatar,
        name: this.user.name,
        size: AvatarSize.l,
        shape: AvatarShape.round,
        status: this.user.isOnline ? AvatarStatus.online : AvatarStatus.offline
      })
      
      Column({ space: Spacing.s }) {
        Text(this.user.name)
          .fontSize(Fonts.size.m)
          .fontWeight(Fonts.weight.semibold)
          .fontColor(Colors.text.primary)
        
        Text(this.user.status)
          .fontSize(Fonts.size.s)
          .fontColor(Colors.text.secondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      ButtonControl({
        content: {
          type: ButtonContent.textOnly,
          text: "Message"
        },
        ButtonControlType: ButtonControlType.outlined,
        colorType: ButtonColorType.primary,
        buttonSize: ButtonSize.s,
        onButtonClick: () => {
          // Start conversation
        }
      })
    }
    .width('100%')
    .padding(Spacing.m)
    .backgroundColor(Colors.background.elevated)
    .borderRadius(Radius.m)
  }
}
```

## Integration with ChatEngine

Atomic_X is designed to work seamlessly with ChatEngine:

```typescript
import { LoginStore } from 'chatengine'
import { ButtonControl, Avatar, Colors } from 'atomic_x'

@
Component
struct
ChatInterface
{
  private
  chatEngine = LoginStore.getInstance()
  @
  State
  loginStatus: LoginStatus = LoginStatus.unlogin

  build()
  {
    Column
    ({ space: Spacing.m })
    {
      if (this.loginStatus === LoginStatus.logged) {
        // Chat UI components using Atomic_X
        Avatar({
          url: this.chatEngine.loginUserInfo?.avatar,
          name: this.chatEngine.loginUserInfo?.name,
          size: AvatarSize.m
        })
      } else {
        ButtonControl({
          content: {
            type: ButtonContent.textOnly,
            text: "Login to Chat"
          },
          ButtonControlType: ButtonControlType.filled,
          colorType: ButtonColorType.primary,
          buttonSize: ButtonSize.m,
          onButtonClick: () => {
            // Login logic
          }
        })
      }
    }
  }
}
```

## Best Practices

1. **Consistent Theming**: Always use the provided color, font, and spacing tokens
2. **Component Composition**: Build complex UI by combining simple components
3. **Accessibility**: Ensure proper contrast ratios and touch target sizes
4. **Performance**: Use lazy loading for large lists and optimize re-renders
5. **Type Safety**: Leverage TypeScript types for better development experience

## Dependencies

- `chatengine`: ChatEngine SDK for HarmonyOS
- HarmonyOS SDK API 9+
- ArkTS/ETS runtime

## Platform Support

- **HarmonyOS**: API 9+ (Primary platform)
- **Cross-Platform**: Consistent API with iOS and Android versions

## Migration Guide

### From Individual Components

If migrating from separate component libraries:

1. Update imports to use `atomic_x` package
2. Replace individual component imports with unified imports
3. Update theme tokens to use the new design system
4. Test component behavior and styling

## Contributing

Please read our contributing guidelines before submitting pull requests.

## License

See LICENSE file for details.

## Support

For technical support and documentation:

- [Component Documentation](./src/main/ets/basecomponent/README.md)
- [HarmonyOS Development Guide](https://developer.harmonyos.com/)
- [Tencent Cloud IM Documentation](https://cloud.tencent.com/document/product/269)

## Changelog

See CHANGELOG.md for version history and updates.