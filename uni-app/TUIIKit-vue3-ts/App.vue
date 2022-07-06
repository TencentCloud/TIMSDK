<script>
	import { SDKAPPID } from './debug'
	export default {
		onLaunch: function() {
			console.log('App onLaunch')
			uni.$aegis.reportEvent({
					name: 'onLaunch',
					ext1: 'onLaunch-success',
					ext2: 'uniTuikitExternalVue3',
					ext3: `${SDKAPPID}`,
			})
		},
		onShow: function() {
			console.log('App Show')
		},
		onHide: function() {
			console.log('App Hide')
		}
	}
</script>

<style lang="scss">
</style>
