<template>
  <div id="preloadedImages" class="home">
    <Header class="home-header">
      <template v-slot:left>
        <div class="menu" :class="[menuStatus && 'menu-open']" @click="toggleMenu">
          <i class="icon icon-menu"></i>
          <label>{{$t('使用指引')}}</label>
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
    <Menu class="home-menu" v-if="menuStatus" >
      <template #header>
        <div class="logo">
          <img src="../assets/image/txc-logo.svg" alt="">
          <label class="logo-name">{{$t('腾讯云')}}</label>
          <p>
            <label class="logo-name">{{$t('即时通信IM')}}</label>
          </p>
        </div>
      </template>
      <template #main>
        <div class="menu-main">
          <ul class="menu-main-list bottom-line">
            <h1 class="menu-main-title">{{$t('Home.建议体验功能')}}</h1>
            <li class="menu-main-list-item flex-justify-between" :class="[item.status && 'complete']" v-for="(item, index) in taskList" :key="index">
              <label>{{$t(`Home.${item.label}`)}}</label>
              <span class="status"><text>{{$t(item.status ? 'Home.已完成' : 'Home.待体验')}}</text></span>
            </li>
          </ul>
          <ul class="menu-main-list">
            <h1 class="menu-main-title">{{$t('Home.用UI组件快速集成')}}</h1>
            <li class="menu-main-list-item" v-for="(item, index) in stepList" :key="index">
              <label class="step">{{index+1}}</label>
              <a @click="openDataLink(item)">{{$t(`Home.${item.label}`)}}</a>
            </li>
          </ul>
        </div>
      </template>
      <template #footer>
        <div class="menu-footer">
          <ul class="menu-footer-list">
            <li class="menu-footer-list-item" v-for="(item, index) in advList" :key="index">
              <a  @click="openDataLink(item)">
                <aside>
                  <h1>{{$t(`Home.${item.label}`)}}</h1>
                  <h1 v-if="item.subLabel" class="sub">{{$t(`Home.${item.subLabel}`)}}</h1>
                </aside>
                <span><text>{{$t(`Home.${item.btnText}`)}}</text></span>
              </a>
            </li>
          </ul>
        </div>
      </template>
    </Menu>
   <main class="home-main" :class="[menuStatus && 'home-main-open']">
    <div class="home-main-box">
      <div class="home-TUIKit">
        <div class="setting">
          <main class="setting-main">
            <aside class="userInfo">
              <img
                class="avatar"
                :src="userInfo.avatar ? userInfo.avatar : 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
                onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'">
              <div class="userInfo-main">
                <header class="userInfo-main-header bottom-line">
                  <aside>
                    <img
                      class="avatar"
                      :src="userInfo.avatar || 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
                      onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'">
                  </aside>
                  <ul class="userInfo-main-header-content">
                    <li>
                      <h3 class="nick">{{userInfo.nick || "-"}}</h3>
                      <p class="gender" v-if="userInfo.gender === 'Gender_Type_Male'">{{$t('Home.男')}}</p>
                      <p class="gender" v-if="userInfo.gender === 'Gender_Type_Female'">{{$t('Home.女')}}</p>
                    </li>
                    <li>
                      <label>{{$t('Home.用户ID')}}:{{userInfo.userID}}</label>
                    </li>
                  </ul>
                </header>
                <ul class="userInfo-main-footer">
                  <li class="userInfo-main-footer-box">
                    <label>{{$t('Home.个性签名')}}</label>
                    <span :title="userInfo.selfSignature || $t('Home.暂未设置')">{{userInfo.selfSignature || $t('Home.暂未设置')}}</span>
                  </li>
                  <li>
                    <label>{{$t('Home.出生年月')}}</label>
                    <span>{{userInfo.birthday?userInfo.birthday:$t('Home.暂未设置')}}</span>
                  </li>
                </ul>
              </div>
            </aside>
            <ul class="setting-main-list">
              <li class="setting-main-list-item" :class="[currentModel === 'message' && 'selected']" @click="selectModel('message')">
                <i v-show="currentModel === 'message'" class="icon icon-message-selected"></i>
                <i v-show="currentModel !== 'message'" class="icon icon-message"></i>
              </li>
              <li class="setting-main-list-item" :class="[currentModel === 'group'&& 'selected']" @click="selectModel('group')">
                <i v-show="currentModel === 'group'" class="icon icon-relation-selected"></i>
                <i v-show="currentModel !== 'group'" class="icon icon-relation"></i>
              </li>
            </ul>
          </main>
          <div class="setting-footer" @click="getProfile">
            <i class="icon icon-setting" @click="openShowMore"></i>
            <div class="setting-more" v-if="showMore">
              <div class="showmore">
                <div class="show-profile" >
                  <span @click="openShowProfile">{{$t('Home.编辑资料')}}</span>
                    <div class="TUIProfile" v-if="showProfile" >
                      <main>
                        <TUIProfile @changeStatus="handleChangeStatus"/>
                      </main>
                    </div>
                </div>
                <div  class="show-about"  @click="openShowAbout">
                  <span>{{$t('Home.关于腾讯云IM')}}</span>
                </div>
                <div  class="dialog"  v-if="showAbout"  @click="closeShowAbout">
                <div class="show-about-box" >
                  <header>
                  <img src="https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/cancel-background.png" alt="">
                  </header>
                  <main>
                  <span>{{$t('Home.SDK版本')}}:<text>{{version}}</text></span>
                  </main>
                  <footer>
                          <a  @click="openLink(Link.Privacy)">《{{$t(`Login.${Link.Privacy.label}`)}}》</a>｜
                          <a  @click="openLink(Link.Agreement)">《{{$t(`Login.${Link.Agreement.label}`)}}》</a>｜
                          <a  @click="openDisclaimer">{{$t('Home.免责声明')}}</a>
                    <span >
                          <a  @click="openLink(Link.contact)">《{{$t(`Home.${Link.contact.label}`)}}》</a>｜
                          <a  @click="openShowCancellation">{{$t('Home.注销账户')}}</a>
                    </span>
                  </footer>
                  <p class="show-about-date">Copyright @ 2015-2022 Tecent. All Rights Reserved.</p>
                </div>
                </div>
                <div v-if="showCancellation" class="dialog">
                  <div  class="cancellation-box">
                    <header>
                      <i><text>!</text></i>
                    </header>
                    <main>
                    <span>{{$t('Home.注销后，您将无法使用当前账号，相关数据也将删除无法找回。 当前账号')}}：<text  class="cancelID">{{userInfo.userID}}</text></span>
                    </main>
                    <footer>
                      <div class="btn-submit" @click="submitCancellation(userInfo)"><text>{{$t('Home.注销')}}</text></div>
                      <div class="btn-default" @click="cancel"><text>{{$t('Home.取消')}}</text></div>
                    </footer>
                  </div>
                </div>
                <div v-if="showDisclaimer" class="dialog" @click.self="showDisclaimer = false">
                  <div class="disclaimer-box">
                    <header>{{$t(`Home.${disclaimer.label}`)}}</header>
                    <main>{{$t(`Home.${disclaimer.text}`)}}</main>
                    <footer @click="submitDisclaimer"><text>{{$t('Home.同意')}}</text></footer>
                  </div>
                </div>
              <div class="show-cut-box">
                <p  class="show-cut"></p>
              </div>
                <div  class="show-quit" @click="exitLogin" >
                  <span>{{$t('Home.退出登录')}}</span>
                </div>
              </div>
              <div class="moreMask" @click.self="openShowMore"></div>
            </div>
          </div>
        </div>
        <div class="home-TUIKit-main" v-show="currentModel === 'message'">
          <div class="conversation">
            <TUIConversation />
          </div>
          <div class="chat" >
            <TUIChat>
              <div class="chat-default">
                <h1>
                  {{$t('Home.欢迎使用')}} <img class="logo" src="../assets/image/logo.svg" alt=""> {{$t('即时通信')}}
                </h1>
                <p>{{$t('Home.我们为您默认提供了一位“示例好友”和一个“示例客服群”您不用额外添加好友和群聊就可完整体验腾讯云 IM 单聊、群聊的所有功能。')}}<br/> {{$t('Home.随时随地')}}</p>
              </div>
            </TUIChat>
          </div>
        </div>
        <div class="home-TUIKit-main" v-show="currentModel === 'group'">
          <TUIContact v-show="currentModel === 'group'">
            <div class="chat-default">
              <h1>
                {{$t('Home.欢迎使用')}} <img class="logo" src="../assets/image/logo.svg" alt=""> {{$t('即时通信')}}
              </h1>
              <p>{{$t('Home.我们为您默认提供了一位“示例好友”和一个“示例客服群”您不用额外添加好友和群聊就可完整体验腾讯云 IM 单聊、群聊的所有功能。')}}
                <br/> {{$t('Home.随时随地')}}</p>
            </div>
          </TUIContact>
        </div>
      </div>
    </div>
   </main>
   </div>
