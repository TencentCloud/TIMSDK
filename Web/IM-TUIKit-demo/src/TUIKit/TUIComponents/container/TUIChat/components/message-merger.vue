<template>
  <div class="message-merger">
    <div class="merger-box" :data-value="data.message">
        <p class="merger-title">{{data.title}}</p>
        <p class="merger-text" v-for="(item, index) in data.abstractList" :key="index">
            {{item}}
        </p>
    </div>
    <span class="merger-label"> 聊天记录</span>
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
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      data: {},
    });

    watchEffect(() => {
      data.data = props.data;
    });
    return {
      ...toRefs(data),
    };
  },
});
</script>
<style lang="scss" scoped>
.message-merger {
  display: flex;
  flex-direction: column;
  .merger-label {
      border-top: 1px solid #dddddd;
      margin-top: 10px;
      padding-top: 5px;
  }
}
</style>
