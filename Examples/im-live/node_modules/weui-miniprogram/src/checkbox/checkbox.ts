Component<any>({
    options: {
        addGlobalClass: true,
        multipleSlots: true,
    },
    properties: {
        multi: {
            type: Boolean,
            value: true,
        },
        checked: {
            type: Boolean,
            value: false,
        },
        value: {
            type: String,
            value: '',
        },
        // disabled: {
        //     type: Boolean,
        //     value: false,
        // },
        // color: {
        //     type: String,
        //     value: '#09BB07',
        // },
        label: {
            type: String,
            value: 'label',
        },
        extClass: {
            type: String,
            value: '',
        }
    },
    data: {

    },
    relations: {
        '../checkbox-group/checkbox-group': {
            type: 'ancestor',
            linked(target) {
                this.data.group = target
            },
            unlinked() {
                this.data.group = null
            }
        },
    },
    methods: {
        setMulti(multi) {
            this.setData({
                multi
            })
        },
        setOuterClass(className) {
            this.setData({
                outerClass: className
            })
        },
        checkedChange(e) {
            if (this.data.multi) {
                const checked = !this.data.checked
                this.setData({
                    checked
                })
                if (this.data.group) {
                    this.data.group.checkedChange(checked, this)
                }
            } else {
                const checked = this.data.checked
                if (checked) return
                this.setData({
                    checked: true
                })
                if (this.data.group) {
                    this.data.group.checkedChange(checked, this)
                }
            }
            this.triggerEvent('change', {value: this.data.value, checked: this.data.checked})
        }
    }
})
