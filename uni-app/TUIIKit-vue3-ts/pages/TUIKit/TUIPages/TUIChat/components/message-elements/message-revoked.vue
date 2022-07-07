<template>
  <div class="revoke">
    <label v-if="message.flow === 'in'">{{message.nick || message.from  }}</label>
    <label v-else>你</label>
    <span>撤回了一条消息</span>
    <span class="edit" v-if="message.flow === 'out'" @click="edit">重新编辑</span>
  </div>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';

const MessageRevoked = defineComponent({
  props: {
    data: {
      type: Object,
      default: () => {
        return {};
      }
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      message: {},
    });

    watchEffect(()=>{
      data.message = props.data;
    });

    const edit = () => {
      ctx.emit('edit', data.message);
    };

    return {
      ...toRefs(data),
      edit
    };
  }
});
export default MessageRevoked
</script>
<style lang="scss" scoped>
.revoke {
  display: flex;
  justify-content: center;
  color: #999999;
  width: 100%;
	font-size: 13px;
	padding: 5px;
  .edit {
    padding: 0 5px;
    color: #006EFF;
  }
}
</style>
