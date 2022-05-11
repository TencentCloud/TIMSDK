<template>
  <div class="TUI-group">TUIGroup</div>
</template>
<script lang="ts">
import { defineComponent, reactive, toRefs } from 'vue';

const TUIGroup = defineComponent({
  name: 'TUIGroup',
  components: {},

  setup(props) {
    const TUIServer:any = TUIGroup.TUIServer;
    const data = reactive({
      groupList: [],
      searchGroup: [],
      searchID: '',
      currentGroup: null,
    });

    TUIServer.bind(data);

    return {
      ...toRefs(data),
    };
  },
});
export default TUIGroup;
</script>

<style lang="scss" scoped>
@import '../../styles/TUIGroup.scss';
</style>
