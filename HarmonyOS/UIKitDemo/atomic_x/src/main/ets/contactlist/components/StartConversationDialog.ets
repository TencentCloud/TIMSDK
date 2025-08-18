import { ThemeState, TextUtils } from '../../basecomponent/Index';
import {
  ContactListStore,
  ContactInfo,
  ContactGetOption,
  ContactOnlineStatus,
  LoginStore,
  MessageInfo,
  MessageBody,
  MessageType,
  ContactListState,
  MessageInputStore
} from 'chatengine';
import { UserInfo, UserPickerComponent } from './UserPickerComponent';
import { GroupCreationComponent, GroupInfo, GroupType } from './GroupCreationComponent';
import { router } from '@kit.ArkUI';

export enum DialogType {
  START_CONVERSATION = 'startConversation',
  CREATE_GROUP = 'createGroup'
}

enum DialogPageState {
  USER_PICKER = 'userPicker',
  GROUP_CREATION = 'groupCreation'
}

@CustomDialog
export struct StartConversationDialog {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  controller: CustomDialogController;
  dialogType: DialogType = DialogType.START_CONVERSATION;
  // Callback function
  onCancel?: () => void;
  onSelectUser?: (contact: ContactInfo) => void;
  onCreateGroup?: (groupInfo: GroupInfo) => void;
  // State management
  @State isLoading: boolean = true;
  @State friendList: UserInfo[] = [];
  @State currentPage: DialogPageState = DialogPageState.USER_PICKER;
  @State selectedContactsForGroup: ContactInfo[] = [];
  private contactListStore: ContactListStore = ContactListStore.createInstance();
  @State private contactListState: ContactListState = this.contactListStore.state;

  aboutToAppear() {
    console.info('[StartConversationDialog] Dialog about to appear, type:', this.dialogType);
    this.contactListStore?.registerListener();
    this.loadFriendList();
  }

  aboutToDisappear() {
    console.info('[StartConversationDialog] Dialog about to disappear');
    // DestroycontactListStore
    if (this.contactListStore) {
      this.contactListStore?.unregisterListener();
    }
  }

