<template>
  <div>
    <i class="icon icon-chat-setting" @click="toggleShow"></i>
    <div class="manage" :class="[isH5 ? 'manage-h5' : '']" v-if="show" ref="dialog">
      <header class="manage-header">
        <i class="icon icon-back" v-if="isH5 && !currentTab" @click="toggleShow"></i>
        <aside class="manage-header-left">
          <i class="icon icon-back" v-if="currentTab" @click="setTab('')"></i>
          <main>
            <h1>{{ $t(`TUIChat.manage.${TabName}`) }}</h1>
          </main>
        </aside>
        <span>
          <i v-if="!isH5" class="icon icon-close" @click="toggleShow"></i>
        </span>
      </header>
      <main class="main" v-if="!currentTab">
        <ManageName
          class="space-top"
          :isAuth="isAuth"
          :isH5="isH5"
          :data="conversation.groupProfile"
          @update="updateProfile"
        />
        <div class="userInfo space-top">
          <header class="userInfo-header" @click="setTab('member')">
            <label>{{ $t(`TUIChat.manage.群成员`) }}</label>
            <p>
              <span
                >{{ conversation.groupProfile.memberCount
                }}{{ $t(`TUIChat.manage.人`) }}</span
              >
              <i class="icon icon-right"></i>
            </p>
          </header>
          <ol>
            <dl
              v-for="(item, index) in userInfo?.list?.slice(0, showUserNum)"
              :key="index"
            >
              <dt>
                <img
                  class="avatar"
                  :src="
                    item?.avatar ||
                    'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'
                  "
                  onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
                />
              </dt>
              <dd>{{ item?.nick || item?.userID }}</dd>
            </dl>
            <dl v-if="isShowAddMember">
              <dt class="avatar" @click="toggleMask('add')">+</dt>
            </dl>
            <dl v-if="conversation.groupProfile.selfInfo.role === 'Owner'">
              <dt class="avatar" @click="toggleMask('remove')">-</dt>
            </dl>
          </ol>
        </div>
        <ul class="content space-top" @click="editLableName = ''">
          <li @click.stop="setTab('notification')">
            <aside>
              <label>{{ $t(`TUIChat.manage.群公告`) }}</label>
              <article>{{ conversation.groupProfile.notification }}</article>
            </aside>
            <i class="icon icon-right end"></i>
          </li>
          <li v-if="isAdmin && isSetMuteTime" @click.stop="setTab('admin')">
            <label>{{ $t(`TUIChat.manage.群管理`) }}</label>
            <i class="icon icon-right"></i>
          </li>
          <li>
            <label>{{ $t(`TUIChat.manage.群ID`) }}</label>
            <span>{{ conversation.groupProfile.groupID }}</span>
          </li>
          <li>
            <label>{{ $t(`TUIChat.manage.群头像`) }}</label>
            <img
              class="avatar"
              :src="
                conversation?.groupProfile?.avatar ||
                'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/constomer.svg'
              "
              onerror="this.src='https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/constomer.svg'"
            />
          </li>
          <li>
            <label>{{ $t(`TUIChat.manage.群类型`) }}</label>
            <span>{{
              $t(`TUIChat.manage.${typeName[conversation.groupProfile.type]}`)
            }}</span>
          </li>
          <li>
            <label>{{ $t(`TUIChat.manage.加群方式`) }}</label>
            <span>{{
              $t(
                `TUIChat.manage.${
                  typeName[conversation.groupProfile.joinOption]
                }`
              )
            }}</span>
          </li>
        </ul>
        <ul class="footer space-top">
          <li
            v-if="
              conversation.groupProfile.selfInfo.role === 'Owner' &&
              userInfo?.list.length > 1
            "
            @click.stop="toggleMask('changeOwner')"
          >
            {{ $t(`TUIChat.manage.转让群组`) }}
          </li>
          <li
            v-if="!!isDismissGroupAuth"
            @click.stop="dismiss(conversation.groupProfile)"
          >
            {{ $t(`TUIChat.manage.解散群聊`) }}
          </li>
          <li v-else @click.stop="quit(conversation.groupProfile)">
            {{ $t(`TUIChat.manage.退出群组`) }}
          </li>
        </ul>
      </main>
      <ManageMember
        v-else-if="currentTab === 'member'"
        :self="conversation.groupProfile.selfInfo"
        :list="userInfo.list"
        :total="~~conversation.groupProfile.memberCount"
        :isShowDel="conversation.groupProfile.selfInfo.role === 'Owner'"
        @more="getMember('more')"
        @del="submit"
      />
      <ManageNotification
        v-else-if="currentTab === 'notification'"
        :isAuth="isAuth"
        :data="conversation.groupProfile"
        @update="updateProfile"
      />
      <main class="admin" v-else-if="currentTab === 'admin'">
        <div class="admin-list" v-if="isAdmin">
          <label>{{ $t(`TUIChat.manage.群管理员`) }}</label>
          <ol>
            <dl v-for="(item, index) in member.admin" :key="index">
              <dt>
                <img
                  class="avatar"
                  :src="
                    item?.avatar ||
                    'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'
                  "
                  onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
                />
              </dt>
              <dd>{{ item?.nick || item?.userID }}</dd>
            </dl>
            <dl>
              <dt class="avatar" @click="toggleMask('addAdmin')">+</dt>
            </dl>
            <dl>
              <dt
                class="avatar"
                v-if="member.admin.length > 0"
                @click="toggleMask('removeAdmin')"
              >
                -
              </dt>
            </dl>
          </ol>
        </div>
        <div class="admin-content space-top" v-if="isSetMuteTime">
          <aside>
            <label>{{ $t(`TUIChat.manage.全员禁言`) }}</label>
            <p>
              {{
                $t(`TUIChat.manage.全员禁言开启后，只允许群主和管理员发言。`)
              }}
            </p>
          </aside>
          <Slider
            :open="conversation.groupProfile.muteAllMembers"
            @change="setAllMuteTime"
          />
        </div>
        <div class="admin-list last" v-if="isSetMuteTime">
          <label>{{ $t(`TUIChat.manage.单独禁言人员`) }}</label>
          <ol>
            <dl v-for="(item, index) in member.muteMember" :key="index">
              <dt>
                <img
                  class="avatar"
                  :src="
                    item?.avatar ||
                    'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'
                  "
                  onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
                />
              </dt>
              <dd>{{ item?.nick || item?.userID }}</dd>
            </dl>
            <dl>
              <dt class="avatar" @click="toggleMask('addMute')">+</dt>
            </dl>
            <dl>
              <dt
                class="avatar"
                v-if="member.muteMember.length > 0"
                @click="toggleMask('removeMute')"
              >
                -
              </dt>
            </dl>
          </ol>
        </div>
      </main>
      <Mask :show="mask" @update:show="(e) => (mask = e)">
        <Transfer
          :title="$t(`TUIChat.manage.${transferTitle}`)"
          :list="transferList"
          :isSearch="isSearch"
          :isRadio="isRadio"
          :selectedList="selectedList"
          @submit="submit"
          @cancel="cancel"
          @search="handleSearchMember"
          :isH5="isH5"
        />
      </Mask>
      <Dialog
        :title="$t(`TUIChat.manage.删除成员`)"
        :show="delDialogShow"
        :isH5="isH5"
        :center="true"
        :isHeaderShow="!isH5"
        @submit="handleManage(userList, 'remove')"
        @update:show="(e) => (delDialogShow = e)"
      >
        <p v-if="userList.length === 1" class="delDialog-title">
          {{ $t(`TUIChat.manage.确定从群聊中删除该成员？`) }}
        </p>
        <p v-if="userList.length > 1" class="delDialog-title">
          {{ $t(`TUIChat.manage.确定从群聊中删除所选成员？`) }}
        </p>
      </Dialog>
    </div>
  </div>
