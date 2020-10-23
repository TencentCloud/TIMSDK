<script>
export default {
  created () {
  }
}
</script>

<style lang="stylus">
@import "stylus/base.styl"
.button-disabled
  color $dark-background !important
  background-color transparent !important
.input-focus
  transition: all 0.2s ease-in-out;
  border-bottom 1px solid $primary !important
</style>
