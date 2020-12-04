<template>
  <div class="chat-footer-container">
    <!-- <p class="gift-title">礼物列表</p> -->
    <carousel :autoplay="false" :loop="false" :initial-index="1" indicator-position="none" arrow="always">
      <carousel-item v-for="(item, index) in giftList" :key="`item_${index}`">
        <template v-for="(_item, _index) in item">
          <div class="gift-item" :key="`gift_item_${index}_${_index}`" @click="handleGiftPic(_item.index)">
            <img class="gift-icon" :src="_item.icon" alt=""/>
            <p class="gift-name">{{ _item.name }}</p>
          </div>
        </template>
      </carousel-item>
    </carousel>
  </div>
</template>

<script>
 import { Carousel , CarouselItem } from 'element-ui'
  export default {
    name: 'liveGift',
    props: {},
    data() {
      return {
        giftList: [
          [
            {
              index: 1,
              icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590482989_25.png',
              name: '火箭'
            },
            {
              index: 2,
              icon: 'https://8.url.cn/huayang/resource/now/new_gift/1507876726_3',
              name: '鸡蛋'
            },
            {
              index: 3,
              icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590482294_7.png',
              name: '吻'
            },
          ],
          [
            {
              index: 4,
              icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590482461_11.png',
              name: '跑车'
            },
            {
              index: 5,
              icon: 'https://8.url.cn/huayang/resource/now/new_gift/1594714453_7.png',
              name: '嘉年华'
            },
            {
              index: 6,
              icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590482754_17.png',
              name: '玫瑰'
            }
          ],
          [
            {
              index: 7,
              icon: 'https://8.url.cn/huayang/resource/now/new_gift/1594281297_11.png',
              name: '直升机'
            },
            {
              index: 8,
              icon: 'https://8.url.cn/huayang/resource/now/new_gift/1507876472_1',
              name: '点赞'
            },
            {
              index: 9,
              icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590483038_27.png',
              name: '比心'
            }
          ],
          [
            {
              index: 10,
              icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590483168_31.png',
              name: '冰淇淋'
            },
            {
              index: 11,
              icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590483225_33.png',
              name: '玩偶'
            },
            {
              index: 12,
              icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590483278_35.png',
              name: '蛋糕'
            }
          ],
          [
            {
              index: 13,
              icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590483348_37.png',
              name: '豪华轿车'
            },
            {
              index: 14,
              icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590483429_39.png',
              name: '游艇'
            },
            {
              index: 15,
              icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590483505_41.png',
              name: '翅膀'
            }
          ]
        ]
      }
    },
    components: {
      Carousel,
      CarouselItem
    },
    methods: {
      handleGiftPic(index) {
        this.$bus.$emit('group-live-send-gift', index)
      }
    }
  }
</script>

<style lang="stylus" scoped>
 .chat-footer-container {
   position relative
   width 100%
   height 50px
   box-sizing border-box
   border-top 1px solid #e6e6e6
   .gift-title {
     margin 10px 0 0 0
     padding 0 10px
     font-size 16px
     font-weight 400
     color #888585
     border-bottom 1px solid #e6e6e6
   }

 }
</style>
<style>
  .el-carousel {
    height: 60px;
  }
  .el-carousel .el-carousel__container {
    height: 100%;
  }
  .el-carousel__arrow {
    top: 40%!important
  }
  .el-carousel__item {
    padding: 0px 30px 0 45px;
    box-sizing: 'border-box'
  }
  .el-carousel__item div {
    float: left;
    margin: 0 15px;
    width: 65px;
    height: 40px;
    cursor: pointer;
  }
  .el-carousel__item div img {
    width: 30px;
    height: 30px;
    margin: 0 0 0 15px;
  }
  .el-carousel__item div p {
    position: relative;
    top: -8px;
    margin: 0;
    text-align: center;
    color: #888585;
    font-size: 12px;
  }
</style>