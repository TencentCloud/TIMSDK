<template>
  <div class="imagePreviewer">
    <main class="viewer">
      <!-- <i class="reduce" v-if="currentImageIndex>=1" @click="currentImageIndex--">-</i> -->
      <img :src="ImageList[currentImageIndex].payload.imageInfoArray[0].url">
      <!-- <i class="plus" v-if="currentImageIndex<ImageList.length-1" @click="currentImageIndex++">+</i> -->
    </main>

  </div>
</template>

<script lang="ts">
import { defineComponent, reactive, watchEffect, toRefs } from 'vue';

const ImagePreviewer = defineComponent({
  props: {
    data: {
      type: Array,
      default: () => [],
    },
    currentImage: {
      type: Object,
      default: () => ({}),
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      ImageList: [],
      currentImageIndex: 0,
    });

    watchEffect(() => {
      data.ImageList = props.data;
      data.ImageList.map((message:any, index:number) => {
        if (props.currentImage.ID === message.ID) {
          data.currentImageIndex = index;
        }
      });
    });

    return {
      ...toRefs(data),
    };
  },
});
export default ImagePreviewer;
</script>

<style lang="scss" scoped>
.imagePreviewer {
    position: relative;
    display: flex;
    justify-content: center;
    align-items: center;
    box-sizing: border-box;
    padding: 30px;
    .viewer {
      flex: 1;
      display: flex;
      justify-content: center;
      align-items: center;
      img {
        max-width: 100%;
        max-height: 100%;
      }
    }
  }
.reduce, .plus {
  display: inline-flex;
  width: 50px;
  height: 50px;
  margin: 10px;
  border-radius: 50px;
  font-size: 30px;
  background: #ffffff;
  justify-content: center;
  align-items: center;
}
</style>
