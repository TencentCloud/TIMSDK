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

<style>
.login-wrapper {
  display: flex;
  align-items: center;
  flex-direction: column;
  padding: 24px;
  background: #fff;
  color: #000;
  border-radius: 5px;
}
</style>
