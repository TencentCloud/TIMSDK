<template>
<div class="TUI-search" :class="[env.isH5 ? 'TUI-search-H5' : '']" ref="dialog">
    <header @click="toggleOptionalShow">
      <i class="plus"></i>
      <h1 v-if="env.isH5">{{$t('TUISearch.发起会话')}}</h1>
      <ul v-show="optionalShow">
        <li>
          <i class="icon icon-c2c" v-if="env.isH5"></i>
          <h1 @click="showOpen('isC2C')">{{$t('TUISearch.发起单聊')}}</h1>
        </li>
        <li>
          <i class="icon icon-group"></i>
          <h1 @click="showOpen('isGroup')">{{$t('TUISearch.发起群聊')}}</h1>
        </li>
      </ul>
    </header>
    <Dialog
      :show="open"
      :isH5="env.isH5"
      :isHeaderShow="false"
      :isFooterShow="false"
      :background="false"
      @update:show="(e)=>(open = e)"
      >
      <Transfer
        :title="showTitle"
        :list="searchUserList"
        :isH5="env.isH5"
        :isRadio="createConversationType === 'isC2C'"
        @search="handleSearch"
        @submit="submit"
        @cancel="toggleOpen"
        v-if="step===1" />
      <CreateGroup v-else @submit="create" @cancel="toggleOpen" :isH5="env.isH5" />
    </Dialog>
</div>
</template>
<script lang="ts">
import { defineComponent, reactive, ref, toRefs } from 'vue';
import CreateGroup from './components/createGroup';
import Dialog from '../../components/dialog/index.vue';
import Transfer from '../../components/transfer/index.vue';
import TUIMessage from '../../components/message';
import { useStore } from 'vuex';
import TUIAegis from '../../../utils/TUIAegis';
import constant from '../constant';
import { onClickOutside } from '@vueuse/core';

const TUISearch = defineComponent({
  name: 'TUISearch',

  components: {
    Transfer,
    Dialog,
    CreateGroup,
  },

  setup(props) {
    const TUIServer:any = TUISearch?.TUIServer;
    const { t } = TUIServer.TUICore.config.i18n.useI18n();
    const data = reactive({
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
      showTitle: '',
      createConversationType: '',
      env: TUIServer.TUICore.TUIEnv,
      optionalShow: !TUIServer.TUICore.TUIEnv.isH5,
    });

    TUIServer.bind(data);

    const GroupServer = TUIServer?.TUICore?.TUIServer?.TUIGroup;
    CreateGroup.TUIServer = TUIServer;

    const VuexStore = useStore();

    const dialog:any = ref();

    onClickOutside(dialog, () => {
      if (data.env.isH5) {
        data.optionalShow = false;
      }
    });

    // 初始化群组属性
    // Initialize group parameters
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


    const toggleOpen = () => {
      data.open = !data.open;
      if (!data.open) {
        data.searchUserID = '';
        data.searchUserList = [];
        data.step = 1;
        initGroupOptions();
      }
    };

    const handleSearch = async (val:any) => {
      try {
        const imResponse:any = await TUIServer.getUserProfile([val]);
        if (imResponse.data.length === 0) {
          return TUIMessage({ message: t('TUISearch.该用户不存在') });
        }
        const isCurrent = data.searchUserList.filter((item:any) => item.userID === imResponse.data[0].userID);
        if (isCurrent.length === 0) {
          (data.searchUserList as any).push(imResponse.data[0]);
        }
      } catch (error) {
        TUIMessage({ message: t('TUISearch.该用户不存在') });
      }
    };

    const submit = (userList: any) =>  {
      if  (data.createConversationType  === constant.typeC2C)  {
        const { userID } = userList[0];
        handleCurrentConversation(userID, 'C2C');
        toggleOpen();
      } else  {
        if (!CreateGroup.TUIServer) {
          TUIMessage({ message: t('TUISearch.创建群聊，请注册 TUIGroup 模块') });
        }
        initGroupOptions();
        data.group.memberList = userList.map((item:any) => ({ userID: item.userID }));
        data.step = 2;
      }
    };

    // creating group
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
        TUIMessage({ message: t('TUISearch.创建成功') });
        VuexStore.commit('handleTask', 3);
        toggleOpen();
        if (params.type === TUIServer.TUICore.TIM.TYPES.GRP_AVCHATROOM) {
          GroupServer.joinGroup({
            groupID: imResponse.data.group.groupID,
            applyMessage: '',
            type: imResponse.data.group.type,
          });
        }
        handleCurrentConversation(imResponse.data.group.groupID, 'GROUP');
      } catch (imError:any) {
        TUIMessage({ message: imError });
      }
    };

    const handleCurrentConversation = (id: string, type: string) => {
      const name = `${type}${id}`;
      TUIServer.getConversationProfile(name).then((imResponse:any) => {
        // 通知 TUIConversation 模块切换当前会话
        // Notify TUIConversation to toggle the current conversation
        TUIServer.TUICore.TUIServer.TUIConversation.handleCurrentConversation(imResponse.data.conversation);
        TUIAegis.getInstance().reportEvent({
          name: 'conversationType',
          ext1: type === 'C2C' ? 'TypeC2C-success' : 'TypeGroup-success',
        });
      });
    };

    const showOpen  = (type: string) => {
      data.open = true;
      TUIAegis.getInstance().reportEvent({
        name: 'conversationType',
        ext1: 'createConversation',
      });
      switch (type) {
        case 'isC2C':
          data.createConversationType = constant.typeC2C;
          data.showTitle = t('TUISearch.发起单聊');
          return data.showTitle;
        case 'isGroup':
          data.createConversationType = constant.typeGroup;
          data.showTitle = t('TUISearch.发起群聊');
          return data.showTitle;
      }
    };

    const toggleOptionalShow = ()=> {
      if (data.env.isH5) {
        data.optionalShow = !data.optionalShow;
      }
    };
    return {
      ...toRefs(data),
      toggleOpen,
      handleSearch,
      submit,
      create,
      showOpen,
      toggleOptionalShow,
      dialog,
    };
  },
});
export default TUISearch;
</script>

<style lang="scss" scoped src="./style/index.scss"></style>
