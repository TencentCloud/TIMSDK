Component({
  options: {
    addGlobalClass: true,
    multipleSlots: true,
  },
  properties: {
    title: { // Msg 标题
      type: String,
      value: '',
    },
    subtitle: { // icon 的 type
      type: String,
      value: ''
    },
  },
  relations: {
    '../cells/cells': {
      type: 'descendant',
      linked(target) {
          if (!this.data.firstItem) {
              this.data.firstItem = target
          }
          if (target !== this.data.firstItem) {
              target.setOuterClass('weui-cells__group_wxss')
          }
      },
  },
  },
  data: {
    firstItem: null
  },
})