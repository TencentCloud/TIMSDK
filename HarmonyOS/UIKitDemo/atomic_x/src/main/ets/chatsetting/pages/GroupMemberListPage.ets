import { Avatar, AvatarContentType, AvatarSize, TextUtils, ThemeState, Toast } from '../../basecomponent/Index';
import { GroupSettingStore, GroupSettingState, Member, GroupMemberRole, GroupType, LoginStore } from 'chatengine';
import { GroupPermissionManager, GroupPermission } from '../manager/GroupPermissionManager';
import { ActionButtonConfig } from '../dialog/GroupSettingDialogs';
import { ActionSheet, ActionItem } from '../../basecomponent/Index';
import { C2CChatSettingView } from './C2CChatSettingView';

@CustomDialog
struct C2CSettingDialogInMemberList {
  controller: CustomDialogController;
  conversationID: string = '';
  title: string = 'Contact Info';

  build() {
    C2CChatSettingView({
      conversationID: this.conversationID,
      title: this.title,
      onBack: () => {
        this.controller.close();
      },
      onSelectedNavigateMessagePage: () => {

      },
      dialogController: this.controller
    })
  }
}

@Component
export struct GroupMemberListPage {
  private static readonly CELL_HEIGHT: number = 56;
  private static readonly SECTION_MARGIN: number = 12;
  private static readonly HORIZONTAL_PADDING: number = 16;
  private static readonly BORDER_RADIUS: number = 12;
  private static readonly MEMBER_AVATAR_SIZE: number = 40;
  private static readonly SEARCH_BAR_HEIGHT: number = 36;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State groupStore?: GroupSettingStore = undefined;
  @State groupState?: GroupSettingState = this.groupStore?.state;
  @State isLoading: boolean = true;
  @State searchText: string = '';
  @State filteredMembers: Member[] = [];
  @State showSearchBar: boolean = false;
  @State selectedMember?: Member = undefined;
  @Prop groupID: string = '';
  @Prop groupName: string = TextUtils.getResourceString($r('app.string.chatsetting_group_members_title'));
  onBack?: () => void;
  onMemberSelect?: (member: Member) => void;
  dialogController?: CustomDialogController;
  onDialogClose?: () => void;
  private memberOptionsDialogController?: CustomDialogController;
  private c2cSettingDialogController?: CustomDialogController;

  aboutToAppear(): void {
    if (this.groupID) {
      this.groupStore = GroupSettingStore.createInstance(this.groupID);
      this.groupStore.registerListener();
      this.groupState = this.groupStore.state;
      this.loadGroupData();
    }
  }

  aboutToDisappear(): void {

    this.groupStore?.unregisterListener();
    this.groupState = undefined;

    if (this.memberOptionsDialogController) {
      this.memberOptionsDialogController = undefined;
    }
    if (this.c2cSettingDialogController) {
      this.c2cSettingDialogController = undefined;
    }
  }

