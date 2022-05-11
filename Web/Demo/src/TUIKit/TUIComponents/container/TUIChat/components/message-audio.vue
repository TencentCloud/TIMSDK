<template>
  <div class="message-audio" :class="[data.message.flow === 'out' && 'reserve']" @click.self="play">
    <label>{{data.second}}s</label>
    <i class="icon icon-voice" :class="[data.message.flow === 'out' && 'icon-reserve']"></i>
    <audio ref="audio" :src="data.url" controls></audio>
    <div v-if="show" class="mask" @click.self="play"></div>
    <!-- <progress v-if="data.progress" :value="data.progress" max="1"></progress> -->
  </div>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs, ref } from 'vue';

export default defineComponent({
  props: {
    data: {
      type: Object,
      default: () => ({}),
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      data: {},
      show: false,
    });

    const audio = ref(null);

    watchEffect(() => {
      data.data = props.data;
    });
    const play = () => {
      const audioPlayer:any = audio.value;
      if (audioPlayer.paused) {
        audioPlayer.play();
        data.show = true;
      } else {
        audioPlayer.pause();
        audioPlayer.load();
        data.show = false;
      }
    };

    return {
      ...toRefs(data),
      audio,
      play,
    };
  },
});
</script>
<style lang="scss" scoped>
.message-audio {
  display: flex;
  align-items: center;
  position: relative;
  .icon {
    margin: 0 4px;
  }
  audio {
    width: 0;
    height: 0;
  }
}
.reserve {
  flex-direction: row-reverse;
}
.mask {
  position: fixed;
  width: 100vw;
  height: 100vh;
  top: 0;
  left: 0;
  opacity: 0;
  z-index: 1;
}
</style>
