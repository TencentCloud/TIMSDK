<template>
  <div class="login-wrapper">
    <img :src="logo" width="50" height="50" style="border-radius: 5px;margin-bottom:12px;"/>
    <el-select v-model="userID">
      <el-option v-for="index in 30" :key="index" :label="`user${index-1}`" :value="`user${index-1}`"></el-option>
    </el-select>
    <br>
    <el-button type="primary" @click="login" style="width:100%;">登录</el-button>
  </div>
</template>

<script>
import { Select, Option } from 'element-ui'
import logo from '../../assets/image/logo.png'
export default {
  name: 'Login',
  components: {
    ElSelect: Select,
    ElOption: Option
  },
  data() {
    return {
      userID: 'user0',
      logo: logo
    }
  },
  methods: {
    login() {
      this.$store.dispatch('login', this.userID)
    }
  }
}
</script>

<style lang="stylus" scoped>
.login-wrapper {
  display: flex;
  align-items: center;
  flex-direction: column;
  padding: 24px;
  background: $white;
  color: $black;
  border-radius: 5px;
  box-shadow: 0 11px 20px 0 rgba(0, 0, 0, .3);
}
</style>
