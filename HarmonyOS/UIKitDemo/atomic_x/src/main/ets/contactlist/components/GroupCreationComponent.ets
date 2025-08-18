import { Avatar, AvatarSize, AvatarContentType, TextUtils, ThemeState } from '../../basecomponent/Index';
import { LoginStore, ContactInfo, ContactListStore } from 'chatengine';
import { GroupType, GroupTypeSelector, GroupTypeSelection } from './GroupTypeSelector';

export { GroupType };

export interface GroupCreationParams {
  selectedContacts: ContactInfo[];
  onCancel?: () => void;
  onCreate?: (groupInfo: GroupInfo) => void;
}

export interface GroupInfo {
  groupName: string;
  groupID: string;
  groupType: GroupType;
  avatarUrl: string;
  selectedPortraitIndex: number;
  selectedContacts: ContactInfo[];
}

@Component
export struct GroupCreationComponent {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @Prop selectedContacts: ContactInfo[] = [];
  onCancel?: () => void;
  onCreate?: (groupInfo: GroupInfo) => void;
  @State groupName: string = '';
  @State groupID: string = '';
  @State groupType: GroupType = GroupType.WORK;
  @State groupTypeTitle: string | Resource = $r('app.string.group_type_work_title');
  @State groupTypeDescription: string | Resource = $r('app.string.group_type_work_description');
  @State selectedPortraitIndex: number = 0;
  @State showGroupTypeSelector: boolean = false;
  private contactListStore: ContactListStore = ContactListStore.createInstance();

  aboutToAppear() {

    this.contactListStore?.registerListener();

    if (this.selectedContacts.length > 0) {
      const names = this.selectedContacts.slice(0, 3).map(contact =>
      contact.title || contact.identifier
      );
      this.groupName = names.join(', ');
      if (this.selectedContacts.length > 3) {
        this.groupName += `...`;
      }
    }
  }

  aboutToDisappear() {
    // DestroycontactListStore
    if (this.contactListStore) {
      this.contactListStore.unregisterListener();
    }
  }

