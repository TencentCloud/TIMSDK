var cp = require('cp')

var src = process.argv[2] 
var dest = process.argv[3]
if (!src) {
  console.warn('src is empty')
}
if (!dest) {
  console.warn('dest is empty')
}

cp(src, dest , function(event){
  if (event) {
    console.log('event', event)
  }
  console.log(`cp ${src} ${dest}; success!`)
})

