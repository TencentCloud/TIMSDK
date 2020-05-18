Component({
    options: {
        addGlobalClass: true,
        multipleSlots: true,
    },
    properties: {
        hover: {
            type: Boolean,
            value: false,
        },
        link: {
            type: Boolean,
            value: false,
        },
        extClass: {
            type: String,
            value: ''
        },
        iconClass: {
            type: String,
            value: ''
        },
        bodyClass: {
            type: String,
            value: ''
        },
        icon: {
            type: String,
            value: '',
        },
        title: { // 和icon二选一，都是放在cell_hd里面
            type: String,
            value: '',
        },
        value: {
            type: String,
            value: '',
        },
        showError: {
            type: Boolean,
            value: false
        },
        prop: { // 校验的属性，给父元素form使用
            type: String,
            value: ''
        },
        url: { // 在link为true的时候有效，表示navigator的跳转url
            type: String,
            value: ''
        },
        footerClass: {
            type: String,
            value: ''
        },
        footer: {
            type: String,
            value: ''
        },
        inline: { // 左右布局样式还是上下布局
            type: Boolean,
            value: true
        },
        hasHeader: {
            type: Boolean,
            value: true
        },
        hasFooter: {
            type: Boolean,
            value: true
        },
        hasBody: {
            type: Boolean,
            value: true
        }
    },
    relations: {
        '../form/form': {
            type: 'ancestor',
        },
        '../cells/cells': {
            type: 'ancestor',
        }
    },
    data: {
        inForm: false
    },
    methods: {
        setError(error) {
            this.setData({
                error: error || false
            })
        },
        setInForm() {
            this.setData({
                inForm: true
            })
        },
        setOuterClass(className) {
            this.setData({
                outerClass: className
            })
        },
        navigateTo() {
            const data:any = this.data
            if (data.url && data.link) {
                wx.navigateTo({
                    url: data.url,
                    success: (res) => {
                        this.triggerEvent('navigatesuccess', res, {})
                    },
                    fail: (fail) => {
                        this.triggerEvent('navigateerror', fail, {})
                    }
                })
            }
        }
    }
})
