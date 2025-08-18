import { ThemeState, Colors, AppBuilderConfig } from '../Index';
import { GlobalAvatarShape } from '../utils/AppBuilderHelper';
import TextUtils from '../utils/TextUtils';

// Add all enum definitions, aligned with Swift version

export enum AvatarType {
  Image = 'image',
  Text = 'text',
  Symbol = 'symbol',
  Local = 'local'
}

export enum AvatarSize {
  XS = 24,
  S = 32,
  M = 40,
  L = 48,
  XL = 64,
  XXL = 96
}

export enum AvatarShape {
  Round = 'round',
  RoundedRectangle = 'roundedRectangle',
  Rectangle = 'rectangle'
}

export enum AvatarBadgePosition {
  Up = 'up',
  Bottom = 'bottom'
}

export enum AvatarStatus {
  None = 'none',
  Online = 'online',
  Offline = 'offline'
}

export enum AvatarBadge {
  None = 'none',
  Dot = 'dot',
  Text = 'text',
  Count = 'count'
}

// Avatar content types - aligned with Swift AvatarContent enum
export enum AvatarContentType {
  Image = 'image',
  Text = 'text',
  Symbol = 'symbol',
  Local = 'local'
}

export interface AvatarContent {
  type: AvatarContentType;
  url?: string;
  name?: string;
  isGroup?: boolean;
}

// Badge configuration interface
export interface AvatarBadgeConfig {
  type: AvatarBadge;
  text?: string;
  count?: number;
  position?: AvatarBadgePosition;
}

@Component
export struct Avatar {
  @Prop content?: AvatarContent;
  @Prop avatarSize: AvatarSize = AvatarSize.M;
  @Prop status?: AvatarStatus;
  @Prop badge?: AvatarBadgeConfig;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State private imageLoaded: boolean = false;
  @State private imageError: boolean = false;
  @State private config: AppBuilderConfig = AppBuilderConfig.getInstance();
  @Prop shape?: AvatarShape = this.convertShape(this.config.avatarShape);

  aboutToAppear() {
    this.imageLoaded = false;
    this.imageError = false;
  }

  build() {
    Stack() {
      // Main avatar content
      this.AvatarContentBuilder()

      // Status indicator
      if (this.status && this.status !== AvatarStatus.None) {
        this.StatusDotBuilder()
      }

      // Badge
      if (this.badge && this.badge.type !== AvatarBadge.None) {
        this.BadgeBuilder()
      }
    }
    .width(this.avatarSize)
    .height(this.avatarSize)
  }

  @Builder
  AvatarContentBuilder() {
    Stack() {
      // Render by content type or traditional way
      if (this.content) {
        this.renderByContentType()
      }
    }
  }

  @Builder
  renderByContentType() {
    if (this.content) {
      if (this.content.type === AvatarContentType.Image) {
        if (this.content.url && this.imageLoaded && !this.imageError) {
          Image(this.content.url)
            .width(this.avatarSize)
            .height(this.avatarSize)
            .objectFit(ImageFit.Cover)
            .borderRadius(this.computedBorderRadius())
        } else {
          this.DefaultAvatarBuilder(this.content.name)
        }

        // Hidden image for loading detection
        if (this.content.url) {
          Image(this.content.url)
            .width(0)
            .height(0)
            .visibility(Visibility.Hidden)
            .onComplete(() => {
              this.imageLoaded = true;
              this.imageError = false;
            })
            .onError(() => {
              this.imageLoaded = false;
              this.imageError = true;
            })
        }
      } else if (this.content.type === AvatarContentType.Text) {
        this.DefaultAvatarBuilder(this.content.name)
      } else if (this.content.type === AvatarContentType.Symbol) {
        this.SymbolAvatarBuilder()
      } else if (this.content.type === AvatarContentType.Local) {
        this.LocalAvatarBuilder(this.content.isGroup)
      }
    }
  }

  @Builder
  DefaultAvatarBuilder(name?: string) {
    Stack() {
      // Render different background shapes based on shape
      if (this.shape === AvatarShape.Round) {
        Circle()
          .width(this.avatarSize)
          .height(this.avatarSize)
          .fill(this.themeState.colors.bgColorAvatar)
          .borderRadius(this.computedBorderRadius())
      } else {
        Rect()
          .width(this.avatarSize)
          .height(this.avatarSize)
          .fill(this.themeState.colors.bgColorAvatar)
          .borderRadius(this.computedBorderRadius())
      }

      Text(TextUtils.getAvatarLetter(name || this.content?.name))
        .fontSize(this.avatarFontSize())
        .fontWeight(500)
        .fontColor(this.themeState.colors.textColorPrimary)
    }
  }

