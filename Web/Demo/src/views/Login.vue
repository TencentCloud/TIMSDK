<template>
  <div :class="['login' + (env.isH5 ? '-h5' : '')]" data-env="H5">
    <Header class="login-header">
      <template v-slot:left>
        <div class="logo">
          <img src="../assets/image/txc-logo.svg" alt="">
          <label class="logo-name">{{$t('腾讯云')}}</label>
          <p>
            <label class="logo-name">{{$t('即时通信IM')}}</label>
          </p>
        </div>
      </template>
      <template v-slot:right>
        <!-- <el-dropdown @command="change"> -->
        <el-dropdown>
          <span class="dropdown">
            <i class="icon icon-global"></i>
            <label>{{$t('当前语言')}}</label>
            <i class="icon icon-arrow-down"></i>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item  command="zh_cn">简体中文</el-dropdown-item>
              <el-dropdown-item  command="en">English(敬请期待)</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </template>
    </Header>
    <main class="login-main">
      <div class="login-main-content">
        <div class="login-main-adv" :class="[locale === 'en' && 'small-txt']" v-if="!env.isH5">
          <p class="login-main-adv-introduce">
             {{$t('Login.超10亿用户的信赖')}}<br/>
             {{$t('腾讯云')}}{{$t('即时通信')}}
             </p>
          <a class="login-sale" @click="openLink(Link.adv)">
            <label>{{$t('Home.首购低至1折')}}, {{$t('Home.复购75%起')}}!  {{$t('Home.立即选购')}}</label>
            <i class="icon icon-adv-arrow"></i>
          </a>
        </div>
        <el-form
          ref="ruleFormRef"
          :model="ruleForm"
          status-icon
          :rules="rules"
          label-width="0"
          class="login-form"
        >
        <div class="login-title">
          <img src="../assets/image/logo.svg" alt="">
          <p>{{$t('Login.免费体验')}}</p>
        </div>
          <el-form-item class="login-from-item" prop="userID">
            <el-input
              size="large"
              v-model="ruleForm.userID"
              :placeholder="$t('Login.请输入userID')"
              class="input-with-select"
              :disabled="isLogin"
            >
            </el-input>
          </el-form-item>
          <el-form-item prop="checked">
            <el-checkbox v-model="ruleForm.checked">
              <p class="checked-text">
                {{$t('Login.我已阅读并同意')}}
                <a @click="openLink(Link.Privacy)">《{{$t(`Login.${Link.Privacy.label}`)}}》</a>{{$t('Login.和')}}
                <a @click="openLink(Link.Agreement)">《{{$t(`Login.${Link.Agreement.label}`)}}》</a>
              </p>
              </el-checkbox>
          </el-form-item>
          <el-form-item class="login-btn">
            <button class="btn btn-primary" @click.prevent="submitForm(ruleFormRef)" v-if="isLogin">{{$t('Login.登录当前账号')}}</button>
            <button class="btn btn-primary" @click.prevent="submitForm(ruleFormRef)" v-else>{{$t('Login.登录')}}</button>
          </el-form-item>
          <el-form-item class="login-btn" v-if="isLogin">
            <button class="btn" @click.prevent="exitLogin">{{$t('Login.切换其他账号')}}</button>
          </el-form-item>
          <footer class="login-form-footer">
            <a @click="openLink(Link.demo)">{{$t(`Login.${Link.demo.label}`)}}</a>
            <a @click="openLink(Link.im)" v-if="!env.isH5">{{$t(`Login.${Link.im.label}`)}}</a>
          </footer>
        </el-form>
      </div>
      <div class="login-main-footer" v-if="!env.isH5">
        <div class="buttom-mask">
          <p class="buttom-mask-top"> {{$t('Login.一分钟')}}</p>
          <p class="buttom-mask-under">{{$t('Login.改2行代码，1分钟跑通demo')}}</p>
        </div>
         <div class="buttom-mask">
          <p class="buttom-mask-top"> 10000+</p>
          <p class="buttom-mask-under">{{$t('Login.每月服务客户数超过10000家')}}</p>
        </div>
        <div class="buttom-mask">
          <p class="buttom-mask-top"> 99.99%</p>
          <p class="buttom-mask-under">{{$t('Login.消息收发成功率')}}</p>
        </div>
        <div class="buttom-mask">
          <p class="buttom-mask-top"> {{$t('Login.10亿')}}+</p>
          <p class="buttom-mask-under">{{$t('Login.每月活跃用户数超过10亿')}}</p>
        </div>
      </div>
    </main>
    <footer  class="login-footer" v-if="env.isH5">
        <ul class="login-footer-list">
          <li class="login-footer-list-item" v-for="(item, index) in Link.advList" :key="index">
            <a  @click="openLink(item)">
              <aside>
                <h1>{{$t(`Home.${item.label}`)}}</h1>
                <h1 v-if="item.subLabel" class="sub">{{$t(`Home.${item.subLabel}`)}}</h1>
              </aside>
              <span><text>{{$t(`Home.${item.btnText}`)}}</text></span>
            </a>
          </li>
        </ul>
      </footer>
  </div>
