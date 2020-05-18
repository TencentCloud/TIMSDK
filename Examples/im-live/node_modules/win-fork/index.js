var cSpawn = require('child_process').spawn;
var os = require('os').type();

exports = module.exports = spawn;
function spawn(command, args, options) {
  if (os === 'Windows_NT') {
    if (command === 'rm') {
      command = 'rmdir';
      if (args[0] === '-rf' || args[0] == '-fr') {
        args[0] = '/q';
        args.unshift('/s');
      }
      if (args[0] === '-f') {
        args[0] = '/q';
      }
      if (args[0] === '-r') {
        args[0] = '/s';
      }
    }
    args = args || [];
    options = options || {};
    var match, matchA;
    if (matchA = /((?:[A-Z_]+\=[^ \=]+ )+)?([^\r\n]+)/.exec(command)) {
      try {
        var file = require('fs').readFileSync(matchA[2], 'utf8');
        if (match = /\#\!\/usr\/bin\/env ([^\r\n]+)/.exec(file)) {
          args.unshift(matchA[2]);
          command = (matchA[1] || '') + match[1];
        }
      } catch (ex) { }
    }

    if (match = /((?:[A-Z_]+\=[^ \=]+ )+)([^\r\n]+)/.exec(command)) {
      command = match[2];

      options.env = options.env || shallowClone(process.env);

      var env = match[1].split(' ');
      env.forEach(function (v) {
        v = v.split('=');
        if (v.length === 2) {
          options.env[v[0]] = v[1];
        }
      });
    }

    args.unshift(command);
    args.unshift('/c');
    command = 'cmd';
  }
  return cSpawn(command, args, options);
}

function shallowClone(obj) {
  var out = {};
  Object.keys(obj)
    .forEach(function (key) {
      out[key] = obj[key];
    });
  return out;
}

var fs = require('fs');
var join = require('path').join;

exports.transformDir = transformDir;
function transformDir(dirname, options) {
  options = options || {};
  var dir = fs.readdirSync(dirname);
  dir.forEach(function (child) {
    if (fs.statSync(join(dirname, child)).isDirectory()) {
      if (child !== 'node_modules' && child !== '.git') {
        transformDir(join(dirname, child), options);
      }
    } else {
      transform(join(dirname, child), options);
    }
  });
}

exports.transform = transform;
function transform(file, options) {
  options = options || {};
  var content = fs.readFileSync(file, 'utf8').toString();
  if (/\r\n/g.test(content)) {
    console.warn('converting ' + file);
    if (!options.preview) fs.writeFileSync(file, content.replace(/\r\n/g, '\n'), 'utf8');
  }
}