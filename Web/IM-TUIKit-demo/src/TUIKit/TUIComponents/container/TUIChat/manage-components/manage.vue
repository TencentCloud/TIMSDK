<template>
  <div>
    <i class="icon icon-chat-setting" @click="toggleShow"></i>
    <div class="manage" v-if="show" ref="dialog">
      <header class="manage-header">
        <aside class="manage-header-left">
          <i class="icon icon-left" v-if="currentTab" @click="setTab('')"></i>
          <main>
            <h1>{{ $t(`TUIChat.manage.${TabName}`) }}</h1>
          </main>
        </aside>
        <i class="icon icon-close" @click="toggleShow"></i>
      </header>
      <main class="main" v-if="!currentTab">
        <ManageName
          class="space-top"
          :isAuth="isAuth"
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
        :total="conversation.groupProfile.memberCount"
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
        />
      </Mask>
      <Dialog
        :title="$t(`TUIChat.manage.删除成员`)"
        :show="delDialogShow"
        @submit="handleManage(userList, 'remove')"
        @update:show="(e) => (delDialogShow = e)"
      >
        <p v-if="userList.length === 1">
          {{ $t(`TUIChat.manage.确定从群聊中删除该成员？`) }}
        </p>
        <p v-if="userList.length > 1">
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
} from "vue";
import { onClickOutside } from "@vueuse/core";
import Mask from "../../../components/mask/mask.vue";
import Transfer from "../../../components/transfer/index.vue";
import Slider from "../../../components/slider/index.vue";
import ManageName from "./manage-name.vue";
import ManageNotification from "./manage-notification.vue";
import ManageMember from "./manage-member.vue";
import Dialog from "../../../components/dialog/index.vue";

