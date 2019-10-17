<template>
  <div>
    <el-image
      class="avatar"
      :class="shape"
      v-if="src"
      :src="src"
    >
      <div class="avatar" slot="error">{{text[0]}}</div>
    </el-image>
    <div
      class="avatar"
      :style="{width: width + 'px',height: height + 'px', lineHeight: height + 'px'}"
      :class="shape"
      v-else
    >{{text?text[0]:'E'}}</div>
  </div>
</template>

<script>
import { Image } from 'element-ui'
export default {
  props: {
    src: String,
    text: {
      type: String,
      default: 'U'
    },
    shape: {
      type: String,
      default: 'circle'
    },
    width: {
      type: Number,
      default: 30
    },
    height: {
      type: Number,
      default: 30
    }
  },
  components: {
    ElImage: Image
  }
}
</script>

<style lang="stylus" scoped>
.avatar {
  display: block;
  background-color: $first;
  color: $white;
  text-align: center;
  line-height: 30px;
}
.circle {
  border-radius: 50%;
}
.square {
  border-radius: 3px;
}
</style>
