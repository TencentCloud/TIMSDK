<template>
  <div class="transfer"  :class="[isH5 ? 'transfer-h5' : '']">
    <header class="transfer-h5-header" v-if="isH5">
      <i class="icon icon-back" @click="cancel"></i>
      <span class="title">{{title}}</span>
    </header>
    <main class="main">
      <div class="left">
        <header v-if="isSearch">
          <input type="text" @keyup.enter="handleInput" :placeholder="$t('component.请输入userID')" enterkeyhint="search">
        </header>
        <ul class="list">
          <li class="list-item" @click="selectedAll" v-if="optional.length > 1 && !isRadio">
            <i class="icon" :class="[selectedList.length === optional.length ? 'icon-selected': 'icon-unselected']" ></i>
            <span class="all">{{$t('component.全选')}}</span>
          </li>
          <li class="list-item" v-for="(item, index) in list" :key="index"  @click="selected(item)">
            <i class="icon" :class="[item?.isDisabled && 'disabled', selectedList.indexOf(item)>-1 ? 'icon-selected': 'icon-unselected']" ></i>
            <template v-if="!isCustomItem">
              <img
                class="avatar"
                :src="item?.avatar || 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
                onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'">
              <span class="name">{{item?.nick || item?.userID}}</span>
              <span v-if="item?.isDisabled">（{{$t('component.已在群聊中')}}）</span>
            </template>
            <template v-else>
              <slot name="left" :data="item" />
            </template>
          </li>
        </ul>
      </div>
      <div class="right">
        <header v-if="!isH5">{{title}}</header>
        <ul class="list" v-show="resultShow">
          <p v-if="selectedList.length>0 && !isH5">{{$t('component.已选中')}}{{selectedList.length}}{{$t('component.人')}}</p>
          <li class="list-item space-between" v-for="(item, index) in selectedList" :key="index">
            <aside>
              <template v-if="!isCustomItem">
                <img
                  class="avatar"
                  :src="item?.avatar || 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
                  onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'">
                <span  v-if="!isH5">{{item.nick || item.userID}}</span>
              </template>
              <template v-else>
                <slot name="right" :data="item" />
              </template>
            </aside>
            <i class="icon icon-cancel" @click="selected(item)"  v-if="!isH5"></i>
          </li>
        </ul>
        <footer>
          <button class="btn btn-cancel" @click="cancel">{{$t('component.取消')}}</button>
          <button v-if="selectedList.length>0" class="btn" @click="submit">{{$t('component.完成')}}</button>
          <button v-else class="btn btn-no" @click="submit">{{$t('component.完成')}}</button>
        </footer>
      </div>
    </main>
  </div>
</template>

<script lang="ts">
import { defineComponent, reactive, watchEffect, toRefs, computed } from 'vue';

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
    type: {
      type: String,
      default: () => '',
    },
    isH5: {
      type: Boolean,
      default: () => false,
    },
    resultShow: {
      type: Boolean,
      default: () => true,
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      type: '',
      list: [],
      selectedList: [],
      isSearch: true,
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
      data.isCustomItem = props.isCustomItem;
      data.title = props.title;
      data.type = props.type;
    });

    // 可选项
    const optional = computed(() => data.list.filter((item: any) => !item.isDisabled));

    const handleInput = (e:any) => {
      ctx.emit('search', e.target.value);
    };

    const selected = (item:any) => {
      if (item.isDisabled) {
        return;
      }
      let list:any = data.selectedList;
      const index:number = list.indexOf(item);
      if (index > -1) {
        return data.selectedList.splice(index, 1);
      }
      if (props.isRadio) {
        list = [];
      }
      list.push(item);
      data.selectedList = list;
    };

    const selectedAll = () => {
      if (data.selectedList.length === optional.value.length) {
        data.selectedList = [];
      } else {
        data.selectedList = [...optional.value];
      }
    };

    const submit = () => {
      ctx.emit('submit', data.selectedList);
    };

    const cancel = () => {
      ctx.emit('cancel');
    };

    return {
      ...toRefs(data),
      optional,
      handleInput,
      selected,
      selectedAll,
      submit,
      cancel,
    };
  },
});
</script>

<style lang="scss" scoped src="./style/transfer.scss"></style>
