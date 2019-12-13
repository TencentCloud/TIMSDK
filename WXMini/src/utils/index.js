function formatNumber (n) {
  const str = n.toString()
  return str[1] ? str : `0${str}`
}

export function formatDuration (time) {
  let interval = time
  let continued = ''
  if (interval > 3600) {
    const hour = Math.floor(interval / 3600)
    continued += hour + '小时'
    interval -= hour * 3600
  }
  if (interval > 60 && interval < 3600) {
    const min = Math.floor(interval / 60)
    continued += min + '分'
    interval -= min * 60
  }
  if (interval < 60) {
    continued += Math.floor(interval) + '秒'
  }
  return continued
}
export function formatTime (date) {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()

  const hour = date.getHours()
  const minute = date.getMinutes()

  const t1 = [year, month, day].map(formatNumber).join('-')
  const t2 = [hour, minute].map(formatNumber).join(':')

  return `${t1} ${t2}`
}

export function throttle (func, wait) {
  let timeout
  return function () {
    let that = this
    let args = arguments

    if (!timeout) {
      timeout = setTimeout(function () {
        timeout = null
        func.apply(that, args)
      }, wait)
    }
  }
}

export const videoStatus = {
  0: {
    state: 'VIDEO_CALL_CMD_DIALING',
    action: '[请求通话]'
  },
  1: {
    state: ' VIDEO_CALL_CMD_SPONSOR_CANCEL',
    action: '[取消通话]'
  },
  2: {
    state: 'VIDEO_CALL_CMD_REJECT',
    action: '[拒绝通话]'
  },
  3: {
    state: 'VIDEO_CALL_CMD_SPONSOR_TIMEOUT',
    action: '[无应答]'
  },
  4: {
    state: 'VIDEO_CALL_CMD_ACCEPTED',
    action: '[开始通话]'
  },
  5: {
    state: 'VIDEO_CALL_CMD_HANGUP',
    action: '[通话结束]'
  },
  6: {
    state: 'VIDEO_CALL_CMD_LINE_BUSY',
    action: '[正在通话中]'
  }
}

const CHARS = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
const CHARS_LENGTH = CHARS.length
/**
 * 获取[0,9],[a-z],[A,Z]拼成的随机字符串，长度32
 * @returns {String} 长度为32的随机字符串
 */
export function randomString () {
  let result = ''
  for (let i = 32; i > 0; --i) {
    result += CHARS[Math.floor(Math.random() * CHARS_LENGTH)]
  }
  return result
}

export default {
  formatNumber,
  formatTime,
  throttle,
  randomString
}
