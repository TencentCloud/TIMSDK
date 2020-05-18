'use strict'; //jshint evil:true,node:true
try {
  new Function('return function*() { yield 3 }')
  module.exports = true
}
catch (e) {
  module.exports = false
}