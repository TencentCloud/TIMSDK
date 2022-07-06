<template>
  <view class="message-image"  @tap="handlePreviewImage" >
    <image :src="data.info[1].url" :style="{height:imageHeight, width:imageWidth}" :class="['content-' + message.flow]"></image>
   <!-- <div class="progress"  v-if="data.progress">
      <progress :value="data.progress" max="1"></progress>
    </div> -->
  </view>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs, onMounted } from 'vue';

export default defineComponent({
  props: {
    data: {
      type: Array,
      default: () => {
        return [];
      }
    },
		messageData: {
		  type: Object,
		  default: () => {
		    return {};
		  }
		},
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      imageInfo: [],
			imageHeight: 0,
			imageWidth: 0,
			message: {},
    });
    
    watchEffect(()=>{
			// 等比例计算图片的 width、height
			const DEFAULT_MAX_SIZE = 155;
			let imageWidth = 0;
			let imageHeight = 0;
			data.message = props.messageData;
			data.imageInfo = props.data.info[1];
			 if (data.imageInfo.width >= data.imageInfo.height) {
			     imageWidth= DEFAULT_MAX_SIZE;
			     imageHeight = DEFAULT_MAX_SIZE * data.imageInfo.height / data.imageInfo.width;
			  } else {
					 imageWidth = DEFAULT_MAX_SIZE * data.imageInfo.width / data.imageInfo.height;
					 imageHeight = DEFAULT_MAX_SIZE;
			}
			
			// const imgHeight = data.imageInfo.height >= 140 ?  140 : data.imageInfo.height;
			// const imgWidth = imgHeight * data.imageInfo.width / data.imageInfo.height 
			data.imageWidth = imageWidth + 'px';
			data.imageHeight = imageHeight  + 'px';
		})
	
		// todo 优化 查看大图重新加载图片
		const handlePreviewImage = () => {
			console.error(props.data.info[0].url, '----linda')
			uni.previewImage({
				current: props.data.info[0].url,
				// 当前显示图片的http链接
				urls: [props.data.info[0].url],
			});
		}
    return {
      ...toRefs(data),
			handlePreviewImage
    };
  }
});
</script>
<style lang="scss" scoped>
.message-image {
  position: relative;
  img {
    max-width: 150px;
  }
  .progress {
    position: absolute;
    box-sizing: border-box;
    width: 100%;
    height: 100%;
    padding: 0 20px;
    left: 0;
    top: 0;
    background: rgba(#000000, 0.5);
    display: flex;
    align-items: center;
    progress {
      width: 100%;
    }
  }
}
.content {
		&-in {
			border-radius: 6px;
		}
		&-out {
			border-radius: 6px;
		}
 }

</style>
