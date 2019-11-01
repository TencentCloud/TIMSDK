<template>
  <div>
    <group-member-list :groupProfile="groupProfile" />
    <div class="group-info-content">
      <div class="info-item">
        <div class="label">群ID</div>
        <div class="content">{{ groupProfile.groupID }}</div>
      </div>
      <div class="info-item">
        <div class="label">
          群头像
          <i
              class="el-icon-edit"
              v-if="editable"
              @click="
            showEditFaceUrl = true
            inputFocus('editFaceUrl')
          "
              style="cursor:pointer; font-size:16px;"
          />
        </div>
        <div class="content" v-if="!showEditFaceUrl">
          <avatar :src="groupProfile.avatar"/>

        </div>
        <el-input
            ref="editFaceUrl"
            v-else
            autofocus
            v-model="avatar"
            size="mini"
            @blur="showEditFaceUrl = false"
            @keydown.enter.native="editFaceUrl"
        />
      </div>

      <div class="info-item">
        <div class="label">群类型</div>
        <div class="content">{{ groupProfile.type }}</div>
      </div>
      <div class="info-item">
        <div class="label">
          群名称
          <i
              class="el-icon-edit"
              v-if="editable"
              @click="
            showEditName = true
            inputFocus('editName')
          "
              style="cursor:pointer; font-size:16px;"
          />
        </div>

        <div class="content text-ellipsis" :title="groupProfile.name" v-if="!showEditName">
          {{ groupProfile.name || '暂无' }}
        </div>
        <el-input
            ref="editName"
            v-else
            autofocus
            v-model="name"
            size="mini"
            @blur="showEditName = false"
            @keydown.enter.native="editName"
        />
      </div>
      <div class="info-item">
        <div class="label">
          群介绍
          <i
              class="el-icon-edit"
              v-if="editable"
              @click="
            showEditIntroduction = true
            inputFocus('editIntroduction')
          "
              style="cursor:pointer; font-size:16px;"
          />
        </div>
        <div class="long-content" :title="groupProfile.introduction" v-if="!showEditIntroduction">
          {{ groupProfile.introduction || '暂无' }}
        </div>
        <el-input
            ref="editIntroduction"
            v-else
            autofocus
            v-model="introduction"
            size="mini"
            @blur="showEditIntroduction = false"
            @keydown.enter.native="editIntroduction"
        />
      </div>
      <div class="info-item">
        <div class="label">
          群公告
          <i
              class="el-icon-edit"
              v-if="editable"
              @click="
            showEditNotification = true
            inputFocus('editNotification')
          "
              style="cursor:pointer; font-size:16px;"
          />
        </div>
        <div class="long-content" :title="groupProfile.notification" v-if="!showEditNotification">
          {{ groupProfile.notification || '暂无' }}
        </div>

        <el-input
            ref="editNotification"
            v-else
            autofocus
            v-model="notification"
            size="mini"
            @blur="showEditNotification = false"
            @keydown.enter.native="editNotification"
        />
      </div>
      <div class="info-item" v-if="groupProfile.type !== 'Private'">
        <div class="label">
          申请加群方式
          <i
              class="el-icon-edit"
              v-if="editable"
              @click="
            showEditJoinOption = true
            inputFocus('editJoinOption')
          "
              style="cursor:pointer; font-size:16px;"
          />
        </div>
        <div class="content" v-show="!showEditJoinOption">
          {{ joinOptionMap[groupProfile.joinOption] }}
        </div>
        <el-select
            ref="editJoinOption"
            v-model="joinOption"
            v-show="showEditJoinOption"
            size="mini"
            automatic-dropdown
            @blur="showEditJoinOption = false"
            @change="editJoinOption"
        >
          <el-option label="自由加入" value="FreeAccess"></el-option>
          <el-option label="需要验证" value="NeedPermission"></el-option>
          <el-option label="禁止加群" value="DisableApply"></el-option>
        </el-select>
      </div>
      <div class="info-item">
        <div class="label">
          群消息提示类型
          <i
              class="el-icon-edit"
              v-if="editable"
              @click="
            showEditMessageRemindType = true
            inputFocus('editMessageRemindType')
          "
              style="cursor:pointer; font-size:16px;"
          />
        </div>
        <div class="content" v-show="!showEditMessageRemindType">
          {{ messageRemindTypeMap[this.groupProfile.selfInfo.messageRemindType] }}
        </div>
        <el-select
            ref="editMessageRemindType"
            v-show="showEditMessageRemindType"
            v-model="messageRemindType"
            size="mini"
            automatic-dropdown
            @change="editMessageRemindType"
            @blur="showEditMessageRemindType = false"
        >
          <el-option label="接收消息并提示" value="AcceptAndNotify"></el-option>
          <el-option label="接收消息但不提示" value="AcceptNotNotify"></el-option>
          <el-option label="屏蔽消息" value="Discard"></el-option>
        </el-select>
      </div>
      <!-- <div class="info-item">
        <div class="label">
          我的群名片
          <i
            class="el-icon-edit"
            @click="
              showEditNameCard = true
              inputFocus('editNameCard')
            "
            style="cursor:pointer; font-size:16px;"
          />
        </div>
        <div class="content cursor-pointer" v-if="!showEditNameCard">
          {{ groupProfile.selfInfo.nameCard || '暂无' }}
        </div>
        <el-input
          ref="editNameCard"
          v-else
          autofocus
          v-model="nameCard"
          size="mini"
          @blur="showEditNameCard = false"
          @keydown.enter.native="editNameCard"
        />
      </div> -->
      <div v-if="isOwner">
        <el-button type="text" @click="showChangeGroupOwner = true">转让群组</el-button>
        <el-input
            v-if="showChangeGroupOwner"
            v-model="newOwnerUserID"
            placeholder="新群主的userID"
            size="mini"
            @blur="showChangeGroupOwner = false"
            @keydown.enter.native="changeOwner"
        />
      </div>
      <div>
        <el-button type="text" style="color:red;" @click="quitGroup">退出群组</el-button>
      </div>
      <div v-if="showDissmissGroup">
        <el-button type="text" style="color:red;" @click="dismissGroup">解散群组</el-button>
      </div>
    </div>
  </div>
