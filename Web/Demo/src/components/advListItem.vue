<template>
  <li class="adv-list-item">
    <div class="show-box" @click="showEvent">
      <label class="img-box">
        <img :src="item?.icon" alt="">
      </label>
      <span class="name">{{item?.name && $t(`Login.${item?.name}`)}}</span>
    </div>
    <div class="show-box hover-box" @click="hoverEvent">
      <label class="img-box">
        <img :src="item?.link" alt="">
      </label>
      <span class="name">{{item?.detail && $t(`Login.${item?.name}`)}}</span>
      <span class="name">{{item?.detail && $t(`Login.${item?.detail}`)}}</span>
    </div>
  </li>
</template>

<script lang="ts">
import { defineComponent } from 'vue';

export default defineComponent({
  props: {
    item: {
      type: Object,
      default: () => ({}),
    },
  },

  setup(props:any, ctx:any) {
    const showEvent = () => {
      ctx.emit('showEvent', props.item);
    };

    const hoverEvent = () => {
      ctx.emit('hoverEvent', props.item);
    };

    return {
      showEvent,
      hoverEvent,
    };
  },
});
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.adv-list-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  &:hover {
    .show-box{
      display: none;
    }
    .hover-box {
      display: flex;
    }
  }
  .show-box {
    display: flex;
    flex-direction: column;
    align-items: center;
    .img-box {
      width: 82px;
      height: 82px;
      border-radius: 8px;
      background: rgba(255,255,255,1);
      box-shadow: 0 8px 12px 0 rgba(223,235,253,0.5);
      display: flex;
      justify-content: center;
      align-items: center;
      img {
        max-width: 100%;
        max-height: 100%;
      }
    }
    .name {
      color: rgba(0,0,0,1);
      font-size: 12px;
      font-weight: 400;
      font-family: "PingFang SC";
      text-align: left;
      line-height: 16px;
      height: 16px;
      padding-top: 8px;
    }
  }
  .hover-box {
    display: none;
    position: relative;
    top: -15px;
  }
}
</style>
