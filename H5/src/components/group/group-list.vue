<template>
  <div class="list-container">
    <div class="group-container">
      <el-dialog title="创建群组" :visible="createGroupModelVisible" @close="closeCreateGroupModel">
        <create-group></create-group>
      </el-dialog>
      <div class="header-bar">
        <el-autocomplete
          :value-key="'name' || 'groupID'"
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
        <i class="el-icon-plus create-group-button" title="创建群组" @click="showCreateGroupModel"></i>
      </div>
      <group-item v-for="group in groupList" :key="group.groupID" :group="group" />
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
            this.$message('没有找到该群')
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
          if (res.data.status === 'JoinedSuccess') {
            this.$message({ message: '加群成功', type: 'success' })
          } else {
            this.$message.info('申请成功，等待群管理员确认。')
          }
        })
        .catch(error => {
          this.$message.error(error.error.message)
        })
    }
  }
}
</script>

<style scoped>
.header-bar {
  display: flex;
  justify-content: center;
  align-items: center;
  border-bottom: 1px solid #d1d1d1;
  background: #dcdcdc;
  height: 40px;
}
.group-seach-bar {
  width: 75%;
  margin: 6px auto;
  display: block;
}
.create-group-button {
  font-size: 20px;
  background: #fff;
  color: gray;
  padding: 3px;
  border-radius: 3px;
  border: 1px solid #cecece;
  margin-right: 6px;
  cursor: pointer;
}
</style>
