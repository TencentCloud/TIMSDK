<template>
  <div class="profile-card-wrapper">
    <div class="profile-header">
      <avatar :src="profile.avatar" shape="square" text="U" />
      <div class="basic">
        <span class="nick text-ellipsis">{{ profile.nick || profile.userID }}</span>
        <span class="iconfont" :class="genderClass"></span>
        <div>ID:{{ profile.userID }}</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ProfileCard',
  props: {
    profile: {
      type: Object,
      required: true
    }
  },
  computed: {
    genderClass() {
      switch (this.profile.gender) {
        case this.TIM.TYPES.GENDER_MALE:
          return 'icon-male'
        case this.TIM.TYPES.GENDER_FEMALE:
          return 'icon-female'
        default:
          return '暂无'
      }
    }
  }
}
</script>

<style scpoed>
.profile-header {
  display: flex;
  margin-bottom: 12px;
}
.basic {
  margin-left: 12px;
}
.icon-male {
  color: #14b1f6;
}
.icon-female {
  color: #ff8096;
}
.nick {
  margin-right: 8px;
  max-width: 100px;
  display: inline-block;
}
</style>
