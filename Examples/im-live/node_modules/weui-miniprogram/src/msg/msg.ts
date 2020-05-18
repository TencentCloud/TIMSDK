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
    type: { // icon 的 type
      type: String,
      value: ''
    },
    icon: { // 可以自行设置 icon, 设置icon 之后，type 失效
      type: String,
      value: ''
    },
    desc: { // 描述
      type: String,
      value: ''
    },
    extClass: {
      type: String,
      value: ''
    },
    size: { // 可以自行设置 icon, 设置icon 之后，type 失效
      type: Number,
      value: 64
    }
  },
  data: {
  },
})