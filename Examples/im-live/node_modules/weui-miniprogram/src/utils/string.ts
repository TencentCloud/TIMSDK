
/**
 * 占位替换
 * @method sprintf
 * @method String.prototype.sprintf
 * @example
 * "my name is %s  %s".sprintf("a","b")  =》"my name is a  b"
 */
export const sprintf = (...args) => {
  let i
  let result = args[0] || ''
  let para
  let reg
  const length = args.length - 1

  if (length < 1) {
    return result
  }

  i = 1
  while (i < length + 1) {
    result = result.replace(/%s/, '{#' + i + '#}')
    i++
  }
  result.replace('%s', '')

  i = 1
  while (true) {
    para = args[i]
    if (para === undefined) { // 0 也是可能的替换数字
      break
    }
    reg = new RegExp('{#' + i + '#}', 'g')
    result = result.replace(reg, para)
    i++
  }
  return result
}
