<template>
    <div class="TUI-profile">
       <div class="cancle">
         <i class="icon icon-close" @click="changeStatus"></i>
      </div>
      <header class="TUI-profile-header">{{$t('TUIProfile.编辑资料')}}</header>
      <ul class="TUI-profile-main">
        <li class="TUI-profile-main-item">
          <label>{{$t('TUIProfile.头像')}}</label>
          <span v-if="isEdit">
          <span class="avatar" v-for="(item,index) in avatarList"  :key="index">
            <img :class="[profile.avatar === item.avatar &&  'selected']" :src="item.avatar" @click="chooseAvatar(item)">
          </span>
          </span>
          <span v-else>
            <img :src="profile.avatar" alt="">
          </span>
        </li>
        <li class="TUI-profile-main-item">
          <label>{{$t('TUIProfile.昵称')}}</label>
          <span v-if="!isEdit">{{profile.nick}}</span>
          <input v-else type="text" v-model="profile.nick">
        </li>
        <li class="TUI-profile-main-item">
          <label>{{$t('TUIProfile.账号')}}</label>
          <span>{{profile.userID}}</span>
        </li>
        <li class="TUI-profile-main-item">
          <label>{{$t('TUIProfile.个性签名')}}</label>
          <span v-if="!isEdit">{{profile.selfSignature}}</span>
          <input v-else type="text" v-model="profile.selfSignature">
        </li>
        <li class="TUI-profile-gender-item">
          <label>{{$t('TUIProfile.性别')}}</label>
          <span class="gender-save"  v-if="!isEdit">{{profile.gender}}</span>
          <div v-else class="gender-box-item">
            <div class="gender-box" v-for="(item, index) in type" :key="index"  @click="showChooseGender(item)">
            <p class="gender" :class="[profile.gender === item.type && 'choose-gender']"></p>
              <text>{{$t(`TUIProfile.${item.label}`)}}</text>
            </div>
          </div>
        </li>
        <li class="TUI-profile-main-item">
          <label>{{$t('TUIProfile.出生年月')}}</label>
          <span v-if="!isEdit">{{birthday}}</span>
          <input v-else type="date" :value="birthday" @change="showBirthday">
        </li>
      </ul>
      <footer  v-if="isEdit" class="TUI-profile-footer">
        <button class="btn-default" @click="cancel(profile)">{{$t('TUIProfile.取消')}}</button>
        <button class="btn-submit" @click="submit(profile)">{{$t('TUIProfile.保存')}}</button>
      </footer>
    </div>
</template>
<script lang="ts">
import { computed, defineComponent, reactive, toRefs } from 'vue';

const TUIProfile = defineComponent({
  name: 'TUIProfile',
  setup(props:any, ctx:any) {
    const TUIServer:any = TUIProfile?.TUIServer;
    const data = reactive({
      profile: {},
      isEdit: true,
      isShowMale: false,
      isShowFemale: false,
      noShow: false,
      avatarList: [
        {
          name: 'avatar_01',
          avatar: 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/avatar_01.svg',
        },
        {
          name: 'avatar_02',
          avatar: 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/avatar_02.svg',
        },
        {
          name: 'avatar_03',
          avatar: 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/avatar_03.svg',
        },
        {
          name: 'avatar_04',
          avatar: 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/avatar_04.svg',
        },
        {
          name: 'avatar_05',
          avatar: 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/avatar_05.svg',
        },
        {
          name: 'avatar_06',
          avatar: 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/avatar_06.svg',
        },
      ],
      type: [
        {
          label: '男',
          type: TUIServer.TUICore.TIM.TYPES.GENDER_MALE,
        },
        {
          label: '女',
          type: TUIServer.TUICore.TIM.TYPES.GENDER_FEMALE,
        },
        {
          label: '不显示',
          type: TUIServer.TUICore.TIM.TYPES.GENDER_UNKNOWN,
        },
      ],
    });

    TUIServer.bind(data);

    // 出生日期展示格式转化
    const birthday = computed(() => {
      const birthday:any = `${(data.profile as any).birthday}`;
      if (birthday.length === 8) {
        const y = birthday.slice(0, 4);
        const m = birthday.slice(4, 6);
        const d = birthday.slice(-2);
        return `${y}-${m}-${d}`;
      }
      return '';
    });

    // 提交资料修改
    const submit = async (profile: any) => {
      const options:any = {
        nick: profile.nick || '',
        avatar: profile.avatar || '',
        gender: profile.gender || TUIServer.TUICore.TIM.TYPES.GENDER_UNKNOWN,
        selfSignature: profile.selfSignature || '',
        birthday: profile.birthday || 0,
      };
      try {
        await TUIServer.updateMyProfile(options);
      } catch (error) {
        console.log(error);
      }
      cancel();
    };

    // 取消
    const cancel = () => {
      changeStatus();
    };

    const changeStatus = ()  =>  {
      ctx.emit('changeStatus');
    };

    // 选择性别
    const showChooseGender = (options: any)  =>  {
      (data.profile as any).gender = options.type;
    };

    // 选择头像
    const  chooseAvatar = (item: any) =>  {
      (data.profile as any).avatar  = item.avatar;
    };

    // 选择出生日期
    const showBirthday = (e:any) => {
      (data.profile as any).birthday = Number((e.target.value.replace(/-/g, '')));
    };
    return {
      ...toRefs(data),
      submit,
      cancel,
      changeStatus,
      showChooseGender,
      chooseAvatar,
      showBirthday,
      birthday,
    };
  },
});
export default TUIProfile;
</script>

<style lang="scss" scoped>
@import '../../styles/TUIProfile.scss';
</style>
