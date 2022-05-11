<template>
    <div class="group">
      <div  class="group-box">
      <header>
        <h1>{{$t('TUIConversation.发起多人会话（群聊）')}}</h1>
        <i class="icon icon-close" @click="cancel"></i>
      </header>
      <ul class="group-list">
        <li class="group-list-item">
            <label>{{$t('TUIConversation.群头像')}}</label>
            <img class="icon" :src="profile.avatar"/>
        </li>
        <li class="group-list-item">
            <label>{{$t('TUIConversation.群名称')}}</label>
            <!-- {{每个人的昵称}} -->
            <span v-if="!isEdit"></span>
            <input  v-else  type="text" v-model="profile.name" placeholder="请输入群名称">
        </li>
        <li class="group-list-item">
            <label>{{$t('TUIConversation.群ID')}}<text>({{$t('TUIConversation.选填')}})</text></label>
            <span v-if="!isEdit"></span>
            <input  v-else  type="text" v-model="profile.groupID">
        </li>
        <li class="group-list-item">
            <label>{{$t('TUIConversation.群类型')}}</label>
            <ul class="select">
              <li
                class="select-item"
                v-for="(item,index) in type"
                :key="index"
                :class="[profile.type === item.type && 'selected']"
                @click="selected(item)">
                <main>
                  <div class="select-item-header">
                    <aside class="left">
                      <img class="icon" :src="item.icon"/>
                      <span class="select-item-label">{{item.label}}</span>
                    </aside>
                    <i v-if="profile.type === item.type" class="icon icon-selected"></i>
                  </div>
                  <span class="select-item-detail">{{$t(`TUIConversation.${item.detail}`)}}</span>
                  <a :href="Link.product.url" target="view_window">{{$t(`TUIConversation.${item.src}`)}}</a>
                </main>
              </li>
            </ul>
        </li>
      </ul>
     <footer v-if="isEdit" class="group-profile-footer">
        <button class="btn-default" @click="cancel"><text>{{$t('TUIConversation.取消')}}</text></button>
        <button  v-if="profile.name === ''" class="btn-submit-nochoose"><text>{{$t('TUIConversation.创建')}}</text></button>
        <button  v-else class="btn-submit" @click="submit(profile)"><text>{{$t('TUIConversation.创建')}}</text></button>
      </footer>
      </div>
    </div>
</template>
<script lang="ts">
import { defineComponent, reactive, toRefs } from 'vue';
import Link from '../../../../utils/link';

const group:any = defineComponent({
  name: 'group',
  setup(props:any, ctx:any) {
    const data = reactive({
      gender: '',
      profile: {
        groupID: '',
        name: '',
        type: '',
        avatar: '',
        introduction: '',
        notification: '',
        joinOption: '',
      },
      editProfile: {},
      isEdit: true,
      isShowMale: false,
      isShowFemale: false,
      noShow: false,
      mask: true,
      type: [
        {
          icon: 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/assets/images/Public.svg',
          label: '陌生人社交群（Public）',
          type: group.TUIServer.TUICore.TIM.TYPES.GRP_PUBLIC,
          detail: '类似 QQ 群，创建后群主可以指定群管理员，用户搜索群 ID 发起加群申请后，需要群主或管理员审批通过才能入群。详见',
          src: '产品文档',
        },
        {
          icon: 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/assets/images/Meeting.svg',
          label: '临时会议群（Metting）',
          type: group.TUIServer.TUICore.TIM.TYPES.GRP_MEETING,
          detail: '创建后可以随意进出，且支持查看入群前消息；适合用于音视频会议场景、在线教育场景等与实时音视频产品结合的场景。详见',
          src: '产品文档',
        },
        {
          icon: 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/assets/images/Work.svg',
          label: '好友工作群（Work）',
          type: group.TUIServer.TUICore.TIM.TYPES.GRP_WORK,
          detail: '类似普通微信群，创建后仅支持已在群内的好友邀请加群，且无需被邀请方同意或群主神奇。详见',
          src: '产品文档',
        },
        {
          icon: 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/assets/images/AVChatroom.svg',
          label: '直播群（AVChatroom）',
          type: group.TUIServer.TUICore.TIM.TYPES.GRP_AVCHATROOM,
          detail: '创建后可以随意进出，没有群成员数量上限，但不支持历史消息存储；适合与直播产品结合，用于弹幕聊天场景。详见',
          src: '产品文档',
        },
      ],
    });

    data.profile.type = data.type[0].type;
    data.profile.avatar = data.type[0].icon;


    const selected = (item:any) => {
      if (data.profile.type !== item.type) {
        data.profile.type = item.type;
        data.profile.avatar = item.icon;
      }
    };

    const submit = (profile: any) => {
      const options:any =   {
        name: profile.name,
        type: profile.type,
        groupID: profile.groupID,
        avatar: profile.avatar,
      };
      ctx.emit('submit',  options);
    };

    const cancel = () => {
      ctx.emit('cancel');
    };

    return {
      ...toRefs(data),
      selected,
      submit,
      cancel,
      Link,
    };
  },
});
export default group;
</script>

