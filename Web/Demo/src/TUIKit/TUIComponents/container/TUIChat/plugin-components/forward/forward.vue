<template>
<div>
  <p @click="toggleShow">{{$t('TUIChat.转发')}}</p>
  <div class="forward dialog" v-if="show" ref="dialog">
    <Transfer
      :list="list"
      :isSearch="false"
      :isCustomItem = "true"
      @submit="handleForWordMessage"
      @cancel="toggleShow">
      <template #item="{data}">
        <slot name="item" :data="data" />
      </template>
      </Transfer>
  </div>
</div>
</template>

<script lang="ts">
import { defineComponent, reactive, watchEffect, toRefs, ref } from 'vue';
import Transfer from '../../../../components/transfer/index.vue';
import TUIMessage from '../../../../components/message';
import { onClickOutside } from '@vueuse/core';

const Forward = defineComponent({
  components: {
    Transfer,
  },
  name: '转发',
  props: {
    list: {
      type: Array,
      default: () => [],
    },
    message: {
      type: Object,
      default: () => ({}),
    },
    show: {
      type: Boolean,
      default: () => false,
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      list: [],
      show: false,
      to: -1,
    });

    const dialog:any = ref();

    watchEffect(() => {
      data.list = props.list;
      data.show = props.show;
    });

    const toggleShow = () => {
      data.show = !data.show;
      if (!data.show) {
        ctx.emit('update:show', data.show);
        data.to = -1;
      }
    };

    onClickOutside(dialog, () => {
      data.show = false;
      ctx.emit('update:show', data.show);
      data.to = -1;
    });

    const handleForWordMessage = async (list:any) => {
      list.map(async (item:any) => {
        try {
          await Forward.TUIServer.forwardMessage(props.message, item);
        } catch (error) {
          TUIMessage({ message: error });
        }
      });
      toggleShow();
    };

    return {
      ...toRefs(data),
      toggleShow,
      handleForWordMessage,
      dialog,
    };
  },
});
export default Forward;
</script>

<style lang="scss" scoped>
.forward {
  position: absolute;
  z-index: 5;
  background: #fff;
  box-sizing: border-box;
  border: 1px solid #dddddd;
  padding: 15px 20px;
  padding: 0;
  width: 450px;
  height: 400px;
  top: -50px;
  left: 0;
  display: flex;
  flex-direction: column;
  justify-content: center;
  box-shadow: 0 11px 20px 0 rgba(0,0,0, .3);
  header {
    padding: 20px;
    display: flex;
    justify-content: space-between;
  }
  .list {
    box-sizing: border-box;
    margin: 0;
    padding: 20px;
    width: 100%;
    height: 100%;
    background: #ffffff;
    overflow-y: auto;
    list-style: none;
    &-item {
      display: flex;
      align-items: center;
      padding: 10px;
      &:hover {
        background: #dddddd;
      }
      .avatar {
        width: 36px;
        height: 36px;
      }
    }
  }
  footer {
    display: flex;
    justify-content: space-around;
    padding: 20px 0;
  }
}
</style>
