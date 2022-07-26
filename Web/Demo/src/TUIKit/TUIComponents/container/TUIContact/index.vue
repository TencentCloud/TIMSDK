<template>
  <transition @before-leave="init">
    <div class="TUI-contact" :class="[env.isH5 ? 'TUI-contact-H5' : '']" >
      <aside class="TUI-contact-left">
        <header class="TUI-contact-left-header">
          <div class="search">
            <div class="search-box" @click="toggleSearch" v-if="!isSearch">
              <i class="plus"></i>
              <h1>{{$t('TUIContact.添加群聊')}}</h1>
            </div>
            <div class="search-box" v-else>
              <div class="input-box">
                <input type="text" v-model="searchID" :placeholder="$t('TUIContact.输入群ID，按回车搜索')" @keyup.enter="handleSearchGroup"  enterkeyhint="search">
                <i class="icon icon-cancel" v-if="!!searchID" @click="searchID=''"></i>
              </div>
              <span class="search-cancel" @click="toggleSearch">{{$t('取消')}}</span>
            </div>
          </div>
        </header>
        <ul class="TUI-contact-column" v-if="!isSearch">
          <li class="TUI-contact-column-item">
            <header  @click="select('system')">
              <i class="icon icon-right" :class="[ columnName === 'system' && 'icon-down']"></i>
              <main>
                <label>{{$t('TUIContact.群聊通知')}}</label>
                <span class="num" v-if="systemConversation && systemConversation.unreadCount>0">{{systemConversation.unreadCount}}</span>
              </main>
            </header>
            <ul class="TUI-contact-list" v-if="columnName === 'system'">
              <li  class="TUI-contact-list-item selected not-aside">
                <label>{{$t('TUIContact.系统通知')}}</label>
                <span class="num" v-if="systemConversation && systemConversation.unreadCount>0">{{systemConversation.unreadCount}}</span>
              </li>
            </ul>
          </li>
          <li class="TUI-contact-column-item">
            <header @click="select('group')">
              <i class="icon icon-right" :class="[ columnName === 'group' && 'icon-down']"></i>
              <main>
                <label>{{$t('TUIContact.我的群聊')}}</label>
              </main>
            </header>
            <ul class="TUI-contact-list" v-show="columnName === 'group'">
              <li  class="TUI-contact-list-item" :class="[currentGroup?.groupID === item?.groupID && 'selected']" v-for="(item, index) in groupList" :key="index"  @click="handleListItem(item)">
                <aside class="left">
                  <img
                    class="avatar"
                    :src="item?.avatar || 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/constomer.svg'"
                    onerror="this.src='https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/constomer.svg'">
                </aside>
                <main class="content">
                  <ul>
                    <li class="name">{{item?.name}}</li>
                    <li class="ID">
                      <label>ID：</label>
                      <span>{{item?.groupID}}</span>
                    </li>
                  </ul>
                  <span class="type">{{item?.type}}</span>
                </main>
              </li>
            </ul>
          </li>
          <li class="TUI-contact-column-item">
            <header @click="select('friend')">
              <i class="icon icon-right" :class="[ columnName === 'friend' && 'icon-down']"></i>
              <main>
                <label>{{$t('TUIContact.我的好友')}}</label>
              </main>
            </header>
            <ul class="TUI-contact-list" v-show="columnName === 'friend'">
              <li  class="TUI-contact-list-item" :class="[currentFriend?.userID === item?.userID && 'selected']" v-for="(item, index) in friendList" :key="index"  @click="handleListItem(item)">
                <aside class="left">
                  <img
                    class="avatar"
                    :src="item?.profile?.avatar || 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
                    onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'">
                </aside>
                <main class="content">
                  <ul>
                    <li class="name">{{item?.profile?.nick || item?.userID}}</li>
                  </ul>
                </main>
              </li>
            </ul>
          </li>
        </ul>
        <ul class="TUI-contact-list" v-else>
          <li v-if="!!searchGroup?.groupID" class="TUI-contact-list-item" :class="[currentGroup?.groupID === searchGroup?.groupID && 'selected']"  @click="handleListItem(searchGroup)">
            <aside class="left">
              <img
                class="avatar"
                :src="searchGroup?.avatar || 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/constomer.svg'"
                onerror="this.src='https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/constomer.svg'">
            </aside>
            <main class="content">
              <ul>
                <li class="name">{{searchGroup?.name}}</li>
                <li class="ID">
                  <label>ID：</label>
                  <span>{{searchGroup?.groupID}}</span>
                </li>
              </ul>
              <span class="type">{{searchGroup?.type}}</span>
            </main>
          </li>
        </ul>
      </aside>
      <main class="TUI-contact-main" v-show="!!currentGroup?.groupID || columnName === 'system' || !env.isH5">
        <header class="TUI-contact-main-h5-title" v-if="env.isH5">
          <i class="icon icon-back" @click="back"></i>
          <h1>{{currentGroup?.name || $t('TUIContact.系统通知')}}</h1>
        </header>
        <div v-if="!!currentGroup?.groupID" class="TUI-contact-main-info">
          <header class="TUI-contact-main-info-header">
            <ul class="list">
              <h1>{{currentGroup?.name}}</h1>
              <li>
                <label>{{$t('TUIContact.群ID')}}：</label>
                <span>{{currentGroup?.groupID}}</span>
              </li>
              <li>
                <label>{{$t('TUIContact.群类型')}}：</label>
                <span>{{currentGroup?.type}}</span>
              </li>
            </ul>
            <img
              class="avatar"
              :src="currentGroup?.avatar || 'https://web.sdk.qcloud.com/component/TUIKit/assets/group_avatar.png' "
              onerror="this.src='https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/constomer.svg'">
          </header>
          <main class="TUI-contact-main-info-main" v-if="isNeedPermission">
            <label>{{$t('TUIContact.请填写验证信息')}}</label>
            <textarea v-model="currentGroup.applyMessage" :disabled="currentGroup.apply"></textarea>
          </main>
          <footer class="TUI-contact-main-info-footer">
            <p v-if="currentGroup.apply && currentGroup.type ==='AVChatRoom'">{{$t('TUIContact.已加入')}}</p>
            <p v-else-if="currentGroup.apply">{{$t('TUIContact.已申请')}}</p>
            <button class="btn btn-default" v-else-if="isNeedPermission" @click="join(currentGroup)">{{$t('TUIContact.申请加入')}}</button>
            <button class="btn btn-default" v-else-if="!currentGroup.selfInfo.userID" @click="join(currentGroup)">{{$t('TUIContact.加入群聊')}}</button>
            <button
              class="btn btn-cancel"
              v-else-if="currentGroup.selfInfo.userID && currentGroup.selfInfo.role ==='Owner' && currentGroup.type !=='Private'"
              @click="dismiss(currentGroup)">{{$t('TUIContact.解散群聊')}}</button>
            <button class="btn btn-cancel" v-else @click="quit(currentGroup)">{{$t('TUIContact.退出群聊')}}</button>
            <button v-if="currentGroup.selfInfo.userID" class="btn btn-default" @click="enter(currentGroup.groupID, 'GROUP')">{{$t('TUIContact.进入群聊')}}</button>
          </footer>
        </div>
        <div v-else-if="currentFriend?.userID && columnName === 'friend'" class="TUI-contact-main-info">
          <header class="TUI-contact-main-info-header">
            <ul class="list">
              <h1>{{currentFriend?.profile?.nick || currentFriend?.userID}}</h1>
              <li>
                <label>ID：</label>
                <span>{{currentFriend?.profile?.userID}}</span>
              </li>
              <li>
                <label>{{$t('TUIContact.个性签名')}}：</label>
                <span>{{currentFriend?.profile?.selfSignature}}</span>
              </li>
            </ul>
            <img
              class="avatar"
              :src="currentFriend?.profile?.avatar || 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
              onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'">
          </header>

          <footer class="TUI-contact-main-info-footer">
            <button class="btn btn-default" @click="enter(currentFriend.userID, 'C2C')">{{$t('TUIContact.发送消息')}}</button>
          </footer>
        </div>
        <div class="TUI-contact-system" v-else-if="columnName === 'system'">
          <header class="TUI-contact-system-header" v-if="!env.isH5">
            <h1>{{$t('TUIContact.系统通知')}}</h1>
          </header>
          <MessageSystem :isH5="env.isH5" :data="systemMessageList" :types="types" @application="handleGroupApplication" />
        </div>
        <slot v-else />
      </main>
    </div>
  </transition>
