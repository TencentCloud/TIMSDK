<template>
  <div class="custom-element-wrapper">
    <span class="iconfont dice" :class="`icon-dice${payload.description}`" v-if="isDice"></span>
    <span v-else>{{text}}</span>
  </div>
</template>

<script>
export default {
  name: 'CustomElement',
  props: {
    payload: {
      type: Object,
      required: true
    }
  },
  computed: {
    text() {
      return this.translateCustomMessage(this.payload)
    },
    isDice() {
      return this.payload.data === 'dice'
    }
  },
  methods: {
    translateCustomMessage(payload) {
      if (payload.data === 'group_create') {
        return `${payload.extension}`
      }
      return '[自定义消息]'
    }
  }
}
</script>

<style scoped>
.dice {
  font-size: 32px;
  color: #fff;
  background: #000;
}
</style>
