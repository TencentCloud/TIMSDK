<template>
  <div class="qr-code-list-wrapper">
    <div class="header">
      其他体验方式 |
      <a
        href="https://cloud.tencent.com/product/im"
        class="link"
        target="_blank"
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
        <img
                src="https://upload-dianshi-1255598498.file.myqcloud.com/gh_47854f5a3fb8_258-b007e3dc9f40667fdcfcac4c4476c7ce276c7d0e.jpg"
        />
        <div class="text">直播电商解决方案</div>
      </div>
      <div class="qr-code-item">
        <img src="https://main.qcloudimg.com/raw/73daa40cef967ba415cdba2cabf4bdc7.png" />
        <div class="text">iOS</div>
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

export default {
  name: 'qr-code-list',
  mounted() {
  },
  methods: {

  }
}
</script>

<style scoped>
.qr-code-list-wrapper {
  /*width: 400px;*/
}
.header {
  color: #fff;
  margin: 16px 0;
}
.link {
  color: #38c9ff;
  text-decoration: none;
}
.qr-code-wrapper {
  display: flex;
  justify-content: space-between;
}
.qr-code-item {
 margin-right: 20px;
}

.qr-code-item .text {
  font-size: 15px;
  text-align: center;
  color: #fff;
}
.qr-code-item img {
  width: 120px;
  height: 120px;
  border-radius: 5px;
}
</style>
