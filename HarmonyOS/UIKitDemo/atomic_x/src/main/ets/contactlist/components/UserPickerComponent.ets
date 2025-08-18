import { Avatar, AvatarSize, AvatarContentType, TextUtils, ThemeState, Toast } from '../../basecomponent/Index';
import { Member } from 'chatengine';

export interface UserInfo {
  id: string;
  userID: string;
  avatarURL?: string;
  displayName: string;
  subtitle?: string;
  isDisabled: boolean;
}

interface UserSection {
  letter: string;
  users: UserInfo[];
}

export interface UserPickerComponentParams {
  title?: string;
  userList: UserInfo[];
  preSelectedUsers?: string[];
  maxSelectCount?: number;
  confirmButtonText?: string;
  action?: string;
  showNavigationBar?: boolean;
  onComplete?: (selectedUsers: UserInfo[]) => void;
}

@Component
export struct UserPickerComponent {
  private static readonly AVATAR_SIZE: number = 40;
  private static readonly ITEM_HEIGHT: number = 68;
  private static readonly SEARCH_BAR_HEIGHT: number = 36;
  private static readonly SECTION_HEADER_HEIGHT: number = 32;
  private static readonly INDEX_BAR_WIDTH: number = 20;
  private static readonly TAG_HEIGHT: number = 28;
  private static readonly TAG_AVATAR_SIZE: number = 20;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @Prop title: string | Resource = 'Add Participants';
  @Prop userList: UserInfo[] = [];
  @Prop preSelectedUsers: string[] = [];
  @Prop maxSelectCount: number = -1;
  @Prop confirmButtonText: string | Resource = 'Next';
  @Prop action: string = '';
  @Prop showNavigationBar: boolean = true;
  onCancel?: () => void;
  onComplete?: (selectedUsers: UserInfo[]) => void;
  onSelectionChange?: (selectedUsers: UserInfo[]) => void;
  @State private preSelectedUsersSet: Set<string> = new Set();
  @State private selectedUsers: Set<string> = new Set();
  @State private selectedUsersOrder: string[] = [];
  @State private searchKeyword: string = '';
  @State private showSearchResults: boolean = false;
  @State private searchResults: UserInfo[] = [];
  @State private currentSelectedLetter: string = '';
  private listScroller: Scroller = new Scroller();

  public static convertMemberToUserInfo(member: Member): UserInfo {
    return {
      id: member.userID,
      userID: member.userID,
      avatarURL: member.faceURL,
      displayName: member.nameCard || member.nickName || member.userID,
      subtitle: UserPickerComponent.getRoleDisplayName(member.role),
      isDisabled: false
    };
  }

  private static getRoleDisplayName(role: number): string {
    switch (role) {
      case 400: // GroupMemberRole.OWNER
        return '群主';
      case 300: // GroupMemberRole.ADMIN
        return '管理员';
      case 200: // GroupMemberRole.MEMBER
      default:
        return '普通成员';
    }
  }

  aboutToAppear(): void {
    this.preSelectedUsersSet = new Set(this.preSelectedUsers || []);
  }

