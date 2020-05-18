Component({
    options: {
        addGlobalClass: true
    },
    properties: {
        extClass: {
            type: String,
            value: ''
        },
        show: { // 默认显示出来
            type: Boolean,
            value: true,
            observer: function (newValue) {
                this._computedStyle(newValue, this.data.animated)
            }
        },
        animated: {
            type: Boolean,
            value: false,
            observer: function (newValue) {
                this._computedStyle(this.data.show, newValue)
            }
        },
        duration: { // 过渡动画时间
            type: Number,
            value: 350
        },
        type: {
            type: String,
            value: 'dot-gray' // 取值dot-white、dot-gray、circle
        },
        tips: { // type是circle的时候才有效
            type: String,
            value: '加载中'
        }
    },
    data: {
        animationData: {},
        animationInstance: {},
        displayStyle: 'none',
    },
    methods: {
        _computedStyle(show, animated) {
            if (!show) {
                if (!animated) {
                    this.setData({
                        displayStyle: 'none'
                    })
                } else {
                    this._startAnimation()
                }
            } else {
                this.setData({
                    displayStyle: '',
                })
            }
        },
        _startAnimation() {
            setTimeout(() => {
                const data: any = this.data
                const animation = data.animationInstance
                animation.height(0).step()
                this.setData({
                    animationData: animation.export()
                })
            }, 0)
        }
    },
    lifetimes: {
        attached() {
            const data: any = this.data
            const animationInstance = wx.createAnimation({
                duration: data.duration,
                timingFunction: 'ease',
            })
            this.setData({ animationInstance })
            this._computedStyle(this.data.show, this.data.animated)
        }
    }
})
