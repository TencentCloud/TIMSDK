Component({
    options: {
        addGlobalClass: true,
    },
    properties: {
        extClass: {
          type: String,
          value: ''
        },
        list: {
            type: Array,
            value: []
        },
        current: {
            type: Number,
            value: 0
        }
    },
    methods: {
        tabChange(e) {
            const {index} = e.currentTarget.dataset
            if (index === this.data.current) {
                return
            }
            this.setData({
                current: index
            })
            this.triggerEvent('change', {index, item: this.data.list[index]})
        }
    }
})
