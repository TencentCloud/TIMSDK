const app = getApp();
const CONFIG = require('../config');

Page({

	/**
	 * 页面的初始数据
	 */
	data: {
		tapTime: '',
		users: CONFIG.users,
		index: 0
	},

	userChange: function (e) {
		this.setData({
			index: e.detail.value
		})
	},

	// 进入聊天室
	entry: function () {

		var self = this;
		// 防止两次点击操作间隔太快
		var nowTime = new Date();
		if (nowTime - this.data.tapTime < 1000) {
			return;
		}
		var identifier = this.data.users[this.data.index]['identifier'];
		var userSig = this.data.users[this.data.index]['userSig'];

		var url = `../index/index?identifier=${identifier}&userSig=${userSig}`;

		wx.navigateTo({
			url: url
		});

		wx.showToast({
			title: '登录IM',
			icon: 'success',
			duration: 1000
		})

		self.setData({
			'tapTime': nowTime
		});
	}
})