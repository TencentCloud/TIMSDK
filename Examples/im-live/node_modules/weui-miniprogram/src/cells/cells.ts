Component({
    options: {
        addGlobalClass: true,
        multipleSlots: true,
    },
    properties: {
        title: {
            type: String,
            value: '',
        },
        extClass: {
          type: String,
          value: ''
        },
        footer: {
          type: String,
          value: ''
        }
    },
    data: {
        firstItem: null,
        checkboxCount: 0,
        checkboxIsMulti: false,
        outerClass: '',
        childClass: '',
    },
    relations: {
        '../cell/cell': {
            type: 'descendant',
            linked(target) {
                if (!this.data.firstItem) {
                    this.data.firstItem = target
                }
                if (target !== this.data.firstItem) {
                    target.setOuterClass('weui-cell_wxss')
                }
            },
        },
        '../form-page/form-page': {
            type: 'ancestor',
        },
        '../checkbox-group/checkbox-group': {
            type: 'descendant',
            linked(target) {
                this.setData({
                    checkboxCount: this.data.checkboxCount + 1,
                    checkboxIsMulti: target.data.multi
                })
            },
            unlinked(target) {
                this.setData({
                    checkboxCount: this.data.checkboxCount - 1,
                    checkboxIsMulti: target.data.multi
                })
            }
        }
    },
    methods: {
        setCellMulti(multi) {
            this.setData({
                checkboxIsMulti: multi
            })
        },
        setCellsClass(className) {
            this.setData({
                childClass: className
            })
        },
        setOuterClass(className) {
            this.setData({
                outerClass: className
            })
        },
    }
})