</template>

<script lang="ts" >
import { computed, defineComponent, getCurrentInstance, reactive, toRefs } from 'vue';
import { useI18nLocale  } from '../TUIKit/TUIPlugin/TUIi18n';
import { TUICore  } from '../TUIKit';
import Header from '../components/Header.vue';
import Menu from '../components/Menu.vue';
import { useStore } from 'vuex';
import router from '@/router';
import { switchTitle } from '../utils/switchTitle';
import Link from '../assets/link';

export default defineComponent({
  components: {
    Header,
    Menu,
  },
  setup(props, context) {
    const instance = getCurrentInstance();
    const locale = useI18nLocale();
    const TUIKit:any = instance?.appContext.config.globalProperties.$TUIKit;
    const data = reactive({
      stepList: Link.stepList,
      advList: Link.advList,
      disclaimer: {
        label: 'IM-免责声明',
        text: 'IM（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。为配合相关部门监管要求，本产品音视频互动全程均有录音录像存档，严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。',
      },
      ruleForm: {
        prePhone: '86',
        phone: '',
        code: '',
        checked: false,
        userInfo: {
          userId: '',
          userSig: '',
          expire: '',
        },
      },
      menuStatus: true,
      showProfile: false,
      showAbout: false,
      showMore: false,
      showCancellation: false,
      showDisclaimer: false,
      currentModel: 'message',
      userInfo: TUICore.instance.getStore().TUIProfile.profile,
    });

    TUICore.instance.TUIServer.TUIProfile.getMyProfile().then((res:any)=>{
      data.userInfo = res.data;
    });

    const store = useStore();
    const taskList = computed(() => store.state.taskList);
    const version : string  = TUICore.instance.TIM.VERSION;
    // 更改语言
    const change = (value:any) => {
      if (locale.value !== value) {
        locale.value = value;
        store.commit('handleTask', 2);
        switchTitle(locale.value);
      }
    };

    // 开关任务侧边栏
    const toggleMenu = () => {
      data.menuStatus = !data.menuStatus;
    };
    // 选择模块
    const selectModel = (modelName:string) => {
      data.currentModel = modelName;
    };
    // 关闭个人资料弹窗
    const handleChangeStatus  = ()  =>  {
      data.showMore = false;
      data.showProfile  = false;
    };
    //  开关showMore
    const openShowMore  = ()  =>  {
      data.showMore = !data.showMore;
      data.showProfile  = false;
      data.showAbout  = false;
      data.showCancellation = false;
    };

    const exitLogin = async () => {
      router.push({ name: 'Login' });
      localStorage.removeItem('TUIKit-userInfo');
      data.ruleForm.userInfo.userId = '';
      data.ruleForm.userInfo.userSig = '';
      data.ruleForm.userInfo.expire = '';
    };
    const openShowProfile = ()  =>  {
      data.showProfile = true;
    };
    const openShowAbout = ()  =>  {
      data.showAbout  = true;
    };
    const openShowCancellation  = ()  =>  {
      data.showCancellation = true;
    };
    const cancel  = ()  =>  {
      data.showCancellation = false;
      data.showMore = false;
    };

    const closeShowAbout  = ()  =>  {
      data.showAbout  = false;
    };
    const openDisclaimer  =  () =>  {
      data.showDisclaimer = true;
    };
    const submitDisclaimer  = ()  =>  {
      data.showDisclaimer = false;
      data.showMore = false;
    };
    // 确认注销
    const submitCancellation = ()  =>  {
      TUIKit.logout().then((res:any) => {
        localStorage.removeItem('TUIKit-userInfo');
        router.push({ name: 'Login' });
      });
    };
    const openDataLink = (item:any) =>  {
      window.open(item.url);
    };
    //  增加链接跳转上报
    const openLink = (type:any) => {
      window.open(type.url);
    };
    return {
      ...toRefs(data),
      taskList,
      change,
      toggleMenu,
      version,
      selectModel,
      handleChangeStatus,
      openShowMore,
      exitLogin,
      openShowCancellation,
      cancel,
      closeShowAbout,
      openShowAbout,
      submitCancellation,
      openDisclaimer,
      submitDisclaimer,
      Link,
      openShowProfile,
      openLink,
      openDataLink,
    };
  },
});
</script>
<style lang="scss" scoped>
@import "../styles/home.scss";
</style>