</template>

<script>
import GroupMemberList from './group-member-list.vue'
import { Select, Option } from 'element-ui'
export default {
  props: ['groupProfile'],
  components: {
    GroupMemberList,
    ElSelect: Select,
    ElOption: Option
  },
  data() {
    return {
      showEditName: false,
      showEditFaceUrl: false,
      showEditIntroduction: false,
      showEditNotification: false,
      showEditJoinOption: false,
      showChangeGroupOwner: false,
      showEditMessageRemindType: false,
      showEditNameCard: false,
      name: this.groupProfile.name,
      avatar: this.groupProfile.avatar,
      introduction: this.groupProfile.introduction,
      notification: this.groupProfile.notification,
      joinOption: this.groupProfile.joinOption,
      newOwnerUserID: '',
      messageRemindType: this.groupProfile.selfInfo.messageRemindType,
      nameCard: this.groupProfile.selfInfo.nameCard || '',
      messageRemindTypeMap: {
        AcceptAndNotify: '接收消息并提示',
        AcceptNotNotify: '接收消息但不提示',
        Discard: '屏蔽消息'
      },
      joinOptionMap: {
        FreeAccess: '自由加入',
        NeedPermission: '需要验证',
        DisableApply: '禁止加群'
      }
    }
  },
  computed: {
    editable() {
      return (
        this.groupProfile.type === this.TIM.TYPES.GRP_PRIVATE ||
        ['Owner', 'Admin'].includes(this.groupProfile.selfInfo.role)
      )
    },
    isOwner() {
      return this.groupProfile.selfInfo.role === 'Owner'
    },
    showDissmissGroup() {
      // 私有群不能解散
      return this.isOwner && this.groupProfile.type !== 'Private'
    }
  },
  watch: {
    groupProfile(groupProfile) {
      Object.assign(this, {
        showEditName: false,
        showEditFaceUrl: false,
        showEditIntroduction: false,
        showEditNotification: false,
        showEditJoinOption: false,
        showChangeGroupOwner: false,
        showEditNameCard: false,
        name: groupProfile.name,
        avatar: groupProfile.avatar,
        introduction: groupProfile.introduction,
        notification: groupProfile.notification,
        joinOption: groupProfile.joinOption,
        messageRemindType: groupProfile.messageRemindType,
        nameCard: groupProfile.selfInfo.nameCard || ''
      })
    }
  },
  methods: {
    inputFocus(ref) {
      this.$nextTick(() => {
        this.$refs[ref].focus()
      })
    },
    editName() {
      this.tim
        .updateGroupProfile({
          groupID: this.groupProfile.groupID,
          name: this.name.trim()
        })
        .then(() => {
          this.showEditName = false
        })
    },
    editFaceUrl() {
      this.tim
        .updateGroupProfile({
          groupID: this.groupProfile.groupID,
          avatar: this.avatar.trim()
        })
        .then(() => {
          this.showEditFaceUrl = false
        })
    },
    editIntroduction() {
      this.tim
        .updateGroupProfile({
          groupID: this.groupProfile.groupID,
          introduction: this.introduction.trim()
        })
        .then(() => {
          this.showEditIntroduction = false
        })
    },
    editNotification() {
      this.tim
        .updateGroupProfile({
          groupID: this.groupProfile.groupID,
          notification: this.notification.trim()
        })
        .then(() => {
          this.showEditNotification = false
        })
    },
    editJoinOption() {
      this.tim
        .updateGroupProfile({
          groupID: this.groupProfile.groupID,
          joinOption: this.joinOption
        })
        .then(() => {
          this.showEditJoinOption = false
        })
    },
    changeOwner() {
      this.tim
        .changeGroupOwner({
          groupID: this.groupProfile.groupID,
          newOwnerID: this.newOwnerUserID
        })
        .then(() => {
          this.showChangeGroupOwner = false
          this.$store.commit('showMessage', {
            message: `转让群主成功，新群主ID：${this.newOwnerUserID}`
          })
          this.newOwnerUserID = ''
        })
    },
    quitGroup() {
      this.tim.quitGroup(this.groupProfile.groupID).then(({ data: { groupID } }) => {
        this.$store.commit('showMessage', {
          message: '退群成功'
        })
        if (groupID === this.groupProfile.groupID) {
          this.$store.commit('resetCurrentConversation')
        }
      })
    },
    dismissGroup() {
      this.tim.dismissGroup(this.groupProfile.groupID).then(({ data: { groupID } }) => {
        this.$store.commit('showMessage', {
          message: `群：${this.groupProfile.name || this.groupProfile.groupID}解散成功！`,
          type: 'success'
        })
        if (groupID === this.groupProfile.groupID) {
          this.$store.commit('resetCurrentConversation')
        }
      })
    },
    editMessageRemindType() {
      this.tim
        .setMessageRemindType({
          groupID: this.groupProfile.groupID,
          messageRemindType: this.messageRemindType
        })
        .then(() => {
          this.showEditMessageRemindType = false
        })
    },
    editNameCard() {
      if (this.nameCard.trim().length === 0) {
        this.$store.commit('showMessage', {
          message: '不能设置空的群名片',
          type: 'warning'
        })
        return
      }
      this.tim
        .setGroupMemberNameCard({
          groupID: this.groupProfile.groupID,
          nameCard: this.nameCard.trim()
        })
        .then(() => {
          this.showEditNameCard = false
        })
    }
  }
}
</script>

<style lang="stylus">
.group-info-content
  padding 10px 10px
  .avatar
    width 40px
    height 40px
    border-radius 50%
.info-item {
  margin-bottom: 12px;

  .label {
    font-size: 14px;
    color: $secondary;
  }
  .content {
    color: $background;
    word-wrap: break-word;
    word-break: break-all;
  }
  .long-content {
    word-wrap:break-word;
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-box-orient: vertical;
    -webkit-line-clamp: 3;
  }
}
.cursor-pointer {
  cursor: pointer;
}
/* 设置滚动条的样式 */
::-webkit-scrollbar {
  width: 0px;
  height: 0px;
}
</style>
