<template>
  <view class="name">
    <label>群名称</label>
    <input class="input" v-if="isEdit" v-model="input" type="text" @blur="updateProfile">
    <view class="name-container" v-else>
      <span>{{groupProfile.name}}</span>
      <image
        src="/pages/TUIKit/assets/icon/edit.svg"
        mode="scaleToFill"
        @click="isEdit = !isEdit"
        class="edit-image"
      />
    </view>
  </view>
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
    const TUIGroupServer: any = uni.$TUIKit.TUIGroupServer;
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
        const params = {
          groupID: data.groupProfile.groupID,
          name: data.input,
        };
        TUIGroupServer.updateGroupProfile(params)
          .then((res: any) => {
          }).catch((err: any) => {
          });
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
  .name-container {
    display: flex;
    align-items: center;
    .edit-image {
      width: 20px;
      height: 20px;
      margin-left: 10px;
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