  @Builder
  SymbolAvatarBuilder() {
    Stack() {
      if (this.shape === AvatarShape.Round) {
        Circle()
          .width(this.avatarSize)
          .height(this.avatarSize)
          .fill(this.themeState.colors.bgColorAvatar)
          .borderRadius(this.computedBorderRadius())
      } else {
        Rect()
          .width(this.avatarSize)
          .height(this.avatarSize)
          .fill(this.themeState.colors.bgColorAvatar)
          .borderRadius(this.computedBorderRadius())
      }

      // Default contact icon - can be replaced with actual icon resource
      Text("👤")
        .fontSize(this.avatarSize * 0.6)
        .fontColor(this.themeState.colors.textColorPrimary)
    }
  }

  @Builder
  LocalAvatarBuilder(isGroup?: boolean) {
    // Local default avatar - can be replaced with actual image resource
    Text(isGroup ? "👥" : "👤")
      .fontSize(this.avatarSize * 0.6)
      .fontColor(this.themeState.colors.textColorPrimary)
  }

  @Builder
  StatusDotBuilder() {
    if (this.status && this.status !== AvatarStatus.None) {
      Circle()
        .width(8)
        .height(8)
        .fill(this.statusColor())
        .stroke(this.themeState.colors.bgColorDefault)
        .strokeWidth(1)
        .position({
          x: this.avatarSize - 8,
          y: this.avatarSize - 8
        })
    }
  }

  @Builder
  BadgeBuilder() {
    if (this.badge && this.badge.type !== AvatarBadge.None) {
      if (this.badge.type === AvatarBadge.Dot) {
        Circle()
          .width(10)
          .height(10)
          .fill(Color.Red)
          .position({ x: this.badgePositionX(), y: this.badgePositionY() })
      } else if (this.badge.type === AvatarBadge.Text && this.badge.text) {
        Text(this.badge.text)
          .fontSize(10)
          .fontColor(Color.White)
          .padding(4)
          .backgroundColor(Color.Red)
          .borderRadius(10)
          .position({ x: this.badgePositionX(), y: this.badgePositionY() })
      } else if (this.badge.type === AvatarBadge.Count && this.badge.count !== undefined) {
        Text(this.badge.count > 99 ? "99+" : this.badge.count.toString())
          .fontSize(10)
          .fontColor(Color.White)
          .padding(4)
          .backgroundColor(Color.Red)
          .borderRadius(10)
          .position({ x: this.badgePositionX(), y: this.badgePositionY() })
      }
    }
  }

  private avatarFontSize(): number {
    return Math.max(10, this.avatarSize * 0.4);
  }

  private badgePositionX(): number {
    return this.avatarSize - 10;
  }

  private badgePositionY(): number {
    const position = this.badge?.position || AvatarBadgePosition.Up;
    switch (position) {
      case AvatarBadgePosition.Up:
        return -1;
      case AvatarBadgePosition.Bottom:
        return this.avatarSize - 8;
      default:
        return -8;
    }
  }

  private computedBorderRadius(): number {
    const shape = this.shape;
    const size = this.avatarSize;

    switch (shape) {
      case AvatarShape.Round:
        return size / 2;
      case AvatarShape.RoundedRectangle:
        if (size <= AvatarSize.M) {
          return 4;
        }
        if (size <= AvatarSize.L) {
          return 8;
        }
        return 12;
      case AvatarShape.Rectangle:
        return 0;
      default:
        return size / 2;
    }
  }

  private statusColor(): string {
    switch (this.status) {
      case AvatarStatus.Online:
        return this.themeState.colors.textColorSuccess;
      case AvatarStatus.Offline:
        return Colors.GrayLight7;
      default:
        return 'transparent';
    }
  }

  private convertShape(shape: GlobalAvatarShape): AvatarShape {
    switch (shape) {
      case GlobalAvatarShape.CIRCULAR:
        return AvatarShape.Round;
      case GlobalAvatarShape.SQUARE:
        return AvatarShape.Rectangle;
      case GlobalAvatarShape.ROUNDED:
        return AvatarShape.RoundedRectangle;
      default:
        return AvatarShape.Round;
    }
  }
} 