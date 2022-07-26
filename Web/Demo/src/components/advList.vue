<template>
  <ul class="adv-list">
    <li v-for="(item, index) of list" :key="index" :item="item" >
      <slot name="item" :data="item" />
    </li>
  </ul>
</template>

<script lang="ts">
import { defineComponent, reactive, toRefs, watchEffect } from 'vue';

export default defineComponent({
  props: {
    list: {
      type: Object,
      default: () => ({}),
    },
  },

  setup(props:any, ctx:any) {
    const obj = reactive({
      data: {},
    });

    watchEffect(() => {
      obj.data = props.data;
    });

    return {
      ...toRefs(obj),
    };
  },
});
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.adv-list {
  justify-content: center;
  flex: 1;
  display: flex;
    li {
      padding: 0 5rem;
      width: 90px;
      height: 82px;
    }
}
</style>
