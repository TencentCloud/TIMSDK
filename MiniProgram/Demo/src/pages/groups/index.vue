<template>
  <div class="container">
    <div class="group" v-for="item in groupList" :key="item.groupID" @click="startConversation(item)">
      <div class="avatar">
        <i-avatar i-class="img" :src="item.avatar"/>
      </div>
      <div class="name">
        {{item.name}}
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
export default {
  data () {
    return {
    }
  },
  computed: {
    ...mapState({
      groupList: state => {
        return state.group.groupList
      }
    })
  },
  methods: {
    startConversation (item) {
      this.$store.dispatch('checkoutConversation', `GROUP${item.groupID}`)
    }
  }
}
</script>

<style lang='stylus'>
.container
  background-color $background
  min-height 100vh
  .group
    height 50px
    background-color white
    box-sizing border-box
    border-bottom 1px solid $border-base
    display flex
    padding 10px 20px
    .avatar
      width 60px
      .img
        width 30px
        height 30px
.name
  line-height 30px
  width 100%
  overflow hidden
  text-overflow ellipsis
  white-space nowrap
.type
  line-height 30px
</style>
