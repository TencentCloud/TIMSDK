import { TextUtils, ThemeState, Toast } from '../../basecomponent/Index';
import { LoginStore, GroupSettingState, GroupSettingStore, GroupType } from 'chatengine';
import { GroupPermissionManager, GroupPermission } from '../manager/GroupPermissionManager';

@Component
export struct GroupAnnouncementView {
  private static readonly HORIZONTAL_PADDING: number = 16;
  private static readonly VERTICAL_PADDING: number = 12;
  private static readonly BORDER_RADIUS: number = 12;
  private static readonly MIN_HEIGHT: number = 120;
  private static readonly MAX_LENGTH: number = 300;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State groupStore?: GroupSettingStore = undefined;
  @State groupState?: GroupSettingState = this.groupStore?.state;
  @State isEditing: boolean = false;
  @State announcement: string = '';
  @State originalAnnouncement: string = '';
  @State isLoading: boolean = false;
  @State isInitializing: boolean = true;
  groupID: string = '';
  onBack?: () => void;
  onSave?: (announcement: string) => void;
  dialogController?: CustomDialogController;
  onDialogClose?: () => void;

  aboutToAppear(): void {
    if (this.groupID) {
      this.groupStore = createGroupChatSettingStore(this.groupID);
      this.groupStore.registerListener();
      // Bind first-level observable state to avoid deep observation
      this.groupState = this.groupStore.state;
      this.initAnnouncementContent();
    }
  }

  aboutToDisappear(): void {

    if (this.groupStore) {
      this.groupStore.unregisterListener();
    }
    this.groupState = undefined;
  }

