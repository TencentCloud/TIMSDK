<template>
<view>
  <view v-if="renderDom[0].type ==='order'" :class="'custom-message ' + (isMine?'my-custom':'')">
    <image class="custom-image" :src="renderDom[0].imageUrl"></image>
    <view class="custom-content">
      <view class="custom-content-title">{{renderDom[0].title}}</view>
      <view class="custom-content-description">{{renderDom[0].description}}</view>
      <view class="custom-content-price">{{renderDom[0].price}}</view>
    </view>
  </view>
  <view v-if="renderDom[0].type ==='consultion'" :class="'custom-message ' + (isMine?'my-custom':'')">
    <view class="custom-content">
      <view class="custom-content-title">{{renderDom[0].title}}</view>
      <view v-for="(item, index) in renderDom[0].item" :key="index" class="custom-content-description" :id="item.key">{{item.key}}</view>
      <view class="custom-content-description">{{renderDom[0].description}}</view>
    </view>
  </view>
  <view v-if="renderDom[0].type ==='evaluation'" :class="'custom-message ' + (isMine?'my-custom':'')">
    <view class="custom-content">
      <view class="custom-content-title">{{renderDom[0].title}}</view>
      <view class="custom-content-score">
        <image v-for="(item, index) in renderDom[0].score" :key="index" class="score-star" src="/static/static/images/star.png"></image>
      </view>
      <view class="custom-content-description">{{renderDom[0].description}}</view>
    </view>
  </view>
  <view v-if="renderDom[0].type ==='group_create'" :class="'custom-message ' + (isMine?'my-custom':'')">
    <view class="custom-content-text">{{renderDom[0].text}}</view>
  </view>
  <view v-if="renderDom[0].type ==='notSupport'" class="message-body-span text-message">
    <view class="message-body-span-text">{{renderDom[0].text}}</view>
  </view>
</view>
</template>

<script>

export default {
  data() {
    return {};
  },

  components: {},
  props: {
    message: {
      type: Object,
      default: () => {}
    },
    isMine: {
      type: Boolean,
      default: true
    }
  },
  watch: {
    message: {
      handler: function (newVal) {
        this.setData({
          message: newVal,
          renderDom: this.parseCustom(newVal)
        });
      },
      immediate: true,
      deep: true
    }
  },
  methods: {
    parseCustom(message) {
      // 约定自定义消息的 data 字段作为区分，不解析的不进行展示
      if (message.payload.data === 'order') {
        const extension = JSON.parse(message.payload.extension);
        const renderDom = [{
          type: 'order',
          name: 'custom',
          title: extension.title || '',
          imageUrl: extension.imageUrl || '',
          price: extension.price || 0,
          description: message.payload.description
        }];
        return renderDom;
      } // 客服咨询


      if (message.payload.data === 'consultion') {
        const extension = JSON.parse(message.payload.extension);
        const renderDom = [{
          type: 'consultion',
          title: extension.title || '',
          item: extension.item || 0,
          description: extension.description
        }];
        return renderDom;
      } // 服务评价


      if (message.payload.data === 'evaluation') {
        const extension = JSON.parse(message.payload.extension);
        const renderDom = [{
          type: 'evaluation',
          title: message.payload.description,
          score: extension.score,
          description: extension.comment
        }];
        return renderDom;
      } // 群消息解析


      if (message.payload.data === 'group_create') {
        const renderDom = [{
          type: 'group_create',
          text: message.payload.extension
        }];
        return renderDom;
      }

      return [{
        type: 'notSupport',
        text: '[自定义消息]'
      }];
    }

  }
};
</script>
<style>
@import "./index.css";
</style>
