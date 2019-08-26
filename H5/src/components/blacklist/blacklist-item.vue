<template>
  <div class="blacklist-item-wrapper">
    <avatar :src="profile.avatar" text="F" />
    <div>{{profile.nick||profile.userID}}</div>
    <el-button type="text" @click="removeFromBlacklist">取消拉黑</el-button>
  </div>
</template>

<script>
export default {
  name: 'BlacklistItem',
  props: {
    profile: {
      type: Object,
      required: true
    }
  },
  methods: {
    removeFromBlacklist() {
      this.tim
        .removeFromBlacklist({ userIDList: [this.profile.userID] })
        .then(() => {
          this.$store.commit('removeFromBlacklist', this.profile.userID)
        })
    }
  }
}
</script>

<style scoped>
.blacklist-item-wrapper {
  display: flex;
  align-items: center;
  justify-content: space-evenly;
}
</style>
