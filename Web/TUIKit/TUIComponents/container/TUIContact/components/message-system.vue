<template>
  <div class="message-system">
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
<style lang="scss" scoped>
.message-system {
  flex: 1;
}
.list {
  flex: 1;
  height: 100%;
  overflow-y: auto;
  min-width: 600px;
  li {
    display: flex;
    align-items: center;
    position: relative;
    padding:10px 20px;
    font-weight: 400;
    font-size: 14px;
    color: #000000;
    letter-spacing: 0;
    .icon {
      margin-right: 10px;
      border-radius: 100%;
    }
    .message-label {
      max-width: 50px;
    }
    .btn-box {
      padding: 0 12px;
    }
  }
}
.icon {
  display: inline-block;
  width: 16px;
  height: 16px;
  &-warn {
    border-radius: 50%;
    background: coral;
    color: #FFFFFF;
    font-style: normal;
    display: flex;
    justify-content: center;
    align-items: center;
  }
}
.btn {
  padding: 2px 10px;
  margin-right: 12px;
  border-radius: 4px;
  border: none;
  font-weight: 400;
  font-size: 14px;
  color: #FFFFFF;
  letter-spacing: 0;
  text-align: center;
  line-height: 20px;
  &:last-child {
    margin-right: 0;
  }
  &-cancel {
    border: 1px solid #dddddd;
    color: #666666;
  }
  &-default {
    background: #006EFF;
    border: 1px solid #006EFF;
  }
  &:disabled {
    opacity: 0.3;
  }
}
</style>
