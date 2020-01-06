Component({
  externalClasses: ['i-class'],

  data: {
    isError: false
  },
  properties: {
    // circle || square
    shape: {
      type: String,
      value: 'square'
    },
    // small || large || default
    size: {
      type: String,
      value: 'default'
    },
    src: {
      type: String,
      value: ''
    },
    defaultAvatar: {
      type: String,
      value: '/static/images/avatar.png'
    }
  },
  methods: {
    handleError () {
      this.setData({ isError: true })
    }
  }
})
