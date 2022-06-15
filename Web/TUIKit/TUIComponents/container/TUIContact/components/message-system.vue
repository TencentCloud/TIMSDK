<template>
  <div class="message-system" :class="[ isH5 ? 'message-system-h5' : '']">
    <ul class="list">
      <li v-for="(item, index) in messageList" :key="index">
        <template v-if="item.type === types.MSG_GRP_TIP || item.type === types.MSG_GRP_SYS_NOTICE">
          <i class="icon icon-system"></i>
          <span>{{translateGroupSystemNotice(item)}}</span>
          <div class="btn-box" v-if="item?.payload?.operationType === 1">
            <button v-if="!item.isHandle" class="btn btn-default" @click="handleApplication('Agree', item)">{{$t('TUIContact.接受')}}</button>
            <button v-if="!item.isHandle" class="btn btn-cancel" @click="handleApplication('Reject', item)">{{$t('TUIContact.拒绝')}}</button>
            <span v-else>{{$t('TUIContact.已处理')}}</span>
          </div>
        </template>
      </li>
    </ul>
  </div>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';
import { translateGroupSystemNotice } from '../../utils';

export default defineComponent({
  props: {
    data: {
      type: Array,
      default: () => [],
    },
    types: {
      type: Object,
      default: () => ({}),
    },
    isH5: {
      type: Boolean,
      default: false,
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      messageList: [],
      types: {},
      isHandle: false,
    });

    watchEffect(() => {
      (data.messageList as any) = props.data;
      data.types = props.types;
    });

    const handleApplication = (handleAction:string, message:any) => {
      const options:any = {
        handleAction,
        message,
      };
      ctx.emit('application', options);
      message.isHandle = true;
    };

    return {
      ...toRefs(data),
      translateGroupSystemNotice,
      handleApplication,
    };
  },
});
</script>
<style lang="scss" scoped src="./style/index.scss"></style>
