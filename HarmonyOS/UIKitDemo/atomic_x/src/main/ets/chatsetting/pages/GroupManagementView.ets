import {
  TextUtils,
  ThemeState,
  Toast,
  Switch,
  SwitchSize,
  SwitchType,
  Avatar,
  AvatarContentType,
  AvatarSize
} from '../../basecomponent/Index';
import { LoginStore, GroupSettingStore, GroupSettingState, GroupType, Member } from 'chatengine';
import { UserInfo, UserPickerView, UserPickerParams } from './UserPickerView';

import { ImmersiveMode, LevelMode } from '@ohos.promptAction';

@CustomDialog
struct UserPickerDialogInManagement {
  controller: CustomDialogController;
  title: string | Resource = $r('app.string.chatsetting_select_user');
  userList: UserInfo[] = [];
  preSelectedUsers: string[] = [];
  maxSelectCount: number = -1;
  confirmButtonText: string | Resource = $r('app.string.chatsetting_complete');
  action: string = '';
  onConfirm?: (selectedUsers: UserInfo[], action: string) => void;

  build() {
    UserPickerView({
      title: this.title,
      userList: this.userList,
      preSelectedUsers: this.preSelectedUsers,
      maxSelectCount: this.maxSelectCount,
      confirmButtonText: this.confirmButtonText,
      action: this.action,
      onConfirm: this.onConfirm,
      onBack: () => {
        this.controller.close();
      }
    })
  }
}

@Component
export struct GroupManagementView {
  private static readonly CELL_HEIGHT: number = 56;
  private static readonly SECTION_MARGIN: number = 12;
  private static readonly HORIZONTAL_PADDING: number = 16;
  private static readonly BORDER_RADIUS: number = 12;
  @Provide themeState: ThemeState = ThemeState.getInstance();
  @State groupStore?: GroupSettingStore = undefined;
  @State groupState?: GroupSettingState = this.groupStore?.state;
  @State isLoading: boolean = true;
  groupID: string = '';
  onBack?: () => void;
  dialogController?: CustomDialogController;
  onDialogClose?: () => void;
  private userPickerDialogController?: CustomDialogController;

  aboutToAppear(): void {
    if (this.groupID) {
      this.groupStore = createGroupChatSettingStore(this.groupID);
      this.groupStore.registerListener();
      this.groupState = this.groupStore.state;
      this.loadGroupData();
    }
  }

  aboutToDisappear(): void {
    this.groupStore?.unregisterListener();
    this.groupState = undefined;
  }

  build() {
    Column() {
      this.NavigationBarBuilder()

      if (this.isLoading) {
        this.LoadingStateBuilder()
      } else {
        Scroll() {
          Column({ space: 0 }) {
            this.GroupManagementSectionBuilder()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })
        }
        .backgroundColor(this.themeState.colors.bgColorInput)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.colors.bgColorInput)
  }

  @Builder
  NavigationBarBuilder() {
    Row() {
      // Back button
      Image($rawfile('search/back_icon.svg'))
        .width(24)
        .height(24)
        .fillColor(this.themeState.colors.textColorLink)
        .onClick(() => {
          this.closeDialog();
        })

      Blank()

      // Title
      Text($r('app.string.chatsetting_group_management_title'))
        .fontSize(18)
        .fontWeight(600)
        .fontFamily('SF Pro Display')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.colors.bgColorTopBar)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)

