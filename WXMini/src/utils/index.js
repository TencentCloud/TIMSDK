import firstletter from './dict.js'

function formatNumber (n) {
  const str = n.toString()
  return str[1] ? str : `0${str}`
}

export function formatTime (date) {
  if (isToday(date)) {
    return wx.dayjs(date).format('A HH:mm').replace('PM', '下午').replace('AM', '上午')
  }
  return getDate(date)
}

export function getDate (date, splitor = '/') {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()
  return `${year}${splitor}${addZeroPrefix(month)}${splitor}${addZeroPrefix(day)}`
}

/**
 * 返回时分秒/时分
 * @export
 * @param {*} date
 * @param {boolean} [withSecond=false]
 * @returns
 */
export function getTime (date, withSecond = false) {
  const hour = date.getHours()
  const minute = date.getMinutes()
  const second = date.getSeconds()
  return withSecond ? `${addZeroPrefix(hour)}:${addZeroPrefix(minute)}:${addZeroPrefix(second)}` : `${hour}:${addZeroPrefix(minute)}`
}

export function getFullDate (date) {
  return `${getDate(date)} ${getTime(date)}`
}

export function isToday (date) {
  return date.toDateString() === new Date().toDateString()
}

/**
 * 个位数，加0前缀
 * @param {*} number
 * @returns
 */
function addZeroPrefix (number) {
  return number < 10 ? `0${number}` : number
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

// 获取中文字符首字母拼音
export function pinyin (raw) {
  const str = `${raw}`
  if (!str || /^ +$/g.test(str)) {
    return ''
  }
  let result = []
  for (let i = 0; i < str.length; i++) {
    let unicode = str.charCodeAt(i)
    let char = str.charAt(i)
    if (unicode >= 19968 && unicode <= 40869) {
      char = firstletter.charAt(unicode - 19968)
    }
    result.push(char)
  }
  return result.join('')
}
// 判断是否是json string
export function isJSON (str) {
  if (typeof str === 'string') {
    try {
      let obj = JSON.parse(str)
      return !!(typeof obj === 'object' && obj)
    } catch (e) {
      return false
    }
  }
}

export default {
  formatNumber,
  formatTime,
  throttle,
  formatDuration,
  pinyin,
  isJSON
}