<style lang="scss" scoped>
.group {
  padding: 30px;
  box-sizing: border-box;
  width: 750px;
  max-height: calc(100vh - 100px);
  overflow-y: auto;
  background: #FFFFFF;
  border-radius: 10px;
  &-list {
    &-item {
      display: flex;
      padding: 10px 0;
      label {
        width: 84px;
        height: 20px;
        font-family: PingFangSC-Regular;
        font-weight: 400;
        font-size: 14px;
        color: #333333;
      }
      input {
        box-sizing: border-box;
        flex: 1;
        padding: 6px 10px;
        border: 1px solid rgba(131,137,153,0.40);
        border-radius: 2px;
        font-weight: 400;
        font-size: 14px;
        color: #333333;
        line-height: 20px;
      }
      .select {
        flex: 1;
          a {
            color: #006EFF;
          }
        &-item {
          padding: 12px 20px;
          border: 1px solid rgba(131,137,153,0.40);
          border-radius: 2px;
          margin-bottom: 20px;
          &-header {
            display: flex;
            justify-content: space-between;
            .left {
              display: flex;
              align-items: center;
              font-weight: 500;
              font-size: 14px;
              color: #333333;
              .icon {
                margin-right: 12px;
              }
            }
            .icon-selected {
              position: relative;
              left: 12px;
              top: -4px;
            }
          }
          &-detail {
            padding-top: 6px;
            font-weight: 400;
            font-size: 14px;
            color: #4F4F4F;
          }
        }
        .selected {
          border: 1px solid #006EFF;
        }
      }
    }
  }
}
header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  h1 {
    padding-bottom: 20px;
    font-weight: 500;
    font-size: 16px;
    color: #333333;
    line-height: 30px;
  }
  .icon icon-close {
    left: 10px;
    top: -10px;
  }
}
.group-profile-footer   {
  padding-top: 10px;
  display: flex;
  justify-content: flex-end;
}
.btn-default {
    width: 82px;
    height: 32px;
    background: #FFFFFF;
    border: 1px solid #DDDDDD;
    border-radius: 4px;
}
.btn-default text {
    width: 28px;
    height: 20px;
    font-family: PingFangSC-Medium;
    font-weight: 500;
    font-size: 14px;
    color: #828282;
}
.btn-submit-nochoose {
    width: 82px;
    height: 32px;
    background: #e8e8e9;
    border: 1px solid #DDDDDD;
    border-radius: 4px;
    margin-left: 10px;
}
.btn-submit-nochoose text {
    width: 28px;
    height: 20px;
    font-family: PingFangSC-Regular;
    font-weight: 400;
    font-size: 14px;
    color: #FFFFFF;
    letter-spacing: 0;
}
.btn-submit {
    width: 82px;
    height: 32px;
    background: #3370FF;
    border: 0 solid #2F80ED;
    border-radius: 4px;
    margin-left: 10px;
}
.btn-submit text {
    width: 28px;
    height: 20px;
    font-family: PingFangSC-Regular;
    font-weight: 400;
    font-size: 14px;
    color: #FFFFFF;
    letter-spacing: 0;
}
</style>
