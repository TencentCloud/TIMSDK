<template>
  <div class="face-element-wrapper">
    <img :src="url" style="height:90px; width:90px"/>
  </div>
</template>

<script>
export default {
  name: 'FaceElement',
  props: {
    payload: {
      type: Object,
      required: true
    }
  },
  computed:{
    url() {
      return `https://imgcache.qq.com/open/qcloud/tim/assets/face-elem/${this.payload.data}.png`
    }
  }
}
</script>

<style>
</style>