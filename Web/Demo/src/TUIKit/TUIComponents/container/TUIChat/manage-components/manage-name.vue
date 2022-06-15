<template>
  <div class="name">
    <label>{{$t(`TUIChat.manage.群名称`)}}</label>
    <div v-if="isEdit" :class="[isH5 ? 'edit-h5' : '']" ref="dialog">
      <main>
        <header class="edit-h5-header" v-if="isH5">
          <aside class="left">
            <h1>{{$t(`TUIChat.manage.修改群聊名称`)}}</h1>
            <span>{{$t(`TUIChat.manage.修改群聊名称后，将在群内通知其他成员`)}}</span>
          </aside>
          <span class="close" @click="toggleEdit">{{$t(`关闭`)}}</span>
        </header>
        <div class="input-box">
          <input class="input" v-if="isEdit" v-model="input" type="text" @keyup.enter="updateProfile">
          <span v-if="isH5">{{$t(`TUIChat.manage.仅限中文、字母、数字和下划线，2-20个字`)}}</span>
        </div>
        <footer class="edit-h5-footer" v-if="isH5">
          <button class="btn" :disabled="!input" @click="updateProfile">{{$t(`确认`)}}</button>
        </footer>
      </main>
    </div>
    <p v-if="!isEdit || isH5" @click="toggleEdit">
      <span>{{groupProfile.name}}</span>
      <i class="icon icon-edit" v-if="isAuth"></i>
    </p>

  </div>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs, ref } from 'vue';
import { onClickOutside } from '@vueuse/core';

const manageName = defineComponent({
  props: {
    data: {
      type: Object,
      default: () => ({}),
    },
    isAuth: {
      type: Boolean,
      default: false,
    },
    isH5: {
      type: Boolean,
      default: false,
    },
  },
  setup(props:any, ctx:any) {
    const data:any = reactive({
      groupProfile: {},
      input: '',
      isEdit: false,
    });

    watchEffect(() => {
      data.groupProfile = props.data;
    });

    const dialog:any = ref();


    onClickOutside(dialog, () => {
      data.isEdit = false;
    });

    const updateProfile = async () => {
      if (data.input && data.input !== data.groupProfile.name) {
        ctx.emit('update', { key: 'name', value: data.input });
        data.groupProfile.name = data.input;
        data.input = '';
      }
      toggleEdit();
    };

    const toggleEdit = async () => {
      if (props.isAuth) {
        data.isEdit = !data.isEdit;
      }
      if (data.isEdit) {
        data.input = data.groupProfile.name;
      }
    };

    return {
      ...toRefs(data),
      updateProfile,
      toggleEdit,
      dialog,
    };
  },
});
export default manageName;
</script>

<style lang="scss" scoped>
.name {
  padding: 14px 20px;
  font-weight: 400;
  font-size: 14px;
  color: #000000;
  display: flex;
  flex-direction: column;
  p {
    opacity: 0.6;
    display: flex;
    align-items: center;
    .icon {
      margin-left: 4px;
    }
  }
}
.input-box {
  display: flex;
  .input {
    flex: 1;
    border: 1px solid #E8E8E9;
    border-radius: 4px;
    padding: 4px 16px;
    font-weight: 400;
    font-size: 14px;
    color: #000000;
    opacity: 0.6;
  }
}

.space-top{
  border-top: 10px solid #F4F5F9;
}
.edit-h5 {
  position: fixed;
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  background: rgba(0,0,0,.5);
  display: flex;
  align-items: flex-end;
  z-index: 1;
  main {
    background: #FFFFFF;
    flex: 1;
    padding: 18px;
    border-radius: 12px 12px 0 0;
    .input-box {
      flex-direction: column;
      padding: 18px 0;
      .input {
        background: #F8F8F8;
        padding: 10px 12px;
      }
      span {
        font-family: PingFangSC-Regular;
        font-weight: 400;
        font-size: 12px;
        color: #888888;
        letter-spacing: 0;
        padding-top: 8px;
      }
    }
  }
  &-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    .close {
      font-family: PingFangSC-Regular;
      font-weight: 400;
      font-size: 18px;
      color: #3370FF;
      letter-spacing: 0;
      line-height: 27px;
    }
  }
  &-footer {
    display: flex;
    .btn {
      flex: 1;
      border: none;
      background: #147AFF;
      border-radius: 5px;
      font-family: PingFangSC-Regular;
      font-weight: 400;
      font-size: 16px;
      color: #FFFFFF;
      letter-spacing: 0;
      line-height: 27px;
      padding: 8px 0;
      &:disabled {
        opacity: 0.3;
      }
    }
  }
}
</style>
