<template>
  <main class="member">
    <ul class="list">
      <li class="list-item" v-for="(item, index) in list" :key="index">
        <aside>
          <img
            class="avatar"
            :src="item?.avatar || 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
            onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'">
          <span class="name">{{item?.nick || item?.userID}}</span>
          <span >{{handleRoleName(item)}}</span>
        </aside>
        <i v-if="item.role !== 'Owner' && isShowDel" class="icon icon-del" @click="submit(item)"></i>
      </li>
      <li class="list-item" v-if="list.length < total" @click="getMore">{{$t(`TUIChat.manage.查看更多`)}}</li>
    </ul>
  </main>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';
import TIM from 'tim-js-sdk';

const ManageMember = defineComponent({
  components: {},
  props: {
    list: {
      type: Array,
      default: () => [],
    },
    total: {
      type: Number,
      default: () => 0,
    },
    isShowDel: {
      type: Boolean,
      default: () => false,
    },
    self: {
      type: Object,
      default: () => ({}),
    },
  },
  setup(props:any, ctx:any) {
    const types:any = TIM.TYPES;
    const data:any = reactive({
      total: 0,
      list: [],
      isShowDel: false,
      self: {},
    });

    watchEffect(() => {
      data.total = props.total;
      data.isShowDel = props.isShowDel;
      data.list = props.list;
      data.self = props.self;
    });

    const handleRoleName = (item:any) => {
      const { t } = (window as any).TUIKitTUICore.config.i18n.useI18n();
      let name = '';
      switch (item?.role) {
        case types.GRP_MBR_ROLE_ADMIN:
          name = t('TUIChat.manage.管理员');
          break;
        case types.GRP_MBR_ROLE_OWNER:
          name =  t('TUIChat.manage.群主');
          break;
      }
      if (name) {
        name = `(${name})`;
      }
      if (item.userID === data.self.userID) {
        name += ` (${t('TUIChat.manage.我')})`;
      }
      return name;
    };

    const getMore = () => {
      ctx.emit('more');
    };

    const submit = (item:any) => {
      ctx.emit('del', [item]);
    };

    return {
      ...toRefs(data),
      getMore,
      submit,
      handleRoleName,
    };
  },
});
export default ManageMember;
</script>

<style lang="scss" scoped>
.member {
  flex: 1;
  background: #ffffff;
  .list {
    display: flex;
    flex-direction: column;
    background: #F4F5F9;
    padding-top: 22px;
    &-item {
      padding: 13px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      background: #ffffff;
      font-size: 14px;
      &:hover {
        background: #F1F2F6;
      }
      aside {
        display: flex;
        align-items: center;
        .name {
          padding-left: 8px;
          font-weight: 400;
          font-size: 14px;
          color: #000000;
        }
      }
    }
  }
}
.avatar {
  width: 36px;
  height: 36px;
  border-radius: 4px;
}
</style>