  build() {
    Column() {

      if (this.showNavigationBar) {
        this.TitleBarBuilder()

        // Divider
        Divider()
          .height(1)
          .color(this.themeState.colors.strokeColorSecondary)
      }


      if (this.selectedUsersOrder.length > 0 && this.maxSelectCount > 1) {
        this.SelectedTagsBuilder()

        // Divider
        Divider()
          .height(0.5)
          .color(this.themeState.colors.strokeColorSecondary)
      }


      Stack() {

        this.UserListBuilder()


        this.AlphabetIndexBuilder()
      }
      .layoutWeight(1)

    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  TitleBarBuilder() {
    Column() {

      Row() {

        Text($r('app.string.cancel_button'))
          .fontSize(16)
          .fontWeight(400)
          .fontFamily('PingFang SC')
          .fontColor(this.themeState.colors.textColorLink)
          .onClick(() => {
            if (this.onCancel) {
              this.onCancel();
            }
          })

        Blank()


        Text(this.title)
          .fontSize(20)
          .fontWeight(600)
          .fontFamily('PingFang HK')
          .fontColor(this.themeState.colors.textColorPrimary)

        Blank()


        if (this.maxSelectCount !== 1) {
          Text(this.confirmButtonText)
            .fontSize(16)
            .fontWeight(400)
            .fontFamily('PingFang SC')
            .fontColor(this.selectedUsersOrder.length > 0 ? this.themeState.colors.textColorLink :
            this.themeState.colors.textColorSecondary)
            .enabled(this.selectedUsersOrder.length > 0)
            .onClick(() => {
              if (this.selectedUsersOrder.length > 0) {
                this.handleComplete();
              }
            })
        } else {

          Text('')
            .width(60)
        }
      }
      .width('100%')
      .height(44)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)


      Row() {
        Text(`${this.selectedUsersOrder.length}/${this.maxSelectCount > 0 ? this.maxSelectCount : 512}`)
          .fontSize(12)
          .fontWeight(400)
          .fontFamily('PingFang HK')
          .fontColor(this.themeState.colors.textColorTertiary)
      }
      .width('100%')
      .height(30)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(74)
    .padding({ left: 16, right: 16 })
    .margin({ top: 22 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  SelectedTagsBuilder() {

    Scroll() {
      Row({ space: 8 }) {
        ForEach(this.getSelectedUsers(), (user: UserInfo) => {
          this.UserTagBuilder(user)
        })
      }
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(40)
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .align(Alignment.Start)
  }

  @Builder
  UserTagBuilder(user: UserInfo) {
    Stack() {
      // Avatar
      if (user.avatarURL && user.avatarURL.length > 0) {
        Image(user.avatarURL)
          .width(32)
          .height(32)
          .borderRadius(16)
          .objectFit(ImageFit.Cover)
      } else {
        Circle()
          .width(32)
          .height(32)
          .fill(this.themeState.colors.textColorLink)

        Text(TextUtils.getAvatarLetter(user.displayName))
          .fontSize(14)
          .fontWeight(500)
          .fontColor(this.themeState.colors.bgColorOperate)
      }


      Row() {
        Image($rawfile('contactlist/contact_del.svg'))
          .width(12)
          .height(12)
          .fillColor(this.themeState.colors.textColorButton)
      }
      .width(12)
      .height(12)
      .backgroundColor(this.themeState.colors.bgColorTopBar)
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      .position({ x: '100%', y: 0 })
      .translate({ x: -8, y: -4 })
      .onClick(() => {
        this.removeSelectedUser(user.userID);
      })
    }
    .width(32)
    .height(32)
    .margin({ right: 8 })
  }

  @Builder
  AlphabetIndexBuilder() {
    if (!this.showSearchResults && this.userList.length > 0) {
      Column() {

        Row() {
          Image($rawfile('contactlist/search_icon.svg'))
            .width(10)
            .height(10)
            .fillColor(this.themeState.colors.textColorLink)
        }
        .width(20)
        .height(16)
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 2 })


        ForEach(this.getIndexLetters(), (letter: string) => {
          if (letter === this.currentSelectedLetter) {
            Row() {
              Text(letter)
                .fontSize(10)
                .fontColor(this.themeState.colors.bgColorOperate)
                .fontFamily('PingFang SC')
            }
            .width(20)
            .height(16)
            .backgroundColor(this.themeState.colors.textColorLink)
            .borderRadius(10)
            .justifyContent(FlexAlign.Center)
            .margin({ bottom: 2 })
            .onClick(() => this.scrollToSection(letter))
          } else {
            Text(letter)
              .fontSize(10)
              .fontColor(this.themeState.colors.textColorLink)
              .fontFamily('PingFang SC')
              .margin({ bottom: 2 })
              .onClick(() => this.scrollToSection(letter))
          }
        })
      }
      .width(UserPickerComponent.INDEX_BAR_WIDTH)
      .justifyContent(FlexAlign.Center)
      .position({ x: '100%', y: '50%' })
      .translate({ x: -24, y: '-50%' })
    }
  }

  @Builder
  UserListBuilder() {
    if (this.showSearchResults) {
      this.SearchResultsBuilder()
    } else {
      this.GroupedUserListBuilder()
    }
  }

  @Builder
  GroupedUserListBuilder() {
    List({ scroller: this.listScroller }) {

      if (this.getFrequentlyContactedUsers().length > 0) {
        ListItemGroup() {

          ListItem() {
            Row() {
              Text($r('app.string.frequently_contacted'))
                .fontSize(14)
                .fontWeight(600)
                .fontColor('rgba(0, 0, 0, 0.9)')
                .fontFamily('PingFang SC')
            }
            .width('100%')
            .height(UserPickerComponent.SECTION_HEADER_HEIGHT)
            .padding({ left: 16 })
          }


          ForEach(this.getFrequentlyContactedUsers(), (user: UserInfo) => {
            ListItem() {
              this.UserRowBuilder(user)
            }
          })
        }
      }


      ForEach(this.getValidUserSections(), (section: UserSection) => {
        this.SectionBuilder(section.letter, section.users)
      }, (section: UserSection) => section.letter)

    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .contentEndOffset(80)
  }

  @Builder
  SectionBuilder(letter: string, users: UserInfo[]) {
    ListItemGroup() {

      ListItem() {
        Row() {
          Text(letter)
            .fontSize(14)
            .fontWeight(600)
            .fontColor(this.themeState.colors.textColorPrimary)
            .fontFamily('PingFang SC')
        }
        .width('100%')
        .height(UserPickerComponent.SECTION_HEADER_HEIGHT)
        .padding({ left: 16 })
      }


      ForEach(users, (user: UserInfo) => {
        ListItem() {
          this.UserRowBuilder(user)
        }
      }, (user: UserInfo) => user.userID)
    }
  }

  @Builder
  SearchResultsBuilder() {
    List({ scroller: this.listScroller }) {
      if (this.searchResults.length > 0) {
        ForEach(this.searchResults, (user: UserInfo) => {
          ListItem() {
            this.UserRowBuilder(user)
          }
        }, (user: UserInfo) => user.userID)
      } else {
        ListItem() {
          Column() {
            Text($r('app.string.no_results_found'))
              .fontSize(16)
              .fontColor(this.themeState.colors.textColorSecondary)// Figma: #999999
              .margin({ top: 50 })
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
        }
      }
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  UserRowBuilder(user: UserInfo) {
    Row({ space: 13 }) {
      Avatar({
        content: {
          type: AvatarContentType.Image,
          url: user.avatarURL,
          name: user.displayName,
        },
        avatarSize: AvatarSize.M,
      })
      // User info
      Column({ space: 2 }) {
        Text(user.displayName)
          .fontSize(14)
          .fontWeight(400)
          .fontFamily('PingFang SC')
          .fontColor(user.isDisabled || this.preSelectedUsersSet.has(user.userID) ?
          this.themeState.colors.textColorTertiary :
          this.themeState.colors.textColorPrimary)
          .alignSelf(ItemAlign.Start)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        // if (user.subtitle && user.subtitle.length > 0) {
        //   Text(user.subtitle)
        //     .fontSize(12)
        //     .fontWeight(400)
        //     .fontFamily('PingFang SC')
        //     .fontColor('rgba(0, 0, 0, 0.4)')
        //     .alignSelf(ItemAlign.Start)
        //     .maxLines(1)
        //     .textOverflow({ overflow: TextOverflow.Ellipsis })
        // }

        if (this.preSelectedUsersSet.has(user.userID)) {
          Text($r('app.string.selected_count_prefix'))
            .fontSize(12)
            .fontWeight(400)
            .fontFamily('PingFang SC')
            .fontColor(this.themeState.colors.textColorPrimary)
            .alignSelf(ItemAlign.Start)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      if (this.maxSelectCount !== 1) {

        Checkbox({
          name: `checkbox_${user.userID}`,
          group: 'userSelection'
        })
          .select(this.isUserSelected(user.userID))
          .selectedColor(this.themeState.colors.textColorLink)
          .unselectedColor(this.themeState.colors.strokeColorSecondary)
          .width(20)
          .height(20)
          .enabled(!(user.isDisabled || this.preSelectedUsersSet.has(user.userID)))
          .onChange((isChecked: boolean) => {
            if (!(user.isDisabled || this.preSelectedUsersSet.has(user.userID))) {
              this.handleUserToggle(user, isChecked);
            }
          })
      }

    }
    .width('100%')
    .height(UserPickerComponent.ITEM_HEIGHT)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      if (!(user.isDisabled || this.preSelectedUsersSet.has(user.userID))) {
        const isCurrentlySelected = this.isUserSelected(user.userID);
        this.handleUserToggle(user, !isCurrentlySelected);
      }
    })
  }

  private getAlphabetLetters(): string[] {
    return ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
  }

  private getIndexLetters(): string[] {
    const existingLetters = new Set<string>();
    const groupedUsers = this.getGroupedUsers();


    Object.keys(groupedUsers).forEach(letter => {
      if (groupedUsers[letter].length > 0) {
        existingLetters.add(letter);
      }
    });


    const sortedLetters = Array.from(existingLetters).sort((a, b) => {

      if (a === '#') {
        return 1;
      }
      if (b === '#') {
        return -1;
      }
      return a.localeCompare(b);
    });

    return sortedLetters;
  }

  private getGroupedUsers(): Record<string, UserInfo[]> {
    const groups: Record<string, UserInfo[]> = {};


    this.getAlphabetLetters().forEach(letter => {
      groups[letter] = [];
    });
    groups['#'] = [];


    this.userList.forEach((user: UserInfo) => {

      const firstChar = TextUtils.getAvatarLetter(user.displayName)
      if (/^[A-Z]$/.test(firstChar)) {
        groups[firstChar].push(user);
      } else {
        groups['#'].push(user);
      }
    });

    return groups;
  }

  private getValidUserSections(): UserSection[] {
    const sections: UserSection[] = [];
    const groupedUsers = this.getGroupedUsers();
    const letters = this.getIndexLetters();

    letters.forEach(letter => {
      const users = groupedUsers[letter] || [];
      if (users.length > 0) {
        sections.push({ letter, users });
      }
    });

    return sections;
  }

  private getFrequentlyContactedUsers(): UserInfo[] {


    return [];
  }

  private performSearch() {
    if (this.searchKeyword.trim().length === 0) {
      this.clearSearch();
      return;
    }

    const keyword = this.searchKeyword.toLowerCase();
    this.searchResults = this.userList.filter(user =>
    user.displayName.toLowerCase().includes(keyword) ||
      (user.subtitle && user.subtitle.toLowerCase().includes(keyword))
    );
    this.showSearchResults = true;
  }

  private clearSearch() {
    this.searchResults = [];
    this.showSearchResults = false;
  }

  private scrollToSection(letter: string) {
    if (this.showSearchResults) {
      return;
    }

    const targetIndex = this.calculateSectionIndex(letter);
    if (targetIndex >= 0) {
      this.currentSelectedLetter = letter;
      this.listScroller.scrollToIndex(targetIndex, true, ScrollAlign.START);

      setTimeout(() => {
        this.currentSelectedLetter = '';
      }, 1500);
    }
  }

  private calculateSectionIndex(targetLetter: string): number {
    let index = 0;


    if (this.getFrequentlyContactedUsers().length > 0) {
      if (targetLetter === 'Frequently Contacted') {
        return index;
      }
      index += 1;
    }


    const validSections = this.getValidUserSections();
    for (let i = 0; i < validSections.length; i++) {
      const section = validSections[i];
      if (section.letter === targetLetter) {
        return index;
      }
      index += 1;
    }

    return -1;
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

  private handleUserToggle(user: UserInfo, isSelected: boolean): void {
    if (isSelected) {
      if (this.selectedUsers.has(user.userID)) {
        return;
      }

      if (this.maxSelectCount > 0 && this.selectedUsersOrder.length >= this.maxSelectCount) {
        Toast.shortToast(`最多只能选择 ${this.maxSelectCount} 个用户`);
        return;
      }

      this.selectedUsers.add(user.userID);
      this.selectedUsersOrder.push(user.userID);

      if (this.maxSelectCount === 1) {
        this.handleComplete();
        return;
      }
    } else {
      this.selectedUsers.delete(user.userID);
      const index = this.selectedUsersOrder.indexOf(user.userID);
      if (index > -1) {
        this.selectedUsersOrder.splice(index, 1);
      }
    }
  }

  private removeSelectedUser(userID: string): void {
    this.selectedUsers.delete(userID);
    const index = this.selectedUsersOrder.indexOf(userID);
    if (index > -1) {
      this.selectedUsersOrder.splice(index, 1);
    }
  }

  private handleComplete(): void {
    if (this.selectedUsersOrder.length === 0) {
      return;
    }

    const selectedUserList: UserInfo[] = [];
    for (const userID of this.selectedUsersOrder) {
      const user = this.userList.find(u => u.userID === userID);
      if (user) {
        selectedUserList.push(user);
      }
    }

    console.log('[UserPickerComponent] handleComplete - Returning users:', selectedUserList.length);

    if (this.onComplete) {
      this.onComplete(selectedUserList);
    }
  }
} 
