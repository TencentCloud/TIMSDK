/**
 * 返回年月日
 * @export
 * @param {Date} date
 * @param {string} [splitor='-']
 * @returns
 */
export function getDate(date, splitor = '-') {
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
export function getTime(date, withSecond = false) {
  const hour = date.getHours()
  const minute = date.getMinutes()
  const second = date.getSeconds()
  return withSecond ? `${addZeroPrefix(hour)}:${addZeroPrefix(minute)}:${addZeroPrefix(second)}` : `${hour}:${addZeroPrefix(minute)}`
}

export function getFullDate(date) {
  return `${getDate(date)} ${getTime(date)}`
}

export function isToday(date) {
  return date.toDateString() === new Date().toDateString()
}


/**
 * 个位数，加0前缀
 * @param {*} number
 * @returns
 */
function addZeroPrefix(number) {
  return number < 10 ? `0${number}`:number
}

export function formatTime(secondTime) {
  let time = secondTime
  let newTime, hour, minite, seconds
  if (time >= 3600) {
      hour = parseInt(time / 3600) < 10 ? '0' + parseInt(time / 3600) : parseInt(time / 3600)
      minite = parseInt(time % 60 / 60) < 10 ? '0' + parseInt(time % 60 / 60) : parseInt(time % 60 / 60)
      seconds = time % 3600 < 10 ? '0' + time % 3600 : time % 3600
      if(seconds > 60) {
        minite=parseInt(seconds / 60) < 10 ? '0' + parseInt(seconds / 60) : parseInt(seconds / 60)
        seconds = seconds % 60 < 10 ? '0' + seconds % 60 : seconds % 60
      }
      newTime = hour + ':' + minite + ':' + seconds
  } else if (time >= 60 && time < 3600) {
      minite = parseInt(time / 60) < 10 ? '0' + parseInt(time / 60) : parseInt(time / 60)
      seconds = time % 60 < 10 ? '0' + time % 60 : time % 60
      newTime = '00:' + minite + ':' + seconds
  } else if (time < 60) {
      seconds = time < 10 ? '0' + time : time
      newTime = '00:00:' + seconds
  }
  return newTime
}
