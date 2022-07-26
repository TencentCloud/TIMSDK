<template>
  <main class="notification">
    <textarea v-if="isEdit" v-model="input" @keyup.enter="updateProfile"></textarea>
    <section v-else>
      <p v-if="!groupProfile.notification">{{$t(`TUIChat.manage.暂无公告`)}}</p>
      <article v-else>{{groupProfile.notification}}</article>
    </section>
    <footer v-if="isAuth">
      <button class="btn" v-if="isEdit" @click="updateProfile">{{$t(`TUIChat.manage.发布`)}}</button>
      <button class="btn" v-else @click="isEdit = !isEdit">{{$t(`TUIChat.manage.编辑`)}}</button>
    </footer>
  </main>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';

const ManageNotification = defineComponent({
  props: {
    data: {
      type: Object,
      default: () => ({}),
    },
    isAuth: {
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
      data.input = data.groupProfile.notification;
    });

    // 更新群资料
    const updateProfile = async () => {
      if (data.input && data.input !== data.groupProfile.notification) {
        ctx.emit('update', { key: 'notification', value: data.input });
        data.groupProfile.notification = data.input;
        data.input = '';
      }
      data.isEdit = !data.isEdit;
    };

    return {
      ...toRefs(data),
      updateProfile,
    };
  },
});
export default ManageNotification;
</script>

<style lang="scss" scoped>
.notification {
  flex: 1;
  padding: 20px;
  display: flex;
  flex-direction: column;
  section {
    flex: 1;
    font-size: 14px;
    p {
      text-align: center;
      padding-bottom: 20px;
    }
  }
  textarea {
    margin-bottom: 20px;
    flex: 1;
    box-sizing: border-box;
    padding: 10px;
    border: 1px solid #E8E8E9;
    resize: none;
    font-size: 14px;
  }
  footer {
    display: flex;
    justify-content: flex-end;
    padding: 10px;
  }
}
.btn {
  background: #3370FF;
  border: 0 solid #2F80ED;
  padding: 4px 28px;
  font-weight: 400;
  font-size: 12px;
  color: #FFFFFF;
  line-height: 24px;
  border-radius: 4px;
  &-cancel {
    background: #FFFFFF;
    border: 1px solid #DDDDDD;
    color: #828282;
  }
}
</style>
