<template>
  <div>
    <div class="info-item">
      <div class="label">userID</div>
      <div class="content">{{ userProfile.userID }}</div>
    </div>
    <div class="info-item">
      <div class="label">头像</div>
      <div class="content">
        <avatar :src="userProfile.avatar" :text="userProfile.userID" />
      </div>
    </div>
    <div class="info-item">
      <div class="label">昵称</div>
      <div class="content">{{ userProfile.nick || '暂无' }}</div>
    </div>
    <div class="info-item">
      <div class="label">性别</div>
      <div class="content">{{ gender }}</div>
    </div>
    <el-button
      type="text"
      @click="addToBlackList"
      v-if="!isInBlacklist && userProfile.userID !== myUserID"
      style="color:red;"
      >拉黑</el-button
    >
    <el-button type="text" @click="removeFromBlacklist" v-else-if="isInBlacklist">取消拉黑</el-button>
  </div>
</template>

<script>
import { mapState } from 'vuex'
export default {
  props: {
    userProfile: {
      type: Object,
      required: true
    }
  },
  computed: {
    ...mapState({
      blacklist: state => state.blacklist.blacklist,
      myUserID: state => state.user.currentUserProfile.userID
    }),
    isInBlacklist() {
      return this.blacklist.findIndex(item => item.userID === this.userProfile.userID) >= 0
    },
    gender() {
      switch (this.userProfile.gender) {
        case this.TIM.TYPES.GENDER_MALE:
          return '男'
        case this.TIM.TYPES.GENDER_FEMALE:
          return '女'
        default:
          return '未设置'
      }
    }
  },
  methods: {
    addToBlackList() {
      this.tim
        .addToBlacklist({ userIDList: [this.userProfile.userID] })
        .then(() => {
          this.$store.dispatch('getBlacklist')
        })
        .catch(imError => {
          this.$message.error(imError.message)
        })
    },
    removeFromBlacklist() {
      this.tim.removeFromBlacklist({ userIDList: [this.userProfile.userID] }).then(() => {
        this.$store.commit('removeFromBlacklist', this.userProfile.userID)
      })
    }
  }
}
</script>

<style scoped>
.info-item {
  margin: 12px 0;
}
.info-item .label {
  font-size: 0.8em;
  color: gray;
}
</style>
