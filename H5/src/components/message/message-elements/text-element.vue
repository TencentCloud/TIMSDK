<template>
  <div class="text-element-wrapper" :class="isMine ? 'element-send' : 'element-received'">
    <div class="text-element">
      <template v-for="(item, index) in contentList">
        <span :key="index" v-if="item.name === 'text'">{{ item.text }}</span>
        <img v-else-if="item.name === 'img'" :src="item.src" width="20px" height="20px" :key="index" />
      </template>
    </div>
  </div>
</template>

<script>
import { decodeText } from '../../../utils/decodeText'

export default {
  name: 'TextElement',
  props: {
    payload: {
      type: Object,
      required: true
    },
    isMine: {
      type: Boolean
    }
  },
  computed: {
    contentList() {
      return decodeText(this.payload)
    }
  }
}
</script>

<style scoped>
.text-element-wrapper {
  position: relative;
  max-width: 300px;
  border: 1px solid rgb(235, 235, 235);
  border-radius: 3px;
  word-break: break-word;
}
.text-element {
  padding: 6px;
}
.element-received {
  background-color: #fff;
}
.element-send {
  background: rgb(5, 185, 240);
}
</style>
