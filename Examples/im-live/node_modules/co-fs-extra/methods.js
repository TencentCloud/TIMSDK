/**
 * Methods to wrap.
 */

/*
// to regenerate this list (in case fs-extra adds more functions)
var methods = []
var fs = require('fs-extra');
for (var key in fs) {
  if (typeof fs[key] === 'function'
  && key.substr(-6) !== 'Stream'
  && key.substr(0, 5) !== 'grace'
  && !~key.indexOf('watch')
  && key[0] !== '_'
  && key !== 'exists'
  && key !== 'Stats'
  && key.substr(-4) !== 'Sync') {
    var txt = fs[key].toString()
    var l1 = txt.substr(0, txt.indexOf('\n'))
    if (~l1.indexOf('callback') || ~l1.indexOf('cb)'))
      methods.push(key)
    else console.log(key, fs[key].toString())
  }
}

console.log('module.exports = ' + JSON.stringify(methods.sort(), null, '  ').replace(/"/g, '\''))
*/

module.exports = [
  'access',
  'appendFile',
  'chmod',
  'chown',
  'close',
  'copy',
  'createFile',
  'createLink',
  'createSymlink',
  'emptyDir',
  'emptydir',
  'ensureDir',
  'ensureFile',
  'ensureLink',
  'ensureSymlink',
  'fchmod',
  'fchown',
  'fdatasync',
  'fstat',
  'fsync',
  'ftruncate',
  'futimes',
  'lchmod',
  'lchown',
  'link',
  'lstat',
  'lutimes',
  'mkdir',
  'mkdirp',
  'mkdirs',
  'move',
  'open',
  'outputFile',
  'outputJSON',
  'outputJson',
  'read',
  'readFile',
  'readJSON',
  'readJson',
  'readdir',
  'readlink',
  'realpath',
  'remove',
  'rename',
  'rmdir',
  'stat',
  'symlink',
  'truncate',
  'unlink',
  'utimes',
  'write',
  'writeFile',
  'writeJSON',
  'writeJson'
]
