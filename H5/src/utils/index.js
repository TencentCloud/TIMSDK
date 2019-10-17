export function throttle (func, wait) {
  let timeout
  return function () {
    let that = this
    let args = arguments
    
    if (!timeout) {
      timeout = setTimeout(() =>{
        timeout = null
        func.apply(that, args)
      }, wait)
    }
  }
}
