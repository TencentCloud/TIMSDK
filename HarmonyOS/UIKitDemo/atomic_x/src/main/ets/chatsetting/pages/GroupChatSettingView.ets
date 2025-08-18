import {
  TextUtils,
  ThemeState,
  Toast,
  Switch,
  SwitchSize,
  SwitchType,
  AlertDialog,
  Avatar,
  AvatarContentType,
  AvatarSize
} from '../../basecomponent/Index';
import {
  GroupSettingStore,
  Member,
  GroupMemberRole,
  GroupType,
  V2TIMGroupAddOpt,
  GroupJoinOption,
  ContactListStore,
  ContactInfo,
  ContactGetOption,
  ContactOnlineStatus,
  LoginStore,
  ContactListState,
  GroupSettingState,
} from 'chatengine';
import { GroupPermissionManager, GroupPermission } from '../manager/GroupPermissionManager';
import { App, ImmersiveMode, LevelMode, router } from '@kit.ArkUI';
import { AvatarPickerView } from './AvatarPickerView';
import { JoinGroupMethodDialog, InviteGroupMethodDialog, GroupNameEditDialog } from '../dialog/GroupSettingDialogs';
import { GroupAnnouncementView } from './GroupAnnouncementView';
import { GroupManagementView } from './GroupManagementView';
import { GroupMemberListPage } from './GroupMemberListPage';
import { UserInfo, UserPickerView, UserPickerParams } from './UserPickerView';
import { C2CChatSettingView } from './C2CChatSettingView';

interface LoadingProgress {
  groupInfo: boolean;
  conversationInfo: boolean;
  groupMembers: boolean;
  selfMemberInfo: boolean;
}

@CustomDialog
struct AvatarPickerDialog {
  controller: CustomDialogController;
  title: string | Resource = $r('app.string.chatsetting_select_avatar');
  urlList: string[] = [];
  onConfirm?: (selectedUrl: string, selectedIndex: number) => void;

  build() {
    AvatarPickerView({
      title: this.title,
      urlList: this.urlList,
      onConfirm: this.onConfirm,
      onBack: () => {
        this.controller.close();
      }
    })
  }
}

@CustomDialog
struct GroupAnnouncementDialog {
  controller: CustomDialogController;
  groupID: string = '';
  onSave?: (announcement: string) => void;

  build() {
    GroupAnnouncementView({
      groupID: this.groupID,
      onSave: this.onSave,
      onBack: () => {
        this.controller.close();
      }
    })
  }
}

@CustomDialog
struct GroupMemberListDialog {
  controller: CustomDialogController;
  groupID: string = '';
  groupName: string = '';
  onMemberSelect?: (member: Member) => void;

  build() {
    GroupMemberListPage({
      groupID: this.groupID,
      groupName: this.groupName,
      onMemberSelect: this.onMemberSelect,
      onBack: () => {
        this.controller.close();
      }
    })
  }
}

@CustomDialog
struct UserPickerDialog {
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

@CustomDialog
struct GroupManagementDialog {
  controller: CustomDialogController;
  groupID: string = '';

  build() {
    GroupManagementView({
      groupID: this.groupID,
      onBack: () => {
        this.controller.close();
      }
    })
  }
}

@CustomDialog
struct C2CSettingDialogInGroup {
  controller: CustomDialogController;
  conversationID: string = '';
  title: string = 'Contact Info';
  onDialogClose?: () => void;
  onSelectedNavigateMessagePage?: (newConversationID?: string, title?: string, avatarUrl?: string) => void;

  build() {
    C2CChatSettingView({
      conversationID: this.conversationID,
      title: this.title,
      onBack: () => {
        this.controller.close();
      },
      onDialogClose: () => {
        if (this.onDialogClose) {
          this.onDialogClose();
        }
      },
      onSelectedNavigateMessagePage: (newConversationID?: string, title?: string, avatarUrl?: string) => {
        if (this.onSelectedNavigateMessagePage) {
          this.onSelectedNavigateMessagePage(newConversationID, title, avatarUrl);
        }
      },
      dialogController: this.controller
    })
  }
}

@Component
export struct GroupChatSettingView {
  private static readonly AVATAR_SIZE: number = 80;
  private static readonly CELL_HEIGHT: number = 56;
  private static readonly SECTION_MARGIN: number = 12;
  private static readonly HORIZONTAL_PADDING: number = 8;
  private static readonly MEMBER_AVATAR_SIZE: number = 40;
  private static readonly ACTION_BUTTON_SIZE: number = 56;
  private static readonly BORDER_RADIUS: number = 12;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State groupStore?: GroupSettingStore = undefined;
  @State groupState?: GroupSettingState = this.groupStore?.state;
  @State conversationID: string = '';
  @State showMemberList: boolean = true;
  @State isLoading: boolean = true;
  @State loadingProgress: LoadingProgress = {
    groupInfo: false,
    conversationInfo: false,
    groupMembers: false,
    selfMemberInfo: false
  };
  @State showJoinGroupDialog: boolean = false;
  @State showInviteGroupDialog: boolean = false;
  title?: string;
  onBack?: () => void;
  dialogController?: CustomDialogController;
  onDialogClose?: () => void;
  onSelectedNavigateMessagePage?: (newConversationID?: string, title?: string, avatarUrl?: string) => void;
  private contactListStore: ContactListStore = ContactListStore.createInstance();
  @State private contactListState: ContactListState = this.contactListStore.state;
  private loadingTimeoutId?: number;
  private joinGroupDialogController?: CustomDialogController;
  private inviteGroupDialogController?: CustomDialogController;
  private groupNameEditDialogController?: CustomDialogController;
  private groupNicknameEditDialogController?: CustomDialogController;
  private avatarPickerDialogController?: CustomDialogController;
  private groupAnnouncementDialogController?: CustomDialogController;
  private groupMemberListDialogController?: CustomDialogController;
  private userPickerDialogController?: CustomDialogController;
  private groupManagementDialogController?: CustomDialogController;
  private c2cSettingDialogController?: CustomDialogController;

  onPageShow(): void {

    const params = router.getParams() as Record<string, Object>;
    console.log('[GroupSettingPage] onPageShow - Received params:', JSON.stringify(params));

    if (params && params['selectedUrl']) {
      const selectedUrl = params['selectedUrl'] as string;
      const selectedIndex = params['selectedIndex'] as number;
      console.log('[GroupSettingPage] Received avatar selection:', selectedUrl, 'at index:', selectedIndex);
      this.handleAvatarSelected(selectedUrl);
    }


    if (params && params['selectedUsers'] && params['action'] === 'addMember') {
      const selectedUsers = params['selectedUsers'] as UserInfo[];
      console.log('[GroupSettingPage] Processing addMember action with users:', selectedUsers.length);
      this.handleSelectedUsersForAddMember(selectedUsers);
    }


    if (params && params['selectedUsers'] && params['action'] === 'transferOwnership') {
      const selectedUsers = params['selectedUsers'] as UserInfo[];
      console.log('[GroupSettingPage] Processing transferOwnership action with users:', selectedUsers.length);
      this.handleSelectedUserForTransferOwnership(selectedUsers);
    }


    if (params && params['needRefresh']) {
      setTimeout(() => {
        this.loadGroupData();
      }, 1000);
    }
  }

  aboutToAppear(): void {

    console.info('[GroupSettingPage] 接收到的参数:', {
      conversationID: this.conversationID,
      title: this.title
    });


    this.contactListStore?.registerListener();

    if (this.conversationID && this.conversationID.length > 0) {
      const groupID = this.conversationID.replace('group_', '');
      this.groupStore = GroupSettingStore.createInstance(groupID);
      this.groupStore.registerListener();
      this.groupState = this.groupStore.state;
      this.loadGroupData();
    } else {
      this.isLoading = false;
    }
  }

  aboutToDisappear(): void {

    if (this.loadingTimeoutId) {
      clearTimeout(this.loadingTimeoutId);
      this.loadingTimeoutId = undefined;
    }

    this.groupStore?.unregisterListener();
    this.groupState = undefined;
    this.contactListStore?.unregisterListener();
  }

