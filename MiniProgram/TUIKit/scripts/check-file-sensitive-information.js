const fs = require('fs')
const path = require('path')
const { promisify } = require('util')

const target = './miniprogram'

const readFileAsync = promisify(fs.readFile)
const readdirAsync = promisify(fs.readdir)
const statAsync = promisify(fs.stat)

let warnFiles = []

const checkSensitiveInformation = async function(targetPath) {
  try {
    let files = await readdirAsync(targetPath)
    for (let i = 0; i<files.length; i++) {
      let filename = files[i]
      let filedir = path.join(targetPath, filename)
      let stats = await statAsync(filedir)
      if (stats.isFile()) {
        let subFiles = await readFileAsync(filedir, { encoding: 'utf-8' })
        let find_SDKAPPID = subFiles.match(/1400\d{6}/g)
        let find_SECRETKEY = subFiles.match(/var\s+([_]){0,1}SECRETKEY\s+=\s+[\"|\']([0-9a-zA-Z]{2,99})[\"|\']\s*;/g)
        if (find_SDKAPPID || find_SECRETKEY) {
          warnFiles.push(filedir)
        }
      } else {
        await checkSensitiveInformation(filedir)
      }
    }
  } catch (e) {
    console.error(e)
  }
}

const consoleFiles = function () {
  if (warnFiles.length === 0) {
    console.log('\033[32m File desensitization succeeded \033[0m')
  } else {
    console.log('\033[33m Please check the following files for desensitization \033[0m')
    warnFiles.forEach(item => {
      console.log(item)
    })
  }
}

checkSensitiveInformation(target).then(() => {
  consoleFiles()
})
