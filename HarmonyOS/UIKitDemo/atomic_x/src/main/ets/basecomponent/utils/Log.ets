import hilog from '@ohos.hilog'

export default class Log {
  static d(tag: string, str: string) {
    hilog.debug(0, tag, str)
  }

  static i(tag: string, str: string) {
    hilog.info(0, tag, str)
  }

  static w(tag: string, str: string) {
    hilog.warn(0, tag, str)
  }

  static e(tag: string, str: string) {
    hilog.error(0, tag, str)
  }

  static f(tag: string, str: string) {
    hilog.fatal(0, tag, str)
  }
}