</template>

<script lang="ts">
import { getCurrentInstance, ref, reactive, defineComponent, toRefs, onBeforeMount } from 'vue';
import { useI18nLocale  } from '../TUIKit/TUIPlugin/TUIi18n';
import type { FormInstance } from 'element-plus';
import { useRouter } from 'vue-router';
import Header from '../components/Header.vue';
import { ElMessage } from 'element-plus';
import { switchTitle } from '../utils/switchTitle';
import Link from '../assets/link';
import { genTestUserSig, EXPIRETIME } from '../../debug/index';
import { useStore } from 'vuex';

export default defineComponent({
  components: {
    Header,
  },
  setup() {
    const instance = getCurrentInstance();
    const router  = useRouter();

    const TUIKit:any = instance?.appContext.config.globalProperties.$TUIKit;

    const { t } = TUIKit.config.i18n.useI18n();

    const ruleFormRef = ref<FormInstance>();
    const locale = useI18nLocale();

    const store = useStore();

    onBeforeMount(async () => {
      if (TUIKit.isSDKReady) {
        await TUIKit.logout();
      }
    });

    const change = (value:any) => {
      if (locale.value !== value) {
        locale.value = value;
        switchTitle(locale.value);
      }
    };

    const validateUserID = (rule: any, value: any, callback: any) => {
      // const reg = new RegExp('^1[0-9]{10}$', 'gi');
      if (!rule.required) {
        callback();
      } else if (!value) {
        callback(new Error(t('Login.请输入userID')));
      } else {
        callback();
      }
    };

    const validateChecked = (rule: any, value: any, callback: any) => {
      if (!value) {
        callback(new Error(t('Login.请先勾选用户协议')));
      } else {
        callback();
      }
    };

    const data = reactive({
      ruleForm: {
        checked: false,
        userID: '',
      },
      rules: {
        checked: [{ required: true, validator: validateChecked, trigger: 'change' }],
        userID: [{ required: true, validator: validateUserID, trigger: 'blur' }],
      },
      isLogin: false,
      env: TUIKit.TUIEnv,
    });

    if (localStorage.getItem('TUIKit-userInfo')) {
      const storgeUserInfo = localStorage.getItem('TUIKit-userInfo') || '';
      const userInfo = JSON.parse(storgeUserInfo);
      if (new Date(userInfo?.expire) > new Date()) {
        data.isLogin = true;
        data.ruleForm.userID = userInfo.userID || '';
      }
    }

    const submitForm = (formEl: FormInstance | undefined) => {
      if (!formEl) return;
      formEl.validate((valid) => {
        if (valid) {
          const options = genTestUserSig(data.ruleForm.userID);
          const userInfo = {
            userID: data.ruleForm.userID,
            userSig: options.userSig,
          };
          login(userInfo);
        } else {
          return false;
        }
      });
    };

    const login = (userInfo:any) => {
      TUIKit.login(userInfo).then((res: any) => {
        const options = {
          ...userInfo,
          expire: new Date().getTime() + EXPIRETIME * 1000,
        };
        store.commit('setUserInfo', options);
        router.push({ name: 'Home' });
      })
        .catch((error:any) => {
          ElMessage({
            message: error,
            grouping: true,
            type: 'error',
          });
        });
    };

    const exitLogin = async () => {
      localStorage.removeItem('TUIKit-userInfo');
      data.ruleForm.userID = '';
      data.isLogin = false;
    };

    const resetForm = (formEl: FormInstance | undefined) => {
      if (!formEl) return;
      formEl.resetFields();
    };

    const openLink = (type:any) => {
      window.open(type.url);
    };

    return {
      ...toRefs(data),
      ruleFormRef,
      change,
      submitForm,
      exitLogin,
      resetForm,
      locale,
      Link,
      openLink,
    };
  },
});
</script>

<style lang="scss" scoped>
@import "../styles/login.scss";
</style>
