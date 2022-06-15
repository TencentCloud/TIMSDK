<template>
    <div class="TUI-profile" :class="[env.isH5 ? 'TUI-profile-h5': '']">
      <div class="profile" v-if="!isEdit" @click="toggleEdit">
        <header class="profile-header">
          <aside class="profile-avatar">
            <img
              class="avatar"
              :src="profile.avatar ? profile.avatar : 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
              onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'">
          </aside>
          <ul class="profile-main">
            <li class="profile-main-item">
              <h1 class="profile-main-name">{{profile.nick || "-"}}</h1>
              <p class="gender" v-if="!env.isH5">
                {{profile.gender ? $t(`TUIProfile.${genderLabel[profile.gender]}`) : ""}}</p>
            </li>
            <li class="profile-main-item">
              <label class="profile-main-label">{{$t('TUIProfile.用户ID')}}:</label>
              <span>{{profile.userID}}</span>
            </li>
            <li class="profile-main-item" v-if="env.isH5">
              <label class="profile-main-label">{{$t('TUIProfile.个性签名')}}:</label>
              <span>{{profile.selfSignature || $t('TUIProfile.暂未设置')}}</span>
            </li>
          </ul>
        </header>
        <ul class="profile-main" v-if="!env.isH5">
          <li class="profile-main-item">
            <label class="profile-main-label">{{$t('TUIProfile.个性签名')}}</label>
            <span>{{profile.selfSignature || $t('TUIProfile.暂未设置')}}</span>
          </li>
          <li class="profile-main-item">
            <label class="profile-main-label">{{$t('TUIProfile.出生年月')}}</label>
            <span>{{profile.birthday ? profile.birthday : $t('TUIProfile.暂未设置')}}</span>
          </li>
        </ul>
        <i class="icon icon-right" v-if="env.isH5"></i>
      </div>
      <TUIProfileEdit
        v-else
        :userInfo="profile"
        :isH5="env.isH5"
        @submit="submit"
        @cancel="cancel" />
    </div>
</template>
<script lang="ts">
import { defineComponent, reactive, toRefs } from 'vue';
import { useStore } from 'vuex';
import TUIProfileEdit from './components/TUIProfileEdit';

const TUIProfile = defineComponent({
  name: 'TUIProfile',
  components: {
    TUIProfileEdit,
  },
  setup(props:any, ctx:any) {
    const TUIServer:any = TUIProfile?.TUIServer;
    const data = reactive({
      profile: {},
      isEdit: false,
      genderLabel: {
        [TUIServer.TUICore.TIM.TYPES.GENDER_MALE]: '男',
        [TUIServer.TUICore.TIM.TYPES.GENDER_FEMALE]: '女',
        [TUIServer.TUICore.TIM.TYPES.GENDER_UNKNOWN]: '不显示',
      },
      env: TUIServer.TUICore.TUIEnv,
    });

    TUIProfileEdit.TUIServer = TUIServer;

    TUIServer.bind(data);

    const VuexStore = useStore();


    const submit = async (profile: any) => {
      const options:any = {
        nick: profile.nick || '',
        avatar: profile.avatar || '',
        gender: profile.gender || TUIServer.TUICore.TIM.TYPES.GENDER_UNKNOWN,
        selfSignature: profile.selfSignature || '',
        birthday: profile.birthday || 0,
      };
      if (TUIServer.TUICore.getStore().TUIProfile.profile.nick !== profile.nick) {
        VuexStore.commit('handleTask', 2);
      }
      try {
        await TUIServer.updateMyProfile(options);
      } catch (error) {
        console.log(error);
      }
      if (!data.env.isH5) {
        cancel();
      }
    };


    const cancel = () => {
      if (data.env.isH5) {
        data.isEdit = false;
      } else {
        changeStatus();
      }
    };

    const changeStatus = ()  =>  {
      ctx.emit('changeStatus');
    };

    const toggleEdit = () => {
      if (data.env.isH5) {
        data.isEdit = true;
      }
    };
    return {
      ...toRefs(data),
      submit,
      cancel,
      changeStatus,
      toggleEdit,
    };
  },
});
export default TUIProfile;
</script>

<style lang="scss" scoped src="./style/index.scss"></style>
