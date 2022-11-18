/*eslint-disable*/
const fs = require('fs')
const path = require('path')

const copyFile = function(srcPath, tarPath, filter = [], rename = {}) {
  fs.readdir(srcPath, function(err, files) {
    if (err === null) {
      files.forEach(function(filename) {
        let filedir = path.join(srcPath, filename)
        let filterFlag = filter.some(item => item === filename)
        if (!filterFlag) {
          fs.stat(filedir, function(errs, stats) {
            let isFile = stats.isFile()
            if (isFile) {
              const destPath = path.join(tarPath, rename[filename] ? rename[filename] : filename)
              fs.copyFile(filedir, destPath, err => {})
            } else {
              let tarFiledir = path.join(tarPath, filename)
              fs.mkdir(tarFiledir, err => {})
              copyFile(filedir, tarFiledir, filter, rename)
            }
          })
        }
      })
    } else {
      if (err) console.error(err)
    }
  })
} //使用

const changeFile = function(targetPath, rules, contain) {
  let filter = []
  fs.readdir(targetPath, function(err, files) {
    if (err === null) {
      files.forEach(function(filename) {
        let filedir = path.join(targetPath, filename)
        let filterFlag = filter.some(item => item === filename)
        if (!filterFlag) {
          fs.stat(filedir, function(errs, stats) {
            let isFile = stats.isFile()
            if (isFile) {
              if (contain.indexOf(filename) >= 0) {
                console.log(filedir)
                fs.readFile(filedir, { encoding: 'utf-8' }, function(err, files) {
                  let result = files
                  for (let i in rules) {
                    let rule = rules[i]
                    if (filename === rule.name) {
                      result = result.replace(rule.reg, rule.target)
                    }
                  }
                  fs.writeFile(filedir, result, { encoding: 'utf-8' }, function(err) {
                    if (err) {
                      console.log(err)
                    }
                  })
                })
              }
            } else {
              changeFile(filedir, rules, contain)
            }
          })
        }
      })
    } else {
      if (err) console.error(err)
    }
  })
}

// 原 base 文件夹
let base = '../TUICalling-miniprogram'

// 要 copy 到的文件夹
let target = '../TIMSDK/uni-app/TUICalling/TUICalling-miniprogram'

// 忽略的文件和文件夹
let filter = [
  'package-lock.json',
	'unpackage',
	'utils',
  '.git',
  'node_modules',
  '.idea',
  'cp-files-for-github.js',
  'check-files-for-github.js',
  'check-timsdk-version.js',
  'copy.js',
  '.gitignore',
  'babel.config.js'
]

// 文件重命名配置， 源文件名 ： 目标文件名
const rename = {
  'README-github.md': 'README.md',
  'package-github.json': 'package.json',
}

copyFile(base, target, filter, rename)

// 某文件中要替换的规则
// name：文件名
// reg: 正则
// target: 替换后的东西
const rules = [
  {
    name: 'GenerateTestUserSig.js',
    reg: /const\s+([_]){0,1}SDKAPPID\s+=\s+([0-9]*)\s*;/g,
    target: 'const $1SDKAPPID = 0;'
  },
  {
    name: 'GenerateTestUserSig.js',
    reg: /const\s+([_]){0,1}SECRETKEY\s+=\s+[\"|\']([0-9a-zA-Z]*)[\"|\']\s*;/g,
    target: "const $1SECRETKEY = '';"
  },
	{
	  name: 'manifest.json',
	  reg: /"appid"\s*:\s*\"([0-9a-zA-Z]*)\"\s*,/g,
	  target: '\"appid\": \"appid\",'
	}
]

const contain = ['GenerateTestUserSig.js', 'manifest.json']
changeFile(target, rules, contain)
