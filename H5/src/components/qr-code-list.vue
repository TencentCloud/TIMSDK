<template>
  <div class="qr-code-list-wrapper">
    <div class="header">
      其他体验方式 |
      <a
        href="https://cloud.tencent.com/product/im"
        class="link"
        target="_blank"
        @click="handlClick"
      >访问官网</a>
    </div>
    <div class="qr-code-wrapper">
      <div class="qr-code-item">
        <img
          src="https://cloudcache.tencent-cloud.com/open_proj/proj_qcloud_v2/gateway/product/im-new/css/img/applets.png"
        />
        <div class="text">小程序</div>
      </div>
      <div class="qr-code-item">
        <img src="https://main.qcloudimg.com/raw/03ed2f2cb4101d97e234c911b060717a.png" />
        <div class="text">iOS(密码：123)</div>
      </div>
      <div class="qr-code-item">
        <img
          src="https://cloudcache.tencent-cloud.com/open_proj/proj_qcloud_v2/gateway/product/im-new/css/img/android.png"
        />
        <div class="text">Android</div>
      </div>
    </div>
  </div>
</template>

<script>
import MTA from '../utils/mta'

export default {
  name: 'qr-code-list',
  mounted() {
    MTA.clickStat('link_one', { show: 'true' })
  },
  methods: {
    handlClick() {
      MTA.clickStat('link_one', { click: 'true' })
    }
  }
}
</script>

<style scoped>
.qr-code-list-wrapper {
  width: 400px;
  margin-top: 60px;
}
.header {
  color: #fff;
  margin-bottom: 16px;
}
.link {
  color: #38c9ff;
  text-decoration: none;
}
.qr-code-wrapper {
  display: flex;
  justify-content: space-between;
}
.qr-code-item .text {
  text-align: center;
  color: #fff;
}
.qr-code-item img {
  width: 120px;
  height: 120px;
  border-radius: 5px;
}
</style>