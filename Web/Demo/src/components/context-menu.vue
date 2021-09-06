<template>
  <popover
    placement="top"
    style="display: flex;flex-direction: column;"
    v-model="visible"
  >
    <el-button class="context-menu-button" type="text" @click="option.handler" v-for="option in options" :key="option.text">{{options.text}}</el-button>
    <el-button class="context-menu-button" type="text" @click="visible = false ">取消</el-button>
    <slot slot="reference" @contextmenu.prevent=""></slot>
  </popover>
</template>

<script>
import { Popover } from 'element-ui'
export default {
  props: ['visible', 'options'],
  components: {
    Popover
  }
}
</script>

<style lang="stylus" scoped>
</style>
