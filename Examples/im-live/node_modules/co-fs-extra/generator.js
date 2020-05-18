
var fs = require('fs-extra');
var path = require('path');

var methods = [];

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
  }
}

methods = methods.sort();

fs.writeFileSync(path.join(__dirname, 'methods.json'), JSON.stringify(methods, null, 2));
