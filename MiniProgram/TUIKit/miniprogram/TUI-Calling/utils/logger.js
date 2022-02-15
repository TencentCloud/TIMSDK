import console from './console'
import { isArrayOrObject, TimeUtil, isInstanceOfError, stringifyError } from './common-utils'

const LOGLEVEL_DEBUG = -1
const LOGLEVEL_LOG = 0
const LOGLEVEL_INFO = 1
const LOGLEVEL_WARN = 2
const LOGLEVEL_ERROR = 3
const LOGLEVEL_NON_LOGGING = 4 // 无日志记录级别，sdk将不打印任何日志
const MAX_LOG_LENGTH = 1000
let globalLevel = LOGLEVEL_LOG
// 暂停使用 wx.getLogManager，没发现它能起到什么作用
const bCanIUseWxLog = false
const timerMap = new Map()

/**
 * 对齐毫秒字符串
 * @param {*} ms 毫秒
 * @returns {String} 对齐后的毫秒时间字符串
 */
function padMs(ms) {
  const len = ms.toString().length
  let ret
  switch (len) {
    case 1:
      ret = `00${ms}`
      break
    case 2:
      ret = `0${ms}`
      break
    default:
      ret = ms
      break
  }

  return ret
}

/**
 * log前缀
 * @returns {String} 日志前缀
 */
function getPrefix() {
  const date = new Date()
  return `TUIKit ${date.toLocaleTimeString('en-US', { hour12: false })}.${padMs(date.getMilliseconds())}:`
}

/**
 * wx LogManager是否可用
 * @returns {Boolean} true->I can use LogManager
 */
// function canIUseWxLog() {
//   if (IN_WX_MINI_APP) {
//     // 必须是微信小程序环境，百度小程序目前还只能用console
//     const version = wx.getSystemInfoSync().SDKVersion;
//     // HBuilder等工具会在window对象下挂自己模拟的wx对象，但是又没抄好，做个防御
//     if (typeof version === 'undefined' ||
//       typeof wx.getLogManager === 'undefined') {
//       return false;
//     }
//     if (compareVersion(version, '2.1.0') >= 0) {
//       wx.getLogManager().log('I can use wx log. SDKVersion=' + version);
//       return true;
//     }
//   }
//   return false;
// }

/**
 * 比较wx SDKVersion
 * @param {String} v1 版本字符串
 * @param {String} v2 版本字符串
 * @returns {Number} v1>v2，返回1；v1<v2，返回-1；v1==v2，返回0
 */
// function compareVersion(v1, v2) {
//   v1 = v1.split('.');
//   v2 = v2.split('.');
//   const len = Math.max(v1.length, v2.length);

//   while (v1.length < len) {
//     v1.push('0');
//   }
//   while (v2.length < len) {
//     v2.push('0');
//   }

//   for (let i = 0; i < len; i++) {
//     const num1 = parseInt(v1[i]);
//     const num2 = parseInt(v2[i]);

//     if (num1 > num2) {
//       return 1;
//     }
//     if (num1 < num2) {
//       return -1;
//     }
//   }
//   return 0;
// }

const logger = {
  _data: [],
  _length: 0,
  _visible: false,

  // 将函数参数拼成字符串
  arguments2String(args) {
    let s
    if (args.length === 1) {
      s = getPrefix() + args[0]
    } else {
      s = getPrefix()
      for (let i = 0, { length } = args; i < length; i++) {
        if (isArrayOrObject(args[i])) {
          if (isInstanceOfError(args[i])) {
            s += stringifyError(args[i])
          } else {
            s += JSON.stringify(args[i])
          }
        } else {
          s += args[i]
        }
        s += ' '
      }
    }
    return s
  },

  /**
   * 打印调试日志
   */
  debug() {
    if (globalLevel <= LOGLEVEL_DEBUG) {
      // 对参数使用slice会阻止某些JavaScript引擎中的优化 (比如 V8 - 更多信息)
      // see:https://github.com/petkaantonov/bluebird/wiki/Optimization-killers#3-managing-arguments
      const s = this.arguments2String(arguments)
      logger.record(s, 'debug')
      console.debug(s)
      if (bCanIUseWxLog) {
        wx.getLogManager().debug(s)
      }
    }
  },

  /**
   * 打印普通日志
   */
  log() {
    if (globalLevel <= LOGLEVEL_LOG) {
      const s = this.arguments2String(arguments)
      logger.record(s, 'log')
      console.log(s)
      if (bCanIUseWxLog) {
        wx.getLogManager().log(s)
      }
    }
  },

  /**
   * 打印release日志
   */
  info() {
    if (globalLevel <= LOGLEVEL_INFO) {
      const s = this.arguments2String(arguments)
      logger.record(s, 'info')
      console.info(s)
      if (bCanIUseWxLog) {
        wx.getLogManager().info(s)
      }
    }
  },

  /**
   * 打印告警日志
   */
  warn() {
    if (globalLevel <= LOGLEVEL_WARN) {
      const s = this.arguments2String(arguments)
      logger.record(s, 'warn')
      console.warn(s)
      if (bCanIUseWxLog) {
        wx.getLogManager().warn(s)
      }
    }
  },

  /**
   * 打印错误日志
   */
  error() {
    if (globalLevel <= LOGLEVEL_ERROR) {
      const s = this.arguments2String(arguments)
      logger.record(s, 'error')
      console.error(s)
      // 微信写不了error日志，就用warn代替了
      if (bCanIUseWxLog) {
        wx.getLogManager().warn(s)
      }
    }
  },

  time(label) {
    timerMap.set(label, TimeUtil.now())
  },

  timeEnd(label) {
    if (timerMap.has(label)) {
      const cost = TimeUtil.now() - timerMap.get(label)
      timerMap.delete(label)
      return cost
    }
    console.warn(`未找到对应label: ${label}, 请在调用 logger.timeEnd 前，调用 logger.time`)
    return 0
  },

  setLevel(newLevel) {
    if (newLevel < LOGLEVEL_NON_LOGGING) {
      console.log(`${getPrefix()} set level from ${globalLevel} to ${newLevel}`)
    }
    globalLevel = newLevel
  },

  record(s, type) {
    if (bCanIUseWxLog) {
      // 小程序环境不在内存缓存日志
      return
    }

    if (logger._length === MAX_LOG_LENGTH + 100) {
      logger._data.splice(0, 100)
      logger._length = MAX_LOG_LENGTH
    }
    logger._length++
    logger._data.push(`${s} [${type}] \n`)
  },

  getLog() {
    return logger._data
  },
}

export default logger
