<template>
	<view>
		<view class="TUI-fileMessage">
			<view class="fileMessage">
				<view class="fileMessage-box">
					<image class="file-icon" src="/static/static/images/file.png"></image>
					<label @tap="download" class="file-title">{{ filePayload.fileName }}</label>
				</view>
			</view>
		</view>
		<view class="pop" v-if="Show">
			<view class="text-box"><text class="download-confirm" @tap.stop="downloadConfirm">下载</text></view>
			<view class="text-box"><text class="abandon" @tap="cancel">取消</text></view>
		</view>
	</view>
</template>

<script>
export default {
	data() {
		return {
			Show: false,
			filePayload: {}
		};
	},

	components: {},
	props: {
		message: {
			type: Object,
			default: () => {}
		},
		isMine: {
			type: Boolean,
			default: true
		}
	},
	watch: {
		message: {
			handler: function(newVal) {
				this.setData({
					filePayload: newVal.payload
				});
			},
			immediate: true,
			deep: true
		}
	},
	methods: {
		download() {
			this.setData({
				Show: true
			});
		},

		downloadConfirm() {
			uni.downloadFile({
				url: this.filePayload.fileUrl,

				success(res) {
					const filePath = res.tempFilePath;
					uni.openDocument({
						filePath,

						success() {
							console.log('打开文档成功');
						}
					});
				}
			});
		},

		cancel() {
			this.setData({
				Show: false
			});
		}
	}
};
</script>
<style>
@import './index.css';
</style>
