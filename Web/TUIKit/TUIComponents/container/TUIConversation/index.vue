<template>
<div class="TUI-conversation">
    <header @click="showOpen">
      <i class="plus"></i>
      <h1>{{$t('TUIConversation.发起单人/多人会话')}}</h1>
    </header>
    <div class="network" v-if="isNetwork">
      <i class="icon icon-error">!</i>
      <p>️网络异常，请您检查网络设置</p>
    </div>
    <main class="TUI-conversation-list">
      <TUIConversationList
        :currentID="currrentConversationID"
        :data="conversationData"
        @handleItem="handleCurrrentConversation"
        />
    </main>
    <Dialog
      :show="open"
      :isHeaderShow="false"
      :isFooterShow="false"
      :background="false"
      @update:show="(e)=>(open = e)"
      >
      <Transfer :title="$t('TUIConversation.发起单人/多人会话')" :list="searchUserList" @search="handleSearch" @submit="submit" @cancel="toggleOpen" v-if="step===1" />
      <Group v-else @submit="create" @cancel="toggleOpen" />
    </Dialog>
</div>
</template>
<script lang="ts">
import { defineComponent, reactive, toRefs, computed } from 'vue';
import TUIConversationList from './components/conversationList.vue';
import Group from './components/group.vue';
import { caculateTimeago } from '../utils';
import Dialog from '../../components/dialog/index.vue';
import Transfer from '../../components/transfer/index.vue';
import TUIMessage from '../../components/message';
import { handleAvatar, handleName } from '../TUIChat/untils/untis';

const TUIConversation = defineComponent({
  name: 'TUIConversation',

  components: {
    TUIConversationList,
    Transfer,
    Dialog,
    Group,
  },

  setup(props) {
    const TUIServer:any = TUIConversation?.TUIServer;
    const { t } = TUIServer.TUICore.config.i18n.useI18n();
    const data = reactive({
      currrentConversationID: '',
      conversationData: {
        list: [],
        // 处理头像
        handleItemAvator: (item: any) => handleAvatar(item),
        // 处理昵称
        handleItemName: (item: any) => handleName(item),
        // 处理时间
        handleItemTime: (time: number) => {
          if (time > 0) {
            return caculateTimeago(time * 1000);
          }
          return '';
        },
        // 处理lastMessage
        handleItemMessage: (message: any) => {
          if (message.isRevoked) {
            return t('TUIChat.撤回了一条消息');
          }
          switch (message.type) {
            case TUIServer.TUICore.TIM.TYPES.MSG_TEXT:
              return message.payload.text;
            default:
              return message.messageForShow;
          }
        },
      },
      open: false,
      searchUserID: '',
      selectedList: [],
      searchUserList: [],
      step: 1,
      group: {
        groupID: '',
        name: '',
        type: '',
        avatar: '',
        introduction: '',
        notification: '',
        joinOption: '',
        memberList: [
          {
            userID: '',
          },
        ],
      },
      netWork: '',
    });

    // 绑定数据
    TUIServer.bind(data);

    TUIConversationList.TUIServer = TUIServer;
    const GroupServer = TUIServer?.TUICore?.TUIServer?.TUIGroup;
    Group.TUIServer = TUIServer;

    const isNetwork = computed(() => {
      const disconnected = data.netWork === TUIServer.TUICore.TIM.TYPES.NET_STATE_DISCONNECTED;
      const connecting = data.netWork === TUIServer.TUICore.TIM.TYPES.NET_STATE_CONNECTING;
      return  disconnected || connecting;
    });

    // 切换当前会话
    const handleCurrrentConversation = (value: any) => {
      if (data.currrentConversationID) {
        TUIServer.setMessageRead(data.currrentConversationID);
      }
      data.currrentConversationID = value.conversationID;
      TUIServer.setMessageRead(value.conversationID);
      TUIServer.getConversationProfile(value.conversationID).then((res:any) => {
        // 通知 TUIChat 关闭当前会话
        TUIServer.TUICore.getStore().TUIChat.conversation = res.data.conversation;
      });
    };

    // 初始化群组参数
    const initGroupOptions = () => {
      data.group = {
        groupID: '',
        name: '',
        type: '',
        avatar: '',
        introduction: '',
        notification: '',
        joinOption: '',
        memberList: [
          {
            userID: '',
          },
        ],
      };
    };

    // 开关弹窗
    const toggleOpen = () => {
      data.open = !data.open;
      if (!data.open) {
        data.searchUserID = '';
        data.searchUserList = [];
        data.step = 1;
        initGroupOptions();
      }
    };

    // 搜索用户
    const handleSearch = async (val:any) => {
      try {
        const imResponse:any = await TUIServer.getUserProfile([val]);
        if (imResponse.data.length === 0) {
          return TUIMessage({ message: '该用户不存在' });
        }
        const isCurrent = data.searchUserList.filter((item:any) => item.userID === imResponse.data[0].userID);
        if (isCurrent.length === 0) {
          (data.searchUserList as any).push(imResponse.data[0]);
        }
      } catch (error) {
        TUIMessage({ message: '该用户不存在' });
      }
    };

    // 创建C2C或跳转创建群组第二步
    const submit = (userList: any) =>  {
      if  (userList.length  === 1)  {
        const { userID } = userList[0];
        const name = `C2C${userID}`;
        TUIServer.getConversationProfile(name).then((imResponse:any) => {
          handleCurrrentConversation(imResponse.data.conversation);
        });
        toggleOpen();
      } else if (userList.length > 1)  {
        if (!Group.TUIServer) {
          TUIMessage({ message: '创建群聊，请注册 TUIGroup 模块' });
        }
        initGroupOptions();
        data.group.memberList = userList.map((item:any) => ({ userID: item.userID }));
        data.step = 2;
      }
    };

    // 创建群组
    const create = async (params: any) => {
      if (params.type === TUIServer.TUICore.TIM.TYPES.GRP_PUBLIC) {
        data.group.joinOption = TUIServer.TUICore.TIM.TYPES.JOIN_OPTIONS_NEED_PERMISSION;
      }
      const options = { ...data.group, ...params };
      if (params.type === TUIServer.TUICore.TIM.TYPES.GRP_AVCHATROOM) {
        delete options.memberList;
        delete options.joinOption;
      }
      try {
        const imResponse = await GroupServer.createGroup(options);
        TUIMessage({ message: '创建成功' });
        toggleOpen();
        if (params.type === TUIServer.TUICore.TIM.TYPES.GRP_AVCHATROOM) {
          GroupServer.joinGroup({
            groupID: imResponse.data.group.groupID,
            applyMessage: '',
            type: imResponse.data.group.type,
          });
        }
      } catch (imError:any) {
        TUIMessage({ message: imError });
      }
    };

    // 触发创建C2C/群聊选人弹窗
    const showOpen  = () => {
      data.open = true;
    };
    return {
      ...toRefs(data),
      handleCurrrentConversation,
      toggleOpen,
      handleSearch,
      submit,
      create,
      showOpen,
      isNetwork,
    };
  },
});
export default TUIConversation;
</script>

<style lang="scss" scoped>
@import '../../styles/TUIConversation.scss';
</style>
