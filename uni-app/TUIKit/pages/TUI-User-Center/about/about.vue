<template>
  <!--miniprogram/pages/about/about.wxml-->
  <view class="container">
    <view class="title"></view>
    <view class="list">
      <view
        v-for="(item, index) in list"
        :key="index"
        class="list-item"
        :data-item="item"
        @tap="handleRouter"
      >
        <view class="aside-left">
          <text>{{ item.name }}</text>
        </view>
        <image
          v-if="item.path"
          class="icon aside-right"
          src="/static/static/images/right.png"
          lazy-load="true"
        ></image>
        <text v-else>{{ item.value }}</text>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      list: [
        {
          name: "SDK版本",
          value: uni.$TUIKitVersion,
        },
        {
          name: "注销账户",
          path: "../cancel/cancel",
        },
      ],
    };
  },

  components: {},
  props: {},

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad() {
    console.log("获取当前版本", uni.getAccountInfoSync());
    uni.setNavigationBarTitle({
      title: "关于",
    });
  },

  methods: {
    onBack() {
      uni.navigateBack({
        delta: 1,
      });
    },

    /**
     * 路由跳转
     */
    handleRouter(event) {
      const data = event.currentTarget.dataset.item;

      if (data.name === "注销账户") {
        uni.navigateTo({
          url: "../cancel/cancel",
        });
      }
    },
  },
};
</script>
<style>
@import "./about.css";
</style>
