<template>
  <div class="face">
      <i class="icon icon-face" title="表情" @click="toggleShow"></i>
      <main class="face-main"  v-show="show" ref="dialog">
         <ul class="face-list" v-for="(item, index) in list" :key="index" v-show="currentIndex === index">
          <li  class="face-list-item" v-for="(childrenItem, childrenIndex) in item" :key="childrenIndex" @click="select(childrenItem, childrenIndex)">
            <img v-if="index === 0" :src="emojiUrl + emojiMap[childrenItem]">
            <img class="face-img" v-else :src="faceUrl + childrenItem + '@2x.png'">
          </li>
        </ul>
        <ul class="face-tab">
          <li  class="face-tab-item" @click="selectFace(0)">
            <i class="icon icon-face"></i>
          </li>
          <li  class="face-tab-item" v-for="(item, index) in bigEmojiList" :key="index" @click="selectFace(index+1)">
            <img :src="faceUrl + item.icon + '@2x.png'">
          </li>
        </ul>
      </main>
  </div>
</template>

<script lang="ts">
import { defineComponent, reactive, watchEffect, toRefs, computed, ref } from 'vue';
import { emojiUrl, emojiMap, emojiName, faceUrl, bigEmojiList } from '../../untils/emojiMap';
import TUIMessage from '../../../../components/message';
import { onClickOutside } from '@vueuse/core';

const Face = defineComponent({
  props: {
    show: {
      type: Boolean,
      default: () => false,
    },
    isMute: {
      type: Boolean,
      default: () => false,
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      emojiUrl,
      emojiMap,
      emojiName,
      faceUrl,
      bigEmojiList,
      show: false,
      currentIndex: 0,
      isMute: false,
    });

    const dialog:any = ref();

    watchEffect(() => {
      data.show = props.show;
      data.isMute = props.isMute;
    });

    const toggleShow = () => {
      if (!data.isMute) {
        data.show = !data.show;
      }
      if (!data.show) {
        selectFace(0);
      }
    };

    onClickOutside(dialog, () => {
      data.show = false;
    });

    const select = async (item:string, index?:number) => {
      const options:any = {
        name: item,
      };
      if (data.currentIndex === 0) {
        options.type = 'emo';
        options.url = emojiUrl + emojiMap[item];
        options.template = `<img src="${emojiUrl + emojiMap[item]}">`;
        toggleShow();
        return ctx.emit('send', options);
      }
      try {
        await Face.TUIServer.sendFaceMessage({
          index,
          data: data.bigEmojiList[data.currentIndex - 1].icon,
        });
      } catch (error) {
        TUIMessage({ message: error });
      }
      toggleShow();
    };

    const list = computed(() => {
      const emjiList = [data.emojiName];
      for (let i = 0; i < data.bigEmojiList.length; i++) {
        emjiList.push(data.bigEmojiList[i].list);
      }
      return emjiList;
    });

    const selectFace = (index:number) => {
      data.currentIndex = index;
    };

    return {
      ...toRefs(data),
      toggleShow,
      select,
      selectFace,
      list,
      dialog,
    };
  },
});
export default Face;
</script>

<style lang="scss" scoped>
.face {
  display: inline-block;
  position: relative;
  cursor: pointer;
  &-main {
    position: absolute;
    z-index: 5;
    width: 435px;
    height: 250px;
    background: #ffffff;
    top: -270px;
    box-shadow: 0 2px 12px 0 rgba(0,0,0, .1);
    padding: 10px;
    display: flex;
    flex-direction: column;
  }
  &-list {
    flex: 1;
    display: flex;
    flex-wrap: wrap;
    overflow-y: auto;
    &-item {
      padding: 5px;
    }
    img {
      width: 30px;
    }
    .face-img {
      width: 60px;
    }
  }
  &-tab {
    display: flex;
    align-items: center;
    &-item {
      padding: 0 10px;
      img {
        width: 30px;
      }
    }
  }
}
</style>
