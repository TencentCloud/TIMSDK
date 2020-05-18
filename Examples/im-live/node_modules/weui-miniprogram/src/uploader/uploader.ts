Component({
    options: {
        addGlobalClass: true,
    },
    properties: {
        title: {
            type: String,
            value: '图片上传'
        },
        sizeType: {
            type: Array,
            value: ['original', 'compressed']
        },
        sourceType: {
            type: Array,
            value: ['album', 'camera']
        },
        maxSize: {
            type: Number,
            value: 5 * 1024 * 1024
        },
        maxCount: { // 最多上传多少个文件
            type: Number,
            value: 1
        },
        files: { // 当前的图片列表, {url, error, loading}
            type: Array,
            value: [],
            observer: function(newVal, oldVal, changedP) {
                this.setData({
                    currentFiles: newVal
                })
            }
        },
        select: { // 过滤某个文件
            type: Function,
            value: function() {}
        },
        upload: { // 返回Promise的一个文件上传的函数
            type: Function,
            value: null
        },
        tips: {
            type: String,
            value: ''
        },
        extClass: {
            type: String,
            value: '',
        },
        showDelete: { // 是否显示delete按钮
            type: Boolean,
            value: true
        },
    },
    data: {
        currentFiles: [],
        showPreview: false,
        previewImageUrls: []
    },
    ready() {
    },
    methods: {
        previewImage(e) {
            const {index} = e.currentTarget.dataset
            const previewImageUrls = []
            this.data.files.map(item => {
                previewImageUrls.push(item.url)
            })
            this.setData({
                previewImageUrls: previewImageUrls,
                previewCurrent: index,
                showPreview: true
            })
        },
        chooseImage(e) {
            if (this.uploading) return
            wx.chooseImage({
                count: this.data.maxCount - this.data.files.length,
                success: (res) => {
                    // console.log('chooseImage resp', res)
                    // 首先检查文件大小
                    let invalidIndex = -1
                    // @ts-ignore
                    res.tempFiles.forEach((item, index) => {
                        if (item.size > this.data.maxSize) {
                            invalidIndex = index
                        }
                    });
                    if (typeof this.data.select === 'function') {
                        const ret = this.data.select(res)
                        if (ret === false) {
                            return
                        }
                    }
                    if (invalidIndex >= 0) {
                        this.triggerEvent('fail', {type: 1, errMsg: `chooseImage:fail size exceed ${this.data.maxSize}`, total: res.tempFilePaths.length, index: invalidIndex}, {})
                        return
                    }
                    // 获取文件内容
                    const mgr = wx.getFileSystemManager()
                    const contents = res.tempFilePaths.map(item => {
                        const fileContent = mgr.readFileSync(item)
                        return fileContent
                    })
                    const obj = {tempFilePaths: res.tempFilePaths, tempFiles: res.tempFiles, contents}
                    // 触发选中的事件，开发者根据内容来上传文件，上传了把上传的结果反馈到files属性里面
                    this.triggerEvent('select', obj, {})
                    const files = res.tempFilePaths.map((item, i) => {
                        // @ts-ignore
                        return {loading: true, url: `data:image/jpg;base64,${wx.arrayBufferToBase64(contents[i])}`}
                    })
                    if (!files || !files.length) return
                    if (typeof this.data.upload === 'function') {
                        const len = this.data.files.length
                        const newFiles = this.data.files.concat(files)
                        this.setData({files: newFiles, currentFiles: newFiles})
                        this.loading = true
                        this.data.upload(obj).then(json => {
                            this.loading = false
                            if (json.urls) {
                                const oldFiles = this.data.files
                                json.urls.forEach((url, index) => {
                                    oldFiles[len + index].url = url
                                    oldFiles[len + index].loading = false
                                })
                                this.setData({files: oldFiles, currentFiles: newFiles})
                                this.triggerEvent('success', json, {})
                            } else {
                                this.triggerEvent('fail', {type: 3, errMsg: 'upload file fail, urls not found'}, {})
                            }
                        }).catch(err => {
                            this.loading = false
                            const oldFiles = this.data.files
                            res.tempFilePaths.map((item, index) => {
                                oldFiles[len + index].error = true
                                oldFiles[len + index].loading = false
                            })
                            this.setData({files: oldFiles, currentFiles: newFiles})
                            this.triggerEvent('fail', {type: 3, errMsg: 'upload file fail', error: err}, {})
                        })
                    }
                },
                fail: (fail:any) => {
                    if (fail.errMsg.indexOf('chooseImage:fail cancel') >= 0) {
                        this.triggerEvent('cancel', {}, {})
                        return
                    }
                    fail.type = 2
                    this.triggerEvent('fail', fail, {})
                }
            })
        },
        deletePic(e) {
            const index = e.detail.index
            const files = this.data.files
            const file = files.splice(index, 1)
            this.setData({
                files,
                currentFiles: files
            })
            this.triggerEvent('delete', {index, item: file[0]})
        }
    }
})