</template>
<script lang="ts">
import { computed, defineComponent, reactive, toRefs } from 'vue';
import MessageSystem from './components/message-system.vue';
import { handleErrorPrompts } from '../utils';

const TUIContact = defineComponent({
  name: 'TUIContact',
  components: {
    MessageSystem,
  },

  setup(props:any, ctx:any) {
    const TUIServer:any = TUIContact.TUIServer;
    const { t } = TUIServer.TUICore.config.i18n.useI18n();
    const data = reactive({
      groupList: [],
      searchGroup: {},
      searchID: '',
      currentGroup: null,
      systemConversation: {
        unreadCount: 0,
      },
      systemMessageList: [],
      columnName: '',
      types: TUIServer.TUICore.TIM.TYPES,
      isSearch: false,
      env: TUIServer.TUICore.TUIEnv,
      friendList: [],
      currentFriend: {},
    });

    TUIServer.bind(data);

    const isNeedPermission = computed(() => {
      const isHaveSeif = (data.currentGroup as any).selfInfo.userID;
      const isPermission = (data.currentGroup as any).joinOption === TUIServer.TUICore.TIM.TYPES.JOIN_OPTIONS_NEED_PERMISSION;
      return !isHaveSeif && isPermission;
    });

    const handleListItem = async (item:any) => {
      switch (data.columnName) {
        case 'group':
          data.currentGroup = item;
          break;
        case 'friend':
          data.currentFriend = item;
          break;
      }
      if (data.isSearch) {
        data.currentGroup = item;
      }
    };

    const handleSearchGroup = async (e:any) => {
      data.currentGroup = null;
      if (data.searchID.trim()) {
        try {
          await TUIServer.searchGroupByID(data.searchID.trim());
        } catch (error) {
          const message = t('TUIContact.该群组不存在');
          handleErrorPrompts(message, data.env);
        }
      }
    };

    const join = async (group:any) => {
      const options:any = {
        groupID: group.groupID,
        applyMessage: group.applyMessage || t('TUIContact.加群'),
        type: group?.type,
      };
      await TUIServer.joinGroup(options);
      (data.currentGroup as any).apply = true;
    };

    const quit = async (group:any) => {
      await TUIServer.quitGroup(group.groupID);
      data.currentGroup = null;
    };

    const enter = async (ID:any, type:string) => {
      const name = `${type}${ID}`;
      TUIServer.TUICore.TUIServer.TUIConversation.getConversationProfile(name).then((imResponse:any) => {
        // 通知 TUIConversation 添加当前会话
        // Notify TUIConversation to toggle the current conversation
        TUIServer.TUICore.TUIServer.TUIConversation.handleCurrentConversation(imResponse.data.conversation);
        back();
      });
    };

    const dismiss = (group:any) => {
      TUIServer.dismissGroup(group.groupID);
      data.currentGroup = null;
    };

    const select = async (name:string) => {
      if (data.columnName !== 'system' && name === 'system' && (data.systemConversation as any)?.conversationID) {
        await TUIServer.getSystemMessageList();
        await TUIServer.setMessageRead();
      }
      (data.currentGroup as any) = {};
      if (data.columnName !== 'group' && name === 'group' && !data.env.isH5) {
        (data.currentGroup as any) = data.groupList[0];
      } else {
        (data.currentGroup as any) = {};
      }
      data.searchID = '';
      data.columnName = data.columnName === name ? '' : name;
    };

    const toggleSearch = () => {
      data.isSearch = !data.isSearch;
      data.columnName = '';
      data.searchID = '';
      data.searchGroup = {};
      (data.currentGroup as any) = {};
    };

    const init = () => {
      data.isSearch = false;
      data.columnName = '';
      data.searchID = '';
      data.searchGroup = {};
      (data.currentGroup as any) = {};
    };

    const handleGroupApplication = (params:any)=> {
      TUIServer.handleGroupApplication(params);
    };
    const back = ()=> {
      (data.currentGroup as any) = {};
      data.columnName = '';
    };

    return {
      ...toRefs(data),
      handleListItem,
      handleSearchGroup,
      join,
      quit,
      dismiss,
      isNeedPermission,
      select,
      handleGroupApplication,
      toggleSearch,
      init,
      back,
      enter,
    };
  },
});
export default TUIContact;
</script>

<style lang="scss" scoped src="./style/index.scss"></style>
