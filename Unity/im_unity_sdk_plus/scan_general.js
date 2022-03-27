const fs = require("fs");
const path = require("path");
const readline = require("readline").createInterface({
  input: process.stdin,
  output: process.stdout,
});
const singleREP = /'([^']*[^\x00-\xff]{0,200}[^']*)'/g;
const doubleREP = /"([^"]*[^\x00-\xff]{0,200}[^"]*)"/g;
const blockREP = /\s([^\s]*[^\x00-\xff]{0,200}[^\s]*)\s/g;
const tagREP = />([^>]*[^\x00-\xff]{0,200}[^<]*)</g;

const fileList = [];

const hashStr = (text) => {
  "use strict";

  let hash = 5381,
    index = text.length;

  while (index) {
    hash = (hash * 33) ^ text.charCodeAt(--index);
  }

  return hash >>> 0;
};

const hashKey = (value, onError) => {
  const key =
    "k_" + ("0000" + hashStr(value.replace(/\s+/g, "")).toString(36)).slice(-7);
  return key;
};

const output = (md5ChineseMap) => {
  readline.question(`JSON文件输出路径(含文件名):`, (path) => {
    fs.writeFile(path, JSON.stringify(md5ChineseMap), (err) => {
      if (err) {
        console.error(err);
        return;
      } else {
        console.log("输出成功");
        return;
      }
    });
  });
};

const flatArray = (arr) => {
  if (Object.prototype.toString.call(arr) != "[object Array]") {
    return false;
  }
  let res = [];
  arr.map((item) => {
    if (item instanceof Array) {
      res.push(...item);
    } else {
      res.push(item);
    }
  });
  return Array.from(new Set(res));
};

const scanFile = (path, resolve, reject) => {
  fs.readFile(path, "utf8", (err, fileData) => {
    if (err) {
      console.error(err);
      return;
    }
    let chineseList = [];

    const resultSingle = fileData.match(singleREP);
    if (Array.isArray(resultSingle) && resultSingle.length > 0) {
      chineseList.push(...resultSingle.map((item) => item.split("'")[1]));
    }
    const resultDouble = fileData.match(doubleREP);
    if (Array.isArray(resultDouble) && resultDouble.length > 0) {
      chineseList.push(...resultDouble.map((item) => item.split('"')[1]));
    }
    const block = fileData.match(blockREP);
    if (Array.isArray(block) && block.length > 0) {
      chineseList.push(...block.map((item) => item.split(" ")[1]));
    }
    const tag = fileData.match(tagREP);
    if (Array.isArray(tag) && tag.length > 0) {
      chineseList.push(...tag.map((item) => item.split(">")[1]));
    }
    chineseList = Array.from(new Set(chineseList));
    chineseList = chineseList.filter((item) => /[\u4e00-\u9fa5]/.test(item));
    resolve(chineseList);
  });
};

const readPath = (currentDirPath, isMaybeFile) => {
  if (isMaybeFile) {
    let stat = fs.statSync(currentDirPath);
    if (stat.isFile()) {
      fileList.push(currentDirPath);
      return;
    }
  }

  fs.readdirSync(currentDirPath).forEach(function (name) {
    let filePath = path.join(currentDirPath, name);
    let stat = fs.statSync(filePath);
    if (stat.isFile()) {
      fileList.push(filePath);
    } else if (stat.isDirectory()) {
      readPath(filePath, false);
    }
  });
};

readline.question(`原始文件/文件夹路径：`, (path) => {
  readPath(path, true);
  Promise.all(
    fileList.map((item) => {
      return new Promise((resolve, reject) => {
        return scanFile(item, resolve, reject);
      });
    })
  ).then((arr) => {
    const md5ChineseMap = {};
    const finalData = flatArray(arr);

    finalData.forEach((item) => {
      md5ChineseMap[hashKey(item)] = item;
    });

    output(md5ChineseMap);
  });
});
