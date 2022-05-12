<template>
  <div class="revoke">
    <label v-if="message.flow === 'in'">{{message.nick || message.from}}</label>
    <label v-else>{{$t('TUIChat.您')}}</label>
    <span>{{$t("TUIChat.撤回了一条消息")}}</span>
    <span class="edit" v-if="message.flow === 'out'&&isEdit" @click="edit">{{$t('TUIChat.重新编辑')}}</span>
  </div>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';

export default defineComponent({
  props: {
    data: {
      type: Object,
      default: () => ({}),
    },
    isEdit: {
      type: Boolean,
      default: () => false,
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      message: {},
      isEdit: false,
    });

    watchEffect(() => {
      data.message = props.data;
      data.isEdit = props.isEdit;
    });

    const edit = () => {
      ctx.emit('edit', data.message);
    };

    return {
      ...toRefs(data),
      edit,
    };
  },
});
</script>
<style lang="scss" scoped>
.revoke {
  display: flex;
  justify-content: center;
  color: #999999;
  width: 100%;
  font-size: 14px;
  .edit {
    padding: 0 5px;
    color: #006EFF;
  }
}
</style>
