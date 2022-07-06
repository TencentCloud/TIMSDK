<template>
  <TUIGroupManage class="setting"  :conversation="conversation" :userInfo="userInfo" />
</template>
<script lang="ts">
import TUIGroupManage from "./manage-components/manage.vue";
import { defineComponent, reactive, toRefs, computed } from 'vue';
import store from '../../TUICore/store';

const TUIConversation = defineComponent({
  name: "TUIConversation",
  components: {
    TUIGroupManage,
  },

  setup(props) {
    const timStore = store.state.timStore;
    const data: any = reactive({
      conversation: computed(() => timStore.conversation),
      userInfo: {
        isGroup: false,
        list: [],
      },
    });
    return {
      ...toRefs(data),
    };
  },
});
export default TUIConversation;
</script>

<style lang="scss" scoped>
.title-container {
  width: 100%;
  display: flex;
  justify-content: center;
  padding: 34px 0px 0px;
  font-size: 17px;
}

.icon-container {
  width: 66px;
  display: flex;
  justify-content: center;
  padding: 34px 0 0 0;

  .add-icon-image {
    width: 24px;
    height: 24px;
  }

  &.right-icon-container {
    position: relative;
    left: 20px;
  }
}

.chat-container {
  display: flex;
  align-items: center;
  margin-bottom: 16px;
  color: #444444;

  .item-icon {
    display: inline-block;
    width: 21px;
    height: 21px;
    margin-right: 12px;
  }
}
</style>
