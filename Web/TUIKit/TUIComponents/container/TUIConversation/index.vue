<template>
<div class="TUI-conversation">
    <div class="network" v-if="isNetwork">
      <i class="icon icon-error">!</i>
      <p>️{{$t('TUIConversation.网络异常，请您检查网络设置')}}</p>
    </div>
    <main class="TUI-conversation-list">
      <TUIConversationList
        :currentID="currentConversationID"
        :data="conversationData"
        @handleItem="handleCurrentConversation"
        :isH5="env.isH5"
        />
    </main>
</div>
</template>
<script lang="ts">
import { defineComponent, reactive, toRefs, computed, watch } from 'vue';
import TUIConversationList from './components/list';
import { caculateTimeago } from '../utils';
import { handleAvatar, handleName, handleShowLastMessage, handleAt } from '../TUIChat/utils/utils';

const TUIConversation = defineComponent({
  name: 'TUIConversation',

  components: {
    TUIConversationList,
  },

  setup(props: any, ctx: any) {
    const TUIServer:any = TUIConversation?.TUIServer;
    const data = reactive({
      currentConversationID: '',
      conversationData: {
        list: [],
        handleItemAvator: (item: any) => handleAvatar(item),
        handleItemName: (item: any) => handleName(item),
        handleShowAt: (item: any) => handleAt(item),
        handleShowMessage: (item: any) => handleShowLastMessage(item),
        handleItemTime: (time: number) => {
          if (time > 0) {
            return caculateTimeago(time * 1000);
          }
          return '';
        },
      },
      netWork: '',
      env: TUIServer.TUICore.TUIEnv,
    });

    TUIServer.bind(data);

    TUIConversationList.TUIServer = TUIServer;

    watch(() => data.currentConversationID, (newVal: any, oldVal: any) => {
      ctx.emit('current', newVal);
    }, {
      deep: true,
    });

    const isNetwork = computed(() => {
      const disconnected = data.netWork === TUIServer.TUICore.TIM.TYPES.NET_STATE_DISCONNECTED;
      const connecting = data.netWork === TUIServer.TUICore.TIM.TYPES.NET_STATE_CONNECTING;
      return  disconnected || connecting;
    });

    const handleCurrentConversation = (value: any) => {
      TUIServer.handleCurrentConversation(value);
    };

    return {
      ...toRefs(data),
      handleCurrentConversation,
      isNetwork,
    };
  },
});
export default TUIConversation;
</script>

<style lang="scss" scoped src="./style/index.scss"></style>