  build() {
    Column() {
      // this.StatusBarBuilder()
      this.NavigationBarBuilder()

      if (this.isLoading) {

        this.LoadingStateBuilder()
      } else {

        Scroll() {
          Column({ space: 0 }) {
            this.GroupInfoSectionBuilder()
            this.NotificationSettingsSectionBuilder()
            this.SettingsSectionBuilder()
            this.MyGroupNicknameSectionBuilder()
            this.ChatBackgroundSectionBuilder()
            if (this.showMemberList && this.hasPermission(GroupPermission.GET_GROUP_MEMBER_LIST)) {
              this.MemberListSectionBuilder()
            }
            this.ActionButtonsSectionBuilder()
          }
          .width('100%')
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  StatusBarBuilder() {

    Blank().height(0)
  }

  @Builder
  LoadingStateBuilder() {
    Column({ space: 16 }) {

      LoadingProgress()
        .width(40)
        .height(40)
        .color('#0365F9')


      Text($r('app.string.chatsetting_loading_group_information'))
        .fontSize(16)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorSecondary)


      Column({ space: 8 }) {
        this.LoadingItemBuilder(TextUtils.getResourceString($r('app.string.chatsetting_group_info')),
          this.loadingProgress.groupInfo)
        this.LoadingItemBuilder(TextUtils.getResourceString($r('app.string.chatsetting_conversation_settings')),
          this.loadingProgress.conversationInfo)
        this.LoadingItemBuilder(TextUtils.getResourceString($r('app.string.chatsetting_group_members')),
          this.loadingProgress.groupMembers)
        this.LoadingItemBuilder(TextUtils.getResourceString($r('app.string.chatsetting_member_settings')),
          this.loadingProgress.selfMemberInfo)
      }
      .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F2F2F7')
  }

  @Builder
  LoadingItemBuilder(label: string, isCompleted: boolean) {
    Row({ space: 8 }) {

      if (isCompleted) {
        Image($r('sys.symbol.checkmark_circle_fill'))
          .width(16)
          .height(16)
          .fillColor('#34C759')
      } else {
        LoadingProgress()
          .width(16)
          .height(16)
          .color('#0365F9')
      }


      Text(label)
        .fontSize(14)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(isCompleted ? '#34C759' : this.themeState.colors.textColorSecondary)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .padding({ left: 40, right: 40 })
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
          if (this.dialogController) {


            this.dialogController.close();

            if (this.onDialogClose) {
              this.onDialogClose();
            }
          } else if (this.onBack) {


            this.onBack();
          } else {

            console.warn('[GroupSettingPage] 没有提供关闭方式');
          }
        })

      Blank()

      // Title
      Text($r('app.string.chatsetting_group_info'))
        .fontSize(18)
        .fontWeight(600)
        .fontFamily('SF Pro Display')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()
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
  GroupInfoSectionBuilder() {
    Column() {

      Stack() {
        Avatar({
          content: {
            type: AvatarContentType.Image,
            url: this.groupState?.avatar,
            name: this.getGroupInitials() || '',
          },
          avatarSize: AvatarSize.XXL,
        })

        if (this.hasPermission(GroupPermission.SET_GROUP_AVATAR)) {
          Stack() {
            Circle()
              .width(24)
              .height(24)
              .fill('rgba(0, 0, 0, 0.6)')

            Image($rawfile('chatsetting/setting_edit_icon.svg'))
              .width(12)
              .height(12)
              .fillColor(this.themeState.colors.textColorLink)
          }
          .position({ x: GroupChatSettingView.AVATAR_SIZE - 24, y: GroupChatSettingView.AVATAR_SIZE - 24 })
        }
      }
      .onClick(() => {
        if (this.hasPermission(GroupPermission.SET_GROUP_AVATAR)) {
          this.navigateToAvatarPicker();
        }
      })
      .width(GroupChatSettingView.AVATAR_SIZE)
      .height(GroupChatSettingView.AVATAR_SIZE)
      .margin({ top: 24, bottom: 16 })


      Row() {
        Text((this.groupState?.groupName || ''))
          .fontSize(24)
          .fontWeight(600)
          .fontFamily('PingFang HK')
          .fontColor(this.themeState.colors.textColorPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.hasPermission(GroupPermission.SET_GROUP_NAME)) {
          Image($rawfile('chatsetting/setting_edit_icon.svg'))
            .width(15)
            .height(15)
            .margin({ left: 12 })
            .fillColor(this.themeState.colors.textColorLink)
            .onClick(() => {
              this.openGroupNameEditDialog();
            })
        }
      }
      .margin({ bottom: 16 })


      Text(`ID: ${this.groupState?.groupID}`)
        .fontSize(15)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorSecondary)
        .margin({ bottom: 16 })

      Row({ space: 24 }) {
        this.QuickActionButtonBuilder($r('app.string.chatsetting_message'),
          $rawfile('chatsetting/setting_sendmessage_icon.svg'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: 24 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .borderRadius(GroupChatSettingView.BORDER_RADIUS)
    .padding({
      left: GroupChatSettingView.HORIZONTAL_PADDING,
      right: GroupChatSettingView.HORIZONTAL_PADDING
    })
    .margin({
      top: GroupChatSettingView.SECTION_MARGIN,
      bottom: GroupChatSettingView.SECTION_MARGIN
    })
  }

  @Builder
  QuickActionButtonBuilder(label: string | Resource, icon: string | Resource) {
    Column({ space: 8 }) {

      Image(icon)
        .width(36)
        .height(36)
        .fillColor(this.themeState.colors.textColorLink)
        .borderRadius(12)


      Text(label)
        .fontSize(16)
        .fontWeight(400)
        .fontFamily('PingFang SC')
        .fontColor(this.themeState.colors.textColorPrimary)
        .textAlign(TextAlign.Center)
    }
    .width(92)
    .backgroundColor(this.themeState.colors.bgColorTopBar)
    .borderRadius(12)
    .padding({ top: 16, bottom: 16 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.handleQuickActionClick(label);
    })
  }

  @Builder
  NotificationSettingsSectionBuilder() {
    Column({ space: 0 }) {

      if (this.hasPermission(GroupPermission.SET_DO_NOT_DISTURB)) {
        this.MuteNotificationRowBuilder()
        this.DividerBuilder()
      }


      if (this.hasPermission(GroupPermission.PIN_GROUP)) {
        this.PinConversationRowBuilder()
      }
    }
    .backgroundColor(this.themeState.colors.bgColorTopBar)
    .borderRadius(GroupChatSettingView.BORDER_RADIUS)
    .padding({
      left: GroupChatSettingView.HORIZONTAL_PADDING,
      right: GroupChatSettingView.HORIZONTAL_PADDING
    })
    .margin({
      bottom: GroupChatSettingView.SECTION_MARGIN
    })
  }

  @Builder
  MuteNotificationRowBuilder() {
    Row() {
      Text($r('app.string.chatsetting_mute_notifications'))
        .fontSize(17)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()

      Switch({
        checked: this.groupState?.isNotDisturb ?? false,
        type: SwitchType.Basic,
        onCheckedChange: (isOn: boolean) => {
          this.groupStore?.setChatNotDisturb(isOn);
        }
      })
    }
    .width('100%')
    .height(GroupChatSettingView.CELL_HEIGHT)
    .padding({ left: GroupChatSettingView.HORIZONTAL_PADDING, right: GroupChatSettingView.HORIZONTAL_PADDING })
  }

  @Builder
  PinConversationRowBuilder() {
    Row() {
      Text($r('app.string.chatsetting_pin_conversation'))
        .fontSize(17)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()

      Switch({
        checked: this.groupState?.isPinned ?? false,
        type: SwitchType.Basic,
        onCheckedChange: (isOn: boolean) => {
          this.groupStore?.setChatPinned(isOn);
        }
      })
    }
    .width('100%')
    .height(GroupChatSettingView.CELL_HEIGHT)
    .padding({ left: GroupChatSettingView.HORIZONTAL_PADDING, right: GroupChatSettingView.HORIZONTAL_PADDING })
  }

  @Builder
  GroupNoticeRowBuilder() {
    Column({ space: 8 }) {

      Row() {
        Text($r('app.string.chatsetting_group_announcement'))
          .fontSize(16)
          .fontWeight(400)
          .fontFamily('PingFang SC')
          .fontColor(this.themeState.colors.textColorPrimary)

        Blank()

        Image($rawfile('search/right_arrow_icon.svg'))
          .width(12)
          .height(24)
          .fillColor(this.themeState.colors.textColorSecondary)

      }
      .width('100%')
      .alignItems(VerticalAlign.Center)


      Row() {
        Text(this.groupState?.notice)
          .fontSize(14)
          .fontWeight(400)
          .fontFamily('PingFang SC')
          .fontColor(this.themeState.colors.textColorSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding({
      top: 8,
      bottom: 8,
      left: GroupChatSettingView.HORIZONTAL_PADDING,
      right: GroupChatSettingView.HORIZONTAL_PADDING
    })
    .onClick(() => {
      this.navigateToGroupAnnouncement();
    })
  }

  @Builder
  SettingsSectionBuilder() {
    Column({ space: 0 }) {

      if (this.hasPermission(GroupPermission.SET_GROUP_NOTICE)) {
        this.GroupNoticeRowBuilder()
        this.DividerBuilder()
      }


      if (this.hasPermission(GroupPermission.SET_GROUP_MANAGEMENT)) {
        this.GroupManagementRowBuilder()
        this.DividerBuilder()
      }


      if (this.hasPermission(GroupPermission.GET_GROUP_TYPE)) {
        this.GroupTypeRowBuilder()
        this.DividerBuilder()
      }


      if (this.hasPermission(GroupPermission.SET_JOIN_GROUP_APPROVAL_TYPE)) {
        this.JoinMethodRowBuilder()
        this.DividerBuilder()
      }


      if (this.hasPermission(GroupPermission.SET_INVITE_TO_GROUP_APPROVAL_TYPE)) {
        this.InviteMethodRowBuilder()
      }
    }
    .backgroundColor(this.themeState.colors.bgColorTopBar)
    .borderRadius(GroupChatSettingView.BORDER_RADIUS)
    .padding({
      left: GroupChatSettingView.HORIZONTAL_PADDING,
      right: GroupChatSettingView.HORIZONTAL_PADDING
    })
    .margin({
      bottom: GroupChatSettingView.SECTION_MARGIN
    })

  }

  @Builder
  SettingRowBuilder(title: string, value: boolean | string, isSwitch: boolean, onRowClick?: () => void) {
    Row() {
      Text(title)
        .fontSize(17)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()

      if (isSwitch && typeof value === 'boolean') {
        Switch({
          checked: value,
          type: SwitchType.Basic,
          onCheckedChange: (isOn: boolean) => {
            if (title === TextUtils.getResourceString($r('app.string.chatsetting_mute_notifications'))) {
              this.groupStore?.setChatNotDisturb(isOn);
            } else if (title === TextUtils.getResourceString($r('app.string.chatsetting_pin_conversation'))) {
              this.groupStore?.setChatPinned(isOn);
            }
          }
        })
      } else {
        Row({ space: 8 }) {
          if (typeof value === 'string' && value && value !== '') {
            Text(value)
              .fontSize(17)
              .fontWeight(400)
              .fontFamily('SF Pro Text')
              .fontColor(this.themeState.colors.textColorSecondary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          Image($rawfile('search/right_arrow_icon.svg'))
            .width(12)
            .height(24)
            .fillColor(this.themeState.colors.textColorSecondary)
        }
      }
    }
    .width('100%')
    .height(GroupChatSettingView.CELL_HEIGHT)
    .padding({ left: GroupChatSettingView.HORIZONTAL_PADDING, right: GroupChatSettingView.HORIZONTAL_PADDING })
    .onClick(() => {
      if (!isSwitch) {
        if (onRowClick) {
          onRowClick();
        } else {
          console.log(`${title} clicked`);
        }
      }
    })
  }

  @Builder
  GroupManagementRowBuilder() {
    Row() {
      Text($r('app.string.chatsetting_group_management'))
        .fontSize(17)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()

      Row({ space: 8 }) {
        Image($rawfile('search/right_arrow_icon.svg'))
          .width(12)
          .height(24)
          .fillColor(this.themeState.colors.textColorSecondary)
      }
    }
    .width('100%')
    .height(GroupChatSettingView.CELL_HEIGHT)
    .padding({ left: GroupChatSettingView.HORIZONTAL_PADDING, right: GroupChatSettingView.HORIZONTAL_PADDING })
    .onClick(() => {
      this.navigateToGroupManagement();
    })
  }

  @Builder
  GroupTypeRowBuilder() {
    Row() {
      Text($r('app.string.chatsetting_group_type'))
        .fontSize(17)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()

      Row({ space: 8 }) {
        Text(this.getGroupTypeDisplayName())
          .fontSize(17)
          .fontWeight(400)
          .fontFamily('SF Pro Text')
          .fontColor(this.themeState.colors.textColorPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Image($rawfile('search/right_arrow_icon.svg'))
          .width(12)
          .height(24)
          .fillColor(this.themeState.colors.textColorSecondary)
      }
    }
    .width('100%')
    .height(GroupChatSettingView.CELL_HEIGHT)
    .padding({ left: GroupChatSettingView.HORIZONTAL_PADDING, right: GroupChatSettingView.HORIZONTAL_PADDING })
    .onClick(() => {
      console.log('Group Type clicked');
    })
  }

  @Builder
  JoinMethodRowBuilder() {
    Row() {
      Text($r('app.string.chatsetting_join_group_method'))
        .fontSize(17)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()

      Row({ space: 8 }) {
        Text(this.getJoinMethodDisplayName())
          .fontSize(17)
          .fontWeight(400)
          .fontFamily('SF Pro Text')
          .fontColor(this.themeState.colors.textColorPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Image($rawfile('search/right_arrow_icon.svg'))
          .width(12)
          .height(24)
          .fillColor(this.themeState.colors.textColorSecondary)
      }
    }
    .width('100%')
    .height(GroupChatSettingView.CELL_HEIGHT)
    .padding({ left: GroupChatSettingView.HORIZONTAL_PADDING, right: GroupChatSettingView.HORIZONTAL_PADDING })
    .onClick(() => {
      this.joinGroupDialogController = new CustomDialogController({
        builder: JoinGroupMethodDialog({
          currentOpt: this.convertJoinOptionToDialogString(this.groupState?.joinGroupApprovalType),
          onSelect: (opt: string) => {

            let enumValue: V2TIMGroupAddOpt;
            switch (opt) {
              case 'V2TIM_GROUP_ADD_AUTH':
                enumValue = V2TIMGroupAddOpt.V2TIM_GROUP_ADD_AUTH;
                break;
              case 'V2TIM_GROUP_ADD_ANY':
                enumValue = V2TIMGroupAddOpt.V2TIM_GROUP_ADD_ANY;
                break;
              case 'V2TIM_GROUP_ADD_FORBID':
                enumValue = V2TIMGroupAddOpt.V2TIM_GROUP_ADD_FORBID;
                break;
              default:
                enumValue = V2TIMGroupAddOpt.V2TIM_GROUP_ADD_UNKNOWN;
            }
            // Note: Join option is set via setGroupJoinOption method
            this.groupStore?.setGroupJoinOption(this.convertV2TIMGroupAddOptToJoinOption(enumValue));
          },
          onCancel: () => {
            // Dialog will close automatically
          }
        }),
        alignment: DialogAlignment.Bottom,
        customStyle: true,
        maskColor: 'rgba(0, 0, 0, 0.6)',
        autoCancel: true
      });
      this.joinGroupDialogController.open();
    })
  }

  @Builder
  InviteMethodRowBuilder() {
    Row() {
      Text($r('app.string.chatsetting_invite_method'))
        .fontSize(17)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()

      Row({ space: 8 }) {
        Text(this.getInviteMethodDisplayName())
          .fontSize(17)
          .fontWeight(400)
          .fontFamily('SF Pro Text')
          .fontColor(this.themeState.colors.textColorPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Image($rawfile('search/right_arrow_icon.svg'))
          .width(12)
          .height(24)
          .fillColor(this.themeState.colors.textColorSecondary)
      }
    }
    .width('100%')
    .height(GroupChatSettingView.CELL_HEIGHT)
    .padding({ left: GroupChatSettingView.HORIZONTAL_PADDING, right: GroupChatSettingView.HORIZONTAL_PADDING })
    .onClick(() => {
      this.inviteGroupDialogController = new CustomDialogController({
        builder: InviteGroupMethodDialog({
          currentOpt: this.convertJoinOptionToDialogString(this.groupState?.inviteToGroupApprovalType),
          onSelect: (opt: string) => {
            console.log('Set invite method:', opt);

            let enumValue: V2TIMGroupAddOpt;
            switch (opt) {
              case 'V2TIM_GROUP_ADD_AUTH':
                enumValue = V2TIMGroupAddOpt.V2TIM_GROUP_ADD_AUTH;
                break;
              case 'V2TIM_GROUP_ADD_ANY':
                enumValue = V2TIMGroupAddOpt.V2TIM_GROUP_ADD_ANY;
                break;
              case 'V2TIM_GROUP_ADD_UNKNOWN':
                enumValue = V2TIMGroupAddOpt.V2TIM_GROUP_ADD_UNKNOWN;
                break;
              default:
                enumValue = V2TIMGroupAddOpt.V2TIM_GROUP_ADD_UNKNOWN;
            }
            // Note: Invite option is set via setGroupInviteOption method
            this.groupStore?.setGroupInviteOption(this.convertV2TIMGroupAddOptToJoinOption(enumValue));
          },
          onCancel: () => {
            // Dialog will close automatically
          }
        }),
        alignment: DialogAlignment.Bottom,
        customStyle: true,
        maskColor: 'rgba(0, 0, 0, 0.6)',
        autoCancel: true
      });
      this.inviteGroupDialogController.open();
    })
  }

  @Builder
  DividerBuilder() {
    Divider()
      .height(0.4)
      .color(this.themeState.colors.strokeColorSecondary)
  }

  @Builder
  MyGroupNicknameSectionBuilder() {
    Column({ space: 0 }) {
      Row() {
        Text($r('app.string.chatsetting_mygroup_nickname'))
          .fontSize(17)
          .fontWeight(400)
          .fontFamily('SF Pro Text')
          .fontColor(this.themeState.colors.textColorPrimary)

        Blank()

        Row({ space: 8 }) {
          Text(this.getCurrentUserNickname())
            .fontSize(17)
            .fontWeight(400)
            .fontFamily('SF Pro Text')
            .fontColor(this.themeState.colors.textColorPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Image($rawfile('search/right_arrow_icon.svg'))
            .width(12)
            .height(24)
            .fillColor(this.themeState.colors.textColorSecondary)
        }
      }
      .width('100%')
      .height(GroupChatSettingView.CELL_HEIGHT)
      .padding({ left: GroupChatSettingView.HORIZONTAL_PADDING, right: GroupChatSettingView.HORIZONTAL_PADDING })
      .onClick(() => {
        this.openGroupNicknameEditDialog();
      })
    }
    .backgroundColor(this.themeState.colors.bgColorTopBar)
    .borderRadius(GroupChatSettingView.BORDER_RADIUS)
    .padding({
      left: GroupChatSettingView.HORIZONTAL_PADDING,
      right: GroupChatSettingView.HORIZONTAL_PADDING
    })
    .margin({
      bottom: GroupChatSettingView.SECTION_MARGIN
    })
  }

  @Builder
  ChatBackgroundSectionBuilder() {
    if (this.hasPermission(GroupPermission.SET_BACKGROUND)) {
      Column({ space: 0 }) {
        Row() {
          Text($r('app.string.chatsetting_chat_background'))
            .fontSize(17)
            .fontWeight(400)
            .fontFamily('SF Pro Text')
            .fontColor(this.themeState.colors.textColorPrimary)

          Blank()

          Row({ space: 8 }) {
            Text($r('app.string.chatsetting_default'))
              .fontSize(17)
              .fontWeight(400)
              .fontFamily('SF Pro Text')
              .fontColor(this.themeState.colors.textColorPrimary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Image($rawfile('search/right_arrow_icon.svg'))
              .width(12)
              .height(24)
              .fillColor(this.themeState.colors.textColorSecondary)
          }
        }
        .width('100%')
        .height(GroupChatSettingView.CELL_HEIGHT)
        .padding({ left: GroupChatSettingView.HORIZONTAL_PADDING, right: GroupChatSettingView.HORIZONTAL_PADDING })
        .onClick(() => {
          console.log('Chat Background clicked');

        })
      }
      .backgroundColor(this.themeState.colors.bgColorTopBar)
      .borderRadius(GroupChatSettingView.BORDER_RADIUS)
      .padding({
        left: GroupChatSettingView.HORIZONTAL_PADDING,
        right: GroupChatSettingView.HORIZONTAL_PADDING
      })
      .margin({
        bottom: GroupChatSettingView.SECTION_MARGIN
      })
    }
  }

  @Builder
  MemberListSectionBuilder() {
    Column({ space: 0 }) {

      Row() {
        Text($r('app.string.chatsetting_members'))
          .fontSize(17)
          .fontWeight(600)
          .fontFamily('SF Pro Text')
          .fontColor(this.themeState.colors.textColorPrimary)

        Blank()

        Text(`${this.groupState?.memberCount ?? 0} 人`)
          .fontSize(17)
          .fontWeight(400)
          .fontFamily('SF Pro Text')
          .fontColor(this.themeState.colors.textColorPrimary)

        Image($rawfile('search/right_arrow_icon.svg'))
          .width(12)
          .height(24)
          .fillColor(this.themeState.colors.textColorSecondary)

      }
      .width('100%')
      .height(GroupChatSettingView.CELL_HEIGHT)
      .padding({ left: GroupChatSettingView.HORIZONTAL_PADDING, right: GroupChatSettingView.HORIZONTAL_PADDING })
      .onClick(() => {
        this.navigateToGroupMemberList();
      })

      this.DividerBuilder()


      if (this.hasPermission(GroupPermission.ADD_GROUP_MEMBER)) {
        this.AddMemberButtonBuilder()
        this.DividerBuilder()
      }


      ForEach(this.getDisplayMembers(), (member: Member, index: number) => {
        this.MemberRowBuilder(member)
        if (index < this.getDisplayMembers().length - 1) {
          this.DividerBuilder()
        }
      })
    }
    .backgroundColor(this.themeState.colors.bgColorTopBar)
    .borderRadius(GroupChatSettingView.BORDER_RADIUS)
    .padding({
      left: GroupChatSettingView.HORIZONTAL_PADDING,
      right: GroupChatSettingView.HORIZONTAL_PADDING
    })
    .margin({
      bottom: GroupChatSettingView.SECTION_MARGIN
    })
  }

  @Builder
  AddMemberButtonBuilder() {
    Row() {
      Stack() {
        Circle()
          .width(GroupChatSettingView.MEMBER_AVATAR_SIZE)
          .height(GroupChatSettingView.MEMBER_AVATAR_SIZE)
          .fill('rgba(3, 101, 249, 0.1)')

        Text('+')
          .fontSize(20)
          .fontColor(this.themeState.colors.textColorLink)
          .fontWeight(300)
      }
      .width(GroupChatSettingView.MEMBER_AVATAR_SIZE)
      .height(GroupChatSettingView.MEMBER_AVATAR_SIZE)

      Text($r('app.string.chatsetting_add_member'))
        .fontSize(16)
        .fontWeight(400)
        .fontFamily('PingFang SC')
        .fontColor(this.themeState.colors.textColorLink)
        .margin({ left: 12 })

      Blank()
    }
    .width('100%')
    .height(GroupChatSettingView.CELL_HEIGHT)
    .padding({ left: GroupChatSettingView.HORIZONTAL_PADDING, right: GroupChatSettingView.HORIZONTAL_PADDING })
    .onClick(() => {
      this.navigateToAddMember();
    })
  }

  @Builder
  MemberRowBuilder(member: Member) {
    Row() {
      Avatar({
        content: {
          type: AvatarContentType.Image,
          url: member.faceURL,
          name: member.nickName || '',
        },
        avatarSize: AvatarSize.M,
      })
      Column({ space: 2 }) {
        Row() {
          Text((member.nameCard || member.nickName || member.userID).toString())
            .fontSize(17)
            .fontWeight(400)
            .fontFamily('SF Pro Text')
            .fontColor(this.themeState.colors.textColorPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })


          if (member.role === GroupMemberRole.OWNER) {
            Text($r('app.string.chatsetting_owner_role'))
              .fontSize(13)
              .fontWeight(500)
              .fontFamily('SF Pro Text')
              .fontColor('#FF9500')
              .margin({ left: 8 })
              .padding({
                left: 6,
                right: 6,
                top: 2,
                bottom: 2
              })
              .backgroundColor('rgba(255, 149, 0, 0.1)')
              .borderRadius(4)
          } else if (member.role === GroupMemberRole.ADMIN) {
            Text($r('app.string.chatsetting_admin_role'))
              .fontSize(13)
              .fontWeight(500)
              .fontFamily('SF Pro Text')
              .fontColor('#0365F9')
              .margin({ left: 8 })
              .padding({
                left: 6,
                right: 6,
                top: 2,
                bottom: 2
              })
              .backgroundColor('rgba(0, 122, 255, 0.1)')
              .borderRadius(4)
          }
        }

        if (member.userID !== (member.nameCard || member.nickName) && member.userID) {
          Text(`@${member.userID.toString()}`)
            .fontSize(15)
            .fontWeight(400)
            .fontFamily('SF Pro Text')
            .fontColor(this.themeState.colors.textColorSecondary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)


      Image($rawfile('search/right_arrow_icon.svg'))
        .width(12)
        .height(24)
        .fillColor(this.themeState.colors.textColorSecondary)

    }
    .width('100%')
    .height(GroupChatSettingView.CELL_HEIGHT)
    .padding({ left: GroupChatSettingView.HORIZONTAL_PADDING, right: GroupChatSettingView.HORIZONTAL_PADDING })
    .onClick(() => {
      if (this.hasPermission(GroupPermission.GET_GROUP_MEMBER_INFO)) {
        console.log(`View member info: ${member.userID}`);
        this.showMemberOptions(member);
      }
    })
  }

  @Builder
  ActionButtonsSectionBuilder() {
    Column({ space: 0 }) {

      if (this.hasPermission(GroupPermission.CLEAR_HISTORY_MESSAGES)) {
        this.ActionButtonBuilder($r('app.string.chatsetting_clear_chat_history'),
          this.themeState.colors.textColorError, () => {
            this.showClearHistoryConfirmDialog();
          })

        if (this.hasPermission(GroupPermission.TRANSFER_OWNER) ||
        this.hasPermission(GroupPermission.DISMISS_GROUP) ||
        this.hasPermission(GroupPermission.DELETE_AND_QUIT) ||
        this.hasPermission(GroupPermission.REPORT_GROUP)) {
          this.DividerBuilder()
        }
      }


      if (this.hasPermission(GroupPermission.TRANSFER_OWNER)) {
        this.ActionButtonBuilder($r('app.string.chatsetting_transfer_ownership'),
          this.themeState.colors.textColorWarning, () => {
            this.navigateToTransferOwnership();
          })

        if (this.hasPermission(GroupPermission.DISMISS_GROUP) ||
        this.hasPermission(GroupPermission.DELETE_AND_QUIT) ||
        this.hasPermission(GroupPermission.REPORT_GROUP)) {
          this.DividerBuilder()
        }
      }


      if (this.hasPermission(GroupPermission.DISMISS_GROUP)) {
        this.ActionButtonBuilder($r('app.string.chatsetting_dismiss_group'),
          this.themeState.colors.textColorError, () => {
            this.showDismissGroupConfirmDialog();
          })

        if (this.hasPermission(GroupPermission.DELETE_AND_QUIT) ||
        this.hasPermission(GroupPermission.REPORT_GROUP)) {
          this.DividerBuilder()
        }
      }


      if (this.hasPermission(GroupPermission.DELETE_AND_QUIT)) {
        this.ActionButtonBuilder($r('app.string.chatsetting_leave_group'),
          this.themeState.colors.textColorWarning, () => {
            this.showLeaveGroupConfirmDialog();
          })

        if (this.hasPermission(GroupPermission.REPORT_GROUP)) {
          this.DividerBuilder()
        }
      }


      if (this.hasPermission(GroupPermission.REPORT_GROUP)) {
        this.ActionButtonBuilder($r('app.string.chatsetting_report_group'),
          this.themeState.colors.textColorError, () => {
            Toast.shortToast($r('app.string.chatsetting_report_group_toast'));
          })
      }
    }
    .backgroundColor(this.themeState.colors.bgColorTopBar)
    .borderRadius(GroupChatSettingView.BORDER_RADIUS)
    .padding({
      left: GroupChatSettingView.HORIZONTAL_PADDING,
      right: GroupChatSettingView.HORIZONTAL_PADDING
    })
    .margin({
      bottom: GroupChatSettingView.SECTION_MARGIN
    })
  }

  @Builder
  ActionButtonBuilder(title: string | Resource, textColor: string, action: () => void) {
    Row() {
      Text(title)
        .fontSize(17)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(textColor)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(GroupChatSettingView.CELL_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .onClick(action)
  }

  private closeDialog(): void {
    if (this.dialogController) {
      this.dialogController.close();
      if (this.onDialogClose) {
        this.onDialogClose();
      }
    } else if (this.onBack) {
      this.onBack();
    }
  }

  private async loadGroupData(): Promise<void> {
    if (!this.groupStore) {
      return;
    }

    console.info('[GroupSettingPage] Starting to load group data...');

    try {

      const promises = [
        this.loadGroupInfo(),
        this.loadConversationInfo(),
        this.loadGroupMembers(),
        this.loadSelfMemberInfo()
      ];

      await Promise.all(promises);
      console.info('[GroupSettingPage] All data loaded successfully');
    } catch (error) {
      console.error('[GroupSettingPage] Error loading group data:', error);
    } finally {
      this.isLoading = false;

      if (this.loadingTimeoutId) {
        clearTimeout(this.loadingTimeoutId);
        this.loadingTimeoutId = undefined;
      }
    }


    this.loadingTimeoutId = setTimeout(() => {
      if (this.isLoading) {
        console.warn('[GroupSettingPage] Loading timeout, forcing completion');
        this.isLoading = false;
      }
    }, 10000);
  }

  private async loadGroupInfo(): Promise<void> {
    try {
      await this.groupStore?.fetchGroupInfo();
      this.loadingProgress.groupInfo = true;
      console.info('[GroupSettingPage] Group info loaded');
    } catch (error) {
      console.error('[GroupSettingPage] Failed to load group info:', error);
      this.loadingProgress.groupInfo = true;
    }
  }

  private async loadConversationInfo(): Promise<void> {
    try {
      await this.groupStore?.fetchConversationInfo();
      this.loadingProgress.conversationInfo = true;
      console.info('[GroupSettingPage] Conversation info loaded');
    } catch (error) {
      console.error('[GroupSettingPage] Failed to load conversation info:', error);
      this.loadingProgress.conversationInfo = true;
    }
  }

  private async loadGroupMembers(): Promise<void> {
    try {
      await this.groupStore?.fetchGroupMembers();
      this.loadingProgress.groupMembers = true;
      console.info('[GroupSettingPage] Group members loaded');
    } catch (error) {
      console.error('[GroupSettingPage] Failed to load group members:', error);
      this.loadingProgress.groupMembers = true;
    }
  }

  private async loadSelfMemberInfo(): Promise<void> {
    try {
      await this.groupStore?.fetchSelfMemberInfo();
      this.loadingProgress.selfMemberInfo = true;
      console.info('[GroupSettingPage] Self member info loaded');
    } catch (error) {
      console.error('[GroupSettingPage] Failed to load self member info:', error);
      this.loadingProgress.selfMemberInfo = true;
    }
  }

  private hasPermission(permission: GroupPermission): boolean {
    const userRole = this.groupState?.currentUserRole;
    if (!userRole) {
      return false;
    }


    const groupType = this.convertStringToGroupType(this.groupState?.groupType);

    return GroupPermissionManager.hasPermission(
      groupType,
      userRole,
      permission
    );
  }

  private convertStringToGroupType(typeString: string | undefined): GroupType {
    if (!typeString) {
      return GroupType.WORK;
    }
    switch (typeString) {
      case 'Work':
        return GroupType.WORK;
      case 'Public':
        return GroupType.PUBLIC;
      case 'Meeting':
        return GroupType.MEETING;
      case 'AVChatRoom':
        return GroupType.AVCHATROOM;
      case 'Community':
        return GroupType.COMMUNITY;
      default:
        return GroupType.WORK;
    }
  }

  private canManageMember(member: Member): boolean {

    if (member.userID === LoginStore.createInstance().state.loginUserInfo?.userID) {
      return false;
    }


    if (this.groupState?.currentUserRole === GroupMemberRole.OWNER) {
      return this.hasPermission(GroupPermission.SET_GROUP_MEMBER_ROLE) ||
      this.hasPermission(GroupPermission.REMOVE_GROUP_MEMBER);
    }


    if (this.groupState?.currentUserRole === GroupMemberRole.ADMIN &&
      member.role === GroupMemberRole.MEMBER) {
      return this.hasPermission(GroupPermission.REMOVE_GROUP_MEMBER);
    }

    return false;
  }

  private showMemberOptions(member: Member): void {
    console.log(`Show options for member: ${member.userID}`);
    const conversationID = 'c2c_' + member.userID;
    const title = 'Contact Info';


    this.showC2CSettingDialog(conversationID, title);
  }

  private showC2CSettingDialog(conversationID: string, title: string): void {
    try {
      if (this.c2cSettingDialogController) {
        this.c2cSettingDialogController.close();
        this.c2cSettingDialogController = undefined;
      }

      this.c2cSettingDialogController = new CustomDialogController({
        builder: C2CSettingDialogInGroup({
          conversationID: conversationID,
          title: TextUtils.getResourceString($r('app.string.chatsetting_contact_info_title')),
          onDialogClose: () => {

            console.log('[GroupSettingPage] C2C设置对话框关闭');
            if (this.onDialogClose) {
              this.onDialogClose();
            }
          },
          onSelectedNavigateMessagePage: (newConversationID?: string, title?: string, avatarUrl?: string) => {

            console.log('[GroupSettingPage] 选择联系人发送消息, newConversationID:', newConversationID, 'title:',
              title);
            if (this.onSelectedNavigateMessagePage) {
              this.onSelectedNavigateMessagePage(newConversationID, title, avatarUrl);
            }
          }
        }),
        alignment: DialogAlignment.Default,
        customStyle: true,
        autoCancel: true,
        levelMode: LevelMode.EMBEDDED,
        immersiveMode: ImmersiveMode.EXTEND,
        cancel: () => {
          this.c2cSettingDialogController = undefined;
        }
      });

      this.c2cSettingDialogController.open();
      console.log('[GroupSettingPage] C2C设置对话框已打开');
    } catch (error) {

    }
  }

  private getGroupInitials(): string {
    const groupName = this.groupState?.groupName || 'Group';
    const words = groupName.split(' ');
    if (words.length >= 2) {
      return (words[0].charAt(0) + words[1].charAt(0)).toUpperCase();
    }
    return groupName.charAt(0).toUpperCase();
  }

  private getMemberInitials(member: Member): string {
    const name = member.nameCard || member.nickName || member.userID;
    const words = name.split(' ');
    if (words.length >= 2) {
      return (words[0].charAt(0) + words[1].charAt(0)).toUpperCase();
    }
    return name.charAt(0).toUpperCase();
  }

  private getDisplayMembers(): Member[] {
    const allMembers = this.groupState?.allMembers ?? [];
    const currentUserID = LoginStore.createInstance().state.loginUserInfo?.userID;

    if (allMembers.length === 0) {
      return [];
    }


    const currentUser = allMembers.find(member => member.userID === currentUserID);


    const otherMembers = allMembers.filter(member => member.userID !== currentUserID);


    const displayMembers: Member[] = [];


    if (currentUser) {
      displayMembers.push(currentUser);
    }


    const maxOtherMembers = 2;
    const otherMembersToShow = otherMembers.slice(0, maxOtherMembers);
    displayMembers.push(...otherMembersToShow);

    return displayMembers;
  }

  private getCurrentUserNickname(): string {

    if (this.groupState?.selfNameCard && this.groupState.selfNameCard.length > 0) {
      return this.groupState.selfNameCard;
    }


    const allMembers = this.groupState?.allMembers ?? [];
    const currentUserID = LoginStore.createInstance().state.loginUserInfo?.userID;


    const currentUser = allMembers.find(member => member.userID === currentUserID);

    if (currentUser) {

      return currentUser.nameCard || currentUser.nickName || currentUser.userID || 'Not set';
    }

    return 'Not set';
  }

  private getGroupTypeDisplayName(): string {
    const groupType = this.groupState?.groupType;
    if (!groupType) {
      return 'Work Group';
    }
    switch (groupType) {
      case GroupType.WORK:
        return 'Work';
      case GroupType.PUBLIC:
        return 'Public Group';
      case GroupType.MEETING:
        return 'Meeting';
      case GroupType.AVCHATROOM:
        return 'Chat Room';
      case GroupType.COMMUNITY:
        return 'Community';
      default:
        return groupType;
    }
  }

  private getJoinMethodDisplayName(): string {
    const joinOption = this.groupState?.joinGroupApprovalType;
    if (joinOption === undefined) {
      return 'Need Approval';
    }

    switch (joinOption) {
      case GroupJoinOption.AUTH:
        return 'Need Approval';
      case GroupJoinOption.ANY:
        return 'Anyone Can Join';
      case GroupJoinOption.FORBID:
        return 'Forbidden';
      default:
        return 'Need Approval';
    }
  }

  private getNotice(): string {
    if (this.groupState?.notice) {
      return this.groupState?.notice;
    }
    return "";
  }

  private getInviteMethodDisplayName(): string {
    switch (this.groupState?.inviteToGroupApprovalType) {
      case GroupJoinOption.AUTH:
        return 'Need Admin Approval';
      case GroupJoinOption.ANY:
        return 'Anyone Can Invite';
      case GroupJoinOption.FORBID:
        return 'forbid';
      default:
        return 'Anyone Can Invite';
    }
  }

  private navigateToGroupMemberList(): void {
    try {
      console.log('[GroupSettingPage] Show group member list dialog');
      this.showGroupMemberListDialog();
    } catch (error) {
      console.error('[GroupSettingPage] Error showing group member list dialog:', error);
      Toast.shortToast(TextUtils.getResourceString($r('app.string.chatsetting_open_group_member_list_fail')));
    }
  }

  private navigateToGroupManagement(): void {
    try {
      console.log('[GroupSettingPage] Show group management dialog');
      this.showGroupManagementDialog();
    } catch (error) {
      console.error('[GroupSettingPage] Error showing group management dialog:', error);
      Toast.shortToast(TextUtils.getResourceString($r('app.string.chatsetting_open_group_management_fail')));
    }
  }

  private navigateToGroupAnnouncement(): void {
    try {
      console.log('[GroupSettingPage] Show group announcement dialog');
      this.showGroupAnnouncementDialog();

    } catch (error) {
      console.error('[GroupSettingPage] Error navigating to group announcement:', error);
      Toast.shortToast(TextUtils.getResourceString($r('app.string.chatsetting_open_group_announcement_fail')));
    }
  }

  private navigateToAvatarPicker(): void {
    try {
      console.log('[GroupSettingPage] Navigate to avatar picker for group:', this.groupState?.groupID);


      const avatarUrlList: string[] =
        Array.from<undefined, string>({ length: 24 }, (_: undefined, index: number): string =>
        `https://im.sdk.qcloud.com/download/tuikit-resource/group-avatar/group_avatar_${index + 1}.png`
        );

      console.log('[GroupSettingPage] Avatar URL list:', avatarUrlList);


      if (!avatarUrlList || avatarUrlList.length === 0) {
        console.error('[GroupSettingPage] Avatar URL list is empty');
        Toast.shortToast(TextUtils.getResourceString($r('app.string.chatsetting_no_avatar_available')));
        return;
      }

      console.log('[GroupSettingPage] Show avatar picker dialog');
      this.showAvatarPickerDialog(avatarUrlList);

    } catch (error) {
      console.error('[GroupSettingPage] Error navigating to avatar picker:', error);
      Toast.shortToast(TextUtils.getResourceString($r('app.string.chatsetting_open_avatar_picker_fail')));
    }
  }

  private openGroupNameEditDialog(): void {
    this.groupNameEditDialogController = new CustomDialogController({
      builder: GroupNameEditDialog({
        currentName: this.groupState?.groupName || '',
        onSave: (newName: string) => {
          if (newName && newName.trim().length > 0) {
            this.groupStore?.updateGroupProfile(newName.trim())
              .then(() => {
                Toast.shortToast(TextUtils.getResourceString($r('app.string.chatsetting_group_name_update_success')));

                this.groupStore?.fetchGroupInfo();
              })
              .catch((error: Error) => {
                console.error('[GroupSettingPage] Failed to update group name:', error);
                Toast.shortToast($r('app.string.chatsetting_group_name_update_fail'));
              });
          }
        },
        onCancel: () => {
          // Dialog will close automatically
        }
      }),
      alignment: DialogAlignment.Bottom,
      customStyle: true,
      maskColor: 'rgba(0, 0, 0, 0.6)',
      autoCancel: true
    });

    this.groupNameEditDialogController.open();
  }

  private openGroupNicknameEditDialog(): void {
    this.groupNicknameEditDialogController = new CustomDialogController({
      builder: GroupNameEditDialog({
        title: $r('app.string.chatsetting_edit_my_group_nickname'),
        currentName: this.getCurrentUserNickname(),
        placeholder: $r('app.string.chatsetting_input_group_nickname_placeholder'),
        helpText: $r('app.string.chatsetting_group_nickname_help_text'),
        maxLength: 20,
        onSave: (newNickname: string) => {
          if (newNickname && newNickname.trim().length > 0) {
            this.groupStore?.setSelfGroupNameCard(newNickname.trim())
              .then(() => {
                Toast.shortToast($r('app.string.chatsetting_group_nickname_update_success'));

                this.groupStore?.fetchSelfMemberInfo();
              })
              .catch((error: Error) => {
                console.error('[GroupSettingPage] Failed to update group nickname:', error);
                Toast.shortToast($r('app.string.chatsetting_group_nickname_update_fail'));
              });
          }
        },
        onCancel: () => {
          // Dialog will close automatically
        }
      }),
      alignment: DialogAlignment.Bottom,
      customStyle: true,
      maskColor: 'rgba(0, 0, 0, 0.6)',
      autoCancel: true
    });

    this.groupNicknameEditDialogController.open();
  }

  private convertV2TIMGroupAddOptToJoinOption(opt: V2TIMGroupAddOpt): GroupJoinOption {
    switch (opt) {
      case V2TIMGroupAddOpt.V2TIM_GROUP_ADD_FORBID:
        return GroupJoinOption.FORBID;
      case V2TIMGroupAddOpt.V2TIM_GROUP_ADD_AUTH:
        return GroupJoinOption.AUTH;
      case V2TIMGroupAddOpt.V2TIM_GROUP_ADD_ANY:
        return GroupJoinOption.ANY;
      default:
        return GroupJoinOption.ANY;
    }
  }

  private convertJoinOptionToDialogString(option?: GroupJoinOption): string {
    if (option === undefined) {
      return '';
    }

    switch (option) {
      case GroupJoinOption.AUTH:
        return 'V2TIM_GROUP_ADD_AUTH';
      case GroupJoinOption.ANY:
        return 'V2TIM_GROUP_ADD_ANY';
      case GroupJoinOption.FORBID:
        return 'V2TIM_GROUP_ADD_FORBID';
      default:
        return '';
    }
  }

  private async navigateToTransferOwnership(): Promise<void> {
    if (!this.groupStore) {
      Toast.shortToast($r('app.string.chatsetting_group_info_unavailable'));
      return;
    }

    try {
      console.log('[GroupSettingPage] Navigate to transfer ownership page');


      const currentUserID = LoginStore.createInstance().state.loginUserInfo?.userID;
      const allMembers = this.groupState?.allMembers ?? [];


      const availableMembers = allMembers.filter(member =>
      member.userID !== currentUserID
      );

      if (availableMembers.length === 0) {
        Toast.shortToast($r('app.string.chatsetting_no_transferable_member'));
        return;
      }


      const memberUserList: UserInfo[] = availableMembers.map(member => {
        const userInfo: UserInfo = {
          id: member.userID || '',
          userID: member.userID || '',
          avatarURL: member.faceURL || '',
          displayName: member.nameCard || member.nickName || member.userID || '',
          subtitle: this.getMemberRoleDisplayName(member.role),
          isDisabled: false
        };
        return userInfo;
      });


      const transferParams: UserPickerParams = {
        title: TextUtils.getResourceString($r('app.string.chatsetting_select_new_owner')),
        userList: memberUserList,
        preSelectedUsers: [],
        maxSelectCount: 1,
        confirmButtonText: TextUtils.getResourceString($r('app.string.chatsetting_transfer_ownership_button')),
        action: 'transferOwnership'
      };


      this.showUserPickerDialog(
        memberUserList,
        'transferOwnership',
        TextUtils.getResourceString($r('app.string.chatsetting_select_new_owner'))
      );

    } catch (error) {
      console.error('[GroupSettingPage] Error navigating to transfer ownership:', error);
      Toast.shortToast($r('app.string.chatsetting_open_member_picker_fail'));
    }
  }

  private async navigateToAddMember(): Promise<void> {
    if (!this.groupStore) {
      Toast.shortToast($r('app.string.chatsetting_group_info_unavailable'));
      return;
    }

    try {
      console.log('[GroupSettingPage] Navigate to add member page');


      Toast.shortToast($r('app.string.chatsetting_getting_friend_list'));


      const currentMemberIds = (this.groupState?.allMembers ?? []).map(member => member.userID);


      const friendList: UserInfo[] = await this.getFriendList();


      const availableFriends = friendList.filter(friend =>
      !currentMemberIds.includes(friend.userID)
      );

      if (availableFriends.length === 0) {
        Toast.shortToast($r('app.string.chatsetting_no_friends_to_add'));
        return;
      }


      this.showUserPickerDialog(
        availableFriends,
        'addMember',
        $r('app.string.chatsetting_select_friends_to_add')
      );

    } catch (error) {
      console.error('[GroupSettingPage] Error navigating to add member:', error);
      Toast.shortToast($r('app.string.chatsetting_open_friend_picker_fail'));
    }
  }

  private async getFriendList(): Promise<UserInfo[]> {
    try {

      await this.contactListStore.fetchFriends();


      const friendList: UserInfo[] = [];
      for (let i = 0; i < this.contactListState.contactDataSource.totalCount(); i++) {
        const contact = this.contactListState.contactDataSource.getData(i) as ContactInfo;
        if (contact) {
          const userInfo: UserInfo = {
            id: contact.ID || contact.identifier || '',
            userID: contact.identifier || '',
            avatarURL: contact.avatarURL || '',
            displayName: contact.title || contact.identifier || '',
            subtitle: contact.onlineStatus === ContactOnlineStatus.ONLINE ? $r('app.string.chatsetting_online') :
            $r('app.string.chatsetting_offline'),
            isDisabled: false
          };
          friendList.push(userInfo);
        }
      }

      console.log(`[GroupSettingPage] 获取到 ${friendList.length} 个好友`);
      return friendList;

    } catch (error) {
      Toast.shortToast($r('app.string.chatsetting_get_friend_list_fail'));
      return [];
    }
  }

  private handleSelectedUsersForAddMember(selectedUsers: UserInfo[]): void {
    if (!this.groupStore || selectedUsers.length === 0) {
      return;
    }

    console.log('[GroupSettingPage] Handle selected users for adding to group:', selectedUsers.map(u => u.displayName));


    AlertDialog.show(
      TextUtils.getResourceString($r('app.string.chatsetting_invite_friends_to_group')),
      TextUtils.getResourceString($r('app.string.chatsetting_confirm_add_members_dialog')) + ' ' +
      selectedUsers.length + ' ' +
      TextUtils.getResourceString($r('app.string.chatsetting_confirm_add_members_dialog_unit')),
      TextUtils.getResourceString($r('app.string.chatsetting_cancel')),
      TextUtils.getResourceString($r('app.string.chatsetting_confirm')),
      undefined, // onDismiss
      () => {
        console.log('[GroupSettingPage] User cancelled add member operation');
      },
      () => {
        this.addSelectedUsersToGroup(selectedUsers);
      },
      this.getUIContext()
    );
  }

  private async addSelectedUsersToGroup(selectedUsers: UserInfo[]): Promise<void> {
    if (!this.groupStore) {
      return;
    }

    Toast.shortToast($r('app.string.chatsetting_inviting_friends_to_group'));

    try {

      const userIDs = selectedUsers.map(user => user.userID);


      await this.groupStore.addGroupMember(userIDs);

      Toast.shortToast(TextUtils.getResourceString($r('app.string.chatsetting_success_invite_friends')) + ' ' +
      selectedUsers.length +
        ' ' + TextUtils.getResourceString($r('app.string.chatsetting_success_invite_friends_unit')));
      console.log('[GroupSettingPage] Successfully added users to group');


      await this.loadGroupData();

    } catch (error) {
      console.error('[GroupSettingPage] Failed to add users to group:', error);
      Toast.shortToast($r('app.string.chatsetting_invite_friends_to_group_fail'));
    }
  }

  private handleSelectedUserForTransferOwnership(selectedUsers: UserInfo[]): void {
    if (!this.groupStore || selectedUsers.length === 0) {
      return;
    }

    const selectedUser = selectedUsers[0];
    console.log('[GroupSettingPage] Handle selected user for transfer ownership:', selectedUser.displayName);


    AlertDialog.show(
      TextUtils.getResourceString($r('app.string.chatsetting_transfer_ownership_title')),
      TextUtils.getResourceString($r('app.string.chatsetting_confirm_transfer_ownership_dialog')) + ' "' +
      selectedUser.displayName +
        '" ' + TextUtils.getResourceString($r('app.string.chatsetting_confirm_transfer_ownership_dialog_note')),
      TextUtils.getResourceString($r('app.string.chatsetting_cancel_transfer')),
      TextUtils.getResourceString($r('app.string.chatsetting_confirm_transfer')),
      () => {
        //onDismiss
      },
      () => {
        console.log('[GroupSettingPage] User cancelled transfer ownership operation');
      },
      () => {
        this.transferOwnershipToUser(selectedUser);
      },
      this.getUIContext()

    );
  }

  private async transferOwnershipToUser(targetUser: UserInfo): Promise<void> {
    if (!this.groupStore) {
      return;
    }

    Toast.shortToast($r('app.string.chatsetting_transferring_ownership'));

    try {

      await this.groupStore.changeGroupOwner(targetUser.userID);

      Toast.shortToast($r('app.string.chatsetting_success_invite_friends'),
        TextUtils.getResourceString($r('app.string.chatsetting_success_invite_friends'))
          .replace('{name}', targetUser.displayName));
      console.log('[GroupSettingPage] Successfully transferred ownership to:', targetUser.userID);


      await this.loadGroupData();


      setTimeout(() => {
        this.closeDialog();
      }, 1000);

    } catch (error) {
      console.error('[GroupSettingPage] Failed to transfer ownership:', error);
      Toast.shortToast($r('app.string.chatsetting_transfer_ownership_failed'));
    }
  }

  private getMemberRoleDisplayName(role: GroupMemberRole): string {
    switch (role) {
      case GroupMemberRole.OWNER:
        return TextUtils.getResourceString($r('app.string.chatsetting_owner_role'));
      case GroupMemberRole.ADMIN:
        return TextUtils.getResourceString($r('app.string.chatsetting_admin_role'));
      case GroupMemberRole.MEMBER:
        return TextUtils.getResourceString($r('app.string.chatsetting_regular_member_role'));
      default:
        return TextUtils.getResourceString($r('app.string.chatsetting_member_role'));
    }
  }

  private handleAvatarSelected(selectedAvatar: string): void {
    console.log('[GroupSettingPage] Avatar selected:', selectedAvatar);

    if (!selectedAvatar || !this.groupStore) {
      console.error('[GroupSettingPage] Invalid avatar or group state');
      return;
    }

    try {

      Toast.shortToast($r('app.string.chatsetting_updating_group_avatar'));


      this.groupStore.updateGroupProfile(undefined, undefined, selectedAvatar)
        .then(() => {
          Toast.shortToast($r('app.string.chatsetting_group_avatar_update_successful'));
          console.log('[GroupSettingPage] Group avatar updated successfully');


          this.groupStore?.fetchGroupInfo();
        })
        .catch((error: Error) => {
          console.error('[GroupSettingPage] Failed to update group avatar:', error);
          Toast.shortToast($r('app.string.chatsetting_group_avatar_update_failed'));
        });
    } catch (error) {
      console.error('[GroupSettingPage] Error handling avatar selection:', error);
      Toast.shortToast($r('app.string.chatsetting_avatar_processing_failed'));
    }
  }

  private showDismissGroupConfirmDialog(): void {
    const groupName =
      this.groupState?.groupName ||
      TextUtils.getResourceString($r('app.string.chatsetting_group_default'));

    AlertDialog.show(
      TextUtils.getResourceString($r('app.string.chatsetting_dismiss_group_title')),
      `确定要解散"${groupName}"吗？解散后群组将被永久删除，所有成员将被移除。`,
      TextUtils.getResourceString($r('app.string.chatsetting_cancel_dismiss')),
      TextUtils.getResourceString($r('app.string.chatsetting_confirm_dismiss')),
      undefined, // onDismiss
      () => {

        console.log('[GroupSettingPage] User cancelled dismiss group');
      },
      () => {

        console.log('[GroupSettingPage] User confirmed dismiss group');
        this.performDismissGroup();
      },
      this.getUIContext()
    );
  }

  private performDismissGroup(): void {
    if (!this.groupStore) {
      Toast.shortToast($r('app.string.chatsetting_group_info_unavailable'));
      return;
    }


    Toast.shortToast($r('app.string.chatsetting_dismissing_group_progress'));

    this.groupStore.dismissGroup()
      .then(() => {
        Toast.shortToast($r('app.string.chatsetting_dismiss_group_successful'));
        console.log('[GroupSettingPage] Group dismissed successfully');

        // Close dialog
        this.closeDialog();
      })
      .catch((error: Error) => {
        console.error('[GroupSettingPage] Failed to dismiss group:', error);
        Toast.shortToast($r('app.string.chatsetting_dismiss_group_failed'));
      });
  }

  private showClearHistoryConfirmDialog(): void {
    const groupName =
      this.groupState?.groupName ||
      TextUtils.getResourceString($r('app.string.chatsetting_group_default'));

    AlertDialog.show(
      TextUtils.getResourceString($r('app.string.chatsetting_clear_chat_history_title')),
      `确定要清空"${groupName}"的聊天记录吗？此操作不可撤销。`,
      TextUtils.getResourceString($r('app.string.chatsetting_cancel_clear')),
      TextUtils.getResourceString($r('app.string.chatsetting_confirm_clear')),
      undefined, // onDismiss
      () => {

        console.log('[GroupSettingPage] User cancelled clear history');
      },
      () => {

        console.log('[GroupSettingPage] User confirmed clear history');
        this.performClearHistory();
      },
      this.getUIContext()
    );
  }

  private performClearHistory(): void {
    if (!this.groupStore) {
      Toast.shortToast($r('app.string.chatsetting_group_info_unavailable'));
      return;
    }


    Toast.shortToast($r('app.string.chatsetting_clearing_chat_history'));

    this.groupStore.clearHistoryMessage()
      .then(() => {
        Toast.shortToast($r('app.string.chatsetting_clear_chat_history_successful'));
        console.log('[GroupSettingPage] Chat history cleared successfully');
      })
      .catch((error: Error) => {
        console.error('[GroupSettingPage] Failed to clear history:', error);
        Toast.shortToast($r('app.string.chatsetting_clear_chat_history_failed'));
      });
  }

  private showLeaveGroupConfirmDialog(): void {
    const groupName =
      this.groupState?.groupName ||
      TextUtils.getResourceString($r('app.string.chatsetting_group_default'));

    AlertDialog.show(
      TextUtils.getResourceString($r('app.string.chatsetting_leave_group_title')),
      `确定要退出"${groupName}"吗？退出后将无法接收群消息。`,
      TextUtils.getResourceString($r('app.string.chatsetting_cancel_leave')),
      TextUtils.getResourceString($r('app.string.chatsetting_confirm_leave')),
      undefined, // onDismiss
      () => {

        console.log('[GroupSettingPage] User cancelled leave group');
      },
      () => {

        console.log('[GroupSettingPage] User confirmed leave group');
        this.performLeaveGroup();
      },
      this.getUIContext()
    );
  }

  private performLeaveGroup(): void {
    if (!this.groupStore) {
      Toast.shortToast($r('app.string.chatsetting_group_info_unavailable'));
      return;
    }


    Toast.shortToast($r('app.string.chatsetting_leaving_group_progress'));

    this.groupStore.quitGroup()
      .then(() => {
        Toast.shortToast($r('app.string.chatsetting_leave_group_successful'));
        console.log('[GroupSettingPage] Left group successfully');

        // Close dialog
        this.closeDialog();
      })
      .catch((error: Error) => {
        console.error('[GroupSettingPage] Failed to leave group:', error);
        Toast.shortToast($r('app.string.chatsetting_leave_group_failed'));
      });
  }

  private handleQuickActionClick(label: string | Resource): void {
    if (!this.groupStore) {
      Toast.shortToast($r('app.string.chatsetting_group_info_unavailable'));
      return;
    }


    const messageLabel = TextUtils.getResourceString($r('app.string.chatsetting_message'));
    const currentLabel = typeof label === 'string' ? label : TextUtils.getResourceString(label);

    if (currentLabel === messageLabel) {
      this.handleAudioCallClick();
    }
  }

  private handleAudioCallClick(): void {


    this.closeDialog();
  }

  private showAvatarPickerDialog(urlList: string[]): void {
    try {
      if (this.avatarPickerDialogController) {
        this.avatarPickerDialogController.close();
        this.avatarPickerDialogController = undefined;
      }

      this.avatarPickerDialogController = new CustomDialogController({
        builder: AvatarPickerDialog({
          title: $r('app.string.chatsetting_select_avatar'),
          urlList: urlList,
          onConfirm: (selectedUrl: string, selectedIndex: number) => {
            this.handleAvatarSelected(selectedUrl);
          }
        }),
        alignment: DialogAlignment.Default,
        customStyle: true,
        autoCancel: true,
        levelMode: LevelMode.EMBEDDED,
        immersiveMode: ImmersiveMode.EXTEND,
        cancel: () => {
          this.avatarPickerDialogController = undefined;
        }
      });

      this.avatarPickerDialogController.open();
      console.log('[GroupSettingPage] 头像选择对话框已打开');
    } catch (error) {

    }
  }

  private showGroupAnnouncementDialog(): void {
    try {
      if (this.groupAnnouncementDialogController) {
        this.groupAnnouncementDialogController.close();
        this.groupAnnouncementDialogController = undefined;
      }

      if (!this.groupState?.groupID) {

        return;
      }

      this.groupAnnouncementDialogController = new CustomDialogController({
        builder: GroupAnnouncementDialog({
          groupID: this.groupState?.groupID,
          onSave: (announcement: string) => {
            console.log('[GroupSettingPage] 群公告已保存:', announcement);

            this.groupStore?.fetchGroupInfo();
          }
        }),
        alignment: DialogAlignment.Default,
        customStyle: true,
        autoCancel: true,
        levelMode: LevelMode.EMBEDDED,
        immersiveMode: ImmersiveMode.EXTEND,
        cancel: () => {
          this.groupAnnouncementDialogController = undefined;
        }
      });

      this.groupAnnouncementDialogController.open();
      console.log('[GroupSettingPage] 群公告对话框已打开');
    } catch (error) {

    }
  }

  private showGroupMemberListDialog(): void {
    try {
      if (this.groupMemberListDialogController) {
        this.groupMemberListDialogController.close();
        this.groupMemberListDialogController = undefined;
      }

      if (!this.groupState?.groupID) {

        return;
      }

      this.groupMemberListDialogController = new CustomDialogController({
        builder: GroupMemberListDialog({
          groupID: this.groupState?.groupID || '',
          groupName: this.groupState?.groupName || '群成员',
          onMemberSelect: (member: Member) => {
            console.log('[GroupSettingPage] 选择了成员:', member.userID);

          }
        }),
        alignment: DialogAlignment.Default,
        customStyle: true,
        autoCancel: true,
        levelMode: LevelMode.EMBEDDED,
        immersiveMode: ImmersiveMode.EXTEND,
        cancel: () => {
          this.groupMemberListDialogController = undefined;
        }
      });

      this.groupMemberListDialogController.open();
      console.log('[GroupSettingPage] 群成员列表对话框已打开');
    } catch (error) {

    }
  }

  private showUserPickerDialog(userList: UserInfo[], action: string, title?: string | Resource): void {
    try {
      if (this.userPickerDialogController) {
        this.userPickerDialogController.close();
        this.userPickerDialogController = undefined;
      }

      this.userPickerDialogController = new CustomDialogController({
        builder: UserPickerDialog({
          title: title || $r('app.string.chatsetting_select_user'),
          userList: userList,
          preSelectedUsers: [],
          maxSelectCount: -1,
          confirmButtonText: $r('app.string.chatsetting_complete'),
          action: action,
          onConfirm: (selectedUsers: UserInfo[], actionType: string) => {
            this.handleSelectedUsersResult(selectedUsers, actionType);
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
      console.log('[GroupSettingPage] 用户选择器对话框已打开');
    } catch (error) {

    }
  }

  private handleSelectedUsersResult(selectedUsers: UserInfo[], action: string): void {
    console.log('[GroupSettingPage] 处理用户选择结果:', action, '选择的用户数量:', selectedUsers.length);

    switch (action) {
      case 'addMember':
        this.handleSelectedUsersForAddMember(selectedUsers);
        break;
      case 'transferOwnership':
        this.handleSelectedUserForTransferOwnership(selectedUsers);
        break;
      default:
        console.warn('[GroupSettingPage] 未知的用户选择操作:', action);
    }
  }

  private showGroupManagementDialog(): void {
    try {
      if (this.groupManagementDialogController) {
        this.groupManagementDialogController.close();
        this.groupManagementDialogController = undefined;
      }

      if (!this.groupState?.groupID) {

        return;
      }

      this.groupManagementDialogController = new CustomDialogController({
        builder: GroupManagementDialog({
          groupID: this.groupState?.groupID || ''
        }),
        alignment: DialogAlignment.Default,
        customStyle: true,
        autoCancel: true,
        levelMode: LevelMode.EMBEDDED,
        immersiveMode: ImmersiveMode.EXTEND,
        cancel: () => {
          this.groupManagementDialogController = undefined;
        }
      });

      this.groupManagementDialogController.open();
      console.log('[GroupSettingPage] 群管理对话框已打开');
    } catch (error) {

    }
  }
}