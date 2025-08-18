import { TextUtils, ThemeState, Toast } from '../../basecomponent/Index';
import { Member } from 'chatengine';
export interface UserInfo {
  id: string;
  userID: string;
  avatarURL?: string;
  displayName: string;
  subtitle?: string | Resource;
  isDisabled: boolean;
}
export interface UserPickerParams {
  title?: string | Resource;
  userList: UserInfo[];
  preSelectedUsers?: string[]; 
  maxSelectCount?: number; 
  confirmButtonText?: string | Resource; 
  action?: string; 
}
@Component
export struct UserPickerView {
  
  private static readonly CELL_HEIGHT: number = 64; 
  private static readonly AVATAR_SIZE: number = 40; 
  private static readonly SELECTED_AVATAR_SIZE: number = 50; 
  private static readonly HORIZONTAL_PADDING: number = 16; 
  private static readonly BORDER_RADIUS: number = 12; 
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  
  title: string | Resource = $r('app.string.chatsetting_select_user');
  userList: UserInfo[] = [];
  preSelectedUsers: string[] = []; 
  maxSelectCount: number = -1; 
  confirmButtonText: string | Resource = $r('app.string.chatsetting_complete');
  action: string = ''; 
  onBack?: () => void;
  onConfirm?: (selectedUsers: UserInfo[], action: string) => void;
  dialogController?: CustomDialogController;
  onDialogClose?: () => void;
  
  @State preSelectedUsersSet: Set<string> = new Set();
  @State selectedUsers: Set<string> = new Set();
  @State selectedUsersOrder: string[] = []; 

  
  public static convertMemberToUserInfo(member: Member): UserInfo {
    return {
      id: member.userID,
      userID: member.userID,
      avatarURL: member.faceURL,
      displayName: member.nameCard || member.nickName || member.userID,
      subtitle: UserPickerView.getRoleDisplayName(member.role),
      isDisabled: false
    };
  }

  
  private static getRoleDisplayName(role: number): string {
    switch (role) {
      case 400: // GroupMemberRole.OWNER
        return TextUtils.getResourceString($r('app.string.chatsetting_owner_role'));
      case 300: // GroupMemberRole.ADMIN
        return TextUtils.getResourceString($r('app.string.chatsetting_admin_role'));
      case 200: // GroupMemberRole.MEMBER
      default:
        return TextUtils.getResourceString($r('app.string.chatsetting_regular_member_role'));
    }
  }

  aboutToAppear(): void {
    
    this.preSelectedUsersSet = new Set(this.preSelectedUsers || []);
    console.log('[UserPickerPage] aboutToAppear - Title:', this.title);
    console.log('[UserPickerPage] aboutToAppear - User list length:', this.userList.length);
    console.log('[UserPickerPage] aboutToAppear - Action:', this.action);
  }

  build() {
    Column() {
      
      this.NavigationBarBuilder()

      
      if (this.selectedUsersOrder.length > 0) {
        this.SelectedUsersBuilder()
        Divider()
          .height(1)
          .color(this.themeState.colors.strokeColorSecondary)
      }

      
      this.UserListBuilder()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.colors.bgColorTopBar)
  }