  build() {
    Column() {
      this.NavigationBarBuilder()

      if (this.isLoading) {
        this.LoadingStateBuilder()
      } else {
        Column() {


          this.MemberStatsBuilder()


          this.MemberListBuilder()
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(this.themeState.colors.bgColorInput)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.colors.bgColorInput)
  }

  onBackPress(): boolean {
    this.closeDialog();
    return true;
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
      Text(this.groupName)
        .fontSize(18)
        .fontWeight(600)
        .fontFamily('SF Pro Display')
        .fontColor(this.themeState.colors.textColorPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

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

      Text($r('app.string.chatsetting_loading_group_members'))
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
  MemberStatsBuilder() {
    Row() {
      Text(`${this.filteredMembers.length} Members`)
        .fontSize(14)
        .fontWeight(500)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorSecondary)

      Blank()

    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 8
    })
  }

  @Builder
  MemberListBuilder() {
    List() {
      // 1. Show current user first (if exists in members)
      ForEach(this.getCurrentUserMembers(), (member: Member) => {
        ListItem() {
          this.MemberRowBuilder(member)
        }
      })

      // 2. Show group owner (if not current user)
      ForEach(this.getGroupOwnerMembers(), (member: Member) => {
        ListItem() {
          this.MemberRowBuilder(member)
        }
      })

      // 3. Show admin members (excluding current user and owner)
      ForEach(this.getAdminMembers(), (member: Member) => {
        ListItem() {
          this.MemberRowBuilder(member)
        }
      })

      // 4. Show ordinary members (excluding current user)
      ForEach(this.getOrdinaryMembers(), (member: Member) => {
        ListItem() {
          this.MemberRowBuilder(member)
        }
      })
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor(this.themeState.colors.bgColorTopBar)
    .margin({ left: 16, right: 16, bottom: 16 })
    .divider({
      strokeWidth: 1,
      color: this.themeState.colors.strokeColorSecondary,
      startMargin: GroupMemberListPage.HORIZONTAL_PADDING + GroupMemberListPage.MEMBER_AVATAR_SIZE + 12,
      endMargin: GroupMemberListPage.HORIZONTAL_PADDING
    })
  }

  @Builder
  MemberRowBuilder(member: Member) {
    Row() {
      Avatar({
        content: {
          type: AvatarContentType.Image,
          url: member.faceURL,
          name: TextUtils.getAvatarLetter(member.nickName) || '',
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
            .layoutWeight(1)


          if (member.role === GroupMemberRole.OWNER) {
            Text($r('app.string.chatsetting_owner'))
              .fontSize(12)
              .fontWeight(500)
              .fontFamily('SF Pro Text')
              .fontColor(this.themeState.colors.textColorTertiary)
              .padding({
                left: 6,
                right: 6,
                top: 2,
                bottom: 2
              })
              .backgroundColor('rgba(255, 149, 0, 0.1)')
              .borderRadius(4)
          } else if (member.role === GroupMemberRole.ADMIN) {
            Text($r('app.string.chatsetting_admin'))
              .fontSize(12)
              .fontWeight(500)
              .fontFamily('SF Pro Text')
              .fontColor(this.themeState.colors.textColorLink)
              .padding({
                left: 6,
                right: 6,
                top: 2,
                bottom: 2
              })
              .backgroundColor('rgba(3, 101, 249, 0.1)')
              .borderRadius(4)
          }
        }

        if (member.userID !== (member.nameCard || member.nickName) && member.userID) {
          Text(`@${member.userID.toString()}`)
            .fontSize(14)
            .fontWeight(400)
            .fontFamily('SF Pro Text')
            .fontColor(this.themeState.colors.textColorSecondary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }


        if (member.muteUntil && member.muteUntil > Date.now() / 1000) {
          Text($r('app.string.chatsetting_muted'))
            .fontSize(12)
            .fontWeight(500)
            .fontFamily('SF Pro Text')
            .fontColor(this.themeState.colors.textColorTertiary)
            .padding({
              left: 6,
              right: 6,
              top: 2,
              bottom: 2
            })
            .backgroundColor('rgba(255, 88, 76, 0.1)')
            .borderRadius(4)
        }

      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)


      if (this.canManageMember(member)) {
        Image($rawfile('search/right_arrow_icon.svg'))
          .width(20)
          .height(20)
          .fillColor(this.themeState.colors.textColorSecondary)
      }
    }
    .width('100%')
    .height(GroupMemberListPage.CELL_HEIGHT)
    .padding({ left: GroupMemberListPage.HORIZONTAL_PADDING, right: GroupMemberListPage.HORIZONTAL_PADDING })
    .onClick(() => {
      if (this.canManageMember(member)) {
        this.showMemberOptions(member);
      } else {
        this.handleMemberClick(member);
      }
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

    }
  }

  private async loadGroupData(): Promise<void> {
    if (!this.groupStore) {
      return;
    }

    try {
      await Promise.all([
        this.groupStore.fetchGroupInfo(),
        this.groupStore.fetchGroupMembers()
      ]);
      this.filterMembers();
      console.log('[GroupMemberListPage] Group data loaded successfully');
    } catch (error) {
      console.error('[GroupMemberListPage] Failed to load group data:', error);
      Toast.shortToast($r('app.string.chatsetting_load_group_info_fail_toast'));
    } finally {
      this.isLoading = false;
    }
  }

  private filterMembers(): void {
    const allMembers = this.groupState?.allMembers || [];

    if (this.searchText.trim().length === 0) {
      this.filteredMembers = allMembers;
    } else {
      const searchLower = this.searchText.toLowerCase();
      this.filteredMembers = allMembers.filter(member => {
        const name = (member.nameCard || member.nickName || member.userID).toLowerCase();
        const userID = member.userID.toLowerCase();
        return name.includes(searchLower) || userID.includes(searchLower);
      });
    }
  }

  private getCurrentUserMembers(): Member[] {
    const currentUserID = LoginStore.createInstance().state.loginUserInfo?.userID;
    if (!currentUserID) {
      return [];
    }
    return this.filteredMembers.filter(member => member.userID === currentUserID);
  }

  private getGroupOwnerMembers(): Member[] {
    const currentUserID = LoginStore.createInstance().state.loginUserInfo?.userID;
    return this.filteredMembers.filter(member => 
      member.role === GroupMemberRole.OWNER && member.userID !== currentUserID
    );
  }

  private getAdminMembers(): Member[] {
    const currentUserID = LoginStore.createInstance().state.loginUserInfo?.userID;
    return this.filteredMembers.filter(member => 
      member.role === GroupMemberRole.ADMIN && member.userID !== currentUserID
    );
  }

  private getOrdinaryMembers(): Member[] {
    const currentUserID = LoginStore.createInstance().state.loginUserInfo?.userID;
    return this.filteredMembers.filter(member => 
      member.role === GroupMemberRole.MEMBER && member.userID !== currentUserID
    );
  }

  private getFilteredOrdinaryMembers(): Member[] {
    return this.filteredMembers.filter(member =>
    member.role === GroupMemberRole.MEMBER
    );
  }

  private hasPermission(permission: GroupPermission): boolean {
    const userRole = this.groupState?.currentUserRole;
    if (!userRole) {
      return false;
    }

    const groupType = this.convertStringToGroupType(this.groupState?.groupType);
    return GroupPermissionManager.hasPermission(groupType, userRole, permission);
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

  private handleMemberClick(member: Member): void {
    console.log('[GroupMemberListPage] Member clicked:', member.userID);

  }

  private showMemberOptions(member: Member): void {
    console.log('[GroupMemberListPage] Show options for member:', member.userID);
    this.selectedMember = member;


    const options: ActionButtonConfig[] = [];


    options.push({
      text: $r('app.string.chatsetting_member_detail'),
      action: 'detail',
      showDivider: true
    });


    if (this.groupState?.currentUserRole === GroupMemberRole.OWNER &&
      member.role === GroupMemberRole.MEMBER) {
      options.push({
        text: $r('app.string.chatsetting_member_set_admin'),
        action: 'setAdmin',
        showDivider: true
      });
    }


    if (this.groupState?.currentUserRole === GroupMemberRole.OWNER &&
      member.role === GroupMemberRole.ADMIN) {
      options.push({
        text: $r('app.string.chatsetting_member_remove_admin'),
        action: 'removeAdmin',
        showDivider: true
      });
    }


    if (this.canRemoveMember(member)) {
      options.push({
        text: $r('app.string.chatsetting_member_remove'),
        action: 'removeMember',
        color: '#FF584C',
        showDivider: false
      });
    }


    const actionItems: ActionItem[] = options.map((option: ActionButtonConfig): ActionItem => ({
      text: option.text,
      value: option.action,
      isDestructive: option.color === '#FF584C'
    }));


    this.memberOptionsDialogController = new CustomDialogController({
      builder: ActionSheet({
        title: `管理成员: ${member.nameCard || member.nickName || member.userID}`,
        options: actionItems,
        onActionSelected: (item: ActionItem) => {
          this.handleMemberAction(item.value as string, member);
        },
        onDismiss: () => {
          this.selectedMember = undefined;
        }
      }),
      alignment: DialogAlignment.Bottom,
      customStyle: true,
      maskColor: 'rgba(0, 0, 0, 0.6)',
      autoCancel: true
    });

    this.memberOptionsDialogController.open();
  }

  private canRemoveMember(member: Member): boolean {

    if (member.userID === LoginStore.createInstance().state.loginUserInfo?.userID) {
      return false;
    }

    const currentUserRole = this.groupState?.currentUserRole;


    if (currentUserRole === GroupMemberRole.OWNER) {
      return member.role !== GroupMemberRole.OWNER &&
      this.hasPermission(GroupPermission.REMOVE_GROUP_MEMBER);
    }


    if (currentUserRole === GroupMemberRole.ADMIN &&
      member.role === GroupMemberRole.MEMBER) {
      return this.hasPermission(GroupPermission.REMOVE_GROUP_MEMBER);
    }

    return false;
  }

  private handleMemberAction(action: string, member: Member): void {
    console.log('[GroupMemberListPage] Handle member action:', action, 'for member:', member.userID);

    switch (action) {
      case 'detail':
        this.showMemberDetail(member);
        break;
      case 'setAdmin':
        this.setMemberAsAdmin(member);
        break;
      case 'removeAdmin':
        this.removeMemberAdmin(member);
        break;
      case 'removeMember':
        this.removeMemberFromGroup(member);
        break;
      default:
        console.warn('[GroupMemberListPage] Unknown action:', action);
    }


    this.selectedMember = undefined;
  }

  private showMemberDetail(member: Member): void {
    console.log('[GroupMemberListPage] Show member detail for:', member.userID);


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
        builder: C2CSettingDialogInMemberList({
          conversationID: conversationID,
          title: title
        }),
        alignment: DialogAlignment.Default,
        customStyle: true,
        autoCancel: true,
        cancel: () => {
          this.c2cSettingDialogController = undefined;
        }
      });

      this.c2cSettingDialogController.open();
      console.log('[GroupMemberListPage] C2C设置对话框已打开');
    } catch (error) {

    }
  }

  private setMemberAsAdmin(member: Member): void {
    console.log('[GroupMemberListPage] Set member as admin:', member.userID);

    if (!this.groupStore) {
      Toast.shortToast($r('app.string.chatsetting_group_info_unavailable_toast'));
      return;
    }


    Toast.shortToast($r('app.string.chatsetting_member_setting_admin'));

    this.groupStore.setGroupMemberRole(member.userID, GroupMemberRole.ADMIN)
      .then(() => {
        Toast.shortToast(`已将 ${member.nameCard || member.nickName || member.userID} 设置为管理员`);

        this.loadGroupData();
      })
      .catch((error: Error) => {
        console.error('[GroupMemberListPage] Failed to set member as admin:', error);
        Toast.shortToast($r('app.string.chatsetting_member_setting_admin_fail'));
      });
  }

  private removeMemberAdmin(member: Member): void {
    console.log('[GroupMemberListPage] Remove member admin:', member.userID);

    if (!this.groupStore) {
      Toast.shortToast($r('app.string.chatsetting_group_info_unavailable_toast'));
      return;
    }


    Toast.shortToast($r('app.string.chatsetting_member_removing_admin'));

    this.groupStore.setGroupMemberRole(member.userID, GroupMemberRole.MEMBER)
      .then(() => {
        Toast.shortToast(`已取消 ${member.nameCard || member.nickName || member.userID} 的管理员权限`);

        this.loadGroupData();
      })
      .catch((error: Error) => {
        console.error('[GroupMemberListPage] Failed to remove member admin:', error);
        Toast.shortToast($r('app.string.chatsetting_member_remove_admin_fail'));
      });
  }

  private removeMemberFromGroup(member: Member): void {
    console.log('[GroupMemberListPage] Remove member from group:', member.userID);

    if (!this.groupStore) {
      Toast.shortToast($r('app.string.chatsetting_group_info_unavailable_toast'));
      return;
    }


    Toast.shortToast($r('app.string.chatsetting_member_removing'));

    this.groupStore.deleteGroupMember([member])
      .then(() => {
        Toast.shortToast(`已将 ${member.nameCard || member.nickName || member.userID} 移出群组`);

        this.loadGroupData();
      })
      .catch((error: Error) => {
        console.error('[GroupMemberListPage] Failed to remove member from group:', error);
        Toast.shortToast($r('app.string.chatsetting_member_remove_fail'));
      });
  }
}

