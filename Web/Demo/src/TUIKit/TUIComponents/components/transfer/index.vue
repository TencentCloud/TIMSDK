<template>
  <div class="transfer">
    <main class="main">
      <div class="left">
        <header v-if="isSearch">
          <input type="text" @keyup.enter="handleInput" :placeholder="$t('component.请输入userID')">
        </header>
        <ul class="list">
          <li class="list-item" v-for="(item, index) in list" :key="index"  @click="selected(item)">
            <i class="icon" :class="[item?.isDisabled && 'disabled', selectedList.indexOf(item)>-1 ? 'icon-selected': 'icon-unselected']" ></i>
            <template v-if="!isCustomItem">
              <img
                class="avatar"
                :src="item?.avatar || 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
                onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'">
              <span class="name">{{item?.nick || item?.userID}}</span>
              <span v-if="item?.isDisabled">（已在群聊中）</span>
            </template>
            <template v-else>
              <slot name="item" :data="item" />
            </template>
          </li>
        </ul>
      </div>
      <div class="right">
        <header>{{title}}</header>
        <ul class="list">
          <p v-if="selectedList.length>0">{{$t('component.已选中')}}{{selectedList.length}}{{$t('component.人')}}</p>
          <li class="list-item space-between" v-for="(item, index) in selectedList" :key="index">
            <aside>
              <template v-if="!isCustomItem">
                <img
                  class="avatar"
                  :src="item?.avatar || 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
                  onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'">
                <span>{{item.nick || item.userID}}</span>
              </template>
              <template v-else>
                <slot name="item" :data="item" />
              </template>
            </aside>
            <i class="icon icon-cancel" @click="selected(item, 'cancel')"></i>
          </li>
        </ul>
        <footer>
          <button class="btn btn-cancel" @click="cancel">{{$t('component.取消')}}</button>
          <button v-if="selectedList.length>0" class="btn" @click="submit">{{$t('component.完成')}}</button>
          <button v-else class="btn-no" @click="submit">{{$t('component.完成')}}</button>
        </footer>
      </div>
    </main>
  </div>
</template>

<script lang="ts">
import { defineComponent, reactive, watchEffect, toRefs } from 'vue';

export default defineComponent({
  props: {
    list: {
      type: Array,
      default: () => [],
    },
    selectedList: {
      type: Array,
      default: () => [],
    },
    isSearch: {
      type: Boolean,
      default: () => true,
    },
    isRadio: {
      type: Boolean,
      default: () => false,
    },
    isCustomItem: {
      type: Boolean,
      default: () => false,
    },
    title: {
      type: String,
      default: () => '',
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      list: [],
      selectedList: [],
      isSearch: true,
      isRadio: false,
      isCustomItem: false,
      title: '',
    });

    watchEffect(() => {
      if (props.isCustomItem) {
        for (let index = 0 ; index < props.list.length; index++)  {
          if ((props.list[index].conversationID).indexOf('@TIM#SYSTEM') > -1) {
            // eslint-disable-next-line vue/no-mutating-props
            props.list.splice(index, 1);
          }
          data.list = props.list;
        }
      } else {
        data.list = props.list;
      }
      data.selectedList = props.selectedList;
      data.isSearch = props.isSearch;
      data.isRadio = props.isRadio;
      data.isCustomItem = props.isCustomItem;
      data.title = props.title;
    });

    const handleInput = (e:any) => {
      ctx.emit('search', e.target.value);
    };

    const selected = (item:any, type?:string) => {
      if (item.isDisabled) {
        return;
      }
      let list:any = data.selectedList;
      const index:number = list.indexOf(item);
      if (type && type === 'cancel') {
        return data.selectedList.splice(index, 1);
      }
      if (index === -1) {
        if (data.isRadio) {
          list = [];
        }
        list.push(item);
      }
      data.selectedList = list;
    };

    const submit = () => {
      ctx.emit('submit', data.selectedList);
    };

    const cancel = () => {
      ctx.emit('cancel');
    };

    return {
      ...toRefs(data),
      handleInput,
      selected,
      submit,
      cancel,
    };
  },
});
</script>

<style lang="scss" scoped>
.main {
  box-sizing: border-box;
  width: 620px;
  height: 394px;
  display: flex;
  background: #FFFFFF;
  border: 1px solid #E0E0E0;
  box-shadow: 0 -4px 12px 0 rgba(0,0,0,0.06);
  border-radius: 8px;
  padding: 20px 0;
  .left,.right {
    padding: 0 20px;
    flex: 1;
  }
  .left {
    border-right: 1px solid #E8E8E9;
    overflow-y: auto
  }
  .right {
    display: flex;
    flex-direction: column;
    footer {
      align-self: flex-end;
      .btn-cancel {
        margin-right: 12px;
      }
    }
    .list {
      overflow-y: auto;
    }
  }
  header {
    font-weight: 500;
    font-size: 14px;
    color: #000000;
    letter-spacing: 0;
    line-height: 14px;
    padding-bottom: 20px;
    input {
      box-sizing: border-box;
      width: 100%;
      background: #FFFFFF;
      border: 1px solid #DEE0E3;
      border-radius: 30px;
      font-weight: 500;
      font-size: 10px;
      color: #8F959E;
      letter-spacing: 0;
      line-height: 14px;
      padding: 9px 12px;
    }
  }
  .list {
    flex: 1;
    display: flex;
    flex-direction: column;
    p {
      font-weight: 500;
      font-size: 10px;
      color: #8F959E;
      letter-spacing: 0;
      line-height: 14px;
    }
    &-item {
      padding: 6px 0;
      display: flex;
      align-items: center;
      font-size: 14px;
      aside {
        display: flex;
        align-items: center;
      }
      .avatar {
        margin: 0 5px 0 8px;
        border-radius: 50%;
      }
      .name {
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        flex: 1;
      }
      .disabled {
        background: #eeeeee;
      }
    }
  }
}
.avatar {
  width: 36px;
  height: 36px;
  background: #F4F5F9;
  border-radius: 4px;
  font-size: 12px;
  color: #000000;
  display: flex;
  justify-content: center;
  align-items: center;
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
.btn-no {
  background: #e8e8e9;
  border: 1px solid #DDDDDD;
  padding: 4px 28px;
  font-weight: 400;
  font-size: 12px;
  color: #FFFFFF;
  line-height: 24px;
  border-radius: 4px;
}
.space-between {
  justify-content: space-between;
}
</style>
