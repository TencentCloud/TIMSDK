const app = getApp();
const CONFIG = require('../config');
import genTestUserSig from '../../debug/GenerateTestUserSig.js'
Page({

	/**
	 * 页面的初始数据
	 */
	data: {
		tapTime: '',
    users: [
      {
        id: 0,
        identifier: 'u0'
      },
      {
        id: 1,
        identifier: 'u1'
      },
      {
        id: 2,
        identifier: 'u2'
      },
      {
        id: 3,
        identifier: 'u3'
      },
      {
        id: 4,
        identifier: 'u4'
      }
    ],
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

    let identifier = this.data.users[this.data.index].identifier
    let userConfig = genTestUserSig(identifier)

    var url = `../index/index?identifier=${identifier}&userSig=${userConfig.userSig}`;

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