</template>

<script lang="ts">
import {
  defineComponent,
  watchEffect,
  reactive,
  toRefs,
  computed,
  watch,
  ref,
} from 'vue';
import { onClickOutside } from '@vueuse/core';
import Mask from '../../../components/mask/mask.vue';
import Transfer from '../../../components/transfer/index.vue';
import Slider from '../../../components/slider/index.vue';
import ManageName from './manage-name.vue';
import ManageNotification from './manage-notification.vue';
import ManageMember from './manage-member.vue';
import Dialog from '../../../components/dialog/index.vue';

import Vuex from 'vuex';
import TUIAegis from '../../../../utils/TUIAegis';
import { handleErrorPrompts } from '../../utils';

const manage = defineComponent({
  components: {
    Mask,
    Transfer,
    Slider,
    ManageName,
    ManageNotification,
    ManageMember,
    Dialog,
  },
  props: {
    userInfo: {
      type: Object,
      default: () => ({
        isGroup: false,
        list: [],
      }),
    },
    conversation: {
      type: Object,
      default: () => ({}),
    },
    show: {
      type: Boolean,
      default: () => false,
    },
    isH5: {
      type: Boolean,
      default: () => false,
    },
  },
  setup(props: any, ctx: any) {
    const types: any = manage.TUIServer.TUICore.TIM.TYPES;
    const { GroupServer } = manage;
    const { t } = manage.TUIServer.TUICore.config.i18n.useI18n();
    const data: any = reactive({
      conversation: {},
      userInfo: {
        isGroup: false,
        list: [],
      },
      isShowMuteTimeInput: false,
      editLableName: '',
      mask: false,
      currentTab: '',
      transferType: '',
      isSearch: false,
      isRadio: false,
      transferList: [],
      selectedList: [],
      isMuteTime: false,
      show: false,
      typeName: {
        [types.GRP_WORK]: '好友工作群',
        [types.GRP_PUBLIC]: '陌生人社交群',
        [types.GRP_MEETING]: '临时会议群',
        [types.GRP_AVCHATROOM]: '直播群',
        [types.JOIN_OPTIONS_FREE_ACCESS]: '自由加入',
        [types.JOIN_OPTIONS_NEED_PERMISSION]: '需要验证',
        [types.JOIN_OPTIONS_DISABLE_APPLY]: '禁止加群',
      },
      delDialogShow: false,
      userList: [],
      transferTitle: '',
      member: {
        admin: [],
        member: [],
        muteMember: [],
      },
    });

    const dialog: any = ref();

    watchEffect(() => {
      data.conversation = props.conversation;
      data.userInfo = props.userInfo;
      data.show = props.show;
    });

    const VuexStore = (Vuex as any).useStore();

    const TabName = computed(() => {
      let name = '';
      switch (data.currentTab) {
        case 'notification':
          name = '群公告';
          break;
        case 'member':
          name = '群成员';
          break;
        default:
          name = '群管理';
          break;
      }
      return name;
    });


    watch(
      () => data.userInfo.list,
      (newValue: any, oldValue: any) => {
        data.member = {
          admin: [],
          member: [],
          muteMember: [],
        };
        newValue.map((item: any) => {
          switch (item?.role) {
            case types.GRP_MBR_ROLE_ADMIN:
              data.member.admin.push(item);
              break;
            case types.GRP_MBR_ROLE_MEMBER:
              data.member.member.push(item);
              break;
            default:
              break;
          }
          return item;
        });
        const time: number = new Date().getTime();
        data.member.muteMember = newValue.filter((item: any) => item?.muteUntil * 1000 - time > 0);
      },
      { deep: true },
    );

    const isDismissGroupAuth = computed(() => {
      const { conversation } = data;
      const userRole = conversation?.groupProfile?.selfInfo.role;
      const groupType = conversation?.groupProfile?.type;

      const isOwner = userRole === types.GRP_MBR_ROLE_OWNER;
      const isWork = groupType === types.GRP_WORK;

      return isOwner && !isWork;
    });

    const isShowAddMember = computed(() => {
      const { conversation } = data;
      const groupType = conversation?.groupProfile?.type;
      const isWork = groupType === types.GRP_WORK;

      if (isWork) {
        return true;
      }
      return false;
    });

    const showUserNum = computed(() => {
      let num = 3;
      if (!isShowAddMember.value) {
        num += 1;
      }
      if ((data.conversation as any).groupProfile.selfInfo.role !== 'Owner') {
        num += 1;
      }
      return num;
    });

    const isAuth = computed(() => {
      const { conversation } = data;
      const userRole = conversation?.groupProfile?.selfInfo.role;

      const isOwner = userRole === types.GRP_MBR_ROLE_OWNER;
      const isAdmin = userRole === types.GRP_MBR_ROLE_ADMIN;

      return isOwner || isAdmin;
    });

    const isAdmin = computed(() => {
      const { conversation } = data;
      const groupType = conversation?.groupProfile?.type;
      const userRole = conversation?.groupProfile?.selfInfo.role;

      const isOwner = userRole === types.GRP_MBR_ROLE_OWNER;
      const isWork = groupType === types.GRP_WORK;
      const isAVChatRoom = groupType === types.GRP_AVCHATROOM;

      if (!isWork && !isAVChatRoom && isOwner) {
        return true;
      }
      return false;
    });

    const isSetMuteTime = computed(() => {
      const { conversation } = data;
      const groupType = conversation?.groupProfile?.type;
      const isWork = groupType === types.GRP_WORK;

      if (isWork || !isAuth.value) {
        return false;
      }
      return true;
    });

    const getMember = (type?: string) => {
      const { conversation } = data;
      const options: any = {
        groupID: conversation?.groupProfile?.groupID,
        count: 100,
        offset: type && type === 'more' ? data.userInfo.list.length : 0,
      };
      GroupServer.getGroupMemberList(options).then((res: any) => {
        if (type && type === 'more') {
          data.userInfo.list = [...data.userInfo.list, ...res.data.memberList];
        } else {
          data.userInfo.list = res.data.memberList;
        }
      });
    };

    const addMember = async (userIDList: any) => {
      const { conversation } = data;
      const options: any = {
        groupID: conversation.groupProfile.groupID,
        userIDList,
      };
      await GroupServer.addGroupMember(options);
      getMember('More');
    };

    const deleteMember = (user: any) => {
      const { conversation } = data;
      const options: any = {
        groupID: conversation.groupProfile.groupID,
        userIDList: [user.userID],
      };
      GroupServer.deleteGroupMember(options);
    };

    const changeOwner = async (userID: any) => {
      const options: any = {
        groupID: data.conversation.groupProfile.groupID,
        newOwnerID: userID,
      };
      const imResponse = await GroupServer.changeGroupOwner(options);
      data.conversation.groupProfile = {};
      data.conversation.groupProfile = imResponse.data.group;
    };

    const quit = async (group: any) => {
      await GroupServer.quitGroup(group.groupID);
      manage.TUIServer.store.conversation = {};
    };

    const dismiss = async (group: any) => {
      await GroupServer.dismissGroup(group.groupID);
      manage.TUIServer.store.conversation = {};
      VuexStore.commit('handleTask', 5);
    };

    const handleAdmin = async (user: any) => {
      const { conversation } = data;
      let role = '';
      switch (user.role) {
        case types.GRP_MBR_ROLE_ADMIN:
          role = types.GRP_MBR_ROLE_MEMBER;
          break;
        case types.GRP_MBR_ROLE_MEMBER:
          role = types.GRP_MBR_ROLE_ADMIN;
          break;
      }
      const options: any = {
        groupID: conversation.groupProfile.groupID,
        userID: user.userID,
        role,
      };
      await GroupServer.setGroupMemberRole(options);
      getMember();
    };

    const setMemberMuteTime = async (userID: string, type?: string) => {
      const { conversation } = data;
      const options: any = {
        groupID: conversation.groupProfile.groupID,
        userID,
        muteTime: type === 'add' ? 60 * 60 * 24 * 30 : 0,
      };
      await GroupServer.setGroupMemberMuteTime(options);
      if (type === 'add') {
        VuexStore.commit('handleTask', 4);
      }
      getMember();
    };

    const kickedOut = async (userIDList: any) => {
      const { conversation } = data;
      const options: any = {
        groupID: conversation.groupProfile.groupID,
        userIDList,
        reason: '',
      };
      await GroupServer.deleteGroupMember(options);
      getMember();
    };

    const edit = (labelName: string) => {
      data.editLableName = labelName;
    };

    const updateProfile = async (params: any) => {
      const { key, value } = params;
      const options: any = {
        groupID: data.conversation.groupProfile.groupID,
        [key]: value,
      };
      const res = await GroupServer.updateGroupProfile(options);
      const { conversation } = manage.TUIServer.store;
      conversation.groupProfile = res.data.group;
      manage.TUIServer.store.conversation = {};
      manage.TUIServer.store.conversation = conversation;
      data.editLableName = '';
    };

    const setTab = (tabName: string) => {
      data.currentTab = tabName;
      data.editLableName = '';
      if (data.currentTab === 'member') {
        data.transferType = 'remove';
      }
      if (!data.currentTab) {
        data.transferType = '';
      }
    };

    const handleSearchMember = async (value: string) => {
      let imResponse: any = {};
      let imMemberResponse: any = {};
      const options: any = {
        groupID: data.conversation.groupProfile.groupID,
        userIDList: [value],
      };
      switch (data.transferType) {
        case 'add':
          try {
            imMemberResponse = await GroupServer.getGroupMemberProfile(options);
            data.transferList = data.transferList.filter((item: any) => item.userID !== imResponse.data[0]?.userID);
            data.transferList = [...data.transferList, ...imResponse.data];
            if (imMemberResponse?.data?.memberList.length > 0) {
              data.transferList = data.transferList.map((item: any) => {
                if (item.userID === imMemberResponse?.data?.memberList[0].userID) {
                  item.isDisabled = true;
                }
                return item;
              });
            }
          } catch (error) {
            const message = t('TUIChat.manage.该用户不存在');
            handleErrorPrompts(message, props);
          }
          break;
        case 'remove':
          try {
            imResponse = await GroupServer.getGroupMemberProfile(options);
            if (imResponse.data.memberList.length === 0) {
              const message = t('TUIChat.manage.该用户不在群组内');
              return handleErrorPrompts(message, props);
            }
            data.transferList = data.transferList.filter((item: any) => item.userID !== imResponse?.data?.memberList[0]?.userID);
            data.transferList = [
              ...data.transferList,
              ...imResponse?.data?.memberList,
            ];
          } catch (error) {
            const message = t('TUIChat.manage.该用户不存在');
            handleErrorPrompts(message, props);
          }
          break;
        default:
          break;
      }
    };

    const submit = (userList: any) => {
      if (data.transferType === 'remove') {
        data.userList = userList;
        data.delDialogShow = !data.delDialogShow;
      } else {
        handleManage(userList, data.transferType);
      }
      data.mask = false;
    };

    const friendList = async () => {
      const imResponse =  await manage.TUIServer.getFriendList();
      const friendList =  imResponse.data.map((item: any) => item?.profile);
      return friendList.filter((item: any) => !data.userInfo.list.some((infoItem:any) => infoItem.userID === item.userID));
    };

    const cancel = () => {
      toggleMask();
    };

    const toggleMask = async (type?: string) => {
      data.selectedList = [];
      switch (type) {
        case 'add':
          data.isRadio = false;
          data.transferList = await friendList();
          data.transferTitle = '添加成员';
          break;
        case 'remove':
          data.isRadio = false;
          data.transferList = data.userInfo.list.filter((item: any) => item.userID !== data.conversation?.groupProfile?.selfInfo.userID);
          data.transferTitle = '删除成员';
          break;
        case 'addAdmin':
          data.isRadio = true;
          data.transferList = data.member.member;
          data.transferTitle = '新增管理员';
          break;
        case 'removeAdmin':
          data.isRadio = true;
          data.transferList = data.member.admin;
          data.transferTitle = '移除管理员';
          break;
        case 'changeOwner':
          data.isRadio = true;
          data.transferList = [...data.member.admin, ...data.member.member];
          data.transferTitle = '转让群组';
          break;
        case 'addMute':
          data.isRadio = true;
          data.transferList = data.member.member;
          if (data.conversation.groupProfile.selfInfo.role === 'Owner') {
            data.transferList = [...data.member.admin, ...data.member.member];
          }
          data.transferTitle = '新增禁言用户';
          break;
        case 'removeMute':
          data.isRadio = true;
          data.transferList = data.member.muteMember;
          data.transferTitle = '移除禁言用户';
          break;
        default:
          break;
      }
      data.transferType = type;
      data.mask = !data.mask;
    };

    onClickOutside(dialog, () => {
      data.show = false;
    });

    const toggleShow = () => {
      if (!GroupServer) {
        const message = t('TUIChat.manage.请先注册 TUIGroup 模块');
        return handleErrorPrompts(message, props);
      }
      data.show = !data.show;
      if (!data.show) {
        data.currentTab = '';
      }
      if (data.show) {
        getMember();
      }
    };

    const setAllMuteTime = (value: boolean) => {
      updateProfile({ key: 'muteAllMembers', value });
      VuexStore.commit('handleTask', 4);
    };

    const handleManage = (userList: any, type: any) => {
      const userIDList: any = [];
      userList.map((item: any) => {
        userIDList.push(item.userID);
        return item;
      });
      switch (type) {
        case 'add':
          addMember(userIDList);
          TUIAegis.getInstance().reportEvent({
            name: 'groupOptions',
            ext1: 'groupAddMember',
          });
          break;
        case 'remove':
          kickedOut(userIDList);
          TUIAegis.getInstance().reportEvent({
            name: 'groupOptions',
            ext1: 'groupRemoveMember',
          });
          break;
        case 'addAdmin':
          handleAdmin(userList[0]);
          TUIAegis.getInstance().reportEvent({
            name: 'groupOptions',
            ext1: 'groupAddAdmin',
          });
          break;
        case 'removeAdmin':
          handleAdmin(userList[0]);
          TUIAegis.getInstance().reportEvent({
            name: 'groupOptions',
            ext1: 'groupRemoveAdmin',
          });
          break;
        case 'changeOwner':
          changeOwner(userIDList[0]);
          TUIAegis.getInstance().reportEvent({
            name: 'groupOptions',
            ext1: 'groupChangeOwner',
          });
          break;
        case 'addMute':
          setMemberMuteTime(userIDList[0], 'add');
          TUIAegis.getInstance().reportEvent({
            name: 'groupOptions',
            ext1: 'groupAddMute',
          });
          break;
        case 'removeMute':
          setMemberMuteTime(userIDList[0], 'remove');
          TUIAegis.getInstance().reportEvent({
            name: 'groupOptions',
            ext1: 'groupRemoveMute',
          });
          break;
        default:
          break;
      }
    };

    return {
      ...toRefs(data),
      isDismissGroupAuth,
      isShowAddMember,
      isSetMuteTime,
      isAdmin,
      isAuth,
      addMember,
      deleteMember,
      changeOwner,
      quit,
      dismiss,
      handleAdmin,
      setMemberMuteTime,
      kickedOut,
      edit,
      updateProfile,
      setTab,
      TabName,
      getMember,
      handleSearchMember,
      submit,
      cancel,
      toggleMask,
      toggleShow,
      setAllMuteTime,
      handleManage,
      showUserNum,
      dialog,
    };
  },
});
export default manage;
</script>

<style lang="scss" scoped src="./style/index.scss"></style>
