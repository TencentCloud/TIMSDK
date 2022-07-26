<template>
  <span class="upload-btn icon icon-image">
      <input title="图片" v-if="!isMute" type="file" data-type="image" accept="image/*" @change="sendUploadMessage" />
      <slot />
  </span>
</template>

<script lang="ts">
import TUIAegis from '../../../../../utils/TUIAegis';
import { defineComponent, reactive, toRefs, watchEffect } from 'vue';
import { handleErrorPrompts } from '../../../utils';

const Image = defineComponent({
  props: {
    show: {
      type: Boolean,
      default: () => false,
    },
    isMute: {
      type: Boolean,
      default: () => false,
    },
    isH5: {
      type: Boolean,
      default: () => false,
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      isMute: false,
    });

    watchEffect(() => {
      data.isMute = props.isMute;
    });
    // 发送需要上传的消息：图片
    const sendUploadMessage = async (e:any) => {
      if (e.target.files.length > 0) {
        try {
          await Image.TUIServer.sendImageMessage(e.target);
          TUIAegis.getInstance().reportEvent({
            name: 'messageType',
            ext1: 'typeImage',
          });
        } catch (error) {
          handleErrorPrompts(error, props);
        }
      }
      e.target.value = '';
    };

    return {
      ...toRefs(data),
      sendUploadMessage,
    };
  },
});
export default Image;
</script>

<style lang="scss" scoped>
.upload-btn {
  position: relative;
  input {
    position: absolute;
    cursor: pointer;
    left: 0;
    top: 0;
    opacity: 0;
    width: 100%;
    height: 100%;
  }
}
</style>