import Vuex from "vuex";
import TUIMessage from "../../../components/message";

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
  },
  setup(props: any, ctx: any) {
    const types: any = manage.TUIServer.TUICore.TIM.TYPES;
    const GroupServer: any = manage.GroupServer;
    const data: any = reactive({
      conversation: {},
      userInfo: {
        isGroup: false,
        list: [],
      },
      isShowMuteTimeInput: false,
      editLableName: "",
      mask: false,
      currentTab: "",
      transferType: "",
      isSearch: true,
      isRadio: false,
      transferList: [],
      selectedList: [],
      isMuteTime: false,
      show: false,
      typeName: {
        [types.GRP_WORK]: "好友工作群",
        [types.GRP_PUBLIC]: "陌生人社交群",
        [types.GRP_MEETING]: "临时会议群",
        [types.GRP_AVCHATROOM]: "直播群",
        [types.JOIN_OPTIONS_FREE_ACCESS]: "自由加入",
        [types.JOIN_OPTIONS_NEED_PERMISSION]: "需要验证",
        [types.JOIN_OPTIONS_DISABLE_APPLY]: "禁止加群",
      },
      delDialogShow: false,
      userList: [],
      transferTitle: "",
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

    // 获取vuex 的 store
    const VuexStore = (Vuex as any).useStore();

    const TabName = computed(() => {
      let name = "";
      switch (data.currentTab) {
        case "notification":
          name = "群公告";
          break;
        case "member":
          name = "群成员";
          break;
        default:
          name = "群管理";
          break;
      }
      return name;
    });

    // 监听用户列表变化
    watch(
      () => data.userInfo.list,
      (newValue: any, oldValue: any) => {
        data.member = {
          admin: [], // 群管理员列表
          member: [], // 群成员列表
          muteMember: [], // 已被禁言用户
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
        data.member.muteMember = newValue.filter(
          (item: any) => item?.muteUntil * 1000 - time > 0
        );
      },
      { deep: true }
    );

    // 是否有删除群的权限
    const isDismissGroupAuth = computed(() => {
      const { conversation } = data;
      const userRole = conversation?.groupProfile?.selfInfo.role;
      const groupType = conversation?.groupProfile?.type;

      const isOwner = userRole === types.GRP_MBR_ROLE_OWNER;
      const isWork = groupType === types.GRP_WORK;

      return isOwner && !isWork;
    });

    // 是否显示可以添加群成员
    const isShowAddMember = computed(() => {
      const { conversation } = data;
      const groupType = conversation?.groupProfile?.type;
      const isWork = groupType === types.GRP_WORK;

      if (isWork) {
        return true;
      }
      return false;
    });

    // 群成员列表外部显示数量
    const showUserNum = computed(() => {
      let num = 3;
      if (!isShowAddMember.value) {
        num += 1;
      }
      if ((data.conversation as any).groupProfile.selfInfo.role !== "Owner") {
        num += 1;
      }
      return num;
    });

    // 是否为管理员或群主
    const isAuth = computed(() => {
      const { conversation } = data;
      const userRole = conversation?.groupProfile?.selfInfo.role;

      const isOwner = userRole === types.GRP_MBR_ROLE_OWNER;
      const isAdmin = userRole === types.GRP_MBR_ROLE_ADMIN;

      return isOwner || isAdmin;
    });

    // 是否可以设置管理
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

    // 是否可以设置禁言
    const isSetMuteTime = computed(() => {
      const { conversation } = data;
      const groupType = conversation?.groupProfile?.type;
      const isWork = groupType === types.GRP_WORK;

      if (isWork || !isAuth.value) {
        return false;
      }
      return true;
    });

    // 获取群用户列表
    const getMember = (type?: string) => {
      const { conversation } = data;
      const options: any = {
        groupID: conversation?.groupProfile?.groupID,
        count: 100,
        offset: type && type === "more" ? data.userInfo.list.length : 0,
      };
      GroupServer.getGroupMemberList(options).then((res: any) => {
        if (type && type === "more") {
          data.userInfo.list = [...data.userInfo.list, ...res.data.memberList];
        } else {
          data.userInfo.list = res.data.memberList;
        }
      });
    };

    // 添加用户
    const addMember = async (userIDList: any) => {
      const { conversation } = data;
      const options: any = {
        groupID: conversation.groupProfile.groupID,
        userIDList,
      };
      await GroupServer.addGroupMember(options);
      getMember("More");
    };

    // 删除群成员
    const deleteMember = (user: any) => {
      const { conversation } = data;
      const options: any = {
        groupID: conversation.groupProfile.groupID,
        userIDList: [user.userID],
      };
      GroupServer.deleteGroupMember(options);
    };

    // 转让群
    const changeOwner = async (userID: any) => {
      const options: any = {
        groupID: data.conversation.groupProfile.groupID,
        newOwnerID: userID,
      };
      const imResponse = await GroupServer.changeGroupOwner(options);
      data.conversation.groupProfile = {};
      data.conversation.groupProfile = imResponse.data.group;
    };

    // 退出群
    const quit = async (group: any) => {
      await GroupServer.quitGroup(group.groupID);
      manage.TUIServer.store.conversation = {};
    };

    // 解散群
    const dismiss = async (group: any) => {
      await GroupServer.dismissGroup(group.groupID);
      manage.TUIServer.store.conversation = {};
      VuexStore.commit("handleTask", 5);
    };

    // 设置/取消群成员为管理员
    const handleAdmin = async (user: any) => {
      const { conversation } = data;
      let role = "";
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

    // 设置/取消用户禁言时间
    const setMemberMuteTime = async (userID: string, type?: string) => {
      const { conversation } = data;
      const options: any = {
        groupID: conversation.groupProfile.groupID,
        userID,
        muteTime: type === "add" ? 60 * 60 * 24 * 30 : 0,
      };
      await GroupServer.setGroupMemberMuteTime(options);
      if (type === "add") {
        VuexStore.commit("handleTask", 4);
      }
      getMember();
    };

    // 踢出用户
    const kickedOut = async (userIDList: any) => {
      const { conversation } = data;
      const options: any = {
        groupID: conversation.groupProfile.groupID,
        userIDList,
        reason: "",
      };
      await GroupServer.deleteGroupMember(options);
      getMember();
    };

    // 打开编辑栏
    const edit = (labelName: string) => {
      data.editLableName = labelName;
    };

    // 更新群资料
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
      data.editLableName = "";
    };

    // 设置当前tab
    const setTab = (tabName: string) => {
      data.currentTab = tabName;
      data.editLableName = "";
      if (data.currentTab === "member") {
        data.transferType = "remove";
      }
      if (!data.currentTab) {
        data.transferType = "";
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
        case "add":
          try {
            imResponse = await manage.TUIServer.getUserProfile([value]);
            if (imResponse.data.length === 0) {
              return TUIMessage({ message: "该用户不存在" });
            }
            imMemberResponse = await GroupServer.getGroupMemberProfile(options);
            data.transferList = data.transferList.filter(
              (item: any) => item.userID !== imResponse.data[0]?.userID
            );
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
            TUIMessage({ message: "该用户不存在" });
          }
          break;
        case "remove":
          try {
            imResponse = await GroupServer.getGroupMemberProfile(options);
            if (imResponse.data.memberList.length === 0) {
              return TUIMessage({ message: "该用户不在群组内" });
            }
            data.transferList = data.transferList.filter(
              (item: any) =>
                item.userID !== imResponse?.data?.memberList[0]?.userID
            );
            data.transferList = [
              ...data.transferList,
              ...imResponse?.data?.memberList,
            ];
          } catch (error) {
            TUIMessage({ message: "该用户不存在" });
          }
          break;
        default:
          break;
      }
    };

    const submit = (userList: any) => {
      if (data.transferType === "remove") {
        data.userList = userList;
        data.delDialogShow = !data.delDialogShow;
      } else {
        handleManage(userList, data.transferType);
      }
      data.mask = false;
    };

    const cancel = () => {
      toggleMask();
    };

    const toggleMask = (type?: string) => {
      data.selectedList = [];
      switch (type) {
        case "add":
          data.isSearch = true;
          data.transferList = [];
          data.transferTitle = "添加成员";
          break;
        case "remove":
          data.transferList = data.userInfo.list.filter(
            (item: any) =>
              item.userID !== data.conversation?.groupProfile?.selfInfo.userID
          );
          data.transferTitle = "删除成员";
          break;
        case "addAdmin":
          data.isSearch = false;
          data.isRadio = true;
          data.transferList = data.member.member;
          data.transferTitle = "新增管理员";
          break;
        case "removeAdmin":
          data.isSearch = false;
          data.isRadio = true;
          data.transferList = data.member.admin;
          data.transferTitle = "移除管理员";
          break;
        case "changeOwner":
          data.isSearch = false;
          data.isRadio = true;
          data.transferList = [...data.member.admin, ...data.member.member];
          data.transferTitle = "转让群组";
          break;
        case "addMute":
          data.isSearch = false;
          data.isRadio = true;
          data.transferList = data.member.member;
          if (data.conversation.groupProfile.selfInfo.role === "Owner") {
            data.transferList = [...data.member.admin, ...data.member.member];
          }
          data.transferTitle = "新增禁言用户";
          break;
        case "removeMute":
          data.isSearch = false;
          data.isRadio = true;
          data.transferList = data.member.muteMember;
          data.transferTitle = "移除禁言用户";
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
        return TUIMessage({ message: "请先注册 TUIGroup 模块" });
      }
      data.show = !data.show;
      if (!data.show) {
        data.currentTab = "";
      }
      if (data.show) {
        getMember();
      }
    };

    const setAllMuteTime = (value: boolean) => {
      updateProfile({ key: "muteAllMembers", value });
      VuexStore.commit("handleTask", 4);
    };

    const handleManage = (userList: any, type: any) => {
      const userIDList: any = [];
      userList.map((item: any) => {
        userIDList.push(item.userID);
        return item;
      });
      switch (type) {
        case "add":
          addMember(userIDList);
          break;
        case "remove":
          kickedOut(userIDList);
          break;
        case "addAdmin":
          handleAdmin(userList[0]);
          break;
        case "removeAdmin":
          handleAdmin(userList[0]);
          break;
        case "changeOwner":
          changeOwner(userIDList[0]);
          break;
        case "addMute":
          setMemberMuteTime(userIDList[0], "add");
          break;
        case "removeMute":
          setMemberMuteTime(userIDList[0], "remove");
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

<style lang="scss" scoped>
.manage {
  display: flex;
  flex-direction: column;
  background: #ffffff;
  box-sizing: border-box;
  width: 360px;
  overflow-y: auto;
  box-shadow: 0 1px 10px 0 rgba(2, 16, 43, 0.15);
  border-radius: 8px 0 0 8px;
  position: absolute;
  right: 0;
  height: calc(100% - 40px);
  z-index: 2;
  top: 40px;
  &-header {
    padding: 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #e8e8e9;
    aside {
      display: flex;
      align-items: center;
    }
    h1 {
      font-family: PingFangSC-Medium;
      font-weight: 500;
      font-size: 16px;
      color: #000000;
    }
    &-left {
      display: flex;
      .icon {
        margin-right: 14px;
      }
      main {
        display: flex;
        flex-direction: column;
        p {
          padding-top: 8px;
          font-weight: 400;
          font-size: 12px;
          color: #999999;
        }
      }
    }
  }
  .main {
    .userInfo {
      padding: 0 20px;
      display: flex;
      flex-direction: column;
      font-size: 14px;
      &-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 14px 0;
        p {
          display: flex;
          align-items: center;
        }
      }
      ol {
        flex: 1;
        display: flex;
        flex-wrap: wrap;
        padding-bottom: 20px;
        dl {
          position: relative;
          flex: 0 0 36px;
          display: flex;
          flex-direction: column;
          padding-right: 20px;
          &:last-child {
            padding-right: 0;
          }
          .more {
            padding-top: 10px;
          }
          dd {
            text-align: center;
            max-width: 36px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
          }
          .userInfo-mask {
            position: absolute;
            z-index: 5;
            background: #ffffff;
            padding: 20px;
            box-shadow: 0 11px 20px 0 rgba(0,0,0, .3);
            left: 100%;
            li {
              display: flex;
              align-items: center;
              label {
                width: 60px;
              }
              span {
                max-width: 200px;
                word-break: keep-all;
              }
            }
          }
        }
      }
    }
    .content {
      padding: 0 20px;
      li {
        padding: 14px 0;
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 14px;
        .btn {
          flex: 1;
        }
        article {
          opacity: 0.6;
          width: 246px;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }
        .end {
          align-self: flex-end;
          margin-bottom: 4px;
        }
      }
    }
    .footer {
      padding: 0 20px;
      li {
        cursor: pointer;
        width: 100%;
        font-weight: 400;
        font-size: 14px;
        color: #dc2113;
        padding: 14px 0;
        text-align: center;
        border-bottom: 1px solid #e8e8e9;
        &:last-child {
          border: none;
        }
      }
    }
  }
  .admin {
    padding: 20px 0;
    &-content {
      padding: 20px 20px 12px;
      display: flex;
      align-items: center;
      aside {
        flex: 1;
        font-weight: 400;
        font-size: 14px;
        color: #000000;
        letter-spacing: 0;
        p {
          opacity: 0.6;
          font-size: 12px;
        }
      }
    }
    &-list {
      padding: 0 20px;
      label {
        display: inline-block;
        font-weight: 400;
        font-size: 14px;
        color: #000000;
        padding-bottom: 8px;
      }
    }
    .last {
      padding-top: 13px;
      position: relative;
      &::before {
        position: absolute;
        content: "";
        width: calc(100% - 40px);
        height: 1px;
        background: #e8e8e9;
        top: 0;
        left: 0;
        right: 0;
        margin: 0 auto;
      }
    }
  }
  ol {
    flex: 1;
    display: flex;
    flex-wrap: wrap;
    padding-bottom: 20px;
    dl {
      position: relative;
      flex: 0 0 36px;
      display: flex;
      flex-direction: column;
      padding-right: 20px;
      &:last-child {
        padding-right: 0;
      }
      .more {
        padding-top: 10px;
      }
      dd {
        text-align: center;
        max-width: 36px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
      .userInfo-mask {
        position: fixed;
        z-index: 5;
        background: #ffffff;
        padding: 20px;
        box-shadow: 0 11px 20px 0 rgba(0,0,0, .3);
        margin-left: 36px;
        li {
          display: flex;
          align-items: center;
          label {
            width: 60px;
          }
          span {
            max-width: 200px;
            word-break: keep-all;
          }
        }
      }
    }
  }
}
.input {
  border: 1px solid #e8e8e9;
  border-radius: 4px;
  padding: 4px 16px;
  font-weight: 400;
  font-size: 14px;
  color: #000000;
  opacity: 0.6;
}
.avatar {
  width: 36px;
  height: 36px;
  background: #f4f5f9;
  border-radius: 4px;
  font-size: 12px;
  color: #000000;
  display: flex;
  justify-content: center;
  align-items: center;
}
.space-top {
  border-top: 10px solid #f4f5f9;
}
.btn {
  background: #3370ff;
  border: 0 solid #2f80ed;
  padding: 4px 28px;
  font-weight: 400;
  font-size: 12px;
  color: #ffffff;
  line-height: 24px;
  border-radius: 4px;
  &-cancel {
    background: #ffffff;
    border: 1px solid #dddddd;
    color: #828282;
  }
}

.slider {
  &-box {
    display: flex;
    align-items: center;
    width: 34px;
    height: 20px;
    border-radius: 10px;
    background: #e1e1e3;
  }
  &-block {
    display: inline-block;
    width: 16px;
    height: 16px;
    border-radius: 8px;
    margin: 0 2px;
    background: #ffffff;
    border: 0 solid rgba(0, 0, 0, 0.85);
    box-shadow: 0 2px 4px 0 #d1d1d1;
  }
}
.space-between {
  justify-content: space-between;
}
</style>
