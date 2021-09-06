<template>
    <div>
        <message-bubble :isMine=isMine  :message=message>
            <div class="merger-box" @click="mergerHandler(message)">
                <p class="merger-title">{{payload.title}}</p>
                <p class="merger-text" v-for="(item, index) in payload.abstractList" :key="index">
                    {{item}}
                </p>
            </div>
            <span class="merger-text"> 聊天记录</span>
        </message-bubble>
    </div>
</template>

<script>
  import MessageBubble from '../message-bubble'
  export default {
    name: 'MergerElemnt',
    props: {
      payload: {
        type: Object,
        required: true
      },
      message: {
        type: Object,
        required: true
      },
      isMine: {
        type: Boolean
      }
    },
    components: {
      MessageBubble
    },
    data() {
      return {
        mergerContment:{
          title:'',

        }

      }
    },
    computed: {
    },
      methods: {
        mergerHandler(message) {
          this.$bus.$emit('mergerMessageShow', message)
        },
        onImageLoaded(event) {
          this.$bus.$emit('image-loaded', event)
        },
        handlePreview() {
          this.$bus.$emit('image-preview', {
            url: this.payload.imageInfoArray[0].url
          })
        }
      }
    }
</script>

<style lang="stylus" scoped>
    .image-element
        max-width 250px
        cursor zoom-in

    .merger-box {
        border-bottom: 1px #b3b3b3 solid;
        padding: 0 5px 5px -5px;
        margin-bottom 5px
        .merger-title {
            max-width 220px
            min-width 180px
            overflow: hidden;
            font-size 15px
            text-overflow:ellipsis;
            white-space: nowrap;
        }
    }
    .merger-text {
        color #b3b3b3
        margin 10px 0
        font-size 13px
        max-width 280px
        overflow hidden;
        text-overflow ellipsis;
        white-space nowrap;
    }
    .message-send  .merger-text {
        color rgba(255,255,255,0.8)
        margin 10px 0
        font-size 13px
    }
    .message-send .merger-box {
        border-bottom: 1px rgba(255, 255, 255, 0.6) solid
    }
</style>
