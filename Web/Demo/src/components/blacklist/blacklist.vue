<template>
  <div class="blacklist-wrapper" :class="{'default': !hasBlacklist}">
    <div v-if="hasBlacklist">
      <blacklist-item
        v-for="item in blacklist"
        :key="item.userID"
        :profile="item"
      />
    </div>
    <span style="color:gray" v-else>黑名单还是空的</span>
  </div>
</template>

<script>
import BlacklistItem from './blacklist-item'
import { mapState } from 'vuex'
export default {
  name: 'Blacklist',
  components: {
    BlacklistItem
  },
  computed: {
    ...mapState({
      blacklist: state => state.blacklist.blacklist
    }),
    hasBlacklist() {
      return this.blacklist.length > 0
    }
  }
}
</script>

<style lang="stylus" scoped>
.blacklist-wrapper {
  padding: 12px;
  overflow-y: scroll;
}
.default {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
}
</style>
