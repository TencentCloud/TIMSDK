<template>
  <div class="name">
    <label>{{$t(`TUIChat.manage.群名称`)}}</label>
    <input class="input" v-if="isEdit" v-model="input" type="text" @keyup.enter="updateProfile">
    <p v-else>
      <span>{{groupProfile.name}}</span>
      <i class="icon icon-edit" v-if="isAuth" @click="isEdit = !isEdit"></i>
    </p>
  </div>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';

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
  },
  setup(props:any, ctx:any) {
    const data:any = reactive({
      groupProfile: {},
      input: '',
      isEdit: false,
    });

    watchEffect(() => {
      data.groupProfile = props.data;
      data.input = data.groupProfile.name;
    });

    // 更新群资料
    const updateProfile = async () => {
      if (data.input && data.input !== data.groupProfile.name) {
        ctx.emit('update', { key: 'name', value: data.input });
        data.groupProfile.name = data.input;
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
.input {
  border: 1px solid #E8E8E9;
  border-radius: 4px;
  padding: 4px 16px;
  font-weight: 400;
  font-size: 14px;
  color: #000000;
  opacity: 0.6;
}

.space-top{
  border-top: 10px solid #F4F5F9;
}
</style>
