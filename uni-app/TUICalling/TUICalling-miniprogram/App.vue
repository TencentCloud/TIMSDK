<script>
import TIM from 'tim-wx-sdk';
import { genTestUserSig } from './debug/GenerateTestUserSig.js'
  
export default {  
	globalData: {  
		SDKAppID: genTestUserSig('').sdkAppID,
		userID: '',
		userSig: '' 
	},  
	onLaunch() {  
		// 重点注意： 为了 uni-app 更好地接入使用 tim，快速定位和解决问题，请勿修改 uni.$TUIKit 命名。
		// 如果您已经接入 tim ，请将 uni.tim 修改为 uni.$TUIKit。
		uni.$TUIKit = TIM.create({
		  SDKAppID: this.globalData.SDKAppID
		});
		// 如果您已创建了 tim，请将 tim 实例挂载在 wx 上。完成 TUICalling 初始化，如果您没有创建，可以不传
	 	// wx.$TIM = uni.$TUIKit
	 },  
	onShow() {  
		console.log('App Show')  
	},  
	onHide() {  
		console.log('App Hide')  
	}  
}
</script>
<style>
</style>
