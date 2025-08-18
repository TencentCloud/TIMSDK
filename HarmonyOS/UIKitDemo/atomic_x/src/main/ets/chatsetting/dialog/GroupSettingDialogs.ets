import { ThemeState, Toast, ActionSheet, ActionItem } from '../../basecomponent/Index';
export interface ActionButtonConfig {
  text: string | Resource;
  action: string;
  color?: string;
  showDivider?: boolean;
}
@CustomDialog
export struct JoinGroupMethodDialog {
  
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  currentOpt: string = '';
  onSelect?: (opt: string) => void;
  onCancel?: () => void;
  controller: CustomDialogController;

  build() {
    ActionSheet({
      options: [
        {
          text: $r('app.string.chatsetting_forbid_add_group'),
          value: 'V2TIM_GROUP_ADD_FORBID',
          isSelected: this.currentOpt === 'V2TIM_GROUP_ADD_FORBID'
        },
        {
          text: $r('app.string.chatsetting_require_admin_approval'),
          value: 'V2TIM_GROUP_ADD_AUTH',
          isSelected: this.currentOpt === 'V2TIM_GROUP_ADD_AUTH'
        },
        {
          text: $r('app.string.chatsetting_auto_approve'),
          value: 'V2TIM_GROUP_ADD_ANY',
          isSelected: this.currentOpt === 'V2TIM_GROUP_ADD_ANY'
        }
      ],
      onActionSelected: (item: ActionItem) => {
        if (this.onSelect) {
          this.onSelect(item.value as string);
        }
      },
      onDismiss: this.onCancel,
      controller: this.controller
    })
  }
}
@CustomDialog
export struct InviteGroupMethodDialog {
  
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  currentOpt: string = '';
  onSelect?: (opt: string) => void;
  onCancel?: () => void;
  controller: CustomDialogController;

  build() {
    ActionSheet({
      options: [
        {
          text: $r('app.string.chatsetting_forbid_invite'),
          value: 'V2TIM_GROUP_ADD_FORBID',
          isSelected: this.currentOpt === 'V2TIM_GROUP_ADD_FORBID'
        },
        {
          text: $r('app.string.chatsetting_require_admin_approval'),
          value: 'V2TIM_GROUP_ADD_AUTH',
          isSelected: this.currentOpt === 'V2TIM_GROUP_ADD_AUTH'
        },
        {
          text: $r('app.string.chatsetting_auto_approve'),
          value: 'V2TIM_GROUP_ADD_ANY',
          isSelected: this.currentOpt === 'V2TIM_GROUP_ADD_ANY'
        }
      ],
      onActionSelected: (item: ActionItem) => {
        if (this.onSelect) {
          this.onSelect(item.value as string);
        }
      },
      onDismiss: this.onCancel,
      controller: this.controller
    })
  }
}
@CustomDialog
export struct GroupNameEditDialog {
  
  private static readonly BUTTON_HEIGHT: number = 56;
  
  private static readonly BOTTOM_RADIUS: number = 14;
  
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  
  title: string | Resource = $r('app.string.chatsetting_edit_group_name');
  currentName: string = '';
  placeholder: string | Resource = $r('app.string.chatsetting_input_group_name');
  helpText: string | Resource = $r('app.string.chatsetting_group_name_help_text');
  maxLength: number = 30;
  onSave?: (newName: string) => void;
  onCancel?: () => void;
  controller: CustomDialogController;
  @State inputText: string = '';

  aboutToAppear() {
    this.inputText = this.currentName;
  }

  build() {
    Column() {
      
      Column() {
        
        Row() {
          Text(this.title)
            .fontSize(17)
            .fontFamily('PingFang HK')
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeState.colors.textColorPrimary)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(GroupNameEditDialog.BUTTON_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        // Divider
        Divider()
          .height(0.4)
          .color(this.themeState.colors.strokeColorPrimary)
          .width('100%')

        
        Column() {
          TextInput({ text: this.inputText, placeholder: this.placeholder })
            .fontSize(17)
            .fontFamily('PingFang HK')
            .fontWeight(400)
            .fontColor(this.themeState.colors.textColorPrimary)
            .backgroundColor('transparent')
            .border({ width: 0 })
            .padding({
              left: 16,
              right: 16,
              top: 12,
              bottom: 12
            })
            .width('100%')
            .onChange((value: string) => {
              this.inputText = value;
            })
            .maxLength(this.maxLength)

          
          if (this.helpText) {
            Text(this.helpText)
              .fontSize(14)
              .fontFamily('PingFang HK')
              .fontWeight(400)
              .fontColor(this.themeState.colors.textColorSecondary)
              .padding({ left: 16, right: 16, bottom: 12 })
              .width('100%')
          }
        }
        .width('100%')

        // Divider
        Divider()
          .height(0.4)
          .color(this.themeState.colors.strokeColorPrimary)
          .width('100%')

        
        Button() {
          Text($r('app.string.chatsetting_confirm'))
            .fontSize(17)
            .fontFamily('PingFang HK')
            .fontWeight(400)
            .fontColor(this.inputText.trim().length > 0 ? this.themeState.colors.textColorLink :
            this.themeState.colors.textColorSecondary)
            .textAlign(TextAlign.Center)
        }
        .backgroundColor(this.themeState.colors.bgColorBubbleReciprocal)
        .height(GroupNameEditDialog.BUTTON_HEIGHT)
        .width('100%')
        .enabled(this.inputText.trim().length > 0)
        .onClick(() => this.handleSave())
      }
      .width('100%')
      .borderRadius(12)
      .backgroundColor(this.themeState.colors.bgColorBubbleReciprocal)
    }
    .width('100%')
    .padding(16)
    .margin({ bottom: 38 })
  }

  private handleSave() {
    const trimmedText = this.inputText.trim();
    if (trimmedText.length === 0) {
      return;
    }

    if (this.onSave) {
      this.onSave(trimmedText);
    }

    this.controller.close();
  }
} 