<template>
  <view class="face">
      <view class="icon icon-face" @click="toggleShow"></view>
      <view class="face-main"  v-show="show" ref="dialog">
				<view class="face-main-box"  v-for="(item, index) in list" :key="index">
					<view class="face-list"  v-if="currentIndex === index">
					  <view  class="face-list-item" v-for="(childrenItem, childrenIndex) in item" :key="childrenIndex" @click="select(childrenItem, childrenIndex)">
					    <image class="emo-image"   v-if="index === 0" :src="emojiUrl + emojiMap[childrenItem]"></image>
					    <image class="face-img" v-else :src="faceUrl + childrenItem + '@2x.png'"></image>
					  </view>
					</view>
				</view>
       
      <view class="face-tab">
         <view  class="face-tab-item" @click="selectFace(0)">
           <view class="icon icon-face"></view>
         </view>
         <view  class="face-tab-item" v-for="(item, index) in bigEmojiList" :key="index" @click="selectFace(index+1)">
           <image class="face-icon"  :src="faceUrl + item.icon + '@2x.png'"></image>
         </view>
      					<view class="send-btn" @click="handleSendEmoji">发送</view>
       </view>
      </view>
  </view>
</template>

<script lang="ts">
import { defineComponent, reactive, watchEffect, toRefs, computed, ref } from 'vue';
import { emojiUrl, emojiMap, emojiName, faceUrl, bigEmojiList } from "@/pages/TUIKit/utils/emojiMap";

// import TUIMessage from '../../../../components/message';
// import { onClickOutside } from '@vueuse/core';

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

    // onClickOutside(dialog, () => {
    //   data.show = false;
    // });

    const select = async (item:string, index?:number) => {
      const options:any = {
        name: item,
      };
			
      if (data.currentIndex === 0) {
        options.type = 'emo';
        options.url = emojiUrl + emojiMap[item];
        options.template = `<image src="${emojiUrl + emojiMap[item]}"></image>`;
        // toggleShow();
        return ctx.emit('send', options);
      }
      try {
        await uni.$TUIKit.TUIChatServer.sendFaceMessage({
          index,
          data: item,
        });
      } catch (error) {
      //   TUIMessage({ message: error });
       }
      // toggleShow();
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
    const handleSendEmoji = () => {
			return ctx.emit('handleSendEmoji')
		};
    return {
      ...toRefs(data),
      toggleShow,
      select,
      selectFace,
      list,
      dialog,
			handleSendEmoji,
    };
  },
});
export default Face;
</script>

<style lang="scss" scoped>
.face {
  position: relative;
  cursor: pointer;
	width: 100%;
	height: 100%;
  &-main {
    position: absolute;
    // z-index: 5;
    width: 100%;
    height: 100%;
    background: #ffffff;
    box-shadow: 0 2px 12px 0 rgb(0 0 0 / 10%);
    // padding: 10px;
     display: flex;
    flex-direction: column;
  }
	&-main-box {
		width: 100%;
		height: 80%;
		box-shadow: 0 2px 12px 0 rgb(0 0 0 / 10%);
		display: flex;
		flex-direction: column;
	}
  &-list {
    flex: 1;
    display: flex;
    flex-wrap: wrap;
    overflow-y: auto;
		justify-content: center;
    &-item {
      padding: 5px;
			.emo-image {
				display: block;
			  height: 30px;
				width: 30px;
			}
    }
    .face-img {
			display: block;
      width: 60px;
			height: 60px;
    }
  }
  &-tab {
    display: flex;
    align-items: center;
    &-item {
      padding: 8px;
			.face-icon {
				display: block;
				height: 30px;
				width: 30px;
			}
      img {
        width: 30px;
      }
    }
		.send-btn {
			position: absolute;
			background-color: #55C06A;
			color: #ffffff;
			line-height: 30px;
			font-size: 13px;
			text-align: center;
			width: 50px;
			height: 30px;
			right: 0;
			bottom: 10px;
		}
  }
}
</style>