  build() {
    Column() {
      this.NavigationBarBuilder()

      if (this.isInitializing) {

        this.LoadingStateBuilder()
      } else {
        Scroll() {
          Column({ space: 16 }) {

            this.AnnouncementContentBuilder()


            if (this.hasEditPermission()) {
              this.HelpTextBuilder()
            }
          }
          .width('100%')
          .padding({
            left: GroupAnnouncementView.HORIZONTAL_PADDING,
            right: GroupAnnouncementView.HORIZONTAL_PADDING,
            top: 16,
            bottom: 16
          })
        }
        .backgroundColor(this.themeState.colors.bgColorOperate)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  LoadingStateBuilder() {
    Column({ space: 16 }) {

      LoadingProgress()
        .width(40)
        .height(40)
        .color(this.themeState.colors.textColorLink)


      Text($r('app.string.chatsetting_group_announcement_loading'))
        .fontSize(16)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorSecondary)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.themeState.colors.bgColorOperate)
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
          this.handleBackClick();
        })

      Blank()

      // Title
      Text($r('app.string.chatsetting_group_announcement_title'))
        .fontSize(18)
        .fontWeight(600)
        .fontFamily('SF Pro Display')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()


      if (this.hasEditPermission()) {
        if (this.isEditing) {

          Text($r('app.string.chatsetting_save'))
            .fontSize(16)
            .fontWeight(400)
            .fontFamily('SF Pro Text')
            .fontColor(this.canSave() ? this.themeState.colors.textColorLink :
            this.themeState.colors.textColorSecondary)
            .onClick(() => {
              if (this.canSave()) {
                this.saveAnnouncement();
              }
            })
        } else {

          Text($r('app.string.chatsetting_edit'))
            .fontSize(16)
            .fontWeight(400)
            .fontFamily('SF Pro Text')
            .fontColor(this.themeState.colors.textColorLink)
            .onClick(() => {
              this.enterEditMode();
            })
        }
      } else {

        Text('')
          .width(40)
      }
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
  AnnouncementContentBuilder() {
    Column({ space: 0 }) {

      Row() {
        Text($r('app.string.chatsetting_announcement_content'))
          .fontSize(16)
          .fontWeight(500)
          .fontFamily('PingFang SC')
          .fontColor(this.themeState.colors.textColorPrimary)

        Blank()

        if (this.isEditing) {
          Text(`${this.announcement.length}/${GroupAnnouncementView.MAX_LENGTH}`)
            .fontSize(14)
            .fontWeight(400)
            .fontFamily('SF Pro Text')
            .fontColor(this.announcement.length > GroupAnnouncementView.MAX_LENGTH ? '#FF3B30' :
            this.themeState.colors.textColorSecondary)
        }
      }
      .width('100%')
      .padding({
        left: GroupAnnouncementView.HORIZONTAL_PADDING,
        right: GroupAnnouncementView.HORIZONTAL_PADDING,
        top: GroupAnnouncementView.VERTICAL_PADDING,
        bottom: 8
      })


      if (this.isEditing) {

        TextArea({ text: this.announcement, placeholder: $r('app.string.chatsetting_input_announcement_placeholder') })
          .fontSize(16)
          .fontFamily('PingFang SC')
          .fontWeight(400)
          .fontColor(this.themeState.colors.textColorPrimary)
          .backgroundColor('transparent')
          .border({ width: 0 })
          .padding({
            left: GroupAnnouncementView.HORIZONTAL_PADDING,
            right: GroupAnnouncementView.HORIZONTAL_PADDING,
            top: 8,
            bottom: GroupAnnouncementView.VERTICAL_PADDING
          })
          .width('100%')
          .height(GroupAnnouncementView.MIN_HEIGHT)
          .onChange((value: string) => {
            this.announcement = value;
          })
          .maxLength(GroupAnnouncementView.MAX_LENGTH + 50)
          .backgroundColor(this.themeState.colors.bgColorInput)
      } else {

        if (this.announcement && this.announcement.length > 0) {
          Text(this.announcement)
            .fontSize(16)
            .fontFamily('PingFang SC')
            .fontWeight(400)
            .fontColor(this.themeState.colors.textColorPrimary)
            .lineHeight(24)
            .width('100%')
            .padding({
              left: GroupAnnouncementView.HORIZONTAL_PADDING,
              right: GroupAnnouncementView.HORIZONTAL_PADDING,
              top: 8,
              bottom: GroupAnnouncementView.VERTICAL_PADDING
            })
        } else {

          Column({ space: 12 }) {

            Text('📢')
              .fontSize(48)
              .fontColor(this.themeState.colors.textColorTertiary)

            Text($r('app.string.chatsetting_group_announcement_empty'))
              .fontSize(16)
              .fontFamily('PingFang SC')
              .fontWeight(400)
              .fontColor(this.themeState.colors.textColorSecondary)

            if (this.hasEditPermission()) {
              Text($r('app.string.chatsetting_group_announcement_add_tip'))
                .fontSize(14)
                .fontFamily('PingFang SC')
                .fontWeight(400)
                .fontColor(this.themeState.colors.textColorTertiary)
            }
          }
          .width('100%')
          .padding({
            top: 40,
            bottom: 40
          })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor(this.themeState.colors.bgColorOperate)
        }
      }
    }
    .width('100%')
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .borderRadius(GroupAnnouncementView.BORDER_RADIUS)
  }

  @Builder
  HelpTextBuilder() {
    Column({ space: 8 }) {
      Text($r('app.string.chatsetting_edit_help'))
        .fontSize(14)
        .fontWeight(500)
        .fontFamily('PingFang SC')
        .fontColor(this.themeState.colors.textColorSecondary)
        .alignSelf(ItemAlign.Start)

      Text($r('app.string.chatsetting_announcement_notify_all'))
        .fontSize(13)
        .fontFamily('PingFang SC')
        .fontWeight(400)
        .fontColor(this.themeState.colors.textColorSecondary)
        .alignSelf(ItemAlign.Start)

      Text($r('app.string.chatsetting_announcement_max_length'))
        .fontSize(13)
        .fontFamily('PingFang SC')
        .fontWeight(400)
        .fontColor(this.themeState.colors.textColorSecondary)
        .alignSelf(ItemAlign.Start)

      Text($r('app.string.chatsetting_announcement_edit_permission'))
        .fontSize(13)
        .fontFamily('PingFang SC')
        .fontWeight(400)
        .fontColor(this.themeState.colors.textColorSecondary)
        .alignSelf(ItemAlign.Start)
    }
    .width('100%')
    .padding({
      left: GroupAnnouncementView.HORIZONTAL_PADDING,
      right: GroupAnnouncementView.HORIZONTAL_PADDING,
      top: GroupAnnouncementView.VERTICAL_PADDING,
      bottom: GroupAnnouncementView.VERTICAL_PADDING
    })
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .borderRadius(GroupAnnouncementView.BORDER_RADIUS)
  }

  onBackPress(): boolean {
    this.handleBackClick();
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
      console.warn('[GroupAnnouncementPage] 没有提供关闭方式');
    }
  }