  build() {
    Column() {

      Column()
        .height(88)
        .width('100%')
        .backgroundColor(this.themeState.colors.bgColorMask)
        .onClick(() => {
          this.handleCancel();
        })

      Column() {
        if (this.currentPage === DialogPageState.USER_PICKER) {
          this.UserPickerPageBuilder()
        } else if (this.currentPage === DialogPageState.GROUP_CREATION) {
          this.GroupCreationPageBuilder()
        }
      }
      .layoutWeight(1)
      .backgroundColor(this.themeState.colors.bgColorOperate) // Figma: #FFFFFF
      .borderRadius({ topLeft: 10, topRight: 10 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  UserPickerPageBuilder() {
    Column() {

      UserPickerComponent({
        title: this.getDialogTitle(),
        userList: this.friendList,
        preSelectedUsers: [],
        maxSelectCount: this.getMaxSelectCount(),
        confirmButtonText: this.getConfirmButtonText(),
        action: 'startConversation',
        showNavigationBar: true,
        onCancel: this.handleUserCancelComplete,
        onComplete: this.handleUserPickerComplete
      })
    }
  }

  @Builder
  GroupCreationPageBuilder() {
    GroupCreationComponent({
      selectedContacts: this.selectedContactsForGroup,
      onCancel: () => {
        this.currentPage = DialogPageState.USER_PICKER;
      },
      onCreate: (groupInfo: GroupInfo) => {
        this.handleGroupCreation(groupInfo);
      }
    })
  }

  private getDialogTitle(): string | Resource {
    return this.dialogType === DialogType.CREATE_GROUP ?
    $r('app.string.create_group_chat_title') :
    $r('app.string.select_contacts_title');
  }

  private getMaxSelectCount(): number {
    return this.dialogType === DialogType.CREATE_GROUP ? 500 : 1;
  }

  private getConfirmButtonText(): string | Resource {
    return this.dialogType === DialogType.CREATE_GROUP ?
    $r('app.string.next_step_button') :
    $r('app.string.start_conversation_button');
  }

  private async loadFriendList(): Promise<void> {
    try {
      console.log('[StartConversationDialog] Loading friend list...');


      await this.contactListStore.fetchFriends();


      const friendList: UserInfo[] = [];
      for (let i = 0; i < this.contactListState.contactDataSource.totalCount(); i++) {
        const contact = this.contactListState.contactDataSource.getData(i) as ContactInfo;
        if (contact) {
          const userInfo: UserInfo = {
            id: contact.identifier || '',
            userID: contact.identifier || '',
            avatarURL: contact.avatarURL || '',
            displayName: contact.title || contact.identifier || '',
            subtitle: contact.onlineStatus === ContactOnlineStatus.ONLINE ? '在线' : '离线',
            isDisabled: false
          };
          friendList.push(userInfo);
        }
      }

      this.friendList = friendList;
      console.log('[StartConversationDialog] Friend list loaded:', this.friendList.length);
      this.isLoading = false;
    } catch (error) {
      console.error('[StartConversationDialog] Failed to load friend list:', error);
      this.isLoading = false;
    }
  }

  private handleUserCancelComplete = () => {
    this.handleCancel()
  }

  private handleCancel() {
    console.info('[StartConversationDialog] Dialog cancelled');
    if (this.onCancel) {
      this.onCancel();
    }
    this.controller.close();
  }

  private handleUserPickerComplete = (selectedUsers: UserInfo[]) => {
    console.info('[StartConversationDialog] User picker completed with users:', selectedUsers.length);

    if (this.dialogType === DialogType.START_CONVERSATION) {

      if (selectedUsers.length > 0) {
        const selectedUser = selectedUsers[0];

        const contactInfo = this.findContactInfoByIdentifier(selectedUser.userID);
        if (contactInfo && this.onSelectUser) {
          this.onSelectUser(contactInfo);
        }
      }
    } else if (this.dialogType === DialogType.CREATE_GROUP) {

      const selectedContacts: ContactInfo[] = [];
      for (const user of selectedUsers) {
        const contactInfo = this.findContactInfoByIdentifier(user.userID);
        if (contactInfo) {
          selectedContacts.push(contactInfo);
        }
      }

      this.selectedContactsForGroup = selectedContacts;
      console.info('[StartConversationDialog] Selected contacts for group:', this.selectedContactsForGroup.length);


      this.currentPage = DialogPageState.GROUP_CREATION;
    }
  }

  private findContactInfoByIdentifier(identifier: string): ContactInfo | null {
    for (let i = 0; i < this.contactListState.contactDataSource.totalCount(); i++) {
      const contact = this.contactListState.contactDataSource.getData(i) as ContactInfo;
      if (contact && contact.identifier === identifier) {
        return contact;
      }
    }
    return null;
  }

  private async handleGroupCreation(groupInfo: GroupInfo) {
    console.info('[StartConversationDialog] Group creation started:', groupInfo.groupName);
    try {
      if (this.onCreateGroup) {
        this.onCreateGroup(groupInfo);
      }

      // Send group create message after successful group creation
      if (groupInfo.groupID) {
        await this.sendGroupCreateMessage(groupInfo.groupID, groupInfo.groupType);
      }

      // Close dialog
      this.controller.close();
    } catch (error) {
      console.error('[StartConversationDialog] Failed to create group:', error);
    }
  }

  private async sendGroupCreateMessage(groupID: string, groupType: GroupType): Promise<void> {
    try {
      const conversationID = `group_${groupID}`;
      const currentUser = LoginStore.createInstance().state.loginUserInfo;
      const customContent: Record<string, ESObject> = {};
      customContent["version"] = 1;
      customContent["businessID"] = "group_create";
      customContent["opUser"] = currentUser?.userID || "";
      customContent["content"] = $r('app.string.create_group_chat');
      customContent["cmd"] = groupType === GroupType.Community ? 1 : 0;

      const messageInputStore = MessageInputStore.createInstance(conversationID);

      const messageInfo = new MessageInfo();
      messageInfo.messageBody = new MessageBody();
      messageInfo.messageBody.customInfo = customContent;
      messageInfo.messageType = MessageType.Custom;
      await new Promise<void>((resolve, reject) => {
        messageInputStore.sendMessage(messageInfo).then(() => {
          console.info('[StartConversationDialog] Group create message sent successfully');
          resolve();
        }).catch((error: Error) => {
          console.error('[StartConversationDialog] Failed to send group create message:', error);
          resolve();
        });
      });

    } catch (error) {
      console.error('[StartConversationDialog] Exception in sendGroupCreateMessage:', error);
    }
  }
}