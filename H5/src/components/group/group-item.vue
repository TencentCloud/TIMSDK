<template>
  <div @click="handleGroupClick" class="scroll-container">
    <div class="group-item">
      <avatar :src="group.avatar" />
      <div class="group-name text-ellipsis">{{ group.name }}</div>
    </div>
  </div>
</template>

<script>
export default {
  props: ['group'],
  data() {
    return {
      visible: false,
      options: [
        {
          text: '退出群组',
          handler: this.quitGroup
        }
      ]
    }
  },
  methods: {
    handleGroupClick() {
      const conversationID = `GROUP${this.group.groupID}`
      this.$store.dispatch('checkoutConversation', conversationID)
    },
    quitGroup() {
      this.tim.quitGroup(this.group.groupID)
    }
  }
}
</script>

<style lang="stylus" scoped>
.scroll-container
  overflow-y scroll
  flex 1
  .group-item
    display flex
    padding 10px 20px
    cursor pointer
    position relative
    overflow hidden
    transition .2s
    &:hover
      background-color $background
    .avatar
      width 30px
      height 30px
      border-radius 50%
      margin-right 10px
      flex-shrink 0
    .group-name
      flex 1
      color $font-light
      line-height 30px
</style>