  build() {
    Stack() {
      if (this.showGroupTypeSelector) {

        GroupTypeSelector({
          selectedType: this.groupType,
          onCancel: () => {
            this.showGroupTypeSelector = false;
          },
          onSelect: (selection: GroupTypeSelection) => {
            this.groupType = selection.type;
            this.groupTypeTitle = selection.title;
            this.groupTypeDescription = selection.description;
            this.showGroupTypeSelector = false;
          }
        })
      } else {

        Column() {

          this.TitleBarBuilder()

          // Divider
          Divider()
            .color(this.themeState.colors.strokeColorSecondary)
            .strokeWidth(0.5)
            .width('100%')


          Scroll() {
            Column() {

              this.GroupNameInputBuilder()


              this.GroupIDInputBuilder()


              this.GroupTypeSelectorBuilder()


              this.GroupPortraitSelectorBuilder()


              this.ParticipantsDisplayBuilder()

            }
          }

          // .backgroundColor(this.themeState.currentTheme.bgColorOperate)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeState.colors.bgColorOperate)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TitleBarBuilder() {
    Row() {
      // Back button
      Text($r('app.string.back_button'))
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

      // Title
      Text($r('app.string.create_group_chat_title'))
        .fontSize(20)
        .fontWeight(600)
        .fontFamily('PingFang HK')
        .fontColor(this.themeState.colors.textColorPrimary)
        .letterSpacing(-0.41)

      Blank()


      Text($r('app.string.create_group_chat'))
        .fontSize(16)
        .fontWeight(400)
        .fontFamily('PingFang SC')
        .fontColor(this.themeState.colors.textColorLink)
        .enabled(this.groupName.trim().length > 0)
        .opacity(this.groupName.trim().length > 0 ? 1 : 0.4)
        .onClick(() => {
          this.handleCreateGroup();
        })
    }
    .width('100%')
    .height(74)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  GroupNameInputBuilder() {
    Column() {
      Row() {

        Column() {
          TextInput({ placeholder: 'Group Name', text: this.groupName })
            .fontSize(14)
            .fontFamily('PingFang SC')
            .fontColor(this.themeState.colors.textColorPrimary)
            .backgroundColor('transparent')
            .border({ width: 0 })
            .padding(0)
            .onChange((value: string) => {
              this.groupName = value;
            })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 16
      })
      .alignItems(VerticalAlign.Center)

      // Divider
      Divider()
        .color(this.themeState.colors.strokeColorSecondary)
        .strokeWidth(0.5)
        .width('100%')
    }
  }

  @Builder
  GroupIDInputBuilder() {
    Column() {
      Row() {

        Column() {
          TextInput({ placeholder: 'Group ID（Certificate）', text: this.groupID })
            .fontSize(14)
            .fontFamily('PingFang SC')
            .fontColor(this.themeState.colors.textColorPrimary)
            .backgroundColor('transparent')
            .border({ width: 0 })
            .padding(0)
            .onChange((value: string) => {
              this.groupID = value;
            })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 16
      })
      .alignItems(VerticalAlign.Center)

      // Divider
      Divider()
        .color(this.themeState.colors.strokeColorSecondary)
        .strokeWidth(0.5)
        .width('100%')
    }
  }

  @Builder
  ParticipantsDisplayBuilder() {
    Column() {

      Row() {
        Text(`PARTICIPANTS: ${this.selectedContacts.length + 1} OF 512`)
          .fontSize(14)
          .fontWeight(600)
          .fontFamily('PingFang SC')
          .fontColor(this.themeState.colors.textColorPrimary)
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 12,
        bottom: 8
      })


      Row({ space: 8 }) {

        ForEach(this.selectedContacts.slice(0, 5), (contact: ContactInfo) => {
          this.ParticipantAvatarBuilder(contact, false)
        })


        if (this.selectedContacts.length > 5) {
          Column({ space: 2 }) {
            Text(`+${this.selectedContacts.length - 5}`)
              .fontSize(12)
              .fontWeight(400)
              .fontFamily('PingFang SC')
              .fontColor(this.themeState.colors.textColorPrimary)

            Text($r('app.string.more'))
              .fontSize(10)
              .fontWeight(400)
              .fontFamily('PingFang SC')
              .fontColor(this.themeState.colors.textColorSecondary)
          }
          .width(34)
          .height(34)
          .backgroundColor(this.themeState.colors.bgColorOperate)
          .borderRadius(17)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
    }
  }

  @Builder
  ParticipantAvatarBuilder(contact: ContactInfo, showRemoveButton: boolean = true) {
    Stack() {
      Avatar({
        content: {
          type: AvatarContentType.Image,
          url: contact.avatarURL,
          name: contact.title || contact.identifier || '',
        },
        avatarSize: AvatarSize.S,
      })


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
        this.removeParticipant(contact);
      })
    }
    .width(34)
    .height(34)
  }

  @Builder
  GroupTypeSelectorBuilder() {
    Column() {

      Row() {
        Column() {
          Text($r('app.string.group_type_selector_title'))
            .fontSize(16)
            .fontWeight(400)
            .fontFamily('PingFang SC')
            .fontColor(this.themeState.colors.textColorSecondary)
            .alignSelf(ItemAlign.Start)
        }
        .layoutWeight(1)

        Row({ space: 16 }) {
          Text(this.groupTypeTitle)
            .fontSize(16)
            .fontWeight(400)
            .fontFamily('PingFang SC')
            .fontColor(this.themeState.colors.textColorPrimary)

          Image($r('sys.symbol.chevron_right'))
            .width(16)
            .height(16)
            .fillColor(this.themeState.colors.textColorSecondary)
        }
        .onClick(() => {
          this.showGroupTypeSelector = true;
        })
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 12,
        bottom: 12
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // Divider
      Divider()
        .color(this.themeState.colors.strokeColorSecondary)
        .strokeWidth(1)
        .width('100%')


      Text(this.groupTypeDescription)
        .fontSize(12)
        .fontWeight(400)
        .fontFamily('PingFang SC')
        .fontColor(this.themeState.colors.textColorSecondary)
        .width('100%')
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 16
        })
    }
  }

  @Builder
  GroupPortraitSelectorBuilder() {
    Column() {
      // Title
      Row() {
        Text($r('app.string.group_portrait'))
          .fontSize(14)
          .fontWeight(600)
          .fontFamily('PingFang SC')
          .fontColor(this.themeState.colors.textColorPrimary)
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 12,
        bottom: 8
      })


      Grid() {

        ForEach(this.portraitOptions, (avatarUrl: string, index: number) => {
          GridItem() {
            this.GroupAvatarItemBuilder(index)
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .margin({ top: 8 })
      .padding({
        left: 12,
        right: 12,
        top: 8,
        bottom: 16
      })
      .width('100%')
    }
  }

  @Builder
  GroupAvatarItemBuilder(index: number) {
    Stack() {

      Image(this.portraitOptions[index])
        .width(50)
        .height(50)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
        .backgroundColor(this.themeState.colors.bgColorOperate)
        .border({
          width: this.selectedPortraitIndex === index ? 2 : 0,
          color: this.themeState.colors.textColorLink,
          radius: 8
        })


      if (false && this.selectedPortraitIndex === index) {
        Stack() {
          Circle()
            .width(20)
            .height(20)
            .fill(this.themeState.colors.textColorLink)

          Text('✓')
            .fontSize(12)
            .fontColor(this.themeState.colors.textColorButton)
            .fontWeight(FontWeight.Bold)
        }
        .position({
          x: 55 - 10, // 55 - 10
          y: -5
        })
      }
    }
    .width(66)
    .height(66)
    .onClick(() => {
      this.selectedPortraitIndex = index;
      console.log('[GroupCreationComponent] Avatar selected, index:', this.selectedPortraitIndex);
    })
  }

  private portraitOptions: string[] = (() => {
    const max = 25;
    const limitemax = 10;
    const avatarUrlList: string[] =
      Array.from<undefined, string>({ length: limitemax }, (_: undefined, index: number): string =>
      `https://im.sdk.qcloud.com/download/tuikit-resource/group-avatar/group_avatar_${index + 1}.png`
      );
    return avatarUrlList;
  })();

  private removeParticipant(contact: ContactInfo) {
    const index = this.selectedContacts.findIndex(c => c.identifier === contact.identifier);
    if (index > -1) {
      this.selectedContacts.splice(index, 1);
    }
  }

  private async handleCreateGroup() {
    if (this.groupName.trim().length === 0) {
      return;
    }

    try {
      const avatarUrl = this.getGroupAvatarUrl() || "";


      const creatGroupID = await this.contactListStore.createGroup(
        this.groupType,
        this.groupName,
        this.groupID || undefined,
        avatarUrl,
        this.selectedContacts
      );


      if (this.onCreate) {
        const groupInfo: GroupInfo = {
          groupName: this.groupName,
          groupID: creatGroupID,
          groupType: this.groupType,
          avatarUrl: avatarUrl || undefined || "",
          selectedPortraitIndex: this.selectedPortraitIndex,
          selectedContacts: this.selectedContacts
        };
        this.onCreate(groupInfo);
      }
    } catch (error) {


    }
  }

  private getGroupAvatarUrl(): string | undefined {
    if (this.selectedPortraitIndex < 0) {
      return undefined;
    }

    return this.portraitOptions[this.selectedPortraitIndex];
  }
} 