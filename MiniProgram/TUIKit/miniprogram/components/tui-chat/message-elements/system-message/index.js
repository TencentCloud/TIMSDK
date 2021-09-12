import { parseGroupSystemNotice } from '../../../base/message-facade'
import { caculateTimeago } from '../../../base/common'
Component({
  /**
   * 组件的属性列表
   */
  properties: {
    message: {
      type: Object,
      value: '',
      observer(newVal) {
        console.log(parseGroupSystemNotice(newVal), '999')
        console.log(caculateTimeago(newVal.time * 1000))
        this.setData({
          message: newVal,
          messageTime: caculateTimeago(newVal.time * 1000),
          renderDom: parseGroupSystemNotice(newVal),
        })
      },
    },
  },

  /**
   * 组件的初始数据
   */
  data: {
    message: {},
    messageTime: '',
    renderDom: '',
  },
  lifetimes: {
    attached() {
      // 在组件实例进入页面节点树时执行
    },
    detached() {
      // 在组件实例被从页面节点树移除时执行
    },
  },
  /**
   * 组件的方法列表
   */
  methods: {


  },

  handleClick() {
    wx.showActionSheet({
      itemList: ['同意', '拒绝'],
      success: res => {
        const option = {
          handleAction: 'Agree',
          handleMessage: '欢迎进群',
          message: this.data.message,
        }
        if (res.tapIndex === 1) {
          option.handleAction = 'Reject'
          option.handleMessage = '拒绝申请'
        }
        wx.$TUIKit.handleGroupApplication(option)
          .then(() => {
            wx.showToast({ title: option.handleAction === 'Agree' ? '已同意申请' : '已拒绝申请' })
          })
          .catch((error) => {
            wx.showToast({
              title: error.message || '处理失败',
              icon: 'none',
            })
          })
      },
    })
  },


})
