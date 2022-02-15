let _console; let method
if (typeof console !== 'undefined') {
  _console = console
} else if (typeof global !== 'undefined' && global.console) {
  _console = global.console
} else if (typeof window !== 'undefined' && window.console) {
  _console = window.console
} else {
  _console = {}
}

const noop = function () {}
const methods = ['assert', 'clear', 'count', 'debug', 'dir', 'dirxml', 'error', 'exception', 'group', 'groupCollapsed', 'groupEnd', 'info', 'log', 'markTimeline', 'profile', 'profileEnd', 'table', 'time', 'timeEnd', 'timeStamp', 'trace', 'warn']
let { length } = methods

while (length--) {
  method = methods[length]

  if (!console[method]) {
    _console[method] = noop
  }
}
_console.methods = methods

export default _console