  private async initAnnouncementContent(): Promise<void> {
    if (!this.groupStore) {
      return;
    }

    try {

      await this.groupStore.fetchGroupInfo();


      this.announcement = this.groupState?.notice || '';
      this.originalAnnouncement = this.announcement;
    } catch (error) {
      console.error('[GroupAnnouncementPage] Failed to load group info:', error);
      this.announcement = '';
      this.originalAnnouncement = '';
    } finally {
      this.isInitializing = false;
    }
  }

  private hasEditPermission(): boolean {
    if (!this.groupStore) {
      return false;
    }

    const userRole = this.groupState?.currentUserRole;
    if (!userRole) {
      return false;
    }


    const groupType = this.convertStringToGroupType(this.groupState?.groupType);

    return GroupPermissionManager.hasPermission(
      groupType,
      userRole,
      GroupPermission.SET_GROUP_NOTICE
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

  private canSave(): boolean {
    return this.announcement.length <= GroupAnnouncementView.MAX_LENGTH &&
      this.announcement !== this.originalAnnouncement;
  }

  private enterEditMode(): void {
    this.isEditing = true;
  }

  private handleBackClick(): void {
    if (this.isEditing && this.announcement !== this.originalAnnouncement) {

      AlertDialog.show({
        title: $r('app.string.chatsetting_leave_confirm'),
        message: $r('app.string.chatsetting_unsaved_changes_leave'),
        primaryButton: {
          value: $r('app.string.chatsetting_save'),
          action: () => {
            this.saveAnnouncement();
          }
        },
        secondaryButton: {
          value: $r('app.string.chatsetting_dont_save'),
          action: () => {
            this.closeDialog();
          }
        }
      });
    } else {
      this.closeDialog();
    }
  }

  private saveAnnouncement(): void {
    if (!this.groupStore || this.isLoading) {
      return;
    }

    if (this.announcement.length > GroupAnnouncementView.MAX_LENGTH) {
      Toast.shortToast(`公告内容不能超过${GroupAnnouncementView.MAX_LENGTH}个字符`);
      return;
    }

    this.isLoading = true;

    this.groupStore.updateGroupProfile(undefined, this.announcement)
      .then(() => {
        Toast.shortToast($r('app.string.chatsetting_group_announcement_save_success'));
        this.originalAnnouncement = this.announcement;
        this.isEditing = false;
        this.isLoading = false;


        this.groupStore?.fetchGroupInfo();


        if (this.onSave) {
          this.onSave(this.announcement);
        }
      })
      .catch((error: Error) => {
        console.error('[GroupAnnouncementPage] Failed to update group announcement:', error);
        Toast.shortToast($r('app.string.chatsetting_group_announcement_save_fail'));
        this.isLoading = false;
      });
  }
}

function createGroupChatSettingStore(groupID: string): GroupSettingStore {
  throw new Error('Function not implemented.');
}
