<template>
  <div class="list-container">
    <div class="group-container">
      <div class="header-bar">
        <el-autocomplete
          :value-key="'groupID'"
          :debounce="500"
          size="mini"
          v-model="groupID"
          placeholder="输入群ID搜索"
          :fetch-suggestions="searchGroupByID"
          class="group-seach-bar"
          prefix-icon="el-icon-search"
          :hide-loading="hideSearchLoading"
          @input="hideSearchLoading = false"
          @select="applyJoinGroup"
        ></el-autocomplete>
        <button title="创建群组" @click="showCreateGroupModel">
          <i class="tim-icon-add"></i>
        </button>
      </div>
      <group-item v-for="group in groupList" :key="group.groupID" :group="group" />
      <el-dialog title="创建群组" :visible="createGroupModelVisible" @close="closeCreateGroupModel" width="30%">
        <create-group></create-group>
      </el-dialog>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import { Dialog, Autocomplete } from 'element-ui'
import CreateGroup from './create-group.vue'
import GroupItem from './group-item.vue'
export default {
  data() {
    return {
      groupID: '',
      hideSearchLoading: true
    }
  },
  components: {
    GroupItem,
    ElDialog: Dialog,
    CreateGroup,
    ElAutocomplete: Autocomplete
  },
  computed: {
    groupList: function() {
      return this.$store.state.group.groupList
    },
    ...mapState({
      createGroupModelVisible: state => {
        return state.group.createGroupModelVisible
      }
    })
  },
  methods: {
    onGroupUpdated(groupList) {
      this.$store.dispatch('updateGroupList', groupList)
    },
    createGroup() {},
    closeCreateGroupModel() {
      this.$store.commit('updateCreateGroupModelVisible', false)
    },
    searchGroupByID(queryString, showInSearchResult) {
      if (queryString.trim().length > 0) {
        this.hideSearchLoading = false
        this.tim
          .searchGroupByID(queryString)
          .then(({ data: { group } }) => {
            showInSearchResult([group])
          })
          .catch(() => {
            this.$store.commit('showMessage', {
              message: '没有找到该群',
              type: 'error'
            })
          })
      } else {
        this.hideSearchLoading = true
      }
    },
    showCreateGroupModel() {
      this.$store.commit('updateCreateGroupModelVisible', true)
    },
    applyJoinGroup(group) {
      this.tim
        .joinGroup({ groupID: group.groupID, type: group.type })
        .then(res => {
          switch(res.data.status) {
            case this.TIM.TYPES.JOIN_STATUS_WAIT_APPROVAL:
              this.$store.commit('showMessage', {
                message: '申请成功，等待群管理员确认。',
                type: 'info'
              })
              break
            case this.TIM.TYPES.JOIN_STATUS_SUCCESS:
              this.$store.commit('showMessage', {
                message: '加群成功',
                type: 'success'
              })
              break
            case this.TIM.TYPES.JOIN_STATUS_ALREADY_IN_GROUP:
              this.$store.commit('showMessage', {
                message: '您已经是群成员了，请勿重复加群哦！',
                type: 'info'
              })
              break
            default: break
          }
        })
        .catch(error => {
          this.$store.commit('showMessage', {
            message: error.error.message,
            type: 'error'
          })
        })
    }
  }
}
</script>

<style lang="stylus" scoped>
.list-container
  height 100%
  width 100%
  display flex
  flex-direction column
  .header-bar
    display: flex;
    flex-shrink 0
    height 50px
    border-bottom 1px solid $background-deep-dark
    padding 10px 10px 10px 20px
    .group-seach-bar
      width 100%
      margin-right 10px
      >>> .el-input
        input
          color $first
          border none
          border-radius 30px
          background-color $deep-background !important
          &::placeholder
            color $font-dark
        .el-icon-search
          color $font-dark
    button
      float right
      display: inline-block;
      cursor: pointer;
      background $background-deep-dark
      border: none
      color: $font-dark;
      box-sizing: border-box;
      transition: .3s;
      -moz-user-select: none;
      -webkit-user-select: none;
      -ms-user-select: none;
      margin: 0
      padding 0
      width 30px
      height 30px
      line-height 34px
      font-size: 24px;
      text-align: center;
      white-space: nowrap;
      border-radius: 50%
      outline 0
      flex-shrink 0
      &:hover
        transform: rotate(360deg);
        color $light-primary
  .scroll-container
    overflow-y scroll
    flex 1

</style>
