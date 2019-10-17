<template>
  <div class="group-tip-element-wrapper">{{text}}</div>
</template>

<script>
export default {
  name: 'GroupTipElement',
  props: {
    payload: {
      type: Object,
      required: true
    }
  },
  computed: {
    text() {
      return this.getGroupTipContent(this.payload)
    }
  },
  methods: {
    getGroupTipContent(payload) {
      switch (payload.operationType) {
        case this.TIM.TYPES.GRP_TIP_MBR_JOIN:
          return `群成员：${payload.userIDList.join(',')}，加入群组`
        case this.TIM.TYPES.GRP_TIP_MBR_QUIT:
          return `群成员：${payload.userIDList.join(',')}，退出群组`
        case this.TIM.TYPES.GRP_TIP_MBR_KICKED_OUT:
          return `群成员：${payload.userIDList.join(',')}，被${
            payload.operatorID
          }踢出群组`

        case this.TIM.TYPES.GRP_TIP_MBR_SET_ADMIN:
          return `群成员：${payload.userIDList.join(',')}，成为管理员`
        case this.TIM.TYPES.GRP_TIP_MBR_CANCELED_ADMIN:
          return `群成员：${payload.userIDList.join(',')}，被撤销管理员`
        default:
          return '[群提示消息]'
      }
    }
  }
}
</script>

<style lang="stylus" scoped>
.group-tip-element-wrapper
  background $white
  padding 4px 15px
  border-radius 3px
  color $secondary
  font-size 12px
  // text-shadow $secondary 0 0 0.05em
</style>