    // Divider
    Divider()
      .height(0.5)
      .color(this.themeState.colors.strokeColorSecondary)
  }

  @Builder
  LoadingStateBuilder() {
    Column({ space: 16 }) {
      LoadingProgress()
        .width(40)
        .height(40)
        .color(this.themeState.colors.textColorLink)

      Text($r('app.string.chatsetting_loading_group_management'))
        .fontSize(16)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorSecondary)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  GroupManagementSectionBuilder() {
    Column({ space: 0 }) {

      this.MuteAllMembersRowBuilder()

      this.DividerBuilder()


      this.AddMutedMemberRowBuilder()
    }
    .backgroundColor(this.themeState.colors.bgColorTopBar)
    .borderRadius(GroupManagementView.BORDER_RADIUS)
    .margin({
      bottom: GroupManagementView.SECTION_MARGIN
    })


    this.MutedMembersListBuilder()
  }

  @Builder
  MuteAllMembersRowBuilder() {
    Row() {
      Column({ space: 4 }) {
        Text($r('app.string.chatsetting_mute_all_members'))
          .fontSize(17)
          .fontWeight(400)
          .fontFamily('SF Pro Text')
          .fontColor(this.themeState.colors.textColorPrimary)
          .alignSelf(ItemAlign.Start)

        Text($r('app.string.chatsetting_mute_all_members_description'))
          .fontSize(13)
          .fontWeight(400)
          .fontFamily('SF Pro Text')
          .fontColor(this.themeState.colors.textColorSecondary)
          .alignSelf(ItemAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Blank()

      Switch({
        checked: this.groupState?.isAllMuted ?? false,
        type: SwitchType.Basic,
        onCheckedChange: (isOn: boolean) => {
          this.handleMuteAllMembersChange(isOn);
        }
      })
    }
    .width('100%')
    .height(GroupManagementView.CELL_HEIGHT + 16)
    .padding({
      left: GroupManagementView.HORIZONTAL_PADDING,
      right: GroupManagementView.HORIZONTAL_PADDING,
      top: 8,
      bottom: 8
    })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  AddMutedMemberRowBuilder() {
    Row() {
      Column({ space: 4 }) {
        Text($r('app.string.chatsetting_add_muted_members'))
          .fontSize(17)
          .fontWeight(400)
          .fontFamily('SF Pro Text')
          .fontColor(this.themeState.colors.textColorPrimary)
          .alignSelf(ItemAlign.Start)

        Text($r('app.string.chatsetting_add_muted_members_description'))
          .fontSize(13)
          .fontWeight(400)
          .fontFamily('SF Pro Text')
          .fontColor(this.themeState.colors.textColorSecondary)
          .alignSelf(ItemAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Blank()

      Image($rawfile('search/right_arrow_icon.svg'))
        .width(12)
        .height(24)
        .fillColor(this.themeState.colors.textColorSecondary)
    }
    .width('100%')
    .height(GroupManagementView.CELL_HEIGHT + 16)
    .padding({
      left: GroupManagementView.HORIZONTAL_PADDING,
      right: GroupManagementView.HORIZONTAL_PADDING,
      top: 8,
      bottom: 8
    })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.navigateToMutedMemberList();
    })
  }

  @Builder
  DividerBuilder() {
    Divider()
      .height(1)
      .color(this.themeState.colors.strokeColorSecondary)
      .margin({ left: GroupManagementView.HORIZONTAL_PADDING })
  }

  @Builder
  MutedMembersListBuilder() {
    if (this.getMutedMembers().length > 0) {
      Column({ space: 0 }) {

        Row() {
          Text(`已禁言成员 (${this.getMutedMembers().length})`)
            .fontSize(15)
            .fontWeight(600)
            .fontFamily('SF Pro Text')
            .fontColor(this.themeState.colors.textColorPrimary)

          Blank()
        }
        .width('100%')
        .height(44)
        .padding({
          left: GroupManagementView.HORIZONTAL_PADDING,
          right: GroupManagementView.HORIZONTAL_PADDING
        })
        .alignItems(VerticalAlign.Center)
        .backgroundColor(this.themeState.colors.bgColorTopBar)


        List({ space: 0 }) {
          ForEach(this.getMutedMembers(), (member: Member, index: number) => {
            ListItem() {
              this.MutedMemberRowBuilder(member, index === this.getMutedMembers().length - 1)
            }
            .swipeAction({
              end: this.UnmuteActionBuilder(member)
            })
          })
        }
        .backgroundColor(this.themeState.colors.bgColorTopBar)
        .divider({
          strokeWidth: 0
        })
      }
      .backgroundColor(this.themeState.colors.bgColorTopBar)
      .borderRadius(GroupManagementView.BORDER_RADIUS)
      .margin({
        bottom: GroupManagementView.SECTION_MARGIN
      })
    }
  }

  @Builder
  MutedMemberRowBuilder(member: Member, isLast: boolean) {
    Column() {
      Row({ space: 12 }) {
        // Avatar
        Avatar({
          content: {
            type: AvatarContentType.Image,
            url: member.faceURL,
            name: TextUtils.getAvatarLetter(member.nameCard || member.nickName || member.userID) || '',
          },
          avatarSize: AvatarSize.M,
        })
        // User info
        Column({ space: 2 }) {
          Text(member.nameCard || member.nickName || member.userID)
            .fontSize(17)
            .fontWeight(400)
            .maxLines(1)
            .fontFamily('SF Pro Text')
            .fontColor(this.themeState.colors.textColorPrimary)
            .alignSelf(ItemAlign.Start)

          Text(this.getMuteTimeText(member.muteUntil))
            .fontSize(13)
            .fontWeight(400)
            .fontFamily('SF Pro Text')
            .fontColor(this.themeState.colors.textColorSecondary)
            .alignSelf(ItemAlign.Start)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Blank()
      }
      .width('100%')
      .height(GroupManagementView.CELL_HEIGHT)
      .padding({
        left: GroupManagementView.HORIZONTAL_PADDING,
        right: GroupManagementView.HORIZONTAL_PADDING
      })
      .alignItems(VerticalAlign.Center)


      if (!isLast) {
        Divider()
          .height(1)
          .color(this.themeState.colors.strokeColorSecondary)
          .margin({ left: GroupManagementView.HORIZONTAL_PADDING + 52 })
      }
    }
  }

  @Builder
  UnmuteActionBuilder(member: Member) {
    Button() {
      Column() {

        Text($r('app.string.chatsetting_unmute'))
          .fontSize(12)
          .fontColor(Color.White)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .type(ButtonType.Normal)
    .backgroundColor(this.themeState.colors.textColorLink)
    .width(80)
    .height(GroupManagementView.CELL_HEIGHT)
    .onClick(() => {
      this.showUnmuteConfirmDialog(member);
    })
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
      console.warn('[GroupManagementPage] 没有提供关闭方式');
    }
  }

  private getMutedMembers(): Member[] {
    return (this.groupState?.allMembers ?? []).filter(member =>
    member.muteUntil > Date.now() / 1000
    ) ?? [];
  }

  private handleMuteAllMembersChange(isOn: boolean): void {
    if (!this.groupStore) {
      Toast.shortToast($r('app.string.chatsetting_group_info_unavailable'));
      return;
    }


    const loadingMessage = isOn ? $r('app.string.chatsetting_muting_all_members_start') :
    $r('app.string.chatsetting_unmuting_all_members_start');
    Toast.shortToast(loadingMessage);


    this.groupStore.setMuteAllMembers(isOn)
      .then(() => {
        const successMessage = isOn ? $r('app.string.chatsetting_mute_all_members_success') :
        $r('app.string.chatsetting_unmute_all_members_success');
        Toast.shortToast(successMessage);
        console.log(`[GroupManagementPage] Mute all members ${isOn ? 'enabled' : 'disabled'} successfully`);
      })
      .catch((error: Error) => {
        const errorMessage = isOn ? $r('app.string.chatsetting_enable_mute_all_members_fail') :
        $r('app.string.chatsetting_disable_mute_all_members_fail');
        Toast.shortToast(errorMessage);
        console.error(`[GroupManagementPage] Failed to ${isOn ? 'enable' : 'disable'} mute all members:`, error);
      });
  }

  private navigateToMutedMemberList(): void {
    if (!this.groupStore) {
      Toast.shortToast($r('app.string.chatsetting_group_info_unavailable'));
      return;
    }

    // const hasPermission = GroupPermissionManager.hasPermission(
    //   this.groupState?.groupType,
    //   this.groupState?.currentUserRole,
    //   'muteMembers'
    // );
    if (this.groupState?.groupType == GroupType.WORK) {
      Toast.shortToast($r('app.string.chatsetting_work_group_mute_members_unsupported'));
      return;
    }
    try {
      console.log('[GroupManagementPage] Navigate to user picker for muted members');


      const mutedMemberIds = (this.groupState?.allMembers ?? [])
        .filter(member => member.muteUntil > Date.now() / 1000)
        .map(member => member.userID);


      const currentUserRole = this.groupState?.currentUserRole;
      console.log(`[GroupManagementPage] Current user role: ${currentUserRole}, total members: ${(this.groupState?.allMembers ??
        []).length}`);

      const filteredMembers = (this.groupState?.allMembers ?? []).filter(member => {

        if (member.userID === LoginStore.createInstance().state.loginUserInfo?.userID) {
          return false;
        }


        if (currentUserRole === 300) { // GroupMemberRole.ADMIN
          return member.role === 200;
        }


        if (currentUserRole === 400) { // GroupMemberRole.OWNER
          return member.role === 300 || member.role === 200;
        }


        return false;
      });

      console.log(`[GroupManagementPage] Filtered ${filteredMembers.length} members available for muting`);

      const userList: UserInfo[] = filteredMembers.map(member =>
      UserPickerView.convertMemberToUserInfo(member)
      );


      if (userList.length === 0) {
        Toast.shortToast($r('app.string.chatsetting_no_members_to_mute'));
        console.log('[GroupManagementPage] No members available to mute');
        return;
      }


      this.showUserPickerDialog(
        userList,
        'muteMember',
        $r('app.string.chatsetting_select_members_to_mute')
      );

    } catch (error) {
      console.error('[GroupManagementPage] Error navigating to user picker:', error);
      Toast.shortToast($r('app.string.chatsetting_open_member_picker_fail'));
    }
  }

  private handleSelectedUsersForMute(selectedUsers: UserInfo[]): void {
    if (!this.groupStore || selectedUsers.length === 0) {
      return;
    }

    console.log('[GroupManagementPage] Handle selected users for mute:', selectedUsers.map(u => u.displayName));


    AlertDialog.show({
      title: $r('app.string.chatsetting_mute_confirm'),
      message: TextUtils.getResourceString($r('app.string.chatsetting_mute_confirm_message'))
        .replace('{count}', selectedUsers.length.toString()),
      primaryButton: {
        value: $r('app.string.chatsetting_confirm'),
        action: () => {
          this.muteSelectedUsers(selectedUsers);
        }
      },
      secondaryButton: {
        value: $r('app.string.chatsetting_cancel'),
        action: () => {
          console.log('[GroupManagementPage] User cancelled mute operation');
        }
      }
    });
  }

  private async muteSelectedUsers(selectedUsers: UserInfo[]): Promise<void> {
    if (!this.groupStore) {
      return;
    }

    Toast.shortToast($r('app.string.chatsetting_muting_members'));

    try {

      const muteTime = 24 * 60 * 60;
      const mutePromises = selectedUsers.map(user =>
      this.groupStore!.setGroupMemberMuteTime(user.userID, muteTime)
      );

      await Promise.all(mutePromises);

      Toast.shortToast(TextUtils.getResourceString($r('app.string.chatsetting_mute_success'))
        .replace('{count}', selectedUsers.length.toString()));
      console.log('[GroupManagementPage] Successfully muted selected users');


      await this.loadGroupData();

    } catch (error) {
      console.error('[GroupManagementPage] Failed to mute selected users:', error);
      Toast.shortToast($r('app.string.chatsetting_mute_fail'));
    }
  }

  private getMuteTimeText(muteUntil: number): string {
    if (muteUntil <= 0) {
      return '';
    }

    const now = Date.now() / 1000;
    const remainingSeconds = muteUntil - now;

    if (remainingSeconds <= 0) {
      return TextUtils.getResourceString($r('app.string.chatsetting_mute_time_text_unmuted'));
    }

    const days = Math.floor(remainingSeconds / (24 * 60 * 60));
    const hours = Math.floor((remainingSeconds % (24 * 60 * 60)) / (60 * 60));
    const minutes = Math.floor((remainingSeconds % (60 * 60)) / 60);

    if (days > 0) {
      return TextUtils.getResourceString($r('app.string.chatsetting_mute_time_text_remaining'))
        .replace('{days}', days.toString())
        .replace('{hours}', hours.toString());
    } else if (hours > 0) {
      return `禁言中，还剩 ${hours} 小时 ${minutes} 分钟`;
    } else {
      return `禁言中，还剩 ${minutes} 分钟`;
    }
  }

  private showUnmuteConfirmDialog(member: Member): void {
    AlertDialog.show({
      title: $r('app.string.chatsetting_unmute_confirm'),
      message: TextUtils.getResourceString($r('app.string.chatsetting_unmute_confirm_message'))
        .replace('{name}', member.nameCard || member.nickName || member.userID),
      primaryButton: {
        value: $r('app.string.chatsetting_confirm'),
        action: () => {
          this.unmuteMember(member);
        }
      },
      secondaryButton: {
        value: $r('app.string.chatsetting_cancel'),
        action: () => {
          console.log('[GroupManagementPage] User cancelled unmute operation');
        }
      }
    });
  }

  private async unmuteMember(member: Member): Promise<void> {
    if (!this.groupStore) {
      return;
    }

    Toast.shortToast($r('app.string.chatsetting_unmuting_member'));

    try {

      await this.groupStore.setGroupMemberMuteTime(member.userID, 0);

      Toast.shortToast(TextUtils.getResourceString($r('app.string.chatsetting_unmute_success'))
        .replace('{name}', member.nameCard || member.nickName || member.userID));
      console.log(`[GroupManagementPage] Successfully unmuted member: ${member.userID}`);


      await this.loadGroupData();

    } catch (error) {
      console.error('[GroupManagementPage] Failed to unmute member:', error);
      Toast.shortToast($r('app.string.chatsetting_unmute_fail'));
    }
  }

  private async loadGroupData(): Promise<void> {
    if (!this.groupStore) {
      return;
    }

    try {
      await this.groupStore.fetchGroupInfo();
      await this.groupStore.fetchGroupMembers();
      console.log('[GroupManagementPage] Group info loaded successfully');
    } catch (error) {
      console.error('[GroupManagementPage] Failed to load group info:', error);
      Toast.shortToast($r('app.string.chatsetting_load_group_info_fail'));
    } finally {
      this.isLoading = false;
    }
  }

  private showUserPickerDialog(userList: UserInfo[], action: string, title: string | Resource): void {
    try {
      if (this.userPickerDialogController) {
        this.userPickerDialogController.close();
        this.userPickerDialogController = undefined;
      }

      this.userPickerDialogController = new CustomDialogController({
        builder: UserPickerDialogInManagement({
          title: title,
          userList: userList,
          preSelectedUsers: action === 'muteMember' ? this.getMutedMemberIds() : [],
          maxSelectCount: -1,
          confirmButtonText: action === 'muteMember' ? $r('app.string.chatsetting_mute') :
          $r('app.string.chatsetting_complete'),
          action: action,
          onConfirm: (selectedUsers: UserInfo[], actionType: string) => {
            this.handleUserPickerResult(selectedUsers, actionType);
          }
        }),
        alignment: DialogAlignment.Default,
        levelMode: LevelMode.EMBEDDED,
        immersiveMode: ImmersiveMode.EXTEND,
        customStyle: true,
        autoCancel: true,
        cancel: () => {
          this.userPickerDialogController = undefined;
        }
      });

      this.userPickerDialogController.open();
      console.log('[GroupManagementPage] 用户选择器对话框已打开');
    } catch (error) {

    }
  }

  private handleUserPickerResult(selectedUsers: UserInfo[], action: string): void {
    console.log('[GroupManagementPage] 处理用户选择结果:', action, '选择的用户数量:', selectedUsers.length);

    switch (action) {
      case 'muteMember':
        this.handleSelectedUsersForMute(selectedUsers);
        break;
      default:
        console.warn('[GroupManagementPage] 未知的用户选择操作:', action);
    }
  }

  private getMutedMemberIds(): string[] {
    if (!this.groupState) {
      return [];
    }

    const currentTime = Date.now() / 1000;
    return this.groupState.allMembers
      .filter(member => member.muteUntil && member.muteUntil > currentTime)
      .map(member => member.userID);
  }
}

function createGroupChatSettingStore(groupID: string): GroupSettingStore {
  throw new Error('Function not implemented.');
}
