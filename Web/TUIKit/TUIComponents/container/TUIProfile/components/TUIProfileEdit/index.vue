<template >
  <div class="edit" :class="[isH5 ? 'edit-h5': '']">
    <header class="edit-header">
      <i v-if="isH5" class="icon icon-back" @click="cancel"></i>
      <h1 class="edit-header-title">{{$t('TUIProfile.资料设置')}}</h1>
    </header>
    <ul class="edit-list">
      <li class="edit-list-item space-top">
          <main class="edit-list-item-content" @click="setProfile('avatar')">
            <label>{{$t('TUIProfile.头像')}}</label>
            <span v-if="isH5">
              <img
                :src="profile.avatar ? profile.avatar : 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
                onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'">
            </span>
            <ul class="avatar-list" v-else>
              <li class="avatar-list-item" v-for="(item,index) in avatarList"  :key="index" @click="chooseAvatar(item)">
                <img :class="[profile.avatar === item.avatar &&  'selected']" :src="item.avatar" >
              </li>
            </ul>
          </main>
          <i v-if="isH5" class="icon icon-right"></i>
      </li>
      <li class="edit-list-item space-top">
        <main class="edit-list-item-content" @click="setProfile('nick')">
          <label>{{$t('TUIProfile.昵称')}}</label>
          <span v-if="isH5">{{profile.nick}}</span>
          <input v-else type="text" v-model="profile.nick">
        </main>
        <i v-if="isH5" class="icon icon-right"></i>
      </li>
      <li class="edit-list-item">
        <main class="edit-list-item-content">
          <label>{{$t('TUIProfile.账号')}}</label>
          <span>{{profile.userID}}</span>
        </main>
      </li>
      <li class="edit-list-item space-top">
        <main class="edit-list-item-content" @click="setProfile('selfSignature')">
          <label>{{$t('TUIProfile.个性签名')}}</label>
          <span v-if="isH5">{{profile.selfSignature}}</span>
          <input v-else type="text" v-model="profile.selfSignature">
        </main>
        <i v-if="isH5" class="icon icon-right"></i>
      </li>
      <li class="edit-list-item">
        <main class="edit-list-item-content" @click="setProfile('gender')">
          <label>{{$t('TUIProfile.性别')}}</label>
          <span v-if="isH5">{{profile.gender ? $t(`TUIProfile.${genderLabel[profile.gender]}`) : ''}}</span>
          <ul v-else class="gender-list">
            <li class="gender-list-item" v-for="(item, index) in type" :key="index"  @click="showChooseGender(item)">
              <i class="gender" :class="[profile.gender === item.type && 'gender-selected']"></i>
              <p class="name">{{$t(`TUIProfile.${item.label}`)}}</p>
            </li>
          </ul>
        </main>
        <i v-if="isH5" class="icon icon-right"></i>
      </li>
      <li class="edit-list-item">
        <main class="edit-list-item-content" @click="setProfile('birthday')">
          <label>{{$t('TUIProfile.出生年月')}}</label>
          <span v-if="isH5">{{profile.birthday}}</span>
          <Datepicker
            v-else
            :placeholder="$t(`TUIProfile.请选择出生日期`)"
            :enableTimePicker="false"
            :format="format"
            :previewFormat="format"
            :modelValue="birthday"
            @update:modelValue="showBirthday" />
        </main>
        <i v-if="isH5" class="icon icon-right"></i>
      </li>
    </ul>
    <footer class="edit-footer" v-if="!isH5">
      <button class="btn-default" @click="cancel">{{$t('TUIProfile.取消')}}</button>
      <button class="btn-submit" @click="submit">{{$t('TUIProfile.保存')}}</button>
    </footer>
    <div class="mask" v-if="setName&&isH5" @click.self="closeMask">
      <div class="mask-main">
        <header class="edit-h5-header">
          <h1>{{$t(`TUIProfile.${editConfig.title}`)}}</h1>
          <span class="close" @click="closeMask">{{$t(`关闭`)}}</span>
        </header>
        <main class="edit-h5-main">
          <ul class="list" v-if="editConfig.type === 'select'">
            <li class="list-item" v-for="(item,index) in editConfig.list"  :key="index" @click="choose(item)">
              <img v-if="item?.avatar" :class="[editConfig.value === item.avatar &&  'selected']" :src="item.avatar">
              <span v-else :class="[editConfig.value === item.type &&  'selected']">{{$t(`TUIProfile.${item.label}`)}}</span>
            </li>
          </ul>
          <div class="input" v-else>
            <textarea v-if="editConfig.type === 'textarea'" :placeholder="editConfig.placeholder" v-model="editConfig.value"></textarea>
            <Datepicker
              class="datePicker"
              :placeholder="$t(`TUIProfile.请选择出生日期`)"
              v-else-if="editConfig.type === 'date'"
              :enableTimePicker="false"
              :format="format"
              :previewFormat="format"
              :modelValue="birthday"
              @update:modelValue="showBirthday" />
            <input v-else :type="editConfig.type" :placeholder="$t(`TUIProfile.${editConfig.placeholder}`)" v-model="editConfig.value">
          </div>
          <sub v-if="editConfig.subText">{{$t(`TUIProfile.${editConfig.subText}`)}}</sub>
        </main>
        <footer class="edit-h5-footer">
          <button class="btn btn-submit" :disabled="!editConfig.value" @click="submit">{{$t(`确定`)}}</button>
        </footer>
      </div>
    </div>
  </div>