  @Builder
  NavigationBarBuilder() {
    Row() {
      
      Button($r('app.string.chatsetting_cancel_button'))
        .fontSize(17)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorLink)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.closeDialog();
        })

      Blank()

      // Title
      Text(this.title)
        .fontSize(18)
        .fontWeight(600)
        .fontFamily('SF Pro Display')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()

      
      Button(this.confirmButtonText)
        .fontSize(17)
        .fontWeight(600)
        .fontFamily('SF Pro Text')
        .fontColor(this.selectedUsersOrder.length > 0 ? this.themeState.colors.textColorLink :
        this.themeState.colors.textColorSecondary)
        .backgroundColor(Color.Transparent)
        .enabled(this.selectedUsersOrder.length > 0)
        .onClick(() => {
          this.handleComplete();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)

    // Divider
    Divider()
      .height(0.5)
      .color(this.themeState.colors.strokeColorSecondary)
  }

  @Builder
  SelectedUsersBuilder() {
    Column({ space: 0 }) {
      // Title
      Row() {
        Text(`已选择 ${this.selectedUsersOrder.length} 人`)
          .fontSize(13)
          .fontWeight(400)
          .fontFamily('SF Pro Text')
          .fontColor(this.themeState.colors.textColorSecondary)
        Blank()
      }
      .padding({
        left: 16,
        right: 16,
        top: 12,
        bottom: 8
      })

      
      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.getSelectedUsers(), (user: UserInfo) => {
            this.SelectedUserItemBuilder(user);
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ bottom: 12 })
    }
    .backgroundColor(this.themeState.colors.bgColorTopBar)
  }

  @Builder
  SelectedUserItemBuilder(user: UserInfo) {
    Column({ space: 4 }) {
      // Avatar
      Stack() {
        if (user.avatarURL && user.avatarURL.length > 0) {
          Image(user.avatarURL)
            .width(UserPickerView.SELECTED_AVATAR_SIZE)
            .height(UserPickerView.SELECTED_AVATAR_SIZE)
            .borderRadius(UserPickerView.SELECTED_AVATAR_SIZE / 2)
        } else {
          Circle()
            .width(UserPickerView.SELECTED_AVATAR_SIZE)
            .height(UserPickerView.SELECTED_AVATAR_SIZE)
            .fill(this.themeState.colors.textColorLink)

          Text(TextUtils.getAvatarLetter(user.displayName))
            .fontSize(20)
            .fontWeight(500)
            .fontColor(this.themeState.colors.textColorButton)
        }
      }

      
      Text(user.displayName)
        .fontSize(12)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(UserPickerView.SELECTED_AVATAR_SIZE)
        .textAlign(TextAlign.Center)
    }
  }

  @Builder
  UserListBuilder() {
    Scroll() {
      Column({ space: 1 }) {
        ForEach(this.userList, (user: UserInfo) => {
          this.UserRowBuilder(user)
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
      .padding({ bottom: 20 }) 
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor(this.themeState.colors.bgColorTopBar)
    .scrollBar(BarState.Auto)
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.TopStart)
  }

  @Builder
  UserRowBuilder(user: UserInfo) {
    Row({ space: 12 }) {
      
      Checkbox()
        .select(this.isUserSelected(user.userID))
        .enabled(!(user.isDisabled || this.preSelectedUsersSet.has(user.userID)))
        .onChange((value: boolean) => {
          if (!(user.isDisabled || this.preSelectedUsersSet.has(user.userID))) {
            this.handleUserToggleFromCheckbox(user, value);
          }
        })

      // Avatar
      Stack() {
        if (user.avatarURL && user.avatarURL.length > 0) {
          Image(user.avatarURL)
            .width(UserPickerView.AVATAR_SIZE)
            .height(UserPickerView.AVATAR_SIZE)
            .borderRadius(UserPickerView.AVATAR_SIZE / 2)
            .objectFit(ImageFit.Cover)
        } else {
          Circle()
            .width(UserPickerView.AVATAR_SIZE)
            .height(UserPickerView.AVATAR_SIZE)
            .fill(this.themeState.colors.textColorLink)

          Text(TextUtils.getAvatarLetter(user.displayName))
            .fontSize(16)
            .fontWeight(500)
            .fontColor(this.themeState.colors.textColorButton)
        }
      }

      // User info
      Column({ space: 2 }) {
        Text(user.displayName)
          .fontSize(17)
          .fontWeight(400)
          .fontFamily('SF Pro Text')
          .fontColor(user.isDisabled || this.preSelectedUsersSet.has(user.userID) ?
          this.themeState.colors.textColorSecondary : this.themeState.colors.textColorPrimary)
          .alignSelf(ItemAlign.Start)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (user.subtitle) {
          Text(user.subtitle)
            .fontSize(13)
            .fontWeight(400)
            .fontFamily('SF Pro Text')
            .fontColor(this.themeState.colors.textColorSecondary)
            .alignSelf(ItemAlign.Start)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }

        if (this.preSelectedUsersSet.has(user.userID)) {
          Text($r('app.string.chatsetting_user_picker_selected_tag'))
            .fontSize(12)
            .fontWeight(400)
            .fontFamily('SF Pro Text')
            .fontColor(this.themeState.colors.textColorTertiary)
            .alignSelf(ItemAlign.Start)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      Blank()
    }
    .width('100%')
    .height(UserPickerView.CELL_HEIGHT)
    .padding({
      left: UserPickerView.HORIZONTAL_PADDING,
      right: UserPickerView.HORIZONTAL_PADDING,
      top: 8,
      bottom: 8
    })
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }

  onBackPress(): boolean {
    this.handleComplete();
    return true;
  }

  
  private closeDialog(): void {
    if (this.dialogController) {
      
      this.dialogController.close();
      if (this.onDialogClose) {
        this.onDialogClose();
      }
    } else if (this.onBack) {
      
      this.onBack();
    } else {
      console.warn('[UserPickerPage] 没有提供关闭方式');
    }
  }

  
  private getSelectedUsers(): UserInfo[] {
    const selectedUserList: UserInfo[] = [];
    for (const userID of this.selectedUsersOrder) {
      const user = this.userList.find(u => u.userID === userID);
      if (user) {
        selectedUserList.push(user);
      }
    }
    return selectedUserList;
  }

  
  private isUserSelected(userID: string): boolean {
    return this.selectedUsers.has(userID) || this.preSelectedUsersSet.has(userID);
  }

  
  private handleUserToggleFromCheckbox(user: UserInfo, isSelected: boolean): void {
    if (isSelected) {
      
      if (this.selectedUsers.has(user.userID)) {
        return;
      }

      
      if (this.maxSelectCount > 0 && this.selectedUsersOrder.length >= this.maxSelectCount) {
        Toast.shortToast(TextUtils.getResourceString($r('app.string.chatsetting_max_select_tip'))
          .replace('{max}', this.maxSelectCount.toString()));
        return;
      }

      
      this.selectedUsers.add(user.userID);
      this.selectedUsersOrder.push(user.userID);
    } else {
      
      this.selectedUsers.delete(user.userID);
      const index = this.selectedUsersOrder.indexOf(user.userID);
      if (index > -1) {
        this.selectedUsersOrder.splice(index, 1);
      }
    }
  }

  
  private handleComplete(): void {
    if (this.selectedUsersOrder.length === 0) {
      this.closeDialog();
      return;
    }

    
    const selectedUserList: UserInfo[] = [];
    for (const userID of this.selectedUsersOrder) {
      const user = this.userList.find(u => u.userID === userID);
      if (user) {
        selectedUserList.push(user);
      }
    }

    console.log('[UserPickerPage] handleComplete - Returning with action:', this.action, 'users:',
      selectedUserList.length);

    
    if (this.onConfirm) {
      this.onConfirm(selectedUserList, this.action);
    }

    this.closeDialog();
  }
}