</template>
<script lang="ts">
import { computed, defineComponent, reactive, toRefs, watchEffect } from 'vue';
import Datepicker from '@vuepic/vue-datepicker';
import '@vuepic/vue-datepicker/dist/main.css';

const TUIProfileEdit:any = defineComponent({
  props: {
    userInfo: {
      type: Object,
      default: () => ({}),
    },
    isH5: {
      type: Boolean,
      default: () => false,
    },
  },
  components: { Datepicker },
  setup(props:any, ctx:any) {
    const TUIServer:any = TUIProfileEdit?.TUIServer;
    const data = reactive({
      profile: {},
      isEdit: false,
      avatarList: [
        {
          name: 'avatar_01',
          avatar: ' https://im.sdk.qcloud.com/download/tuikit-resource/avatar/avatar_1.png',
        },
        {
          name: 'avatar_02',
          avatar: ' https://im.sdk.qcloud.com/download/tuikit-resource/avatar/avatar_2.png',
        },
        {
          name: 'avatar_03',
          avatar: ' https://im.sdk.qcloud.com/download/tuikit-resource/avatar/avatar_3.png',
        },
        {
          name: 'avatar_04',
          avatar: ' https://im.sdk.qcloud.com/download/tuikit-resource/avatar/avatar_4.png',
        },
        {
          name: 'avatar_05',
          avatar: ' https://im.sdk.qcloud.com/download/tuikit-resource/avatar/avatar_5.png',
        },
        {
          name: 'avatar_06',
          avatar: ' https://im.sdk.qcloud.com/download/tuikit-resource/avatar/avatar_6.png',
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
      ],
      genderLabel: {
        [TUIServer.TUICore.TIM.TYPES.GENDER_MALE]: '男',
        [TUIServer.TUICore.TIM.TYPES.GENDER_FEMALE]: '女',
        [TUIServer.TUICore.TIM.TYPES.GENDER_UNKNOWN]: '不显示',
      },
      setName: '',
      editConfig: {
        title: '',
        list: [],
        type: '', // select、text、textarea、date
        subText: '',
        placeholder: '',
        value: '',
      },
    });

    const format = (date:any) => {
      const day = date.getDate() > 9 ? date.getDate() : `0${date.getDate()}`;
      const month = date.getMonth() > 8 ? date.getMonth() + 1 : `0${date.getMonth() + 1}`;
      const year = date.getFullYear();
      return `${year}${month}${day}`;
    };

    watchEffect(() => {
      data.profile = JSON.parse(JSON.stringify(props.userInfo));
    });


    const birthday = computed(() => {
      let value = (data.profile as any).birthday;
      if (data.setName === 'birthday' && props.isH5) {
        value = data.editConfig.value;
      }
      return handleBirthdayFamate(value);
    });

    const handleBirthdayFamate = (value: any) => {
      const birthday:any = `${value}`;
      if (birthday.length === 8) {
        const y = birthday.slice(0, 4);
        const m = birthday.slice(4, 6);
        const d = birthday.slice(-2);
        return  `${y}-${m}-${d}`;
      }
      return '';
    };


    const showChooseGender = (options: any)  =>  {
      (data.profile as any).gender = options.type;
    };


    const  chooseAvatar = (item: any) =>  {
      (data.profile as any).avatar  = item.avatar;
    };

    const showBirthday = (e:any) => {
      if (!props.isH5) {
        (data.profile as any).birthday = e ? Number(format(e)) : 0;
      } else {
        (data.editConfig.value as unknown) = e ? Number(format(e)) : 0;
      }
    };

    const submit = () => {
      if (props.isH5) {
        (data.profile as any)[data.setName] = data.editConfig.value;
        closeMask();
      }
      ctx.emit('submit', data.profile);
    };

    const cancel = () => {
      ctx.emit('cancel', data.profile);
    };

    const setProfile = (name: string) => {
      data.editConfig.value = `${(data.profile as any)[name]}`;
      data.setName = name;
      switch (name) {
        case 'avatar':
          data.editConfig.title = '选择头像';
          (data.editConfig.list as unknown) = data.avatarList;
          data.editConfig.type = 'select';
          break;
        case 'nick':
          data.editConfig.title = '设置昵称';
          data.editConfig.subText = '仅限中文、字母、数字和下划线，2-20个字';
          data.editConfig.placeholder = '请输入昵称';
          data.editConfig.type = 'text';
          break;
        case 'gender':
          data.editConfig.title = '性别选择';
          (data.editConfig.list as unknown) = data.type;
          data.editConfig.type = 'select';
          break;
        case 'selfSignature':
          data.editConfig.title = '个性签名';
          data.editConfig.type = 'textarea';
          data.editConfig.placeholder = '请输入内容';
          break;
        case 'birthday':
          data.editConfig.title = '出生年月';
          data.editConfig.type = 'date';
          data.editConfig.placeholder = '请选择出生日期';
          break;
        default:
          break;
      }
    };

    const choose = (item: any) =>  {
      data.editConfig.value  = item?.avatar || item?.type;
    };

    const closeMask = () => {
      data.setName = '';
      data.editConfig = {
        title: '',
        list: [],
        type: '',
        subText: '',
        placeholder: '',
        value: '',
      };
    };

    return {
      ...toRefs(data),
      showChooseGender,
      chooseAvatar,
      showBirthday,
      birthday,
      submit,
      cancel,
      setProfile,
      choose,
      closeMask,
      format,
    };
  },
});
export default TUIProfileEdit;
</script>
<style lang="scss" scoped src="./style/index.scss"></style>
